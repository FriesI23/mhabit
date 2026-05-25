// Copyright 2025 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:data_saver/data_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart' as l;
import 'package:logger/logger.dart' show LogEvent;
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../common/consts.dart';
import '../common/utils.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../logging/logger_message.dart' show AppLoggerMessage;
import '../logging/logger_utils.dart';
import '../models/app_sync_options.dart';
import '../models/app_sync_server.dart';
import '../models/app_sync_server_form.dart';
import '../models/app_sync_tasks.dart';
import '../models/app_sync_timer.dart';
import '../reminders/providers/noti_app_sync_provider.dart';
import '../storage/db_helper_provider.dart';
import '../storage/profile/handlers.dart';
import '../storage/profile_provider.dart';
import '../utils/app_clock.dart';
import '../utils/app_path_provider.dart';
import '../utils/async_debouncer.dart';
import 'commons.dart';

part 'app_sync.g.dart';

const kAppSyncDelayDuration1 = Duration(seconds: 1);
const kAppSyncDelayDuration2 = Duration(milliseconds: 1500);
const kAppSyncDelayDuration3 = Duration(milliseconds: 2500);
const kAppSyncOnceDelay = Duration(seconds: 5);

abstract interface class AppSyncPasswordReader {
  Future<String?> readPassword({String? identity});
}

abstract interface class AppSyncStartEventSource {
  Stream<String> get startSyncEvents;
}

abstract interface class AppSyncSettingsAccess implements Listenable {
  bool get enabled;

  Future<void> setSyncSwitch(bool value, {bool listen = true});

  AppSyncFetchInterval get fetchInterval;

  Future<void> setFetchInterval(
    AppSyncFetchInterval value, {
    bool listen = true,
  });

  AppSyncServer? get serverConfig;

  Future<bool> saveServerConfigForm(
    AppSyncServerForm form, {
    bool resetStatus = true,
  });

  Future<bool> deleteServerConfig();
}

abstract interface class AppSyncDebugAccess implements Listenable {
  bool get enabled;

  AppSyncFetchInterval get fetchInterval;

  AppSyncServer? get serverConfig;

  Future<String> readDebugPasswordText();
}

abstract interface class AppSyncStatusSource implements Listenable {
  AppSyncStatusSnapshot? get syncStatus;
}

abstract interface class AppSyncTriggerAccess implements Listenable {
  bool get canStartSync;

  Future<void> startSync({Duration? initWait});

  void cancelSync();
}

abstract interface class AppSyncDelayedTriggerAccess implements Listenable {
  void delayedStartTaskOnce({Duration delay = kAppSyncOnceDelay});
}

abstract interface class AppSyncWorkflowAccess
    implements
        AppSyncTriggerAccess,
        AppSyncDelayedTriggerAccess,
        AppSyncStatusSource,
        AppSyncStartEventSource {
  Future? get syncProcessing;
}

class AppSyncViewModel
    with
        ChangeNotifier,
        ProfileHandlerLoadedMixin,
        DBHelperLoadedMixin,
        NotificationChannelDataMixin
    implements
        ProviderMounted,
        AppSyncPasswordReader,
        AppSyncStartEventSource,
        AppSyncSettingsAccess,
        AppSyncDebugAccess,
        AppSyncStatusSource,
        AppSyncTriggerAccess,
        AppSyncWorkflowAccess {
  late final AppSyncTaskDispatcher _appSyncTask;

  late final CascadingAsyncDebouncer _delayedSyncTrigger;

  late AppLifecycleListener _lifecycleListener;

  WeakReference<L10n>? _l10n;

  bool _mounted = true;
  AppSyncSwitchHandler? _switch;
  AppSyncFetchIntervalHandler? _interval;
  AppSyncServerConfigHandler? _serverConfig;
  Stopwatch? _appPauseStopwatch;

  AppSyncPeriodicTimer? _autoSyncTimer;
  bool _clearLogsOnStartup = false;

  AppSyncViewModel() {
    _appSyncTask = AppSyncTaskDispatcher(this);
    _appSyncTask.addListener(notifyListeners);
    _delayedSyncTrigger = CascadingAsyncDebouncer(
      action: () async {
        if (!mounted) return;
        appLog.appsync.debug(
          "AppSyncViewModel.onSyncTriggerred",
          ex: [_delayedSyncTrigger],
        );
        await startSync();
        await _appSyncTask.task?.task.result;
      },
    );
    _lifecycleListener = AppLifecycleListener(
      onPause: () {
        _appPauseStopwatch?.stop();
        _appPauseStopwatch = Stopwatch()..start();
        appLog.appsync.debug("AppSyncViewModel", ex: ["App Paused"]);
      },
      onRestart: () {
        Duration? stopDuration;
        final stopwatch = _appPauseStopwatch;
        if (stopwatch != null && stopwatch.isRunning) {
          stopwatch.stop();
          stopDuration = stopwatch.elapsed;
          _appPauseStopwatch = null;
          appLog.appsync.debug(
            "AppSyncViewModel",
            ex: ["App Resumed from Paused", stopDuration],
          );
        }
        // re-sync
        final interval = _interval?.get()?.t;
        if (interval != null && stopDuration != null) {
          final window = Duration(microseconds: interval.inMicroseconds ~/ 2);
          appLog.appsync.debug(
            "AppSyncViewModel",
            ex: ["Try re-sync after resumed", stopDuration, window],
          );
          if (stopDuration > window) {
            delayedStartTaskOnce(delay: kAppSyncDelayDuration3);
          }
        }
      },
    );
  }

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    _lifecycleListener.dispose();
    _delayedSyncTrigger.cancel();
    _autoSyncTimer?.cancel();
    _appSyncTask.dispose();
    super.dispose();
  }

  @override
  bool get mounted => _mounted;

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _switch = newProfile.getHandler<AppSyncSwitchHandler>();
    _interval = newProfile.getHandler<AppSyncFetchIntervalHandler>();
    _serverConfig = newProfile.getHandler<AppSyncServerConfigHandler>();
    // start auto sync
    regrPeriodicSync(fireDelay: kAppSyncDelayDuration3);
    // clear failed sync logs
    if (!_clearLogsOnStartup) {
      _clearLogsOnStartup = true;
      cleanExpiredSyncFailedLogs()
          .then((results) {
            if (results.isNotEmpty) {
              appLog.appsync.info(
                "clear logs on startup",
                ex: [hashCode, results],
              );
            }
          })
          .catchError((e, s) {
            appLog.appsync.warn(
              "clear logs on startup failed",
              ex: [hashCode],
              error: e,
              stackTrace: s,
            );
            if (kDebugMode) Error.throwWithStackTrace(e, s);
          });
    }
  }

  void onL10nUpdate(L10n? l10n) {
    _l10n = l10n != null ? WeakReference(l10n) : null;
  }

  @override
  bool get enabled => _switch?.get() ?? false;

  @override
  Future<void> setSyncSwitch(bool value, {bool listen = true}) async {
    if (_switch?.get() != value) {
      await _switch?.set(value);
      if (listen) notifyListeners();
    }
  }

  @override
  AppSyncFetchInterval get fetchInterval =>
      _interval?.get() ?? defaultAppSyncFetchInterval;

  @override
  Future<void> setFetchInterval(
    AppSyncFetchInterval value, {
    bool listen = true,
  }) async {
    if (_interval?.get() != value) {
      await _interval?.set(value);
      regrPeriodicSync();
      if (listen) notifyListeners();
    }
  }

  @override
  AppSyncServer? get serverConfig => _serverConfig?.get();

  @override
  AppSyncStatusSnapshot? get syncStatus =>
      _appSyncTask.task?.toStatusSnapshot();

  @override
  bool get canStartSync => enabled && serverConfig != null;

  @override
  Future? get syncProcessing => _appSyncTask.processing;

  Stream<AppSyncNeedConfirmEvent> get confirmEvents =>
      _appSyncTask.confirmEvents;

  @override
  Stream<String> get startSyncEvents => _appSyncTask.startSyncEvents;

  @override
  void cancelSync() => _appSyncTask.cancelSync();

  @override
  Future<bool> saveServerConfigForm(
    AppSyncServerForm form, {
    bool resetStatus = false,
  }) => _applyServerConfigChange(form, resetStatus: resetStatus);

  @override
  Future<bool> deleteServerConfig() =>
      _applyServerConfigChange(null, removable: true);

  @override
  Future<String?> readPassword({String? identity}) {
    identity = identity ?? serverConfig?.identity;
    if (identity == null) return Future.value(null);
    return const FlutterSecureStorage()
        .read(key: "sync-pwd-$identity")
        .catchError((e, s) {
          if (kDebugMode) Error.throwWithStackTrace(e, s);
          switch (serverConfig) {
            case AppWebDavSyncServer(:final password):
              return password;
            default:
              return null;
          }
        });
  }

  @override
  Future<String> readDebugPasswordText() => readPassword().then(
    (password) => switch (password) {
      null || '' => '',
      _ => kDebugMode ? password : '*' * password.length,
    },
  );

  Future<bool> writePassword({String? identity, required String? value}) async {
    identity = identity ?? serverConfig?.identity;
    if (identity == null) return false;
    try {
      await const FlutterSecureStorage(
        mOptions: MacOsOptions(),
      ).write(key: "sync-pwd-$identity", value: value);
    } catch (e, s) {
      if (kDebugMode) Error.throwWithStackTrace(e, s);
      return false;
    }
    return true;
  }

  Future<bool>? _setOrRemoveConfig(AppSyncServer? config) =>
      config != null ? _serverConfig?.set(config) : _serverConfig?.remove();

  Future<bool> _removeOldPassword(
    AppSyncServer? oldConfig,
    AppSyncServer? newConfig,
  ) => (oldConfig?.identity != newConfig?.identity && oldConfig != null)
      ? writePassword(identity: oldConfig.identity, value: null)
      : Future.value(true);

  Future<bool> _applyServerConfigChange(
    AppSyncServerForm? form, {
    bool resetStatus = false,
    bool removable = false,
  }) {
    final now = AppClock().now();
    final crtConfig = serverConfig;
    final pendingConfig = switch (form) {
      FakeSyncServerForm() => form.toConfig(
        createTime: crtConfig?.createTime ?? now,
        modifyTime: crtConfig?.modifyTime ?? now,
        configed: crtConfig?.configed ?? false,
      ),
      WebDavSyncServerForm() => form.toConfig(
        createTime: crtConfig?.createTime ?? now,
        modifyTime: crtConfig?.modifyTime ?? now,
        configed: crtConfig?.configed ?? false,
      ),
      null => null,
    };
    if (pendingConfig == null && !removable) return Future.value(false);

    final isSameServer = switch ((crtConfig, pendingConfig)) {
      (null, null) => true,
      (null, _) || (_, null) => false,
      (_, _) => crtConfig!.isSameServer(pendingConfig!, withoutPassword: true),
    };
    appLog.appsync.info(
      "applyServerConfigChange",
      ex: [resetStatus, removable, crtConfig, pendingConfig],
    );
    appLog.appsync.debug(
      "applyServerConfigChange.verbose",
      ex: [
        isSameServer,
        form?.toDebugString,
        crtConfig?.toDebugString,
        pendingConfig?.toDebugString,
      ],
    );

    AppSyncServer? buildConfig({bool withPwd = false}) =>
        (!isSameServer || resetStatus)
        ? switch (form) {
            FakeSyncServerForm() =>
              form
                  .copyWith(
                    uuid: isSameServer
                        ? form.uuid
                        : AppSyncServer.genNewIdentity(),
                  )
                  .toConfig(
                    createTime: pendingConfig?.createTime ?? now,
                    modifyTime: pendingConfig?.modifyTime ?? now,
                    configed: false,
                  ),
            WebDavSyncServerForm() =>
              form
                  .copyWith(
                    uuid: isSameServer
                        ? form.uuid
                        : AppSyncServer.genNewIdentity(),
                    password: withPwd ? form.password : '',
                  )
                  .toConfig(
                    createTime: pendingConfig?.createTime ?? now,
                    modifyTime: pendingConfig?.modifyTime ?? now,
                    configed: false,
                  ),
            null => null,
          }
        : pendingConfig?.copy(password: withPwd ? null : '');

    Future<bool> postSaveWebDavServer(AppWebDavSyncServer newConfig) async {
      assert(pendingConfig is AppWebDavSyncServer);
      if (pendingConfig is! AppWebDavSyncServer) return true;
      final result =
          await writePassword(
            identity: newConfig.identity,
            value: pendingConfig.password,
          ).then((result) async {
            if (result) return result;
            return await _setOrRemoveConfig(buildConfig(withPwd: true)) ??
                false;
          });
      return result;
    }

    Future<bool> doSave() async {
      final oldConfig = crtConfig;
      final deidentifiedNewConfig = buildConfig();
      if (await _setOrRemoveConfig(deidentifiedNewConfig) != true) return false;
      final removeOldPasswordTask = _removeOldPassword(
        oldConfig,
        deidentifiedNewConfig,
      );
      final Future<bool>? postTask;
      switch (deidentifiedNewConfig) {
        case AppWebDavSyncServer():
          postTask = postSaveWebDavServer(deidentifiedNewConfig);
        default:
          postTask = null;
      }
      return Future.wait([
        removeOldPasswordTask,
        ?postTask,
      ]).then((results) => results.every((e) => e));
    }

    return doSave().then((value) {
      if (mounted) notifyListeners();
      return value;
    });
  }

  @override
  Future<void> startSync({Duration? initWait}) =>
      _appSyncTask.shouldSync().then((result) {
        if (!result) {
          final config = _serverConfig?.get();
          appLog.appsync.info(
            "$runtimeType.startSync",
            ex: ["cant't sync now", config?.toDebugString],
          );
          return null;
        }
        return _appSyncTask.startSync(initWait: initWait);
      });

  Future<List<String>> cleanExpiredSyncFailedLogs() => AppPathProvider()
      .getSyncFailLogDir()
      .then((dir) => cleanExpiredFiles(dir, const Duration(days: 30)));

  void regrPeriodicSync({Duration? fireDelay}) {
    final interval = _interval?.get();
    if (interval == null || interval.t == null) {
      final oldTimer = _autoSyncTimer?..cancel();
      _autoSyncTimer = null;
      appLog.appsync.info(
        "regrPeriodicSync",
        ex: ["disabled", fireDelay, interval, oldTimer?.interval],
      );
    } else if (_autoSyncTimer?.interval != interval) {
      void onPeriodicSyncTriggered(Timer timer) async {
        if (!mounted) return;
        final config = _serverConfig?.get();
        appLog.appsync.debug(
          "[${timer.tick}] [${timer.hashCode}] Auto sync",
          ex: [timer.isActive, interval, () => config?.toDebugString()],
        );
        if (!enabled || !(await _appSyncTask.shouldSync())) return;
        if (!mounted) return;
        await _appSyncTask.startSync();
      }

      final oldTimer = _autoSyncTimer?..cancel();
      final timer = _autoSyncTimer = AppSyncPeriodicTimer(
        interval,
        onPeriodicSyncTriggered,
      );
      appLog.appsync.info(
        "regrPeriodicSync",
        ex: ["update", fireDelay, interval, oldTimer?.interval],
      );
      if (fireDelay != null) {
        Future.delayed(fireDelay, () => onPeriodicSyncTriggered(timer));
      }
    }
  }

  @override
  void delayedStartTaskOnce({Duration delay = kAppSyncOnceDelay}) {
    if (!(mounted &&
        _serverConfig?.get() != null &&
        _interval?.get()?.t != null)) {
      return;
    }
    appLog.appsync.debug(
      "AppSyncViewModel.delayedStartTaskOnce",
      ex: [delay, _delayedSyncTrigger],
    );
    _delayedSyncTrigger.exec(delay: delay);
  }
}

@immutable
final class AppSyncStatusSnapshot {
  final String id;
  final String sessionId;
  final AppSyncTaskStatus status;
  final DateTime? startTime;
  final DateTime? endedTime;
  final AppSyncTaskResult? result;
  final num? percentage;

  const AppSyncStatusSnapshot({
    required this.id,
    required this.sessionId,
    required this.status,
    required this.startTime,
    required this.endedTime,
    required this.result,
    required this.percentage,
  });

  bool get isProcessing => switch (status) {
    AppSyncTaskStatus.running || AppSyncTaskStatus.cancelling => true,
    _ => false,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSyncStatusSnapshot &&
          other.id == id &&
          other.sessionId == sessionId &&
          other.status == status &&
          other.startTime == startTime &&
          other.endedTime == endedTime &&
          other.result == result &&
          other.percentage == percentage;

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    status,
    startTime,
    endedTime,
    result,
    percentage,
  );
}

class AppSyncNeedConfirmEvent<T> {
  final T checklist;
  final Completer<bool> _completer;

  AppSyncNeedConfirmEvent(this.checklist) : _completer = Completer<bool>();

  Future<bool> get future => _completer.future;

  void complete(FutureOr<bool> value) {
    if (!_completer.isCompleted) _completer.complete(value);
  }
}

@CopyWith(skipFields: false, copyWithNull: false, constructor: "_copyWith")
class AppSyncContainer<T extends AppSyncTask<R>, R extends AppSyncTaskResult> {
  final String id;
  final T task;
  final DateTime? startTime;
  final DateTime? endedTime;
  final R? result;
  final ReplaySubject<l.LogEvent>? loggerReplay;
  final String? filePath;

  final NotiAppSyncProvider? notification;
  late final void Function(LogEvent) logEventCallback;

  num? percentage;
  ReplayAppLoggerStreamer? loggerStreamer;

  AppSyncContainer({
    required this.id,
    required this.task,
    this.startTime,
    this.endedTime,
    this.result,
    this.loggerReplay,
    this.filePath,
    this.notification,
    void Function(l.LogEvent)? logEventCallback,
  }) {
    final loggerReplay = this.loggerReplay;
    this.logEventCallback =
        logEventCallback ?? (event) => loggerReplay?.add(event);
  }

  AppSyncContainer._copyWith({
    required this.id,
    required this.task,
    this.startTime,
    this.endedTime,
    this.result,
    this.loggerReplay,
    this.filePath,
    this.percentage,
    this.loggerStreamer,
    this.notification,
    required this.logEventCallback,
  });

  AppSyncContainer.generate({
    required this.task,
    required String this.filePath,
    this.notification,
  }) : id = const Uuid().v4(),
       startTime = AppClock().now(),
       loggerReplay = ReplaySubject<l.LogEvent>(),
       endedTime = null,
       result = null {
    final loggerReplay = this.loggerReplay!;
    logEventCallback = loggerReplay.add;
  }

  void startRecordSyncLog() {
    final loggerReplay = this.loggerReplay;
    if (loggerReplay == null || loggerReplay.isClosed) return;
    l.Logger.addLogListener(logEventCallback);
  }

  void stopRecordSyncLog() {
    final loggerReplay = this.loggerReplay;
    if (loggerReplay == null || loggerReplay.isClosed) return;
    l.Logger.removeLogListener(logEventCallback);
    loggerReplay.close();
  }

  void recordSyncFailureLog() {
    final loggerReplay = this.loggerReplay;
    final filePath = this.filePath;
    if (loggerReplay != null &&
        filePath != null &&
        loggerStreamer == null &&
        result?.isSuccessed != true) {
      final sr = loggerStreamer = ReplayAppLoggerStreamer.buildAppSyncFailed(
        replaySubject: loggerReplay,
        filePath: filePath,
        sessionId: task.sessionId,
      );
      sr.init().then((_) {
        if (!sr.isComplete) sr.run();
      });
    }
  }

  @override
  String toString() =>
      "AppSyncContainer<$T>(id=$id, "
      "task=<${task.sessionId}>$task, startT=$startTime, endedT=$endedTime, "
      "reuslt=$result, loggerReplay=$loggerReplay, filePath=$filePath, "
      "logEventCallback=${logEventCallback.hashCode}"
      ")";

  AppSyncStatusSnapshot toStatusSnapshot() => AppSyncStatusSnapshot(
    id: id,
    sessionId: task.sessionId,
    status: task.status,
    startTime: startTime,
    endedTime: endedTime,
    result: result,
    percentage: percentage,
  );
}

final class AppSyncTaskDispatcher with ChangeNotifier {
  final AppSyncViewModel _root;
  final StreamController<AppSyncNeedConfirmEvent> _confirmEventController;
  final StreamController<String> _startSyncEventController;

  AppSyncContainer? _task;

  AppSyncTaskDispatcher(this._root)
    : _task = null,
      _confirmEventController = StreamController.broadcast(),
      _startSyncEventController = StreamController.broadcast() {
    addListener(() {
      final task = _task;
      if (task != null) {
        switch (task.task.status) {
          case AppSyncTaskStatus.running:
            _task?.notification?.syncing(percentage: task.percentage);
          case AppSyncTaskStatus.cancelling:
            _task?.notification?.syncing(percentage: null);
          default:
            break;
        }
      }
    });
  }

  Future? get processing => task?.task.result;

  AppSyncContainer? get task => _task;

  Stream<AppSyncNeedConfirmEvent> get confirmEvents =>
      _confirmEventController.stream;

  Stream<String> get startSyncEvents => _startSyncEventController.stream;

  @override
  void dispose() {
    _confirmEventController.close();
    _startSyncEventController.close();
    super.dispose();
  }

  void changePercentage({required num? prt}) {
    prt = prt?.clamp(0.0, 1.0);
    if (_task?.percentage != prt) {
      _task?.percentage = prt;
      notifyListeners();
    }
  }

  Future<AppSyncTask> buildNewTask(
    AppSyncServer config, [
    Duration? initWait,
  ]) async {
    AppSyncTask buildDefaultTask() => BasicAppSyncTask(
      config: config,
      onExec: (task) => Future.value(const BasicAppSyncTaskResult.error()),
    );

    Future<bool> requestWebDavUserConfirm(WebDavConfigTaskChecklist checklist) {
      final event = AppSyncNeedConfirmEvent(checklist);
      _confirmEventController.add(event);
      return event.future;
    }

    switch (config.type) {
      case AppSyncServerType.fake:
        final rand = math.Random();
        final sessionId = (rand.nextInt(10000) + 99999).toString();
        return BasicAppSyncTask(
          sessionId: sessionId,
          config: config,
          onExec: (task) async {
            const loopCount = 10;
            appLog.appsynctask.debug(task, ex: ["Start, looping $loopCount"]);
            await Future.delayed(const Duration(seconds: 1));
            for (var i = 0; i < loopCount; i++) {
              if (task.isCancalling) {
                await Future.delayed(const Duration(seconds: 1));
                appLog.appsynctask.debug(task, ex: ["loop $i -> canceled"]);
                return const BasicAppSyncTaskResult.cancelled();
              }
              if (task == _task?.task) changePercentage(prt: i / loopCount);
              final delayed = Duration(milliseconds: rand.nextInt(500) + 500);
              appLog.appsynctask.debug(
                task,
                ex: [
                  "loop $i -> running,",
                  "delayed for ${delayed.inMilliseconds}ms",
                ],
              );
              await Future.delayed(delayed);
            }
            if (task == _task?.task) changePercentage(prt: 1);
            await Future.delayed(const Duration(milliseconds: 600));
            if (task == _task?.task) changePercentage(prt: null);
            await Future.delayed(const Duration(seconds: 1));
            appLog.appsynctask.debug(task, ex: ['Done']);
            return const BasicAppSyncTaskResult.success();
          },
        );

      case AppSyncServerType.webdav:
        switch (config) {
          case AppWebDavSyncServer():
            final password = await _root.readPassword(
              identity: config.identity,
            );
            final sessionId = WebDavAppSyncTask.genSessionId();
            final isFirstSync = !config.configed;
            return WebDavAppSyncTask(
              sessionId: sessionId,
              config: config.copyWith(
                password: password ?? config.password,
                timeout: isFirstSync
                    ? (config.timeout ?? defaultAppSyncTimeout) * 10
                    : config.timeout,
              ),
              syncDBHelper: _root.syncDBHelper,
              initWait: initWait,
              progressController: WebDavProgressController(
                onPercentageChanged: (percentage) {
                  if (_task?.task.sessionId != sessionId) return;
                  changePercentage(prt: percentage);
                },
              ),
              onConfigTaskComplete: (result) {
                if (_task?.task.sessionId != sessionId) return;
                if (!result.isSuccessed || config.configed) return;
                final crtConfig = _root._serverConfig?.get();
                if (crtConfig == null) return;
                if (config.isSameConfig(crtConfig)) {
                  _root._serverConfig?.set(config.copyWith(configed: true));
                }
              },
              onNeedConfirmCallback: (checklist) {
                final task = _task;
                if (task == null) return false;
                final sessionId = task.task.sessionId;
                if (task.task.sessionId != sessionId) return false;
                return requestWebDavUserConfirm(checklist);
              },
            );
          default:
            return buildDefaultTask();
        }

      default:
        return buildDefaultTask();
    }
  }

  Future<bool> shouldSync() async {
    bool basicCheck([AppSyncServer? config]) {
      if (!_root.enabled) return false;
      config = config ?? _root._serverConfig?.get();
      if (config == null) return false;
      return true;
    }

    final config = _root._serverConfig?.get();
    if (!(basicCheck(config))) return false;
    switch (config?.type) {
      case AppSyncServerType.unknown || null:
        return false;
      case AppSyncServerType.fake:
        return kDebugMode;
      case AppSyncServerType.webdav:
        switch (config) {
          case AppWebDavSyncServer():
            return shouldSyncInWebDav(
              config,
            ).then((result) => result && basicCheck());
          default:
            throw UnimplementedError(
              "<${config.runtimeType}> isn't support yet, got $config",
            );
        }
    }
  }

  Future<bool> shouldSyncInWebDav(AppWebDavSyncServer config) =>
      Future.wait<bool>([
        if (!config.syncInLowData)
          const DataSaver().checkMode().then(
            (mode) => mode == DataSaverMode.disabled,
          ),
        Connectivity().checkConnectivity().then(
          (results) => results
              .map(
                (e) => switch (e) {
                  ConnectivityResult.none => false,
                  ConnectivityResult.wifi => config.syncMobileNetworks.contains(
                    AppSyncServerMobileNetwork.wifi,
                  ),
                  ConnectivityResult.mobile =>
                    config.syncMobileNetworks.contains(
                      AppSyncServerMobileNetwork.mobile,
                    ),
                  _ => true,
                },
              )
              .any((e) => e),
        ),
      ]).then((results) => results.every((e) => e));

  Future<void> startSync({Duration? initWait}) async {
    final config = _root._serverConfig?.get();
    if (config == null) return;

    final tmpNewTask = (_task == null || _task!.task.isDone)
        ? await buildNewTask(config, initWait).then(
            (task) => AppPathProvider()
                .getSyncFailedLogFilePath(task.sessionId)
                .then(
                  (filePath) => AppSyncContainer.generate(
                    task: task,
                    filePath: filePath,
                    notification: NotiAppSyncProvider.generate(
                      data: _root.channelData,
                      l10n: _root._l10n?.target,
                      type: config.type,
                    ),
                  ),
                ),
          )
        : null;

    final AppSyncContainer newTask;
    final crtTask = _task;

    if ((crtTask == null || crtTask.task.isDone) && tmpNewTask != null) {
      newTask = _task = tmpNewTask;
      crtTask?.stopRecordSyncLog();
    } else if (crtTask != null &&
        crtTask.task.status == AppSyncTaskStatus.idle) {
      newTask = crtTask;
    } else {
      return;
    }

    newTask.notification?.readyToSync();
    newTask.startRecordSyncLog();
    newTask.task.run().whenComplete(() async {
      final crtTask = _task;
      if (crtTask == null ||
          newTask.id != crtTask.id ||
          crtTask.task.status != AppSyncTaskStatus.completed) {
        return;
      }
      final finalTask = _task = crtTask.copyWith(
        result: await crtTask.task.result,
        endedTime: AppClock().now(),
      );
      appLog.value.info(
        "$runtimeType.task",
        beforeVal: crtTask,
        afterVal: finalTask,
        ex: ['completed'],
        error: finalTask.result?.error.error,
        stackTrace: finalTask.result?.error.trace,
      );
      notifyListeners();
      finalTask
        ..recordSyncFailureLog()
        ..stopRecordSyncLog();
      finalTask.notification?.syncComplete(result: finalTask.result);
    });

    _startSyncEventController.add(newTask.id);
    notifyListeners();
  }

  void cancelSync() {
    final cancelTask = _task;
    if (cancelTask == null || cancelTask.task.isCancalling) return;
    cancelTask.task.cancel().whenComplete(() async {
      final crtTask = _task;
      if (crtTask == null ||
          cancelTask.id != crtTask.id ||
          crtTask.task.status != AppSyncTaskStatus.cancelled) {
        return;
      }
      final finalTask = _task = crtTask.copyWith(
        result: await crtTask.task.result,
        endedTime: AppClock().now(),
      );
      appLog.value.info(
        "$runtimeType.task",
        beforeVal: crtTask,
        afterVal: finalTask,
        ex: ['cancelled'],
        error: finalTask.result?.error.error,
        stackTrace: finalTask.result?.error.trace,
      );
      notifyListeners();
      finalTask
        ..recordSyncFailureLog()
        ..stopRecordSyncLog();
      finalTask.notification?.syncComplete(result: finalTask.result);
    });

    notifyListeners();
  }
}

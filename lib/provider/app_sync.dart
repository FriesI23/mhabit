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
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart' as l;
import 'package:logger/logger.dart' show LogEvent;
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../common/consts.dart';
import '../common/global.dart';
import '../common/utils.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../logging/logger_message.dart' show AppLoggerMessage;
import '../logging/logger_utils.dart';
import '../model/app_sync_options.dart';
import '../model/app_sync_server.dart';
import '../model/app_sync_task.dart';
import '../model/app_sync_timer.dart';
import '../persistent/db_helper_provider.dart';
import '../persistent/profile/handlers.dart';
import '../persistent/profile_provider.dart';
import '../reminders/providers/noti_app_sync_provider.dart';
import '../utils/app_path_provider.dart';
import '../utils/async_debouncer.dart';
import '../view/common/app_sync_confirm_dialog.dart';
import 'commons.dart';

part 'app_sync.g.dart';

const kAppSyncDelayDuration1 = Duration(seconds: 1);
const kAppSyncDelayDuration2 = Duration(milliseconds: 1500);
const kAppSyncDelayDuration3 = Duration(milliseconds: 2500);
const kAppSyncOnceDelay = Duration(seconds: 5);

class AppSyncViewModel
    with
        ChangeNotifier,
        ProfileHandlerLoadedMixin,
        DBHelperLoadedMixin,
        NotificationChannelDataMixin
    implements ProviderMounted {
  late final DispatcherForAppSyncTask appSyncTask;

  late final ValueNotifier<num> _autoSyncTickNotifier;

  late final CascadingAsyncDebouncer _delayedSyncTrigger;

  late AppLifecycleListener _lifecycleListener;

  WeakReference<L10n>? _l10n;

  bool _mounted = true;
  AppSyncSwitchHandler? _switch;
  AppSyncFetchIntervalHandler? _interval;
  AppSyncServerConfigHandler? _serverConfig;
  AppSyncExperimentalFeature? _expSwitch;
  Stopwatch? _appPauseStopwatch;

  AppSyncPeriodicTimer? _autoSyncTimer;
  bool _clearLogsOnStartup = false;

  AppSyncViewModel() {
    appSyncTask = DispatcherForAppSyncTask(this);
    appSyncTask.addListener(notifyListeners);
    _autoSyncTickNotifier = ValueNotifier(0);
    _delayedSyncTrigger = CascadingAsyncDebouncer(action: () async {
      if (!mounted) return;
      appLog.appsync.debug("AppSyncViewModel.onSyncTriggerred",
          ex: [_delayedSyncTrigger]);
      await startSync();
      await appSyncTask.task?.task.result;
    });
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
          appLog.appsync.debug("AppSyncViewModel",
              ex: ["App Resumed from Paused", stopDuration]);
        }
        // re-sync
        final interval = _interval?.get()?.t;
        if (interval != null && stopDuration != null) {
          final window = Duration(microseconds: interval.inMicroseconds ~/ 2);
          appLog.appsync.debug("AppSyncViewModel",
              ex: ["Try re-sync after resumed", stopDuration, window]);
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
    _autoSyncTickNotifier.dispose();
    _lifecycleListener.dispose();
    _delayedSyncTrigger.cancel();
    _autoSyncTimer?.cancel();
    appSyncTask.dispose();
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
    _expSwitch = newProfile.getHandler<AppSyncExperimentalFeature>();
    // start auto sync
    regrPeriodicSync(fireDelay: kAppSyncDelayDuration3);
    // clear failed sync logs
    if (!_clearLogsOnStartup) {
      _clearLogsOnStartup = true;
      cleanExpiredSyncFailedLogs().then((results) {
        if (results.isNotEmpty) {
          appLog.appsync.info("clear logs on startup", ex: [hashCode, results]);
        }
      }).catchError((e, s) {
        appLog.appsync.warn("clear logs on startup failed",
            ex: [hashCode], error: e, stackTrace: s);
        if (kDebugMode) Error.throwWithStackTrace(e, s);
      });
    }
  }

  void onL10nUpdate(L10n? l10n) {
    _l10n = l10n != null ? WeakReference(l10n) : null;
  }

  bool get enabled => _switch?.get() ?? false;

  Future<void> setSyncSwitch(bool value, {bool listen = true}) async {
    if (_switch?.get() != value) {
      await _switch?.set(value);
      if (listen) notifyListeners();
    }
  }

  AppSyncFetchInterval get fetchInterval =>
      _interval?.get() ?? defaultAppSyncFetchInterval;

  Future<void> setFetchInterval(AppSyncFetchInterval value,
      {bool listen = true}) async {
    if (_interval?.get() != value) {
      await _interval?.set(value);
      regrPeriodicSync();
      if (listen) notifyListeners();
    }
  }

  AppSyncServer? get serverConfig => _serverConfig?.get();

  bool get expFeatureEnabled =>
      _expSwitch == null ? true : _expSwitch?.get() ?? false;

  Future<void> setExpFeatureSwitch(bool value, {bool listen = true}) async {
    if (_expSwitch?.get() != value) {
      await _expSwitch?.set(value);
      if (listen) notifyListeners();
    }
  }

  Future<String?> getPassword({String? identity}) {
    identity = identity ?? serverConfig?.identity;
    if (identity == null) return Future.value(null);
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ).read(key: "sync-pwd-$identity").catchError((e, s) {
      if (kDebugMode) Error.throwWithStackTrace(e, s);
      return serverConfig?.password;
    });
  }

  Future<bool> setPassword({String? identity, required String? value}) async {
    identity = identity ?? serverConfig?.identity;
    if (identity == null) return false;
    try {
      const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        mOptions: MacOsOptions(),
      ).write(key: "sync-pwd-$identity", value: value);
    } catch (e, s) {
      if (kDebugMode) Error.throwWithStackTrace(e, s);
      return false;
    }
    return true;
  }

  Future<bool> saveWithConfigForm(AppSyncServerForm? form,
      {bool resetStatus = false, bool removable = false}) async {
    final oldConfig = serverConfig;
    final tmpNewConfig = AppSyncServer.fromForm(form);
    if (tmpNewConfig == null && !removable) return false;

    final isSameServer = switch ((oldConfig, tmpNewConfig)) {
      (null, null) => true,
      (null, _) || (_, null) => false,
      (_, _) => oldConfig!.isSameServer(tmpNewConfig!, withoutPassword: true)
    };
    appLog.appsync.info("saveWithConfigForm",
        ex: [resetStatus, removable, oldConfig, tmpNewConfig]);
    appLog.appsync.debug("saveWithConfigForm.verbose", ex: [
      isSameServer,
      form?.toDebugString,
      oldConfig?.toDebugString,
      tmpNewConfig?.toDebugString
    ]);

    AppSyncServer? buildConfig({bool withPwd = false}) =>
        (!isSameServer || resetStatus)
            ? AppSyncServer.fromForm(form?.copyWith(
                uuid: isSameServer
                    ? form.uuid
                    : UuidValue.raw(AppSyncServer.genNewIdentity()),
                configed: false,
                password: withPwd ? form.password : ''))
            : tmpNewConfig;

    Future<bool> doSave() async {
      Future<bool>? setOrRemoveConfig(AppSyncServer? config) =>
          config != null ? _serverConfig?.set(config) : _serverConfig?.remove();

      // step1: set or remove new server config
      final deidentifiedNewConfig = buildConfig();
      if (await setOrRemoveConfig(deidentifiedNewConfig) != true) return false;
      // step2(optional): remove old password from sec-storage if necessary
      if (oldConfig?.identity != deidentifiedNewConfig?.identity &&
          oldConfig != null) {
        await setPassword(identity: oldConfig.identity, value: null);
      }
      // step3: set new password to sec-storage
      final result = (tmpNewConfig != null && deidentifiedNewConfig != null)
          ? await setPassword(
              identity: deidentifiedNewConfig.identity,
              value: tmpNewConfig.password)
          : true;
      // step4(optional): set server config with password (backup process)
      if (result != true) {
        return await setOrRemoveConfig(buildConfig(withPwd: true)) ?? false;
      }
      return true;
    }

    return await doSave().then((value) {
      if (mounted) notifyListeners();
      return value;
    });
  }

  Future<void> startSync({Duration? initWait}) =>
      appSyncTask.shouldSync().then((result) {
        if (!result) {
          final config = _serverConfig?.get();
          appLog.appsync.info("$runtimeType.startSync",
              ex: ["cant't sync now", config?.toDebugString]);
          return null;
        }
        return appSyncTask.startSync(initWait: initWait);
      });

  Future<List<String>> cleanExpiredSyncFailedLogs() => AppPathProvider()
      .getSyncFailLogDir()
      .then((dir) => cleanExpiredFiles(dir, const Duration(days: 30)));

  ValueListenable<num> get onAutoSyncTick => _autoSyncTickNotifier;

  void regrPeriodicSync({Duration? fireDelay}) {
    final interval = _interval?.get();
    if (interval == null || interval.t == null) {
      final oldTimer = _autoSyncTimer?..cancel();
      _autoSyncTimer = null;
      appLog.appsync.info("regrPeriodicSync",
          ex: ["disabled", fireDelay, interval, oldTimer?.interval]);
    } else if (_autoSyncTimer?.interval != interval) {
      void onPeriodicSyncTriggered(Timer timer) async {
        if (!mounted) return;
        final config = _serverConfig?.get();
        appLog.appsync.debug("[${timer.tick}] [${timer.hashCode}] Auto sync",
            ex: [timer.isActive, interval, () => config?.toDebugString()]);
        if (!enabled || !(await appSyncTask.shouldSync())) return;
        if (!mounted) return;
        await appSyncTask.startSync();
        _autoSyncTickNotifier.value += 1;
      }

      final oldTimer = _autoSyncTimer?..cancel();
      final timer = _autoSyncTimer =
          AppSyncPeriodicTimer(interval, onPeriodicSyncTriggered);
      appLog.appsync.info("regrPeriodicSync",
          ex: ["update", fireDelay, interval, oldTimer?.interval]);
      if (fireDelay != null) {
        Future.delayed(fireDelay, () => onPeriodicSyncTriggered(timer));
      }
    }
  }

  void delayedStartTaskOnce({Duration delay = kAppSyncOnceDelay}) {
    if (!(mounted &&
        _serverConfig?.get() != null &&
        _interval?.get()?.t != null)) return;
    appLog.appsync.debug("AppSyncViewModel.delayedStartTaskOnce",
        ex: [delay, _delayedSyncTrigger]);
    _delayedSyncTrigger.exec(delay: delay);
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

  AppSyncContainer(
      {required this.id,
      required this.task,
      this.startTime,
      this.endedTime,
      this.result,
      this.loggerReplay,
      this.filePath,
      this.notification,
      void Function(l.LogEvent)? logEventCallback}) {
    final loggerReplay = this.loggerReplay;
    this.logEventCallback =
        logEventCallback ?? (event) => loggerReplay?.add(event);
  }

  AppSyncContainer._copyWith(
      {required this.id,
      required this.task,
      this.startTime,
      this.endedTime,
      this.result,
      this.loggerReplay,
      this.filePath,
      this.percentage,
      this.loggerStreamer,
      this.notification,
      required this.logEventCallback});

  AppSyncContainer.generate(
      {required this.task, required String this.filePath, this.notification})
      : id = const Uuid().v4(),
        startTime = DateTime.now(),
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
          sessionId: task.sessionId);
      sr.init().then((_) {
        if (!sr.isComplete) sr.run();
      });
    }
  }

  @override
  String toString() => "AppSyncContainer<$T>(id=$id, "
      "task=<${task.sessionId}>$task, startT=$startTime, endedT=$endedTime, "
      "reuslt=$result, loggerReplay=$loggerReplay, filePath=$filePath, "
      "logEventCallback=${logEventCallback.hashCode}"
      ")";
}

abstract class _ForAppSynDispatcher {
  final AppSyncViewModel root;

  const _ForAppSynDispatcher(this.root);
}

final class DispatcherForAppSyncTask extends _ForAppSynDispatcher
    with ChangeNotifier {
  AppSyncContainer? _task;

  DispatcherForAppSyncTask(super.root) : _task = null {
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

  void changePercentage({required num? prt}) {
    prt = prt?.clamp(0.0, 1.0);
    if (_task?.percentage != prt) {
      _task?.percentage = prt;
      notifyListeners();
    }
  }

  Future<AppSyncTask> buildNewTask(AppSyncServer config,
      [Duration? initWait]) async {
    AppSyncTask buildDefaultTask() => BasicAppSyncTask(
        config: config,
        onExec: (task) => Future.value(const BasicAppSyncTaskResult.error()));

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
                appLog.appsynctask.debug(task, ex: [
                  "loop $i -> running,",
                  "delayed for ${delayed.inMilliseconds}ms"
                ]);
                await Future.delayed(delayed);
              }
              if (task == _task?.task) changePercentage(prt: 1);
              await Future.delayed(const Duration(milliseconds: 600));
              if (task == _task?.task) changePercentage(prt: null);
              await Future.delayed(const Duration(seconds: 1));
              appLog.appsynctask.debug(task, ex: ['Done']);
              return const BasicAppSyncTaskResult.success();
            });

      case AppSyncServerType.webdav:
        switch (config) {
          case AppWebDavSyncServer():
            final password = await root.getPassword(identity: config.identity);
            final sessionId = WebDavAppSyncTask.genSessionId();
            final isFirstSync = !config.configed;
            return WebDavAppSyncTask(
              sessionId: sessionId,
              config: config.copyWith(
                  password: password,
                  timeout: isFirstSync
                      ? (config.timeout ?? defaultAppSyncTimeout) * 10
                      : config.timeout),
              syncDBHelper: root.syncDBHelper,
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
                final crtConfig = root._serverConfig?.get();
                if (crtConfig == null) return;
                if (config.isSameConfig(crtConfig)) {
                  root._serverConfig?.set(config.copyWith(configed: true));
                }
              },
              onNeedConfirmCallback: (checklist) {
                if (_task?.task.sessionId != sessionId) return false;
                final context = navigatorKey.currentState?.context;
                if (context == null) return true;
                return showDialog<bool>(
                  context: context,
                  builder: (context) => checklist.isEmptyDir
                      ? const AppSyncWebDavNewServerConfirmDialog()
                      : const AppSyncWebDavOldServerConfirmDialog(),
                ).then((value) => value ?? false);
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
      if (!root.enabled) return false;
      config = config ?? root._serverConfig?.get();
      if (config == null) return false;
      return true;
    }

    final config = root._serverConfig?.get();
    if (!(basicCheck(config))) return false;
    switch (config?.type) {
      case AppSyncServerType.unknown || null:
        return false;
      case AppSyncServerType.fake:
        return kDebugMode;
      case AppSyncServerType.webdav:
        switch (config) {
          case AppWebDavSyncServer():
            return shouldSyncInWebDav(config)
                .then((result) => result && basicCheck());
          default:
            throw UnimplementedError(
                "<${config.runtimeType}> isn't support yet, got $config");
        }
    }
  }

  Future<bool> shouldSyncInWebDav(AppWebDavSyncServer config) =>
      Future.wait<bool>([
        if (!config.syncInLowData)
          const DataSaver()
              .checkMode()
              .then((mode) => mode == DataSaverMode.disabled),
        Connectivity().checkConnectivity().then((results) => results
            .map((e) => switch (e) {
                  ConnectivityResult.none => false,
                  ConnectivityResult.wifi => config.syncMobileNetworks
                      .contains(AppSyncServerMobileNetwork.wifi),
                  ConnectivityResult.mobile => config.syncMobileNetworks
                      .contains(AppSyncServerMobileNetwork.mobile),
                  _ => true,
                })
            .any((e) => e)),
      ]).then((results) => results.every((e) => e));

  Future<void> startSync({Duration? initWait}) async {
    final config = root._serverConfig?.get();
    if (config == null) return;

    final tmpNewTask = (_task == null || _task!.task.isDone)
        ? await buildNewTask(config, initWait).then(
            (task) => AppPathProvider()
                .getSyncFailedLogFilePath(task.sessionId)
                .then((filePath) => AppSyncContainer.generate(
                      task: task,
                      filePath: filePath,
                      notification: NotiAppSyncProvider.generate(
                          data: root.channelData,
                          l10n: root._l10n?.target,
                          type: config.type),
                    )),
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
        endedTime: DateTime.now(),
      );
      appLog.value.info("$runtimeType.task",
          beforeVal: crtTask,
          afterVal: finalTask,
          ex: ['completed'],
          error: finalTask.result?.error.error,
          stackTrace: finalTask.result?.error.trace);
      notifyListeners();
      finalTask
        ..recordSyncFailureLog()
        ..stopRecordSyncLog();
      finalTask.notification?.syncComplete(result: finalTask.result);
    });

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
        endedTime: DateTime.now(),
      );
      appLog.value.info("$runtimeType.task",
          beforeVal: crtTask,
          afterVal: finalTask,
          ex: ['cancelled'],
          error: finalTask.result?.error.error,
          stackTrace: finalTask.result?.error.trace);
      notifyListeners();
      finalTask
        ..recordSyncFailureLog()
        ..stopRecordSyncLog();
      finalTask.notification?.syncComplete(result: finalTask.result);
    });

    notifyListeners();
  }
}

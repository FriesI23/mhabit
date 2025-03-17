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

import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:data_saver/data_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../common/consts.dart';
import '../common/global.dart';
import '../logging/helper.dart';
import '../model/app_sync_options.dart';
import '../model/app_sync_server.dart';
import '../model/app_sync_task.dart';
import '../persistent/db_helper_provider.dart';
import '../persistent/profile/handler/app_sync.dart';
import '../persistent/profile_provider.dart';
import '../view/common/app_sync_confirm_dialog.dart';
import 'commons.dart';

part 'app_sync.g.dart';

class AppSyncViewModel
    with ChangeNotifier, ProfileHandlerLoadedMixin, DBHelperLoadedMixin
    implements ProviderMounted {
  late final DispatcherForAppSyncTask appSyncTask;

  bool _mounted = true;
  AppSyncSwitchHandler? _switch;
  AppSyncFetchIntervalHandler? _interval;
  AppSyncServerConfigHandler? _serverConfig;

  AppSyncViewModel() {
    appSyncTask = DispatcherForAppSyncTask(this);
    appSyncTask.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _mounted = false;
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
      if (listen) notifyListeners();
    }
  }

  AppSyncServer? get serverConfig => _serverConfig?.get();

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
                verified: false,
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

  Future<void> startSync() => appSyncTask.shouldSync().then((result) {
        if (!result) {
          final config = _serverConfig?.get();
          appLog.appsync.info("$runtimeType.startSync",
              ex: ["cant't sync now", config?.toDebugString]);
          return null;
        }
        return appSyncTask.startSync();
      });
}

@CopyWith(skipFields: false, copyWithNull: false)
class AppSyncContainer<T extends AppSyncTask<R>, R extends AppSyncTaskResult> {
  final String id;
  final T task;
  final DateTime? startTime;
  final DateTime? endedTime;
  final R? result;

  num? percentage;

  AppSyncContainer({
    required this.id,
    required this.task,
    this.startTime,
    this.endedTime,
    this.result,
  });

  AppSyncContainer.generate({required this.task})
      : id = const Uuid().v4(),
        startTime = DateTime.now(),
        endedTime = null,
        result = null;

  @override
  String toString() => "AppSyncContainer<$T>(id=$id, "
      "task=$task, startT=$startTime, endedT=$endedTime, "
      "reuslt=$result"
      ")";
}

abstract class _ForAppSynDispatcher {
  final AppSyncViewModel root;

  const _ForAppSynDispatcher(this.root);
}

final class DispatcherForAppSyncTask extends _ForAppSynDispatcher
    with ChangeNotifier {
  AppSyncContainer? _task;

  DispatcherForAppSyncTask(super.root) : _task = null;

  Future? get processing => task?.task.result;

  AppSyncContainer? get task => _task;

  AppSyncContainer<AppSyncTask<AppSyncTaskResult>, AppSyncTaskResult>?
      get fakeTask => _task;

  void changePercentage({required num? prt}) {
    prt = prt?.clamp(0.0, 1.0);
    if (_task?.percentage != prt) {
      _task?.percentage = prt;
      notifyListeners();
    }
  }

  Future<AppSyncTask> buildNewTask(AppSyncServer config) async {
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
              final loopCount = 10;
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
              return BasicAppSyncTaskResult.success();
            });

      case AppSyncServerType.webdav:
        switch (config) {
          case AppWebDavSyncServer():
            final password = await root.getPassword(identity: config.identity);
            return WebDavAppSyncTask(
              config: config.copyWith(password: password),
              syncDBHelper: root.syncDBHelper,
              onConfigTaskComplete: (result) {
                if (!result.isSuccessed || config.configed) return;
                final crtConfig = root._serverConfig?.get();
                if (crtConfig == null) return;
                if (config.isSameConfig(crtConfig)) {
                  root._serverConfig?.set(config.copyWith(configed: true));
                }
              },
              onNeedConfirmCallback: (checklist) {
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
    final config = root._serverConfig?.get();
    if (config == null) return false;
    switch (config.type) {
      case AppSyncServerType.unknown:
        return false;
      case AppSyncServerType.fake:
        return kDebugMode;
      case AppSyncServerType.webdav:
        switch (config) {
          case AppWebDavSyncServer():
            return shouldSyncInWebDav(config);
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
                  ConnectivityResult.wifi => config.syncMobileNetworks
                      .contains(AppSyncServerMobileNetwork.wifi),
                  ConnectivityResult.mobile => config.syncMobileNetworks
                      .contains(AppSyncServerMobileNetwork.mobile),
                  _ => true,
                })
            .any((e) => e)),
      ]).then((results) => results.every((e) => e));

  Future<void> startSync() async {
    final config = root._serverConfig?.get();
    if (config == null) return;

    final tmpNewTask = (_task == null || _task!.task.isDone)
        ? AppSyncContainer.generate(task: await buildNewTask(config))
        : null;

    final AppSyncContainer newTask;
    final crtTask = _task;

    if ((crtTask == null || crtTask.task.isDone) && tmpNewTask != null) {
      newTask = _task = tmpNewTask;
    } else if (crtTask != null &&
        crtTask.task.status == AppSyncTaskStatus.idle) {
      newTask = _task = crtTask;
    } else {
      return;
    }

    newTask.task.run().whenComplete(() async {
      final crtTask = _task;
      if (crtTask == null ||
          newTask.id != crtTask.id ||
          crtTask.task.status != AppSyncTaskStatus.completed) {
        return;
      }
      _task = crtTask.copyWith(
        result: await crtTask.task.result,
        endedTime: DateTime.now(),
      );
      appLog.value.info("$runtimeType.task",
          beforeVal: crtTask, afterVal: _task, ex: ['completed']);
      notifyListeners();
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
      _task = crtTask.copyWith(
        result: await crtTask.task.result,
        endedTime: DateTime.now(),
      );
      appLog.value.info("$runtimeType.task",
          beforeVal: crtTask, afterVal: _task, ex: ['cancelled']);
      notifyListeners();
    });

    notifyListeners();
  }
}

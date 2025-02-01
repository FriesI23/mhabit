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

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../model/app_sync_server.dart';
import '../persistent/profile/handler/app_sync.dart';
import '../persistent/profile_provider.dart';
import 'commons.dart';

class AppSyncViewModel
    with ChangeNotifier, ProfileHandlerLoadedMixin
    implements ProviderMounted {
  bool _mounted = true;
  AppSyncSwitchHandler? _switch;
  AppSyncServerConfigHandler? _serverConfig;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  bool get mounted => _mounted;

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _switch = newProfile.getHandler<AppSyncSwitchHandler>();
    _serverConfig = newProfile.getHandler<AppSyncServerConfigHandler>();
  }

  bool get enabled => _switch?.get() ?? false;

  Future<void> setSyncSwitch(bool value, {bool listen = true}) async {
    if (_switch?.get() != value) {
      await _switch?.set(value);
      notifyListeners();
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
      {bool forceSave = false,
      bool resetStatus = true,
      bool removable = false}) async {
    final oldConfig = serverConfig;
    final newConfig = AppSyncServer.fromForm(form);
    if (newConfig == null && !removable) return false;
    final isSameServer = switch ((oldConfig, newConfig)) {
      (null, null) => true,
      (null, _) || (_, null) => false,
      (_, _) => oldConfig!.isSameConfig(newConfig!, withoutPassword: true),
    };
    if (isSameServer && !forceSave) return false;

    AppSyncServer? buildConfig({bool withPwd = false}) =>
        (!isSameServer || resetStatus)
            ? AppSyncServer.fromForm(form?.copyWith(
                configed: false,
                verified: false,
                password: withPwd ? form.password : ''))
            : newConfig;

    Future<bool> doSave() async {
      Future<bool>? setOrRemoveConfig(AppSyncServer? config) =>
          config != null ? _serverConfig?.set(config) : _serverConfig?.remove();

      // step1: set or remove new server config
      if (await setOrRemoveConfig(buildConfig()) != true) return false;
      // step2(optional): remove old password from sec-storage if necessary
      if (oldConfig?.identity != newConfig?.identity && oldConfig != null) {
        await setPassword(identity: oldConfig.identity, value: null);
      }
      // step3: set new password to sec-storage
      final result = newConfig != null
          ? await setPassword(
              identity: newConfig.identity, value: newConfig.password)
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
}

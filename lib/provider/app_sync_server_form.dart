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

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../logging/helper.dart';
import '../model/app_sync_server.dart';
import 'commons.dart';

class AppSyncServerFormViewModel extends ChangeNotifier
    implements ProviderMounted {
  final AppSyncServer? initServerConfig;
  final TextEditingController pathInputController;
  final TextEditingController usernameInputController;
  final TextEditingController passwordInputController;

  bool _mounted = true;
  bool _pwdLoaded = false;
  AppSyncServer? _crtServerConfig;
  Completer<(String, String?)>? _pwdCompleter;

  late AppSyncServerForm _form;

  AppSyncServerFormViewModel({
    this.initServerConfig,
    required this.pathInputController,
    required this.usernameInputController,
    required this.passwordInputController,
  }) {
    _form = initServerConfig?.toForm() ?? getDefaultForm();
    refreshFormInputControllers();
  }

  @override
  void dispose() {
    if (!_mounted) return;
    pathInputController.dispose();
    usernameInputController.dispose();
    passwordInputController.dispose();
    super.dispose();
    _mounted = false;
  }

  @override
  bool get mounted => _mounted;

  bool get pwdLoaded => _pwdLoaded;

  void refreshFormInputControllers() {
    appLog.load.debug("$runtimeType.refreshFormInputControllers", ex: [_form]);
    pathInputController.text = _form.path ?? '';
    usernameInputController.text = _form.username ?? '';
    passwordInputController.text = _form.password ?? '';
  }

  void flushInputControllersToForm() {
    appLog.load.debug("$runtimeType.flushInputControllersToForm", ex: [_form]);
    _form.path = pathInputController.text;
    _form.username = usernameInputController.text;
    _form.password = passwordInputController.text;
    appLog.load
        .debug("$runtimeType.flushInputControllersToForm", ex: ["DONE", _form]);
  }

  AppSyncServerForm getDefaultForm() =>
      AppWebDavSyncServer.newServer(identity: const Uuid().v4(), path: '')
          .toForm();

  AppSyncServer? get crtServerConfig => initServerConfig ?? _crtServerConfig;

  AppSyncServerForm get formSnapshot => _form.copyWith();

  void updateCrtServerConfig(AppSyncServer? newConfig) {
    if (newConfig != crtServerConfig) {
      appLog.load.info("$runtimeType.updateCrtServerConfig", ex: [newConfig]);
      _crtServerConfig = newConfig;
      notifyListeners();
    }
  }

  String get identity => _form.uuid.uuid;

  AppSyncServerType get type => _form.type;
  set type(AppSyncServerType value) {
    if (type == value) return;
    final oldForm = _form;
    _form = value != crtServerConfig?.type
        ? AppSyncServer.newServer(value)?.toForm() ?? getDefaultForm()
        : crtServerConfig!.toForm();
    refreshFormInputControllers();
    _pwdCompleter = null;
    _pwdLoaded = false;
    appLog.value.info('$runtimeType.type', beforeVal: oldForm, afterVal: _form);
    notifyListeners();
  }

  Future<(String, String?)> getPassword({
    Duration timeout = const Duration(seconds: 1),
    bool changeController = true,
  }) {
    final crtCompleter = _pwdCompleter;
    if (crtCompleter != null) return crtCompleter.future;
    final completer = _pwdCompleter = Completer<(String, String?)>();
    final identity = this.identity;
    const FlutterSecureStorage()
        .read(key: identity)
        .timeout(timeout)
        .then((value) {
          value = value ?? _form.password;
          if (!changeController || identity != this.identity) return null;
          if (value == null) return value;
          if (passwordInputController.text.isEmpty ||
              passwordInputController.text == _form.password) {
            appLog.value.debug("passwordInputController.text",
                beforeVal: passwordInputController.text, afterVal: value);
            passwordInputController.text = value;
            _pwdLoaded = true;
          }
          return value;
        })
        .then((value) => completer.isCompleted
            ? null
            : completer.complete((identity, value)))
        .catchError((e, s) =>
            completer.isCompleted ? null : completer.completeError(e, s))
        .whenComplete(() {
          if (completer == _pwdCompleter) _pwdCompleter = null;
        });
    return completer.future;
  }
}

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

import 'package:flutter/material.dart';
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
  AppSyncServer? _crtServerConfig;

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

  AppSyncServerType get type => _form.type;
  set type(AppSyncServerType value) {
    if (type == value) return;
    final oldForm = _form;
    _form = value != crtServerConfig?.type
        ? AppSyncServer.newServer(value)?.toForm() ?? getDefaultForm()
        : crtServerConfig!.toForm();
    refreshFormInputControllers();
    appLog.value.info('$runtimeType.type', beforeVal: oldForm, afterVal: _form);
    notifyListeners();
  }
}

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

import '../logging/helper.dart';
import '../models/app_sync_server.dart';
import '../models/app_sync_server_form.dart';
import 'app_sync.dart';
import 'commons.dart';

class AppSyncServerFormViewModel extends ChangeNotifier
    implements ProviderMounted {
  final AppSyncServer? initServerConfig;

  bool _mounted = true;
  bool _pwdLoaded = false;
  bool _edited = false;
  AppSyncViewModel? _parent;
  Completer<(String, String?)>? _pwdCompleter;

  late AppSyncServerForm _form;

  AppSyncServerFormViewModel({this.initServerConfig}) {
    _form = initServerConfig?.toForm() ?? getDefaultForm();
  }

  @override
  void dispose() {
    if (!_mounted) return;
    super.dispose();
    _mounted = false;
  }

  @override
  void notifyListeners() {
    _edited = true;
    super.notifyListeners();
  }

  @override
  bool get mounted => _mounted;

  bool get pwdLoaded => _pwdLoaded;

  bool get edited => _edited;

  bool get canSave => _form.canSave();

  WebDavSyncServerFromHandler? get webdav => type == AppSyncServerType.webdav
      ? WebDavSyncServerFromHandler(this)
      : null;

  AppSyncServerForm getDefaultForm() =>
      AppSyncServer.newServer(AppSyncServerType.webdav)!.toForm();

  AppSyncServer? get serverConfig => initServerConfig ?? _parent?.serverConfig;

  void attachParent(AppSyncViewModel? parent) {
    if (parent != _parent) {
      appLog.load.info("$runtimeType.attachParent", ex: [parent]);
      _parent = parent;
    }
  }

  void attachNewForm(AppSyncServerForm newForm, {bool listen = true}) {
    assert(newForm.type == _form.type);
    if (newForm == _form) return;
    final oldForm = _form;
    _form = newForm;
    appLog.value.info('$runtimeType.form', beforeVal: oldForm, afterVal: _form);
    if (listen) notifyListeners();
  }

  String get identity => _form.uuid;

  AppSyncServerType get type => _form.type;
  set type(AppSyncServerType value) {
    if (type == value) return;
    final oldForm = _form;
    _form = value != serverConfig?.type
        ? AppSyncServer.newServer(value)?.toForm() ?? getDefaultForm()
        : serverConfig!.toForm();
    _pwdCompleter = null;
    _pwdLoaded = false;
    appLog.value.info('$runtimeType.type', beforeVal: oldForm, afterVal: _form);
    notifyListeners();
  }
}

abstract interface class _Handler {
  final AppSyncServerFormViewModel root;

  const _Handler(this.root);
}

final class WebDavSyncServerFromHandler implements _Handler {
  @override
  final AppSyncServerFormViewModel root;

  late final WebDavSyncServerForm _cache;

  WebDavSyncServerFromHandler(this.root) {
    _cache = root._form as WebDavSyncServerForm;
  }

  WebDavSyncServerForm get form => _cache;
  set form(WebDavSyncServerForm newForm) {
    root.attachNewForm(newForm);
    if (_cache != root._form) _cache = newForm;
  }

  bool? get ignoreSSL => form.ignoreSSL;
  set ignoreSSL(bool? value) {
    if (value == ignoreSSL) return;
    final oldValue = ignoreSSL;
    form = form.copyWith(ignoreSSL: value);
    appLog.value
        .info('$runtimeType.ignoreSSL', beforeVal: oldValue, afterVal: value);
  }

  Duration? get timeout => form.timeout;
  set timeout(Duration? value) {
    assert((value?.inSeconds ?? 0) >= 0);
    if (value == timeout) return;
    final oldValue = timeout;
    form = form.copyWith(timeout: value);
    appLog.value.info('$runtimeType.timeout',
        beforeVal: oldValue?.inSeconds, afterVal: value?.inSeconds);
  }

  Duration? get connectTimeout => form.connectTimeout;
  set connectTimeout(Duration? value) {
    assert((value?.inSeconds ?? 0) >= 0);
    if (value == connectTimeout) return;
    final oldValue = connectTimeout;
    form = form.copyWith(connectTimeout: value);
    appLog.value.info('$runtimeType.connectTimeout',
        beforeVal: oldValue?.inSeconds, afterVal: value?.inSeconds);
  }

  int? get connectRetryCount => form.connectRetryCount;
  set connectRetryCount(int? value) {
    assert((value ?? 0) >= 0);
    if (value == connectRetryCount) return;
    final oldValue = connectRetryCount;
    form = form.copyWith(connectRetryCount: value);
    appLog.value.info('$runtimeType.connectRetryCount',
        beforeVal: oldValue, afterVal: value);
  }

  Iterable<AppSyncServerMobileNetwork>? get syncMobileNetworks =>
      form.syncMobileNetworks;
  set syncMobileNetworks(Iterable<AppSyncServerMobileNetwork>? value) {
    final newValue = value?.toSet();
    final oldValue = form.syncMobileNetworks;
    if (newValue == oldValue) return;
    form = form.copyWith(syncMobileNetworks: newValue);
    appLog.value.info('$runtimeType.syncMobileNetworks',
        beforeVal: oldValue, afterVal: newValue);
  }

  bool? get syncInLowData => form.syncInLowData;
  set syncInLowData(bool? value) {
    if (value == syncInLowData) return;
    final oldValue = syncInLowData;
    form = form.copyWith(syncInLowData: value);
    appLog.value.info('$runtimeType.syncInLowData',
        beforeVal: oldValue, afterVal: value);
  }

  Future<(String, String?)> readPassword({
    Duration timeout = const Duration(seconds: 1),
    bool changeController = true,
  }) {
    final crtCompleter = root._pwdCompleter;
    if (crtCompleter != null) return crtCompleter.future;
    final completer = root._pwdCompleter = Completer<(String, String?)>();
    final identity = root.identity;
    (root._parent?.readPassword(identity: identity) ?? Future.value(null))
        .timeout(timeout)
        .then((value) {
          value = value ?? form.password;
          if (form.password != value) form = form.copyWith(password: value);
          return value;
        })
        .then((value) => completer.isCompleted
            ? null
            : completer.complete((identity, value)))
        .catchError((e, s) =>
            completer.isCompleted ? null : completer.completeError(e, s))
        .whenComplete(() {
          if (completer == root._pwdCompleter) root._pwdCompleter = null;
        });
    return completer.future;
  }
}

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

import 'package:flutter/foundation.dart';

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

  AppSyncServerForm get form => _form;

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

  WebDavSyncServerFromHandler(this.root);

  WebDavSyncServerForm get form => root._form as WebDavSyncServerForm;

  void notifyListeners() => root.notifyListeners();

  String? get path => form.path;
  set path(String? value) {
    if (value == path) return;
    final oldValue = path;
    form.path = value;
    appLog.value
        .info('$runtimeType.path', beforeVal: oldValue, afterVal: value);
    notifyListeners();
  }

  String? get username => form.username;
  set username(String? value) {
    if (value == username) return;
    final oldValue = username;
    form.username = value;
    appLog.value
        .info('$runtimeType.username', beforeVal: oldValue, afterVal: value);
    notifyListeners();
  }

  String? get password => form.password;
  set password(String? value) {
    if (value == password) return;
    final oldValue = password;
    form.password = value;
    appLog.value
        .info('$runtimeType.password', beforeVal: oldValue, afterVal: value);
    notifyListeners();
  }

  bool? get ignoreSSL => form.ignoreSSL;
  set ignoreSSL(bool? value) {
    if (value == ignoreSSL) return;
    final oldValue = ignoreSSL;
    form.ignoreSSL = value;
    appLog.value
        .info('$runtimeType.ignoreSSL', beforeVal: oldValue, afterVal: value);
    notifyListeners();
  }

  Duration? get timeout => form.timeout;
  set timeout(Duration? value) {
    assert((value?.inSeconds ?? 0) >= 0);
    if (value == timeout) return;
    final oldValue = timeout;
    form.timeout = value;
    appLog.value.info('$runtimeType.timeout',
        beforeVal: oldValue?.inSeconds, afterVal: value?.inSeconds);
    notifyListeners();
  }

  Duration? get connectTimeout => form.connectTimeout;
  set connectTimeout(Duration? value) {
    assert((value?.inSeconds ?? 0) >= 0);
    if (value == connectTimeout) return;
    final oldValue = connectTimeout;
    form.connectTimeout = value;
    appLog.value.info('$runtimeType.connectTimeout',
        beforeVal: oldValue?.inSeconds, afterVal: value?.inSeconds);
    notifyListeners();
  }

  int? get connectRetryCount => form.connectRetryCount;
  set connectRetryCount(int? value) {
    assert((value ?? 0) >= 0);
    if (value == connectRetryCount) return;
    final oldValue = connectRetryCount;
    form.connectRetryCount = value;
    appLog.value.info('$runtimeType.connectRetryCount',
        beforeVal: oldValue, afterVal: value);
    notifyListeners();
  }

  Iterable<AppSyncServerMobileNetwork>? get syncMobileNetworks =>
      form.syncMobileNetworks;
  set syncMobileNetworks(Iterable<AppSyncServerMobileNetwork>? value) {
    final newValue = value?.toSet();
    final oldValue = form.syncMobileNetworks;
    if (newValue == oldValue) return;
    form.syncMobileNetworks = newValue;
    appLog.value.info('$runtimeType.syncMobileNetworks',
        beforeVal: oldValue, afterVal: newValue);
    notifyListeners();
  }

  bool? get syncInLowData => form.syncInLowData;
  set syncInLowData(bool? value) {
    if (value == syncInLowData) return;
    final oldValue = syncInLowData;
    form.syncInLowData = value;
    appLog.value.info('$runtimeType.syncInLowData',
        beforeVal: oldValue, afterVal: value);
    notifyListeners();
  }

  Future<(String, String?)> readPassword(
      {Duration timeout = const Duration(seconds: 1), bool useCache = false}) {
    final crtCompleter = root._pwdCompleter;
    if (crtCompleter != null) return crtCompleter.future;
    if (useCache && root._pwdLoaded) {
      return Future.value((root.identity, form.password));
    }
    final completer = root._pwdCompleter = Completer<(String, String?)>();
    final identity = root.identity;
    (root._parent?.readPassword(identity: identity) ?? Future.value(null))
        .timeout(timeout)
        .then((value) {
          value = value ?? form.password;
          if (form.password != value) {
            form.password = value;
            root._pwdLoaded = true;
            notifyListeners();
          }
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

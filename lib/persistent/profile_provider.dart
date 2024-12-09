// Copyright 2024 Fries_I23
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

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/async.dart';
import '../common/global.dart';
import '../logging/helper.dart';
import '../provider/commons.dart';
import 'profile/profile_helper.dart';

typedef ProfileHandlerBuilder<T extends ProfileHelperHandler> = T Function(
    SharedPreferences pref);

class ProfileViewModel extends ChangeNotifier
    implements ProviderMounted, AsyncInitialization {
  late final SharedPreferences _pref;

  final Iterable<ProfileHandlerBuilder> _handlerBuilders;
  late final Map<Type, ProfileHelperHandler> _handlers;

  CancelableCompleter<bool?>? _completer;
  bool _mounted = true;

  ProfileViewModel(Iterable<ProfileHandlerBuilder> builders)
      : _handlerBuilders = builders;

  CancelableCompleter<bool?> doInit(
      {required bool reinit, Duration timeout = const Duration(seconds: 5)}) {
    final completer = CancelableCompleter<bool>();
    (reinit
            ? _pref.reload()
            : SharedPreferences.getInstance().then((inst) async {
                _pref = inst;
                if (kDebugMode && debugClearSharedPrefWhenStart) {
                  appLog.profile
                      .info("$runtimeType.init", ex: ["clear preferences"]);
                  await clear();
                }
              }))
        .timeout(timeout)
        .onError(Future.error)
        .then((_) {
      if (completer.isCanceled == true) return;
      final handlerKeyColl = <String, Type>{};
      _handlers =
          Map.fromEntries(_handlerBuilders.map((e) => e.call(_pref)).where((e) {
        if (handlerKeyColl.containsKey(e.key)) {
          appLog.profile.error("$runtimeType.init",
              ex: ["load handler failed", e, e.key, handlerKeyColl[e.key]]);
          if (kDebugMode) throw FlutterError("load handler failed: $e");
          return false;
        }
        handlerKeyColl[e.key] = e.runtimeType;
        return true;
      }).map((e) => MapEntry(e.runtimeType, e)));
      completer.complete(true);
    }).onError((e, s) {
      if (!completer.isCompleted) {
        e != null ? completer.completeError(e, s) : completer.complete(false);
      }
      if (e != null) return Future.error(e, s);
    });
    return completer;
  }

  @override
  Future<bool> init() {
    if (_completer != null) {
      return _completer!.operation.value.then((value) => value ?? false);
    }
    _completer = doInit(reinit: false);
    return _completer?.operation.value.then((value) => value ?? false) ??
        Future.value(false);
  }

  @override
  void dispose() {
    _mounted = false;
    if (_completer?.isCompleted != true) _completer?.operation.cancel();
    super.dispose();
  }

  Future<void> reload() async {
    if (_completer?.isCompleted != true) await _completer?.operation.cancel();
    _completer = doInit(reinit: true);
    await _completer?.operation.value;
    notifyListeners();
  }

  Future<bool> clear() =>
      (_mounted && inited) ? _pref.clear() : Future.value(false);

  @override
  bool get mounted => _mounted;

  bool get inited => _completer?.isCompleted ?? false;

  T? getHandler<T extends ProfileHelperHandler>() => _handlers[T] as T?;

  @override
  String toString() {
    return "$runtimeType[$hashCode](pref=${inited ? _pref : null},"
        "mounted=$mounted,inited=$inited,handlers=$_handlers)";
  }
}

abstract mixin class ProfileHandlerLoadedMixin {
  late ProfileViewModel _profile;

  ProfileViewModel get profile => _profile;

  @mustCallSuper
  void updateProfile(ProfileViewModel newProfile) {
    appLog.profile.info("$runtimeType.updateProfile", ex: [newProfile]);
    _profile = newProfile;
  }
}

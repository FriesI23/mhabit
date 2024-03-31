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

import '../common/abc.dart';
import '../provider/commons.dart';
import 'profile/profile_helper.dart';

typedef ProfileHandlerBuilder<T extends ProfileHelperHandler> = T Function(
    SharedPreferences pref);

class ProfileViewModel extends ChangeNotifier
    with FutureInitializationABC, ProviderMounted {
  late final SharedPreferences _pref;

  final Map<String, ProfileHandlerBuilder> _handlers;

  Completer? _completer;
  bool _mounted = true;

  ProfileViewModel(Map<String, ProfileHandlerBuilder> handlers)
      : _handlers = handlers;

  @override
  Future init() async {
    if (_completer == null) {
      _completer = Completer();
      _pref = await SharedPreferences.getInstance();
      _completer!.complete();
    }
    return _completer!.future;
  }

  @override
  void dispose() {
    _mounted = false;
    if (_completer?.isCompleted != true) {
      CancelableOperation.fromFuture(_completer!.future).cancel();
      _completer = null;
    }
    super.dispose();
  }

  Future reload() async {
    if (_completer?.isCompleted != true) {
      CancelableOperation.fromFuture(_completer!.future).cancel();
      _completer = null;
    }
    await _pref.reload();
    notifyListeners();
  }

  Future<bool> clear() =>
      (_mounted && inited) ? _pref.clear() : Future.value(false);

  @override
  bool get mounted => _mounted;

  bool get inited => _completer?.isCompleted ?? false;

  T? getHandler<T extends ProfileHelperHandler>() =>
      _handlers[T.runtimeType.toString()]?.call(_pref) as T?;

  bool addHandler<T extends ProfileHelperHandler>(
      ProfileHandlerBuilder<T> builder) {
    _handlers[builder.runtimeType.toString()] = builder;
    return true;
  }

  @override
  String toString() {
    return "$runtimeType[$hashCode](pref=$_pref,mounted=$mounted,"
        "inited=$inited)";
  }
}

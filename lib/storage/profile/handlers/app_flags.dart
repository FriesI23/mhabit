// Copyright 2026 Fries_I23
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

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/types.dart';
import '../profile_helper.dart';

final class AppFlagsProfileHandler implements ProfileHelperHandler<JsonMap> {
  final SharedPreferences _pref;

  const AppFlagsProfileHandler(SharedPreferences pref) : _pref = pref;

  @override
  String get key => "appFlags";

  @override
  Future<bool> set(JsonMap value) => _pref.setString(key, jsonEncode(value));

  @override
  JsonMap? get() {
    final raw = _pref.getString(key);
    return raw != null ? jsonDecode(raw) : null;
  }

  @override
  Future<bool> remove() => _pref.remove(key);
}

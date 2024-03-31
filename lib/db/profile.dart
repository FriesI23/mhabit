// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/abc.dart';
import '../common/global.dart';
import '../logging/helper.dart';

mixin CacheInterface {
  Map<String, Object?> getInputFillCache();
  Future<bool> setInputFillCache(Map<String, Object?> newCache);
}

abstract class ProfileInterface {
  Future<bool> clearAll();
}

enum ProfileKey {
  // cache
  inputFillCache,
}

class Profile
    implements ProfileInterface, CacheInterface, FutureInitializationABC {
  late final SharedPreferences _pref;
  static Profile? _instance;

  Profile._internal() {
    _instance = this;
  }

  factory Profile() => _instance ?? Profile._internal();

  @override
  Future<void> init() async {
    appLog.profile.info('Initializing profiles ...');
    _pref = await SharedPreferences.getInstance();
    if (kDebugMode && debugClearSharedPrefWhenStart) {
      appLog.db.info("Clear shared preferences");
      await clearAll();
    }
    appLog.profile.info("Initialized profiles", ex: [_pref]);
  }

  @override
  Future<bool> clearAll() {
    return _pref.clear();
  }

  @override
  Map<String, Object?> getInputFillCache() {
    final raw = _pref.getString(ProfileKey.inputFillCache.name);
    if (raw == null) return {};
    try {
      return jsonDecode(raw);
    } catch (e) {
      appLog.json.warn("$runtimeType.getInputFillCache",
          ex: ["profile decode err"], error: e);
      return {};
    }
  }

  @override
  Future<bool> setInputFillCache(Map<String, Object?> newCache) {
    return _pref.setString(
        ProfileKey.inputFillCache.name, jsonEncode(newCache));
  }
}

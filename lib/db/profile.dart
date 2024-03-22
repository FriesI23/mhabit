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
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import '../common/abc.dart';
import '../common/consts.dart';
import '../common/enums.dart';
import '../common/global.dart';
import '../common/utils.dart';
import '../logging/helper.dart';
import '../model/app_reminder_config.dart';
import '../model/custom_date_format.dart';
import '../model/habit_display.dart';
import '../theme/color.dart';

mixin CacheInterface {
  Map<String, Object?> getInputFillCache();
  Future<bool> setInputFillCache(Map<String, Object?> newCache);
}

abstract class ProfileInterface {
  Future<bool> clearAll();
  int getThemeType();
  Future<bool> setThemeType(AppThemeType newThemeType);

  int getSysThemeMainColor();
  Future<bool> setSysThemeMainColor(Color newColor);

  Tuple2<int, int> getSortMode();
  Future<bool> setSortMode(HabitDisplaySortType t, HabitDisplaySortDirection d);

  Map<String, Object?> getHabitDisplayFilter();
  Future<bool> setHabitDisplayFilter(Map<String, Object?> filterMap);

  int getHabitsRecordScrollBehavior();
  Future<bool> setHabitsRecordScrollBehavior(
      HabitsRecordScrollBehavior behavior);

  int getFirstDay();
  Future<bool> setFirstDay(int newFirstDay);

  AppReminderConfig? getAppReminder();
  Future<bool> setAppReminder(AppReminderConfig newTimeOfDay);

  CustomDateYmdHmsConfig? getCustomDateYmdHmsConfig();
  Future<bool> setCustomDateYmdHmsConfig(CustomDateYmdHmsConfig newConfig);

  int getDisplayCalendarBarOccupyPrt();
  Future<bool> setDisplayCalendarBarOccupyPrt(int newPrt);

  bool getCompactUISwticher();
  Future<bool> setCompactUISwitcher(bool newStatus);

  HabitDisplayOpConfig? getDisplayOpConfig();
  Future<bool> setDisplayOpConfig(HabitDisplayOpConfig opConfig);
}

enum ProfileKey {
  themeType,
  sysThemeMainColor,
  habitSortMode,
  habitDisplayFilter,
  habitsRecordScrollBehavior,
  firstDay,
  appReminder,
  customDateYmdHmsConfig,
  displayCalendarBarOccupyPrt,
  compactUISwitcher,
  displayOpConfig,
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
  int getThemeType() {
    return _pref.getInt(ProfileKey.themeType.name) ??
        appDefaultThemeType.dbCode;
  }

  @override
  Future<bool> setThemeType(AppThemeType newThemeType) async {
    if (newThemeType == AppThemeType.unknown) {
      throw TypeError();
    }
    return _pref.setInt(ProfileKey.themeType.name, newThemeType.dbCode);
  }

  @override
  int getSysThemeMainColor() {
    return _pref.getInt(ProfileKey.sysThemeMainColor.name) ??
        appDefaultThemeMainColor;
  }

  @override
  Future<bool> setSysThemeMainColor(Color newColor) async {
    return _pref.setInt(ProfileKey.sysThemeMainColor.name, newColor.value);
  }

  @override
  Tuple2<int, int> getSortMode() {
    var raw = _pref.getString(ProfileKey.habitSortMode.name);
    if (raw == null) {
      return Tuple2(HabitDisplaySortType.manual.dbCode,
          HabitDisplaySortDirection.asc.dbCode);
    }
    return Tuple2.fromList(jsonDecode(raw));
  }

  @override
  Future<bool> setSortMode(
      HabitDisplaySortType t, HabitDisplaySortDirection d) {
    return _pref.setString(
        ProfileKey.habitSortMode.name, jsonEncode([t.dbCode, d.dbCode]));
  }

  @override
  Map<String, Object?> getHabitDisplayFilter() {
    var raw = _pref.getString(ProfileKey.habitDisplayFilter.name);
    return raw != null ? jsonDecode(raw) : {};
  }

  @override
  Future<bool> setHabitDisplayFilter(Map<String, Object?> filterMap) {
    return _pref.setString(
        ProfileKey.habitDisplayFilter.name, jsonEncode(filterMap));
  }

  @override
  int getHabitsRecordScrollBehavior() {
    return _pref.getInt(ProfileKey.habitsRecordScrollBehavior.name) ??
        defaultHabitsRecordScrollBehavior.dbCode;
  }

  @override
  Future<bool> setHabitsRecordScrollBehavior(
      HabitsRecordScrollBehavior behavior) {
    return _pref.setInt(
        ProfileKey.habitsRecordScrollBehavior.name, behavior.dbCode);
  }

  @override
  int getFirstDay() {
    return _pref.getInt(ProfileKey.firstDay.name) ?? defaultFirstDay;
  }

  @override
  Future<bool> setFirstDay(int newFirstDay) {
    newFirstDay = standardizeFirstDay(newFirstDay);
    return _pref.setInt(ProfileKey.firstDay.name, newFirstDay);
  }

  @override
  AppReminderConfig getAppReminder() {
    final raw = _pref.getString(ProfileKey.appReminder.name);
    return raw != null
        ? AppReminderConfig.fromJson(jsonDecode(raw))
        : defaultAppReminder;
  }

  @override
  Future<bool> setAppReminder(AppReminderConfig newReminder) {
    return _pref.setString(
        ProfileKey.appReminder.name, jsonEncode(newReminder.toJson()));
  }

  @override
  CustomDateYmdHmsConfig getCustomDateYmdHmsConfig() {
    final raw = _pref.getString(ProfileKey.customDateYmdHmsConfig.name);
    if (raw == null) {
      return const CustomDateYmdHmsConfig.withDefault();
    }
    try {
      return CustomDateYmdHmsConfig.fromJson(jsonDecode(raw));
    } catch (e) {
      appLog.json.warn("$runtimeType.getCustomDateYmdHmsConfig",
          ex: ["profile decode err"], error: e);
      return const CustomDateYmdHmsConfig.withDefault();
    }
  }

  @override
  Future<bool> setCustomDateYmdHmsConfig(CustomDateYmdHmsConfig newConfig) {
    return _pref.setString(
        ProfileKey.customDateYmdHmsConfig.name, jsonEncode(newConfig.toJson()));
  }

  @override
  int getDisplayCalendarBarOccupyPrt() {
    return _pref.getInt(ProfileKey.displayCalendarBarOccupyPrt.name) ??
        appCalendarBarDefualtOccupyPrt;
  }

  @override
  Future<bool> setDisplayCalendarBarOccupyPrt(int newPrt) {
    return _pref.setInt(ProfileKey.displayCalendarBarOccupyPrt.name,
        normalizeAppCalendarBarOccupyPrt(newPrt));
  }

  @override
  bool getCompactUISwticher() {
    return _pref.getBool(ProfileKey.compactUISwitcher.name) ?? false;
  }

  @override
  Future<bool> setCompactUISwitcher(bool newStatus) {
    return _pref.setBool(ProfileKey.compactUISwitcher.name, newStatus);
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

  @override
  HabitDisplayOpConfig getDisplayOpConfig() {
    final raw = _pref.getString(ProfileKey.displayOpConfig.name);
    return raw != null
        ? HabitDisplayOpConfig.fromJson(jsonDecode(raw))
        : const HabitDisplayOpConfig.withDefault();
  }

  @override
  Future<bool> setDisplayOpConfig(HabitDisplayOpConfig opConfig) {
    return _pref.setString(
        ProfileKey.displayOpConfig.name, jsonEncode(opConfig.toJson()));
  }
}

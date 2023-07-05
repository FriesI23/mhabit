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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../common/consts.dart';
import '../common/enums.dart';
import '../db/profile.dart';
import '../theme/color.dart';
import 'app_reminder_config.dart';
import 'custom_date_format.dart';
import 'habit_display.dart';

abstract class GlobalProxyProviderInterface {
  Global get g;
  void updateGlobal(Global newGloal);
}

abstract class GlobalInterface {}
// coverage:ignore-end

mixin GlobalDevelopModeMixin {
  Profile get profile;
  bool _isInDevelopMode = kDebugMode ? true : false;
  bool? _displayDebugMenu;

  bool get isInDevelopMode => _isInDevelopMode;
  void switchDevelopMode(bool value) => _isInDevelopMode = value;

  bool get displayDebugMenu => _displayDebugMenu ?? kDebugMode ? true : false;
  void switchDisplayDebugMenu(bool value) => _displayDebugMenu = value;
}

class Global with GlobalDevelopModeMixin implements GlobalInterface {
  @override
  Profile get profile => Profile();

  AppThemeType get themeType =>
      AppThemeType.getFromDBCode(profile.getThemeType())!;
  Color get themeMainColor => Color(profile.getSysThemeMainColor());

  HabitDisplaySortType get sortType =>
      HabitDisplaySortType.getFromDBCode(profile.getSortMode().item1)!;
  HabitDisplaySortDirection get sortDirection =>
      HabitDisplaySortDirection.getFromDBCode(profile.getSortMode().item2)!;

  HabitsDisplayFilter get habitsDisplayFilter {
    var raw = profile.getHabitDisplayFilter();
    return HabitsDisplayFilter.fromMap(raw);
  }

  HabitsRecordScrollBehavior get habitsRecordScrollBehavior =>
      HabitsRecordScrollBehavior.getFromDBCode(
          profile.getHabitsRecordScrollBehavior(),
          withDefault: defaultHabitsRecordScrollBehavior)!;

  int get firstDay => profile.getFirstDay();

  AppReminderConfig get appReminderConfig => profile.getAppReminder();

  CustomDateYmdHmsConfig get customDateYmdHmsConfig =>
      profile.getCustomDateYmdHmsConfig();

  int get displayPageCalendarBarOccupyPrt =>
      profile.getDisplayCalendarBarOccupyPrt();
}

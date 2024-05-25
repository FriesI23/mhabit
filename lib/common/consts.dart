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
// coverage:ignore-file

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/app_reminder_config.dart';
import '../model/habit_display.dart';
import '../model/habit_form.dart';
import '../theme/color.dart';
import 'enums.dart';

const String appName = "mhabit";
const String appDBName = "mhabit.db";
const String aboutInfoFilePath = "configs/about_info.json";
const String debuggerLogFileName = "app_debug.log";
const String debuggerInfoFileName = "debug.txt";
const String debuggerZipFile = "debug.zip";

/// # Sqlite versions
///
/// ## version 1
/// - init databases
/// ## verion 2
/// - add record reason column
/// ## version 3
/// - add daily goal extra column
const int appDBVersion = 3;
//#endregion

//#region app-theme
const Color appDefaultThemeMainColor = Color(0xFF006493);
const AppThemeType appDefaultThemeType = AppThemeType.followSystem;
const int appCalendarBarMaxOccupyPrt = 70;
const int appCalendarBarMinOccupyPrt = 20;
const int appCalendarBarDefualtOccupyPrt = 50;
const int kHabitLargeScreenAdaptWidth = 600;
//#endregion

//#region l10n
const appSupportedLocales = [
  // Fixed #133
  // en must be the first item in the list (default language)
  Locale.fromSubtags(languageCode: 'en'),
  Locale.fromSubtags(languageCode: 'ar'),
  Locale.fromSubtags(languageCode: 'de'),
  // TODO: remove kDebugMode below after translation
  if (kDebugMode) Locale.fromSubtags(languageCode: 'es'),
  Locale.fromSubtags(languageCode: 'fa'),
  Locale.fromSubtags(languageCode: 'fr'),
  Locale.fromSubtags(languageCode: 'it'),
  // TODO: remove kDebugMode below after translation
  if (kDebugMode) Locale.fromSubtags(languageCode: 'nb', countryCode: 'NO'),
  Locale.fromSubtags(languageCode: 'ru'),
  Locale.fromSubtags(languageCode: 'vi'),
  Locale.fromSubtags(languageCode: 'zh'),
];
//#endregion

//#region app-setting
const defaultSortType = HabitDisplaySortType.manual;
const defaultSortDirection = HabitDisplaySortDirection.asc;
const defaultHabitsRecordScrollBehavior = HabitsRecordScrollBehavior.scrollable;
const defaultFirstDay = DateTime.monday;
const defaultAppReminder = AppReminderConfig.off;
//#endregion

//#region habit-field
const defaultHabitType = HabitType.normal;
const defaultHabitColorType = HabitColorType.cc1;

const defaultHabitDailyGoal = 1;
const defaultNegativeHabitDailyGoal = 0;
const minHabitDailyGoal = 0;
const maxHabitdailyGoal = 10000000;
const maxHabitdailyGoalExtra = 50000000;

const defaultHabitDailyGoalUnit = '';
const minHabitDailyGoalUnitLength = 0;
const maxHabitDailyGoalUnitLength = 16;

const defaultHabitTargetDays = 66;
const defaultHabitCustomTargetDays = 365;
const minHabitTargetDays = 7;
const maxHabitTargetDays = 999;

const onSecondMS = 1000;
const oneDaySeconds = 24 * 3600;
const oneDayMilliseconds = oneDaySeconds * onSecondMS;
// Unix timestamp: 2000/01/01
const minHabitSecondsSinceEpoch = 946656000;
const minHabitMillisecondsSinceEpoch = minHabitSecondsSinceEpoch * onSecondMS;
// Unix timestamp: 2070/12/31
const maxHabitSecondsSinceEpoch = 3187180800;
const maxHabitMillisecondsSinceEpoch = maxHabitSecondsSinceEpoch * onSecondMS;

const defaultFrequencyPreWeekFreq = 3;
const defaultFrequencyPreMonthFreq = 10;
const defaultFrequencyCustomFreq = 2;
const defaultFrequencyCustomDays = 5;
const maxFrequencyValue = 99;

const maxRecordReasonTextLenth = 100;

const loadedHabitStatus = <HabitStatus>[
  HabitStatus.activated,
  HabitStatus.archived,
];

//#endregion

//#region common
const minTimeOfDayInt = 0;
const maxTimeOfDayInt = 1440;
//#endregion

//#region components
const double dialogshowTitleMaxHeight = 400.0;

const skipReasonChipTextList = [
  '☕',
  '🛌',
  '🍔',
  '💤',
  '📱',
  '🍹',
  '🏝️',
  '😍',
  '😃',
  '😕',
  '😠',
];

const kRecordAutoMarkStatusIcon = Icons.done_outline;
const kRecordUnknownStatusIcon = Icons.question_mark_outlined;
const kRecordSkipStatusIcon = Icons.remove_outlined;
const kRecordDoneStatusIcon = Icons.check_outlined;
const kRecordZeroStatusIcon = Icons.close_sharp;
//#endregion

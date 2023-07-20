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

import '../l10n/localizations.dart';

import '../common/consts.dart';
import '../common/types.dart';
import 'habit_form.dart';

class HabitDailyGoalHelper {
  final HabitType _habitType;
  final HabitDailyGoal _dailyGoal;

  const HabitDailyGoalHelper({
    required HabitType habitType,
    required HabitDailyGoal dailyGoal,
  })  : _habitType = habitType,
        _dailyGoal = dailyGoal;

  static HabitDailyGoal getDefaultDailyGoal(HabitType habitType) {
    switch (habitType) {
      case HabitType.unknown:
      case HabitType.normal:
        return defaultHabitDailyGoal;
      case HabitType.negative:
        return defaultNegativeHabitDailyGoal;
    }
  }

  HabitDailyGoal get defaultDailyGoal => getDefaultDailyGoal(_habitType);

  bool get isGoalValid {
    switch (_habitType) {
      case HabitType.unknown:
      case HabitType.normal:
        if (_dailyGoal <= minHabitDailyGoal) {
          return false;
        } else if (_dailyGoal > maxHabitdailyGoal) {
          return false;
        } else {
          return true;
        }
      case HabitType.negative:
        if (_dailyGoal < minHabitDailyGoal) {
          return false;
        } else if (_dailyGoal > maxHabitdailyGoal) {
          return false;
        } else {
          return true;
        }
    }
  }

  num get validitedGoal {
    switch (_habitType) {
      case HabitType.unknown:
      case HabitType.normal:
        if (_dailyGoal <= minHabitDailyGoal) {
          return defaultDailyGoal;
        } else if (_dailyGoal > maxHabitdailyGoal) {
          return maxHabitdailyGoal;
        } else {
          return _dailyGoal;
        }
      case HabitType.negative:
        if (_dailyGoal < minHabitDailyGoal) {
          return defaultDailyGoal;
        } else if (_dailyGoal > maxHabitdailyGoal) {
          return maxHabitdailyGoal;
        } else {
          return _dailyGoal;
        }
    }
  }

  String? getTileErrorHint([L10n? l10n]) {
    switch (_habitType) {
      case HabitType.unknown:
      case HabitType.normal:
        if (_dailyGoal <= minHabitDailyGoal) {
          return l10n?.habitEdit_habitDailyGoal_errorText01(minHabitDailyGoal);
        } else if (_dailyGoal > maxHabitdailyGoal) {
          return l10n?.habitEdit_habitDailyGoal_errorText02(maxHabitdailyGoal);
        } else {
          return null;
        }
      case HabitType.negative:
        if (_dailyGoal < minHabitDailyGoal) {
          return l10n
              ?.habitEdit_habitDailyGoal_negativeErrorText01(minHabitDailyGoal);
        } else if (_dailyGoal > maxHabitdailyGoal) {
          return l10n
              ?.habitEdit_habitDailyGoal_negativeErrorText02(minHabitDailyGoal);
        } else {
          return null;
        }
    }
  }
}

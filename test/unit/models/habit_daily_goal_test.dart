// Copyright 2026 Fries_I23
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/models/habit_daily_goal.dart';

void main() {
  group('HabitDailyGoalData bounds', () {
    test('positive goal rejects exact min and normalizes to default', () {
      final data = PositiveHabitDailyGoalData(dailyGoal: minHabitDailyGoal);

      expect(data.isGoalValid, isFalse);
      expect(data.normalizedGoal, defaultHabitDailyGoal);
    });

    test('negative goal accepts exact min and keeps value', () {
      final data = NegativeHabitDailyGoalData(dailyGoal: minHabitDailyGoal);

      expect(data.isGoalValid, isTrue);
      expect(data.normalizedGoal, minHabitDailyGoal);
    });

    test('positive goal below min normalizes to positive default', () {
      final data = PositiveHabitDailyGoalData(dailyGoal: minHabitDailyGoal - 1);

      expect(data.isGoalValid, isFalse);
      expect(data.normalizedGoal, defaultHabitDailyGoal);
    });

    test('negative goal below min normalizes to negative default', () {
      final data = NegativeHabitDailyGoalData(dailyGoal: minHabitDailyGoal - 1);

      expect(data.isGoalValid, isFalse);
      expect(data.normalizedGoal, defaultNegativeHabitDailyGoal);
    });

    test('goals above max normalize to max for both types', () {
      final positive = PositiveHabitDailyGoalData(
        dailyGoal: maxHabitdailyGoal + 1,
      );
      final negative = NegativeHabitDailyGoalData(
        dailyGoal: maxHabitdailyGoal + 1,
      );

      expect(positive.isGoalValid, isFalse);
      expect(positive.normalizedGoal, maxHabitdailyGoal);
      expect(negative.isGoalValid, isFalse);
      expect(negative.normalizedGoal, maxHabitdailyGoal);
    });

    test('in-range goals stay valid and unchanged', () {
      final positive = PositiveHabitDailyGoalData(dailyGoal: 5);
      final negative = NegativeHabitDailyGoalData(dailyGoal: 5);

      expect(positive.isGoalValid, isTrue);
      expect(positive.normalizedGoal, 5);
      expect(negative.isGoalValid, isTrue);
      expect(negative.normalizedGoal, 5);
    });
  });
}

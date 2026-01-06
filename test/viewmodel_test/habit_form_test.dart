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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/common/exceptions.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/providers/habit_form.dart';

void main() {
  HabitFormViewModel getMockViewModel() {
    return HabitFormViewModel();
  }

  group("HabitFormViewModel:API", () {
    test('name', () {
      final provider = getMockViewModel();
      expect(provider.name, '');
      provider.addListener(() async {
        expect(provider.name, 'test');
      });
      provider.name = "test";
      provider.dispose();
    });
    test('colorType', () {
      final provider = getMockViewModel();
      expect(provider.colorType, defaultHabitColorType);
      provider.addListener(() async {
        expect(provider.colorType, HabitColorType.cc5);
      });
      provider.colorType = HabitColorType.cc5;
    });
    test('dailyGoal', () {
      final provider = getMockViewModel();
      expect(provider.dailyGoalValue, defaultHabitDailyGoal);
      provider.addListener(() async {
        expect(provider.dailyGoalValue, 10.5);
      });
      provider.dailyGoalValue = 10.5;
    });
    test('dailyGoalUnit', () {
      final provider = getMockViewModel();
      expect(provider.dailyGoalUnit, defaultHabitDailyGoalUnit);
      provider.addListener(() async {
        expect(provider.dailyGoalUnit, 'test');
      });
      provider.dailyGoalUnit = 'test';
    });
    test('dailyFrequency', () {
      final provider = getMockViewModel();
      expect(provider.frequency, HabitFrequency.daily);
      provider.addListener(() async {
        expect(
          provider.frequency,
          const HabitFrequency(type: HabitFrequencyType.monthly, freq: 10),
        );
      });
      provider.frequency = const HabitFrequency.monthly(freq: 10);
    });
    test('dailyStartDate', () {
      final provider = getMockViewModel();
      expect(
        provider.startDate == HabitStartDate.dateTime(DateTime.now()),
        true,
      );
      final newDate = HabitStartDate.dateTime(DateTime(2020, 1, 20));
      provider.addListener(() async {
        expect(provider.startDate == newDate, true);
      });
      provider.startDate = newDate;
    });
    test('dailyTargetDays', () {
      final provider = getMockViewModel();
      expect(provider.targetDays, defaultHabitTargetDays);
      provider.addListener(() async {
        expect(provider.targetDays, 300);
      });
      provider.targetDays = 300;
    });
    test('dailyDescribtion', () {
      final provider = getMockViewModel();
      expect(provider.desc, '');
      provider.addListener(() async {
        expect(provider.desc, 'test');
      });
      provider.desc = 'test';
    });
  });
  group("HabitFrequency", () {
    test("Constructor", () {
      const obj = HabitFrequency(
        type: HabitFrequencyType.custom,
        freq: 1,
        days: 2,
      );
      expect(obj.freq, 1);
      expect(obj.days, 2);
      expect(obj.type, HabitFrequencyType.custom);
    });
    test("Constructor.daily", () {
      final obj1 = HabitFrequency.custom(days: 5, freq: 2);
      expect(obj1.freq, 2);
      expect(obj1.days, 5);
      expect(obj1.type, HabitFrequencyType.custom);
      final obj2 = HabitFrequency.custom(days: 5, freq: 5);
      expect(obj2.freq, 1);
      expect(obj2.days, 1);
      expect(obj2.type, HabitFrequencyType.custom);
    });
    test("Constructor.weekly", () {
      const obj = HabitFrequency.weekly(freq: 2);
      expect(obj.freq, 2);
      expect(obj.days, 0);
      expect(obj.type, HabitFrequencyType.weekly);
    });
    test("Constructor.monthly", () {
      const obj = HabitFrequency.monthly(freq: 10);
      expect(obj.freq, 10);
      expect(obj.days, 0);
      expect(obj.type, HabitFrequencyType.monthly);
    });
    test("==override", () {
      const obj1 = HabitFrequency(
        type: HabitFrequencyType.custom,
        freq: 1,
        days: 2,
      );
      const obj2 = HabitFrequency(
        type: HabitFrequencyType.custom,
        freq: 1,
        days: 2,
      );
      const obj3 = HabitFrequency(
        type: HabitFrequencyType.custom,
        freq: 1,
        days: 3,
      );
      // hashcode
      expect(obj1.hashCode, obj2.hashCode);
      // ==
      expect(obj1 == 1, false); // ignore: unrelated_type_equality_checks
      expect(obj1 == const HabitFrequency.monthly(), false);
      expect(obj1 == obj2, true);
      expect(obj1 == obj3, false);

      const obj4 = HabitFrequency.monthly(freq: 1);
      const obj5 = HabitFrequency.weekly(freq: 1);
      const obj6 = HabitFrequency.monthly(freq: 2);
      // hascode
      expect(
        obj4.hashCode,
        const HabitFrequency(
          type: HabitFrequencyType.monthly,
          freq: 1,
        ).hashCode,
      );
      // ==
      expect(obj4 == obj5, false);
      expect(obj5 == obj6, false);
      expect(obj4 == obj6, false);
      expect(
        obj4 == const HabitFrequency(type: HabitFrequencyType.monthly, freq: 1),
        true,
      );
    });
    test('toString', () {
      expect(const HabitFrequency.weekly().toString(), "Per week");
      expect(
        const HabitFrequency.weekly(freq: 3).toString(),
        "At least 3 times per week",
      );
      expect(const HabitFrequency.monthly().toString(), "Per month");
      expect(
        const HabitFrequency.monthly(freq: 3).toString(),
        "At least 3 times per month",
      );
      expect(HabitFrequency.custom().toString(), "Daily");
      expect(HabitFrequency.custom(days: 3).toString(), "In every 3 days");
      expect(
        HabitFrequency.custom(freq: 2, days: 3).toString(),
        "At least 2 times in every 3 days",
      );
    });
    test('toMap:monthly', () {
      const obj2 = HabitFrequency.monthly(freq: 3);
      final obj2map = obj2.toJson();
      expect(obj2map['type'], HabitFrequencyType.monthly.dbCode);
      expect((obj2map['args'] as List).length, 1);
      expect(obj2map['args'][0], 3);
    });
    test('toMap:weekly', () {
      const obj3 = HabitFrequency.weekly(freq: 1);
      final obj3map = obj3.toJson();
      expect(obj3map['type'], HabitFrequencyType.weekly.dbCode);
      expect((obj3map['args'] as List).length, 1);
      expect(obj3map['args'][0], 1);
    });
    test('toMap:daily', () {
      final obj1 = HabitFrequency.custom(days: 5, freq: 2);
      final obj1map = obj1.toJson();
      expect(obj1map['type'], HabitFrequencyType.custom.dbCode);
      expect((obj1map['args'] as List).length, 2);
      expect(obj1map['args'][0], 2);
      expect(obj1map['args'][1], 5);
    });
    test('toMapError', () {
      const obj = HabitFrequency(type: HabitFrequencyType.unknown, freq: 0);
      expect(() => obj.toJson(), throwsA(isA<UnknownHabitFrequencyError>()));
    });
    test('fromMap:monthly', () {
      final data1 = {
        "type": HabitFrequencyType.monthly.dbCode,
        "args": [10],
      };
      final obj1 = HabitFrequency.fromJson(data1);
      expect(obj1.type, HabitFrequencyType.monthly);
      expect(obj1.freq, 10);
    });
    test('fromMap:weekly', () {
      final data1 = {
        "type": HabitFrequencyType.weekly.dbCode,
        "args": [5],
      };
      final obj1 = HabitFrequency.fromJson(data1);
      expect(obj1.type, HabitFrequencyType.weekly);
      expect(obj1.freq, 5);
    });
    test('fromMap:custom', () {
      final data1 = {
        "type": HabitFrequencyType.custom.dbCode,
        "args": [2, 10],
      };
      final obj1 = HabitFrequency.fromJson(data1);
      expect(obj1.type, HabitFrequencyType.custom);
      expect(obj1.freq, 2);
      expect(obj1.days, 10);
    });
    test('fromMap:error', () {
      final data1 = {
        "type": HabitFrequencyType.unknown.dbCode,
        "args": [1],
      };
      expect(
        () => HabitFrequency.fromJson(data1),
        throwsA(isA<UnknownHabitFrequencyError>()),
      );
    });
  });
}

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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_group_display.dart';

void main() {
  group('HabitGroupOrderType.fromGroupType', () {
    test('manual maps to HabitGroupOrderType.manual', () {
      expect(
        HabitGroupOrderType.fromGroupType(HabitDisplayGroupType.manual),
        HabitGroupOrderType.manual,
      );
    });

    test('habitCount returns null (extrinsic type)', () {
      expect(
        HabitGroupOrderType.fromGroupType(HabitDisplayGroupType.habitCount),
        isNull,
      );
    });

    test('name maps to HabitGroupOrderType.name', () {
      expect(
        HabitGroupOrderType.fromGroupType(HabitDisplayGroupType.name),
        HabitGroupOrderType.name,
      );
    });

    test('colorType maps to HabitGroupOrderType.colorType', () {
      expect(
        HabitGroupOrderType.fromGroupType(HabitDisplayGroupType.colorType),
        HabitGroupOrderType.colorType,
      );
    });

    test('createDate maps to HabitGroupOrderType.createDate', () {
      expect(
        HabitGroupOrderType.fromGroupType(HabitDisplayGroupType.createDate),
        HabitGroupOrderType.createDate,
      );
    });
  });

  group('HabitDisplayGroupType.menuOrderedList includes manual', () {
    test('manual is in menuOrderedList', () {
      expect(
        HabitDisplayGroupType.menuOrderedList,
        contains(HabitDisplayGroupType.manual),
      );
    });

    test('menuOrderedList has 5 entries', () {
      expect(HabitDisplayGroupType.menuOrderedList.length, 5);
    });
  });
}

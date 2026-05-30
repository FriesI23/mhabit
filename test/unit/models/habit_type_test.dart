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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mhabit/models/habit_form.dart';

void main() {
  group('Habit form enum DB code lookups', () {
    test('return matching values for known DB codes', () {
      expect(HabitType.getFromDBCode(1), HabitType.normal);
      expect(HabitStatus.getFromDBCode(3), HabitStatus.archived);
      expect(HabitColorType.getFromDBCode(5), HabitColorType.cc5);
      expect(HabitFrequencyType.getFromDBCode(2), HabitFrequencyType.monthly);
      expect(HabitRecordStatus.getFromDBCode(2), HabitRecordStatus.skip);
    });

    test('return provided defaults for unknown DB codes', () {
      expect(
        HabitType.getFromDBCode(99, withDefault: HabitType.negative),
        HabitType.negative,
      );
      expect(
        HabitStatus.getFromDBCode(99, withDefault: HabitStatus.deleted),
        HabitStatus.deleted,
      );
      expect(
        HabitColorType.getFromDBCode(99, withDefault: HabitColorType.cc10),
        HabitColorType.cc10,
      );
      expect(
        HabitFrequencyType.getFromDBCode(
          99,
          withDefault: HabitFrequencyType.custom,
        ),
        HabitFrequencyType.custom,
      );
      expect(
        HabitRecordStatus.getFromDBCode(
          99,
          withDefault: HabitRecordStatus.done,
        ),
        HabitRecordStatus.done,
      );
    });
  });

  group('HabitType.icon', () {
    test('unknown and normal use outline icon', () {
      expect(HabitType.unknown.icon, MdiIcons.circleOutline);
      expect(HabitType.normal.icon, MdiIcons.circleOutline);
    });

    test('negative uses off outline icon', () {
      expect(HabitType.negative.icon, MdiIcons.circleOffOutline);
    });
  });
}

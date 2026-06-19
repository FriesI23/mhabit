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
import 'package:mhabit/models/_app_sync_tasks/webdav_app_sync_models.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';

void main() {
  group('WebDavSyncHabitData custom_color', () {
    test('fromJson on legacy payload without custom_color key', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc3.dbCode,
      });
      expect(data.customColor, isNull);
      expect(data.color, HabitColorType.cc3.dbCode);
    });

    test('fromHabitDBCell: custom color round-trips through DB cell', () {
      const argb = 0xFF123456;
      final cell = HabitDBCell(
        color: HabitColorType.cc1.dbCode,
        customColor: argb,
      );
      final data = WebDavSyncHabitData.fromHabitDBCell(cell);

      expect(data.customColor, argb);
      expect(data.color, isNull);

      final json = data.toJson();
      final restored = WebDavSyncHabitData.fromJson(json);
      expect(restored.customColor, argb);
      expect(restored.color, isNull);

      final restoredCell = restored.toHabitDBCell();
      expect(restoredCell.customColor, argb);
      expect(restoredCell.color, HabitColorType.cc1.dbCode);
    });

    test('fromHabitDBCell: built-in color round-trips through DB cell', () {
      final cell = HabitDBCell(
        color: HabitColorType.cc5.dbCode,
        customColor: null,
      );
      final data = WebDavSyncHabitData.fromHabitDBCell(cell);

      expect(data.customColor, isNull);
      expect(data.color, HabitColorType.cc5.dbCode);

      final json = data.toJson();
      final restored = WebDavSyncHabitData.fromJson(json);
      expect(restored.customColor, isNull);
      expect(restored.color, HabitColorType.cc5.dbCode);

      final restoredCell = restored.toHabitDBCell();
      expect(restoredCell.customColor, isNull);
      expect(restoredCell.color, HabitColorType.cc5.dbCode);
    });

    test('validate() does not throw for a custom-color habit', () {
      final cell = HabitDBCell(
        color: HabitColorType.cc1.dbCode,
        customColor: 0xFFABCDEF,
      );
      final data = WebDavSyncHabitData.fromHabitDBCell(cell);
      expect(data.validate, returnsNormally);
    });
  });

  group('WebDavSyncHabitData schema_version', () {
    test('fromJson on legacy payload without _schema_version key', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc3.dbCode,
      });
      expect(data.schemaVersion, 1);
    });

    test('toJson omits _schema_version when schemaVersion == 1', () {
      const data = WebDavSyncHabitData(schemaVersion: 1);
      expect(data.toJson(), isNot(contains('_schema_version')));
    });

    test('toJson includes _schema_version when schemaVersion >= 2', () {
      const data = WebDavSyncHabitData(
        schemaVersion: WebDavSyncHabitData.currentSchemaVersion,
      );
      expect(data.toJson()['_schema_version'], 2);
    });

    test('fromHabitDBCell stamps currentSchemaVersion', () {
      final cell = HabitDBCell(color: HabitColorType.cc5.dbCode);
      final data = WebDavSyncHabitData.fromHabitDBCell(cell);
      expect(data.schemaVersion, WebDavSyncHabitData.currentSchemaVersion);
    });

    test('validate() does not throw for a future schema version', () {
      const data = WebDavSyncHabitData(schemaVersion: 99);
      expect(data.validate, returnsNormally);
    });
  });
}

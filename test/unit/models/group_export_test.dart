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
import 'package:mhabit/models/group.dart';
import 'package:mhabit/models/group_export.dart';

void main() {
  group('GroupExportData', () {
    test('fromGroupDBCell → toJson → fromJson round-trip', () {
      const cell = GroupDBCell(
        uuid: 'g-uuid-1',
        name: 'Work',
        desc: 'Work habits',
        icon: 42,
        color: 5,
        customColor: null,
        customColorTinted: null,
      );

      final exportData = GroupExportData.fromGroupDBCell(cell);
      expect(exportData.uuid, 'g-uuid-1');
      expect(exportData.name, 'Work');
      expect(exportData.desc, 'Work habits');
      expect(exportData.icon, 42);
      expect(exportData.color, 5);

      final json = exportData.toJson();
      final roundTripped = GroupExportData.fromJson(json);
      expect(roundTripped.uuid, 'g-uuid-1');
      expect(roundTripped.name, 'Work');
      expect(roundTripped.desc, 'Work habits');
      expect(roundTripped.icon, 42);
      expect(roundTripped.color, 5);
    });

    test('fromGroupDBCell with custom color round-trip', () {
      const cell = GroupDBCell(
        uuid: 'g-uuid-2',
        name: 'Health',
        icon: 1,
        color: 1,
        customColor: 0xFFAABBCC,
        customColorTinted: 0,
      );

      final exportData = GroupExportData.fromGroupDBCell(cell);
      final json = exportData.toJson();
      final roundTripped = GroupExportData.fromJson(json);

      expect(roundTripped.color, 1);
      expect(roundTripped.customColor, 0xFFAABBCC);
      expect(roundTripped.customColorTinted, 0);
    });

    test('null fields are excluded from JSON (includeIfNull: false)', () {
      const cell = GroupDBCell(uuid: 'g-uuid-3', name: 'Minimal');

      final exportData = GroupExportData.fromGroupDBCell(cell);
      final json = exportData.toJson();

      expect(json.containsKey('desc'), isFalse);
      expect(json.containsKey('icon'), isFalse);
      expect(json.containsKey('color'), isFalse);
      expect(json.containsKey('custom_color'), isFalse);
    });

    test('fromJson with partial data (backward compat)', () {
      final json = {'uuid': 'g-uuid-4', 'name': 'Old Group'};

      final data = GroupExportData.fromJson(json);
      expect(data.uuid, 'g-uuid-4');
      expect(data.name, 'Old Group');
      expect(data.desc, isNull);
      expect(data.icon, isNull);
      expect(data.color, isNull);
    });
  });
}

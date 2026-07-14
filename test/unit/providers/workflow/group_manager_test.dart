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

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/group.dart';
import 'package:mhabit/providers/workflow/group_manager.dart';
import 'package:mhabit/storage/db_helper_provider.dart';

void main() {
  late DBHelperViewModel viewModel;
  late GroupManager manager;

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    viewModel = DBHelperViewModel();
    await viewModel.init();
    addTearDown(viewModel.dispose);

    manager = GroupManager()..updateDBHelper(viewModel);
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('GroupManager', () {
    test('loadAllActiveGroups: returns empty list initially', () async {
      final groups = await manager.loadAllActiveGroups();
      expect(groups, isEmpty);
    });

    test('createGroup: throws ArgumentError for empty name', () {
      expect(() => manager.createGroup(name: ''), throwsArgumentError);
    });

    test('createGroup: throws ArgumentError for whitespace-only name', () {
      expect(() => manager.createGroup(name: '   '), throwsArgumentError);
    });

    test('createGroup: creates a group and returns it', () async {
      final cell = await manager.createGroup(name: 'Work');

      expect(cell.uuid, isNotNull);
      expect(cell.name, 'Work');
      expect(cell.desc, isNull);
      expect(cell.icon, isNull);
      expect(cell.color, isNull);
      expect(cell.customColor, isNull);
      expect(cell.customColorTinted, isNull);
    });

    test('createGroup: creates a group with all optional fields', () async {
      final cell = await manager.createGroup(
        name: 'Health',
        desc: 'Health-related habits',
        icon: 0xe80f, // Icons.favorite
      );

      expect(cell.uuid, isNotNull);
      expect(cell.name, 'Health');
      expect(cell.desc, 'Health-related habits');
      expect(cell.icon, 0xe80f);
    });

    test('loadAllActiveGroups: returns created groups', () async {
      await manager.createGroup(name: 'A');
      await manager.createGroup(name: 'B');

      final groups = await manager.loadAllActiveGroups();
      expect(groups.length, 2);
      expect(groups.map((g) => g.name), containsAll(['A', 'B']));
    });

    test('updateGroup: modifies group name', () async {
      final cell = await manager.createGroup(name: 'OldName');
      await manager.updateGroup(cell.copyWith(name: 'NewName'));

      final groups = await manager.loadAllActiveGroups();
      expect(groups.length, 1);
      expect(groups.first.name, 'NewName');
    });

    test('deleteGroup: removes group from list', () async {
      final cell = await manager.createGroup(name: 'Temp');

      await manager.deleteGroup(cell.uuid!);
      final groups = await manager.loadAllActiveGroups();
      expect(groups, isEmpty);
    });
  });
}

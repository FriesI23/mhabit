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
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_color_type.dart';
import 'package:mhabit/models/habit_group.dart';
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
      final data = await manager.createGroup(name: 'Work');

      expect(data.uuid, isNotNull);
      expect(data.name, 'Work');
      expect(data.desc, '');
      expect(data.icon, isNull);
      expect(data.color, isNull);
    });

    test('createGroup: creates a group with all optional fields', () async {
      final data = await manager.createGroup(
        name: 'Health',
        desc: 'Health-related habits',
        icon: GroupIcon.folder,
      );

      expect(data.uuid, isNotNull);
      expect(data.name, 'Health');
      expect(data.desc, 'Health-related habits');
      expect(data.icon, GroupIcon.folder);
    });

    test('loadAllActiveGroups: returns created groups', () async {
      await manager.createGroup(name: 'A');
      await manager.createGroup(name: 'B');

      final groups = await manager.loadAllActiveGroups();
      expect(groups.length, 2);
      expect(groups.map((g) => g.name), containsAll(['A', 'B']));
    });

    test('updateGroupData: modifies group name', () async {
      final data = await manager.createGroup(name: 'OldName');
      await manager.updateGroupData(uuid: data.uuid, name: 'NewName');

      final reloaded = await manager.loadGroupDataByUUID(data.uuid);
      expect(reloaded?.name, 'NewName');
    });

    test('deleteGroup: removes group from list', () async {
      final data = await manager.createGroup(name: 'Temp');

      await manager.deleteGroup(data.uuid);
      final groups = await manager.loadAllActiveGroups();
      expect(groups, isEmpty);
    });

    test('updateGroupData: modifies group description', () async {
      final data = await manager.createGroup(name: 'Test', desc: 'Old desc');

      await manager.updateGroupData(
        uuid: data.uuid,
        name: data.name,
        desc: 'New desc',
      );

      final reloaded = await manager.loadGroupDataByUUID(data.uuid);
      expect(reloaded?.desc, 'New desc');
    });

    test(
      'updateGroupData: leaves desc unchanged when given empty string',
      () async {
        final data = await manager.createGroup(name: 'Test', desc: 'Some desc');

        await manager.updateGroupData(
          uuid: data.uuid,
          name: data.name,
          desc: '',
        );

        // desc: null is dropped by generated toJson, so DB column stays unchanged.
        final reloaded = await manager.loadGroupDataByUUID(data.uuid);
        expect(reloaded?.desc, 'Some desc');
      },
    );

    test('updateGroupData: clears icon when given null', () async {
      final data = await manager.createGroup(
        name: 'Test',
        icon: GroupIcon.folder,
      );
      expect(data.icon, GroupIcon.folder);

      await manager.updateGroupData(
        uuid: data.uuid,
        name: data.name,
        icon: null,
      );

      final reloaded = await manager.loadGroupDataByUUID(data.uuid);
      expect(reloaded?.icon, isNull);
    });

    test('updateGroupData: updates icon to a different value', () async {
      final data = await manager.createGroup(
        name: 'Test',
        icon: GroupIcon.folder,
      );
      expect(data.icon, GroupIcon.folder);

      await manager.updateGroupData(
        uuid: data.uuid,
        name: data.name,
        icon: GroupIcon.star,
      );

      final reloaded = await manager.loadGroupDataByUUID(data.uuid);
      expect(reloaded?.icon, GroupIcon.star);
    });

    test('updateGroupData: updates color to built-in color', () async {
      final data = await manager.createGroup(
        name: 'Test',
        color: const HabitColor.builtIn(HabitColorType.cc1),
      );
      expect(data.color, const HabitColor.builtIn(HabitColorType.cc1));

      await manager.updateGroupData(
        uuid: data.uuid,
        name: data.name,
        color: const HabitColor.builtIn(HabitColorType.cc3),
      );

      final reloaded = await manager.loadGroupDataByUUID(data.uuid);
      expect(reloaded?.color, const HabitColor.builtIn(HabitColorType.cc3));
    });

    test('restoreGroup: restores soft-deleted group to active', () async {
      final data = await manager.createGroup(name: 'Restorable');
      await manager.deleteGroup(data.uuid);

      final afterDelete = await manager.loadAllActiveGroups();
      expect(afterDelete, isEmpty);

      await manager.restoreGroup(data.uuid);

      final afterRestore = await manager.loadAllActiveGroups();
      expect(afterRestore.length, 1);
      expect(afterRestore.first.name, 'Restorable');
    });

    test('restoreGroup: no-op when group not found', () async {
      await manager.restoreGroup('nonexistent-uuid');

      final groups = await manager.loadAllActiveGroups();
      expect(groups, isEmpty);
    });

    test(
      'loadGroupDataByUUID: returns domain model for existing group',
      () async {
        final data = await manager.createGroup(
          name: 'Lookup',
          icon: GroupIcon.star,
        );

        final loaded = await manager.loadGroupDataByUUID(data.uuid);
        expect(loaded, isNotNull);
        expect(loaded!.uuid, data.uuid);
        expect(loaded.name, 'Lookup');
        expect(loaded.icon, GroupIcon.star);
      },
    );

    test('loadGroupDataByUUID: returns null for unknown uuid', () async {
      final loaded = await manager.loadGroupDataByUUID('nonexistent');
      expect(loaded, isNull);
    });

    test('tryLoadGroupCollection: returns GroupCollection', () async {
      await manager.createGroup(name: 'G1');
      await manager.createGroup(name: 'G2');

      final collection = await manager.tryLoadGroupCollection();
      expect(collection, isNotNull);
      expect(collection!.toList().length, 2);
    });

    test(
      'tryLoadGroupCollection: returns empty collection when no groups',
      () async {
        final collection = await manager.tryLoadGroupCollection();
        expect(collection, isNotNull);
        expect(collection!.toList().length, 0);
      },
    );

    test('createGroup: clamps name longer than 100 chars', () async {
      final longName = 'A' * 150;
      final data = await manager.createGroup(name: longName);

      expect(data.name.length, 100);
      expect(data.name, startsWith('AAA'));
    });

    test('createGroup: clamps desc longer than 300 chars', () async {
      final longDesc = 'B' * 500;
      final data = await manager.createGroup(name: 'Test', desc: longDesc);

      expect(data.desc.length, 300);
      expect(data.desc, startsWith('BBB'));
    });

    test(
      'importGroupsData: imported groups get DB default sortPosition',
      () async {
        final mapping = await manager.importGroupsData([
          <String, dynamic>{
            'uuid': 'old-uuid-1',
            'name': 'Imported Group',
            'sort_position': 3.75, // ignored — not metadata
          },
        ]);

        expect(mapping, hasLength(1));
        final newUuid = mapping['old-uuid-1'];
        expect(newUuid, isNotNull);

        final cell = await manager.loadGroupByUUID(newUuid!);
        expect(cell, isNotNull);
        // Import no longer preserves sortPosition; DB trigger sets it to id_.
        expect(cell!.sortPosition, 1);
      },
    );

    // ── fixAndSaveSortPositions ──────────────────────────────────────

    test('fixAndSaveSortPositions: empty list returns empty', () async {
      final result = await manager.fixAndSaveSortPositions(
        [],
        increaseStep: 0.000001,
        decimalPlaces: 6,
      );
      expect(result, isEmpty);
    });

    test('fixAndSaveSortPositions: single item returns empty', () async {
      final g = await manager.createGroup(name: 'Solo');
      final result = await manager.fixAndSaveSortPositions(
        [g],
        increaseStep: 0.000001,
        decimalPlaces: 6,
      );
      expect(result, isEmpty);
    });

    test(
      'fixAndSaveSortPositions: already-ordered items return empty',
      () async {
        final g1 = await manager.createGroup(name: 'A');
        final g2 = await manager.createGroup(name: 'B');
        final g3 = await manager.createGroup(name: 'C');
        // sortPositions are naturally increasing (id-based).

        final result = await manager.fixAndSaveSortPositions(
          [g1, g2, g3],
          increaseStep: 0.000001,
          decimalPlaces: 6,
        );
        expect(result, isEmpty);
      },
    );

    test(
      'fixAndSaveSortPositions: resolves duplicate sort positions',
      () async {
        final g1 = await manager.createGroup(name: 'A');
        final g2 = await manager.createGroup(name: 'B');
        // Force both to the same sort_position.
        await manager.groupDBHelper.updateSelectedGroupsSortPosition(
          [g1.uuid, g2.uuid],
          [10.0, 10.0],
        );

        // Re-read to get updated sortPosition values.
        final r1 = await manager.loadGroupDataByUUID(g1.uuid);
        final r2 = await manager.loadGroupDataByUUID(g2.uuid);
        expect(r1!.sortPosition, 10.0);
        expect(r2!.sortPosition, 10.0);

        final result = await manager.fixAndSaveSortPositions(
          [r1, r2],
          increaseStep: 0.000001,
          decimalPlaces: 6,
        );
        expect(result, isNotEmpty);

        // Verify DB was updated.
        final c1 = await manager.loadGroupByUUID(g1.uuid);
        final c2 = await manager.loadGroupByUUID(g2.uuid);
        expect(c1!.sortPosition, isNot(c2!.sortPosition));
      },
    );

    test('fixAndSaveSortPositions: re-sorts out-of-order items', () async {
      final g1 = await manager.createGroup(name: 'A');
      final g2 = await manager.createGroup(name: 'B');
      final g3 = await manager.createGroup(name: 'C');
      // g2, g3, g1 is out of order (sortPositions are 1,2,3 but we
      // passed them in reverse).
      final result = await manager.fixAndSaveSortPositions(
        [g3, g2, g1],
        increaseStep: 0.000001,
        decimalPlaces: 6,
      );
      // The items need re-assignment because g3.sortPosition > g1.sortPosition
      // but g3 comes first in the desired order, so g3..sortPosition must be
      // the smallest.
      expect(result, isNotEmpty);
      expect(result.length, greaterThanOrEqualTo(1));

      // Verify DB now has monotonically increasing values in g3,g2,g1 order.
      final c3 = await manager.loadGroupByUUID(g3.uuid);
      final c2 = await manager.loadGroupByUUID(g2.uuid);
      final c1 = await manager.loadGroupByUUID(g1.uuid);
      expect(c3!.sortPosition! < c2!.sortPosition!, isTrue);
      expect(c2.sortPosition! < c1!.sortPosition!, isTrue);
    });
  });
}

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
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/models/app_event.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_color_type.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_group_display.dart';
import 'package:mhabit/pages/group_manage/_providers/group_manage.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/group_manager.dart';
import 'package:mhabit/storage/db_helper_provider.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProfileViewModel> _loadProfile() async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel([DisplayGroupModeProfileHandler.new]);
  await profile.init();
  return profile;
}

void main() {
  group('GroupManageViewModel selection mode', () {
    late GroupManageViewModel vm;

    setUp(() {
      vm = GroupManageViewModel();
    });

    tearDown(() {
      vm.dispose();
    });

    test('enterSelectionMode: sets selectionMode and adds uuid', () {
      vm.enterSelectionMode('uuid-1');

      expect(vm.selectionMode, isTrue);
      expect(vm.selectedUUIDs, contains('uuid-1'));
      expect(vm.selectedCount, 1);
    });

    test('exitSelectionMode: clears selectionMode and selectedUUIDs', () {
      vm.enterSelectionMode('uuid-1');
      vm.exitSelectionMode();

      expect(vm.selectionMode, isFalse);
      expect(vm.selectedUUIDs, isEmpty);
    });

    test('toggleSelection: adds uuid when not in set', () {
      vm.enterSelectionMode('uuid-1');
      vm.toggleSelection('uuid-2');

      expect(vm.selectedUUIDs, containsAll(['uuid-1', 'uuid-2']));
      expect(vm.selectedCount, 2);
    });

    test('toggleSelection: removes uuid when already in set', () {
      vm.enterSelectionMode('uuid-1');
      vm.toggleSelection('uuid-2');
      vm.toggleSelection('uuid-1');

      expect(vm.selectedUUIDs, contains('uuid-2'));
      expect(vm.selectedUUIDs, isNot(contains('uuid-1')));
      expect(vm.selectedCount, 1);
    });

    test('toggleSelection: no-op when selectionMode is false', () {
      vm.toggleSelection('uuid-1');

      expect(vm.selectionMode, isFalse);
      expect(vm.selectedUUIDs, isEmpty);
    });

    test('isSelected: returns correct boolean', () {
      vm.enterSelectionMode('uuid-1');

      expect(vm.isSelected('uuid-1'), isTrue);
      expect(vm.isSelected('uuid-2'), isFalse);
    });
  });

  group('GroupManageViewModel sort options', () {
    late DBHelperViewModel dbHelper;
    late GroupManager manager;
    late GroupManageViewModel vm;
    late ProfileViewModel profile;
    late AppEventBus eventBus;

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      dbHelper = DBHelperViewModel();
      await dbHelper.init();
      manager = GroupManager()..updateDBHelper(dbHelper);

      profile = await _loadProfile();
      eventBus = AppEventBus();

      vm = GroupManageViewModel()
        ..attachGroupManager(manager)
        ..updateProfile(profile)
        ..updateAppEvent(eventBus);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      vm.dispose();
      profile.dispose();
      eventBus.dispose();
      dbHelper.dispose();
    });

    test(
      'setSortOptions: updates session sortType and sortDirection',
      () async {
        await manager.createGroup(name: 'A');
        await vm.loadGroups(listen: false);

        vm.setSortOptions(
          HabitDisplayGroupType.createDate,
          HabitDisplaySortDirection.desc,
        );

        expect(vm.sortType, HabitDisplayGroupType.createDate);
        expect(vm.sortDirection, HabitDisplaySortDirection.desc);
        expect(vm.effectiveSortType, HabitDisplayGroupType.createDate);
        expect(vm.effectiveSortDirection, HabitDisplaySortDirection.desc);
      },
    );

    test(
      'effectiveSortType: falls back to default when session is null',
      () async {
        await manager.createGroup(name: 'A');
        await vm.loadGroups(listen: false);

        expect(vm.sortType, isNull);
        expect(vm.effectiveSortType, defaultGroupType);
      },
    );

    test('effectiveSortDirection: falls back to default', () async {
      await manager.createGroup(name: 'A');
      await vm.loadGroups(listen: false);

      expect(vm.sortDirection, isNull);
      expect(vm.effectiveSortDirection, defaultGroupSortDirection);
    });

    test('groups: sorted by name ascending after loadGroups', () async {
      await manager.createGroup(name: 'Banana');
      await manager.createGroup(name: 'Apple');
      await vm.loadGroups(listen: false);

      vm.setSortOptions(
        HabitDisplayGroupType.name,
        HabitDisplaySortDirection.asc,
      );

      final names = vm.groups.map((g) => g.name).toList();
      expect(names, ['Apple', 'Banana']);
    });

    test('groups: sorted by name descending', () async {
      await manager.createGroup(name: 'Apple');
      await manager.createGroup(name: 'Banana');
      await vm.loadGroups(listen: false);

      vm.setSortOptions(
        HabitDisplayGroupType.name,
        HabitDisplaySortDirection.desc,
      );

      final names = vm.groups.map((g) => g.name).toList();
      expect(names, ['Banana', 'Apple']);
    });

    test(
      'groups: colorType sort: null-color groups after colored groups',
      () async {
        await manager.createGroup(
          name: 'A-Color',
          color: const HabitColor.builtIn(HabitColorType.cc1),
        );
        await manager.createGroup(name: 'B-NoColor');
        await vm.loadGroups(listen: false);

        vm.setSortOptions(
          HabitDisplayGroupType.colorType,
          HabitDisplaySortDirection.asc,
        );

        final names = vm.groups.map((g) => g.name).toList();
        expect(names.first, 'A-Color');
        expect(names.last, 'B-NoColor');
      },
    );
  });

  group('GroupManageViewModel event-driven reload', () {
    late DBHelperViewModel dbHelper;
    late GroupManager manager;
    late GroupManageViewModel vm;
    late ProfileViewModel profile;
    late AppEventBus eventBus;

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      dbHelper = DBHelperViewModel();
      await dbHelper.init();
      manager = GroupManager()..updateDBHelper(dbHelper);

      profile = await _loadProfile();
      eventBus = AppEventBus();

      vm = GroupManageViewModel()
        ..attachGroupManager(manager)
        ..updateProfile(profile)
        ..updateAppEvent(eventBus);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      vm.dispose();
      profile.dispose();
      eventBus.dispose();
      dbHelper.dispose();
    });

    test('GroupChangedEvent triggers consumeForceReloadFlag', () async {
      expect(vm.consumeForceReloadFlag(), isFalse);

      eventBus.push(
        const GroupChangedEvent(
          msg: 'test',
          groupUUID: 'g1',
          changeType: GroupChangeType.created,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(vm.consumeForceReloadFlag(), isTrue);
      expect(vm.consumeForceReloadFlag(), isFalse);
    });

    test(
      'ReloadDataEvent from groupManage source does NOT set reload flag',
      () async {
        expect(vm.consumeForceReloadFlag(), isFalse);

        eventBus.push(
          const ReloadDataEvent(
            trace: {
              AppEventPageSource.groupManage: {
                AppEventFunctionSource.groupChanged,
              },
            },
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // Own trace → no reload.
        expect(vm.consumeForceReloadFlag(), isFalse);
      },
    );

    test('ReloadDataEvent without own trace sets reload flag', () async {
      expect(vm.consumeForceReloadFlag(), isFalse);

      eventBus.push(const ReloadDataEvent(clearSnackBar: true));
      await Future<void>.delayed(Duration.zero);

      // No trace → reload triggered.
      expect(vm.consumeForceReloadFlag(), isTrue);
    });
  });

  group('GroupManageViewModel CRUD routing', () {
    late DBHelperViewModel dbHelper;
    late GroupManager manager;
    late GroupManageViewModel vm;
    late ProfileViewModel profile;
    late AppEventBus eventBus;

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      dbHelper = DBHelperViewModel();
      await dbHelper.init();
      manager = GroupManager()..updateDBHelper(dbHelper);

      profile = await _loadProfile();
      eventBus = AppEventBus();

      vm = GroupManageViewModel()
        ..attachGroupManager(manager)
        ..updateProfile(profile)
        ..updateAppEvent(eventBus);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      vm.dispose();
      profile.dispose();
      eventBus.dispose();
      dbHelper.dispose();
    });

    test('createGroup: delegates to GroupManager and pushes event', () async {
      final result = await vm.createGroup(name: 'NewGroup');

      expect(result.name, 'NewGroup');
      expect(vm.consumeForceReloadFlag(), isTrue);

      final loaded = await manager.loadGroupDataByUUID(result.uuid);
      expect(loaded, isNotNull);
      expect(loaded!.name, 'NewGroup');
    });

    test(
      'createGroup: throws StateError when GroupManager not attached',
      () async {
        final detached = GroupManageViewModel();
        addTearDown(detached.dispose);

        expect(() => detached.createGroup(name: 'Test'), throwsStateError);
      },
    );

    test('updateGroup: delegates to GroupManager.updateGroupData', () async {
      final created = await manager.createGroup(name: 'OldName');
      await vm.updateGroup(uuid: created.uuid, name: 'NewName');

      final reloaded = await manager.loadGroupDataByUUID(created.uuid);
      expect(reloaded?.name, 'NewName');
      expect(vm.consumeForceReloadFlag(), isTrue);
    });

    test(
      'updateGroup: throws StateError when GroupManager not attached',
      () async {
        final detached = GroupManageViewModel();
        addTearDown(detached.dispose);

        expect(
          () => detached.updateGroup(uuid: 'x', name: 'Test'),
          throwsStateError,
        );
      },
    );
  });

  group('GroupManageViewModel delete + undo', () {
    late DBHelperViewModel dbHelper;
    late GroupManager manager;
    late GroupManageViewModel vm;
    late ProfileViewModel profile;
    late AppEventBus eventBus;

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      dbHelper = DBHelperViewModel();
      await dbHelper.init();
      manager = GroupManager()..updateDBHelper(dbHelper);

      profile = await _loadProfile();
      eventBus = AppEventBus();

      vm = GroupManageViewModel()
        ..attachGroupManager(manager)
        ..updateProfile(profile)
        ..updateAppEvent(eventBus);

      await manager.createGroup(name: 'G-A');
      await manager.createGroup(name: 'G-B');
      await manager.createGroup(name: 'G-C');
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      vm.dispose();
      profile.dispose();
      eventBus.dispose();
      dbHelper.dispose();
    });

    test('deleteSingleGroup: deletes and exits selection mode', () async {
      final groups = await manager.loadAllActiveGroups();
      final uuid = groups.first.uuid!;

      vm.enterSelectionMode(uuid);
      await vm.deleteSingleGroup(uuid);

      final remaining = await manager.loadAllActiveGroups();
      expect(remaining.map((g) => g.uuid), isNot(contains(uuid)));
      expect(vm.selectionMode, isFalse);
      expect(vm.consumeForceReloadFlag(), isTrue);
    });

    test('deleteSelectedGroups: deletes all selected', () async {
      final groups = await manager.loadAllActiveGroups();
      final uuids = groups.take(2).map((g) => g.uuid!).toList();

      vm.enterSelectionMode(uuids[0]);
      vm.toggleSelection(uuids[1]);
      expect(vm.selectedCount, 2);

      await vm.deleteSelectedGroups();

      final remaining = await manager.loadAllActiveGroups();
      expect(remaining.length, greaterThanOrEqualTo(1));
      expect(remaining.map((g) => g.uuid), isNot(contains(uuids[0])));
      expect(remaining.map((g) => g.uuid), isNot(contains(uuids[1])));
    });

    test('undoLastDelete: restores deleted groups', () async {
      final groups = await manager.loadAllActiveGroups();
      final uuid = groups.first.uuid!;

      await vm.deleteSingleGroup(uuid);

      var active = await manager.loadAllActiveGroups();
      expect(active.map((g) => g.uuid), isNot(contains(uuid)));

      await vm.undoLastDelete();

      active = await manager.loadAllActiveGroups();
      expect(active.map((g) => g.uuid), contains(uuid));
      expect(vm.consumeForceReloadFlag(), isTrue);
    });

    test('undoLastDelete: clears _lastDeletedUUIDs after undo', () async {
      final groups = await manager.loadAllActiveGroups();
      final uuid = groups.first.uuid!;

      await vm.deleteSingleGroup(uuid);
      await vm.undoLastDelete();

      await vm.undoLastDelete();
      expect(vm.consumeForceReloadFlag(), isTrue);
    });
  });

  group('GroupManageViewModel load lifecycle', () {
    late DBHelperViewModel dbHelper;
    late GroupManager manager;
    late GroupManageViewModel vm;
    late ProfileViewModel profile;
    late AppEventBus eventBus;

    setUp(() async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      dbHelper = DBHelperViewModel();
      await dbHelper.init();
      manager = GroupManager()..updateDBHelper(dbHelper);

      profile = await _loadProfile();
      eventBus = AppEventBus();

      vm = GroupManageViewModel()
        ..attachGroupManager(manager)
        ..updateProfile(profile)
        ..updateAppEvent(eventBus);
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      vm.dispose();
      profile.dispose();
      eventBus.dispose();
      dbHelper.dispose();
    });

    test(
      'consumeForceReloadFlag: returns true then false on successive calls',
      () {
        expect(vm.consumeForceReloadFlag(), isFalse);
        vm.requestReload();
        expect(vm.consumeForceReloadFlag(), isTrue);
        expect(vm.consumeForceReloadFlag(), isFalse);
      },
    );

    test(
      'loadGroups: populates groups and preserves session sort overrides',
      () async {
        await manager.createGroup(name: 'Zeta');

        vm.setSortOptions(
          HabitDisplayGroupType.name,
          HabitDisplaySortDirection.desc,
        );
        expect(vm.sortType, HabitDisplayGroupType.name);

        await vm.loadGroups(listen: false);

        expect(vm.sortType, HabitDisplayGroupType.name);
        expect(vm.sortDirection, HabitDisplaySortDirection.desc);
        expect(vm.groups.length, 1);
        expect(vm.groups.single.name, 'Zeta');
      },
    );

    test('loadGroups: sets hasLoaded after completion', () async {
      expect(vm.hasLoaded, isFalse);

      await vm.loadGroups(listen: false);

      expect(vm.hasLoaded, isTrue);
    });
  });
}

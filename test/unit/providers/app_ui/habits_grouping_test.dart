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

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_group_display.dart';
import 'package:mhabit/pages/habits_display/_providers/habits_grouping.dart';
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
  group('DisplayGroupModeProfileHandler', () {
    test('default is null when no value stored', () async {
      SharedPreferences.setMockInitialValues({});
      final pref = await SharedPreferences.getInstance();
      final handler = DisplayGroupModeProfileHandler(pref);

      expect(handler.get(), isNull);
      expect(handler.groupType, isNull);
      expect(handler.groupDirection, isNull);
    });

    test('round-trips set/get for name/asc', () async {
      SharedPreferences.setMockInitialValues({});
      final pref = await SharedPreferences.getInstance();
      final handler = DisplayGroupModeProfileHandler(pref);

      await handler.set((
        HabitDisplayGroupType.name,
        HabitDisplaySortDirection.asc,
      ));

      expect(handler.groupType, HabitDisplayGroupType.name);
      expect(handler.groupDirection, HabitDisplaySortDirection.asc);
    });

    test('round-trips set/get for defaultGroup/desc', () async {
      SharedPreferences.setMockInitialValues({});
      final pref = await SharedPreferences.getInstance();
      final handler = DisplayGroupModeProfileHandler(pref);

      await handler.set((
        HabitDisplayGroupType.createDate,
        HabitDisplaySortDirection.desc,
      ));

      expect(handler.groupType, HabitDisplayGroupType.createDate);
      expect(handler.groupDirection, HabitDisplaySortDirection.desc);
    });

    test('stores JSON [code, dirCode] format', () async {
      SharedPreferences.setMockInitialValues({});
      final pref = await SharedPreferences.getInstance();
      final handler = DisplayGroupModeProfileHandler(pref);

      await handler.set((
        HabitDisplayGroupType.colorType,
        HabitDisplaySortDirection.asc,
      ));

      final raw = pref.getString('habitDisplayGroupMode');
      expect(raw, isNotNull);
      expect(jsonDecode(raw!), [2, 1]);
    });

    test('reads existing JSON format', () async {
      SharedPreferences.setMockInitialValues({
        'habitDisplayGroupMode': jsonEncode([2, 2]),
      });
      final pref = await SharedPreferences.getInstance();
      final handler = DisplayGroupModeProfileHandler(pref);

      expect(handler.groupType, HabitDisplayGroupType.colorType);
      expect(handler.groupDirection, HabitDisplaySortDirection.desc);
    });

    test('remove clears stored value', () async {
      SharedPreferences.setMockInitialValues({
        'habitDisplayGroupMode': jsonEncode([1, 1]),
      });
      final pref = await SharedPreferences.getInstance();
      final handler = DisplayGroupModeProfileHandler(pref);

      await handler.remove();

      expect(handler.get(), isNull);
      expect(pref.containsKey('habitDisplayGroupMode'), isFalse);
    });

    test('handles null type in stored JSON (grouping off)', () async {
      SharedPreferences.setMockInitialValues({
        'habitDisplayGroupMode': jsonEncode([null, 1]),
      });
      final pref = await SharedPreferences.getInstance();
      final handler = DisplayGroupModeProfileHandler(pref);

      expect(handler.groupType, isNull);
      expect(handler.groupDirection, HabitDisplaySortDirection.asc);
    });
  });

  group('HabitsGroupingViewModel', () {
    test('default state uses defaultGroup (grouping off)', () async {
      final profile = await _loadProfile();
      final viewModel = HabitsGroupingViewModel()..updateProfile(profile);

      expect(viewModel.groupType, isNull);
      expect(viewModel.isGroupingEnabled, isFalse);
      expect(viewModel.groupDirection, HabitDisplaySortDirection.asc);

      viewModel.dispose();
      profile.dispose();
    });

    test('setGroupMode persists and notifies', () async {
      final profile = await _loadProfile();
      var notified = false;
      final viewModel = HabitsGroupingViewModel()
        ..updateProfile(profile)
        ..addListener(() => notified = true);

      await viewModel.setGroupMode(
        groupType: HabitDisplayGroupType.createDate,
        groupDirection: HabitDisplaySortDirection.desc,
      );

      expect(viewModel.groupType, HabitDisplayGroupType.createDate);
      expect(viewModel.groupDirection, HabitDisplaySortDirection.desc);
      expect(notified, isTrue);
      expect(
        profile.getHandler<DisplayGroupModeProfileHandler>()?.groupType,
        HabitDisplayGroupType.createDate,
      );
      expect(
        profile.getHandler<DisplayGroupModeProfileHandler>()?.groupDirection,
        HabitDisplaySortDirection.desc,
      );

      viewModel.dispose();
      profile.dispose();
    });

    test('disableGrouping turns grouping off', () async {
      final profile = await _loadProfile();
      final viewModel = HabitsGroupingViewModel()..updateProfile(profile);

      await viewModel.setGroupMode(
        groupType: HabitDisplayGroupType.name,
        groupDirection: HabitDisplaySortDirection.asc,
      );
      expect(viewModel.isGroupingEnabled, isTrue);

      await viewModel.disableGrouping();
      expect(viewModel.groupType, isNull);
      expect(viewModel.isGroupingEnabled, isFalse);

      viewModel.dispose();
      profile.dispose();
    });

    test(
      'setGroupMode preserves existing direction when not specified',
      () async {
        final profile = await _loadProfile();
        final viewModel = HabitsGroupingViewModel()..updateProfile(profile);

        await viewModel.setGroupMode(
          groupType: HabitDisplayGroupType.name,
          groupDirection: HabitDisplaySortDirection.desc,
        );
        await viewModel.setGroupMode(
          groupType: HabitDisplayGroupType.colorType,
        );

        expect(viewModel.groupType, HabitDisplayGroupType.colorType);
        // Direction preserved from previous call.
        expect(viewModel.groupDirection, HabitDisplaySortDirection.desc);

        viewModel.dispose();
        profile.dispose();
      },
    );

    test('getIcon returns hideGroupingIcon when groupType is null', () async {
      final icon = HabitsGroupingViewModel.getIcon(
        null,
        HabitDisplaySortDirection.asc,
      );
      expect(icon, isNotNull);
    });

    test('getIcon returns ascending icons for each type', () async {
      for (final groupType in HabitDisplayGroupType.values) {
        final icon = HabitsGroupingViewModel.getIcon(
          groupType,
          HabitDisplaySortDirection.asc,
        );
        expect(icon, isNotNull);
      }
    });

    test('getIcon returns descending icons for each type', () async {
      for (final groupType in HabitDisplayGroupType.values) {
        final icon = HabitsGroupingViewModel.getIcon(
          groupType,
          HabitDisplaySortDirection.desc,
        );
        expect(icon, isNotNull);
      }
    });

    test(
      'getTitle returns "Flat" (default fallback) when groupType is null',
      () async {
        final title = HabitsGroupingViewModel.getTitle(null, null);
        expect(title, 'Flat');
      },
    );

    test('getTitle returns type-specific text for each group type', () async {
      for (final groupType in HabitDisplayGroupType.values) {
        final title = HabitsGroupingViewModel.getTitle(groupType, null);
        expect(title, isNotEmpty);
        // Should not contain fallback text.
        expect(title, isNot(contains('Grouping')));
      }
    });

    test(
      'getTitle appends direction text when direction is provided',
      () async {
        final title = HabitsGroupingViewModel.getTitle(
          HabitDisplayGroupType.name,
          HabitDisplaySortDirection.desc,
        );
        expect(title, contains('(Desc)'));
      },
    );
  });
}

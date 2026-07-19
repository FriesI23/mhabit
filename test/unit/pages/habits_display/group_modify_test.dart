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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/habits_display/helpers.dart';
import 'package:mhabit/pages/habits_display/widgets.dart';

/// Creates a minimal [HabitSummaryData] for testing.
HabitSummaryData _habit({
  required String uuid,
  String name = 'test',
  String? groupId,
}) {
  return HabitSummaryData(
    id: uuid.hashCode,
    uuid: uuid,
    type: HabitType.normal,
    name: name,
    desc: '',
    color: const HabitColor.builtIn(HabitColorType.cc1),
    dailyGoal: 1,
    targetDays: 1,
    frequency: HabitFrequency.daily,
    startDate: HabitDate(2026, 1, 1),
    status: HabitStatus.activated,
    sortPostion: 1,
    createTime: DateTime.utc(2026, 1, 1),
    groupId: groupId,
  );
}

/// Wraps [child] in a minimal MaterialApp so that Theme and Navigator are
/// available. Localization strings fall back to the hardcoded defaults.
Widget wrapApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('HabitGroupModifyHandler', () {
    group('_buildAffectedHabits', () {
      test('creates affectedHabits from selectedData', () {
        final data = [
          _habit(uuid: 'h1', name: 'Read', groupId: 'g1'),
          _habit(uuid: 'h2', name: 'Write', groupId: null),
        ];

        final handler = HabitGroupModifyHandler(
          selectedData: data,
          getGroupName: (_) => null,
          targetGroupId: 'g2',
        );

        expect(handler.affectedHabits.length, 2);
        expect(handler.affectedHabits[0].uuid, 'h1');
        expect(handler.affectedHabits[0].name, 'Read');
        expect(handler.affectedHabits[0].oldGroupId, 'g1');
        expect(handler.affectedHabits[1].uuid, 'h2');
        expect(handler.affectedHabits[1].name, 'Write');
        expect(handler.affectedHabits[1].oldGroupId, isNull);
      });
    });

    group('_buildSourceGroups', () {
      test('groups habits by old group name (target non-null)', () {
        String? getGroupName(String? gid) =>
            gid == 'g1' ? 'Work' : (gid == 'g2' ? 'Play' : null);
        final data = [
          _habit(uuid: 'h1', name: 'Read', groupId: 'g1'),
          _habit(uuid: 'h2', name: 'Write', groupId: 'g2'),
          _habit(uuid: 'h3', name: 'Draw', groupId: null),
          _habit(uuid: 'h4', name: 'Sing', groupId: 'g1'),
        ];

        final handler = HabitGroupModifyHandler(
          selectedData: data,
          getGroupName: getGroupName,
          targetGroupId: 'g3',
        );

        final groups = handler.sourceGroups;
        expect(groups.length, 2);
        expect(
          groups['Work']!.map((h) => h.name),
          containsAll(['Read', 'Sing']),
        );
        expect(groups['Play']!.map((h) => h.name), ['Write']);
      });

      test('excludes habits already in target group', () {
        String? getGroupName(String? gid) => gid == 'g1' ? 'Work' : null;
        final data = [
          _habit(uuid: 'h1', name: 'Read', groupId: 'g1'),
          _habit(uuid: 'h2', name: 'Write', groupId: 'g2'),
        ];

        final handler = HabitGroupModifyHandler(
          selectedData: data,
          getGroupName: getGroupName,
          targetGroupId: 'g2', // h2 is already here → excluded
        );

        final groups = handler.sourceGroups;
        expect(groups.length, 1);
        expect(groups['Work']!.map((h) => h.name), ['Read']);
      });

      test('includes all groups when removing (target null)', () {
        String? getGroupName(String? gid) =>
            gid == 'g1' ? 'Work' : (gid == 'g2' ? 'Play' : null);
        final data = [
          _habit(uuid: 'h1', name: 'Read', groupId: 'g1'),
          _habit(uuid: 'h2', name: 'Write', groupId: 'g2'),
          _habit(uuid: 'h3', name: 'Draw', groupId: null),
        ];

        final handler = HabitGroupModifyHandler(
          selectedData: data,
          getGroupName: getGroupName,
          targetGroupId: null, // remove all
        );

        final groups = handler.sourceGroups;
        expect(groups.length, 2);
        expect(groups['Work']!.map((h) => h.name), ['Read']);
        expect(groups['Play']!.map((h) => h.name), ['Write']);
        // h3 has no group → not in sourceGroups
      });
    });

    group('allAlreadyInTarget', () {
      test('true when all habits match target', () {
        final data = [
          _habit(uuid: 'h1', name: 'Read', groupId: 'g1'),
          _habit(uuid: 'h2', name: 'Write', groupId: 'g1'),
        ];

        final handler = HabitGroupModifyHandler(
          selectedData: data,
          getGroupName: (_) => null,
          targetGroupId: 'g1',
        );

        expect(handler.allAlreadyInTarget, isTrue);
      });

      test('false when some habits differ from target', () {
        final data = [
          _habit(uuid: 'h1', name: 'Read', groupId: 'g1'),
          _habit(uuid: 'h2', name: 'Write', groupId: 'g2'),
        ];

        final handler = HabitGroupModifyHandler(
          selectedData: data,
          getGroupName: (_) => null,
          targetGroupId: 'g1',
        );

        expect(handler.allAlreadyInTarget, isFalse);
      });

      test('true when all habits already null and target is null', () {
        final data = [
          _habit(uuid: 'h1', name: 'Read', groupId: null),
          _habit(uuid: 'h2', name: 'Write', groupId: null),
        ];

        final handler = HabitGroupModifyHandler(
          selectedData: data,
          getGroupName: (_) => null,
          targetGroupId: null,
        );

        expect(handler.allAlreadyInTarget, isTrue);
      });

      test('false when some have groups and target is null', () {
        final data = [
          _habit(uuid: 'h1', name: 'Read', groupId: 'g1'),
          _habit(uuid: 'h2', name: 'Write', groupId: null),
        ];

        final handler = HabitGroupModifyHandler(
          selectedData: data,
          getGroupName: (_) => null,
          targetGroupId: null,
        );

        expect(handler.allAlreadyInTarget, isFalse);
      });
    });
  });

  group('GroupModifySelectorCancelled', () {
    test('isGroupModifySelectorCancelled returns true for sentinel', () {
      expect(
        isGroupModifySelectorCancelled(kGroupModifySelectorCancelled),
        isTrue,
      );
    });

    test('isGroupModifySelectorCancelled returns false for null', () {
      expect(isGroupModifySelectorCancelled(null), isFalse);
    });

    test('isGroupModifySelectorCancelled returns false for uuid', () {
      expect(isGroupModifySelectorCancelled('some-uuid'), isFalse);
    });
  });

  group('Confirm dialog', () {
    testWidgets('renders with pure new group case', (tester) async {
      final affected = [
        const HabitGroupModifyItem(uuid: 'h1', name: 'Read', oldGroupId: null),
        const HabitGroupModifyItem(uuid: 'h2', name: 'Write', oldGroupId: null),
      ];

      await tester.pumpWidget(
        wrapApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showHabitGroupModifyConfirmDialog(
                  context: context,
                  affectedHabits: affected,
                  targetGroupId: 'g1',
                  targetGroupName: 'Work',
                  sourceGroups: const {},
                  skipFutureEnabled: false,
                  onSkipFutureChanged: (_) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Move to Group'), findsOneWidget);
      expect(find.text("Don't show again"), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('renders with mixed change case', (tester) async {
      final affected = [
        const HabitGroupModifyItem(uuid: 'h1', name: 'Read', oldGroupId: 'old'),
        const HabitGroupModifyItem(uuid: 'h2', name: 'Write', oldGroupId: null),
      ];

      await tester.pumpWidget(
        wrapApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showHabitGroupModifyConfirmDialog(
                  context: context,
                  affectedHabits: affected,
                  targetGroupId: 'g1',
                  targetGroupName: 'Work',
                  sourceGroups: const {},
                  skipFutureEnabled: false,
                  onSkipFutureChanged: (_) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Mixed case: dialog should render without error.
      // Title fallback is 'Confirm' (same as button), so finds at least one.
      expect(find.text('Confirm'), findsAtLeast(1));
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('confirm button always enabled (idempotent)', (tester) async {
      final affected = [
        const HabitGroupModifyItem(uuid: 'h1', name: 'Read', oldGroupId: 'g1'),
      ];

      await tester.pumpWidget(
        wrapApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showHabitGroupModifyConfirmDialog(
                  context: context,
                  affectedHabits: affected,
                  targetGroupId: 'g1',
                  targetGroupName: 'Work',
                  sourceGroups: const {},
                  skipFutureEnabled: false,
                  onSkipFutureChanged: (_) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Confirm is always enabled; caller filters at execution time.
      final confirmButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Confirm'),
      );
      expect(confirmButton.onPressed, isNotNull);
    });

    testWidgets('habit names rendered with separator', (tester) async {
      final affected = [
        const HabitGroupModifyItem(uuid: 'h1', name: 'Read', oldGroupId: null),
        const HabitGroupModifyItem(uuid: 'h2', name: 'Write', oldGroupId: null),
      ];

      await tester.pumpWidget(
        wrapApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showHabitGroupModifyConfirmDialog(
                  context: context,
                  affectedHabits: affected,
                  targetGroupId: 'g1',
                  targetGroupName: 'Work',
                  sourceGroups: const {},
                  skipFutureEnabled: false,
                  onSkipFutureChanged: (_) {},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Read'), findsOneWidget);
      expect(find.textContaining('Write'), findsOneWidget);
    });
  });
}

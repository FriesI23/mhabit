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

import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:flutter/cupertino.dart'
    show
        CupertinoActivityIndicator,
        CupertinoListTile,
        CupertinoSwitch,
        CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/group.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_group.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/habits_display/_providers/habit_group_modify.dart';
import 'package:mhabit/pages/habits_display/helpers.dart';
import 'package:mhabit/pages/habits_display/widgets.dart';
import 'package:mhabit/providers/app_ui/app_caches.dart';
import 'package:mhabit/providers/app_ui/custom_color_history.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/group_manager.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

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

final class _DialogCountingObserver extends NavigatorObserver {
  int popupPushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PopupRoute<dynamic>) popupPushes += 1;
  }
}

final class _EmptyGroupManager extends GroupManager {
  @override
  Future<GroupCollection?> tryLoadGroupCollection() async =>
      GroupCollection.fromDBQueryResult([]);
}

final class _StaticGroupManager extends GroupManager {
  @override
  Future<GroupCollection?> tryLoadGroupCollection() async =>
      GroupCollection.fromDBQueryResult(const [
        GroupDBCell(uuid: 'group-1', name: 'First', status: 1, sortPosition: 1),
        GroupDBCell(
          uuid: 'group-2',
          name: 'Second',
          status: 1,
          sortPosition: 2,
        ),
      ]);
}

final class _LoadingGroupManager extends GroupManager {
  final loading = Completer<GroupCollection?>();

  @override
  Future<GroupCollection?> tryLoadGroupCollection() => loading.future;
}

final class _DelayedGroupManager extends GroupManager {
  final creation = Completer<HabitGroupData>();
  int createCalls = 0;

  @override
  Future<GroupCollection?> tryLoadGroupCollection() async =>
      GroupCollection.fromDBQueryResult([]);

  @override
  Future<HabitGroupData> createGroup({
    required String name,
    String? desc,
    GroupIcon? icon,
    HabitColor? color,
  }) {
    createCalls++;
    return creation.future;
  }
}

void main() {
  test(
    'confirm translations own source-name truncation and preview references',
    () {
      for (final locale in L10n.supportedLocales) {
        final l10n = lookupL10n(locale);
        expect(
          l10n.habitDisplay_groupModifyConfirm_previewTitle,
          l10n.appDateFormat_preview_text,
        );
        for (final count in [1, 2, 5]) {
          final full = l10n.habitDisplay_groupModifyConfirm_bodyChangeStat(
            count,
            'A, B, C',
            'Target',
            0,
            3,
          );
          final shortened = l10n.habitDisplay_groupModifyConfirm_bodyChangeStat(
            count,
            'A, B, C',
            'Target',
            2,
            5,
          );
          expect(full, contains('A, B, C'));
          expect(full, isNot(contains('...')));
          expect(shortened, contains('A, B, C'));
          expect(shortened, isNot(contains('...')));
          expect(shortened, isNot(full));
          expect(shortened, contains('Target'));
        }
      }
    },
  );
  test('source group quantities use localized singular and plural forms', () {
    final cases = <Locale, (String, String)>{
      const Locale('en'): ('and 1 more group', 'and 34 more groups'),
      const Locale('zh'): ('等共 4 个分组', '等共 37 个分组'),
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'): (
        '等共 4 個群組',
        '等共 37 個群組',
      ),
      const Locale('he'): ('ועוד קבוצה אחת', 'ועוד 34 קבוצות'),
      const Locale('cs'): ('a jedné další skupiny', 'a dalších 34 skupin'),
      const Locale('uk'): ('та ще 1 групи', 'та ще 34 груп'),
    };
    for (final entry in cases.entries) {
      final l10n = lookupL10n(entry.key);
      final (open, close, space) = switch (entry.key.languageCode) {
        'zh' => ('「', '」', ''),
        'he' => ('„', '”', ' '),
        'cs' => ('„', '“', ' '),
        _ => ('"', '"', ' '),
      };
      final quotedNames = '${open}A, B, C$close$space';
      expect(
        l10n.habitDisplay_groupModifyConfirm_bodyChangeStat(
          5,
          'A, B, C',
          'Target',
          1,
          4,
        ),
        contains('$quotedNames${entry.value.$1}'),
      );
      expect(
        l10n.habitDisplay_groupModifyConfirm_bodyChangeStat(
          5,
          'A, B, C',
          'Target',
          34,
          37,
        ),
        contains('$quotedNames${entry.value.$2}'),
      );
    }
    final uk = lookupL10n(const Locale('uk'));
    expect(
      uk.habitDisplay_groupModifyConfirm_bodyChangeStat(
        5,
        'A, B, C',
        'Target',
        21,
        24,
      ),
      contains('та ще 21 групи'),
    );
    expect(
      uk.habitDisplay_groupModifyConfirm_bodyChangeStat(
        5,
        'A, B, C',
        'Target',
        11,
        14,
      ),
      contains('та ще 11 груп'),
    );
  });
  for (final count in [3, 4]) {
    testWidgets('confirm limits source names to three for $count groups', (
      tester,
    ) async {
      final habits = [
        for (var i = 0; i < count; i++)
          HabitGroupModifyItem(
            uuid: 'h$i',
            name: 'Habit $i',
            oldGroupId: 'g$i',
            oldGroupName: 'Group $i',
          ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                HabitGroupModifyConfirmContent(
                  affectedHabits: habits,
                  addCount: 0,
                  changeCount: count,
                  removeCount: 0,
                  sourceGroups: {
                    for (final habit in habits) habit.oldGroupId!: [habit],
                  },
                  targetGroupId: 'target',
                  targetGroupName: 'Target',
                  isMixed: true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final summary = tester
          .widget<Text>(find.textContaining('will change from'))
          .data!;
      expect(summary, contains('Group 0, Group 1, Group 2'));
      expect(summary.contains('and 1 more group'), count > 3);
      expect(summary, isNot(contains('...')));
      expect(summary, isNot(contains('Group 3')));
      await tester.tap(
        find.byKey(const ValueKey('group-modify-preview-toggle')),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Group ${count - 1} (1)'), 120);
      expect(find.text('Group ${count - 1} (1)'), findsOneWidget);
    });
  }

  test('current group is shared by every selected habit', () {
    for (final ids in <List<String?>>[
      [],
      [null],
      ['group-2'],
      ['group-2', 'group-2'],
      ['group-1', 'group-2'],
      ['group-2', null],
    ]) {
      final vm = HabitGroupModifyViewModel(
        selectedData: [
          for (var i = 0; i < ids.length; i++)
            _habit(uuid: 'h$i', groupId: ids[i]),
        ],
      );
      expect(
        vm.currentGroupId,
        ids.isNotEmpty && ids.every((id) => id == 'group-2') ? 'group-2' : null,
      );
      vm.dispose();
    }
  });
  for (final size in [const Size(400, 800), const Size(800, 800)]) {
    for (final returnWhileSaving in [false, true]) {
      testWidgets('delayed group save at $size preserves selector '
          'when returning during save: $returnWhileSaving', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);
        final manager = _DelayedGroupManager();
        var completed = false;
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<GroupManager>.value(value: manager),
              Provider<AppCachesViewModel>(create: (_) => AppCachesViewModel()),
              ChangeNotifierProvider<CustomColorHistoryViewModel>(
                create: (_) => CustomColorHistoryViewModel(),
              ),
              ChangeNotifierProvider<AppEventBus>(create: (_) => AppEventBus()),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    await showHabitGroupModifySelector(
                      context: context,
                      selectedHabitsData: const [],
                    );
                    completed = true;
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create Group'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).first, 'New group');
        final createContext = tester.element(find.byType(TextFormField).first);
        final createRoute = ModalRoute.of(createContext)!;
        await tester.tap(find.byKey(const ValueKey('adaptive-modal-confirm')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('adaptive-modal-confirm')));
        await tester.pumpAndSettle();
        expect(manager.createCalls, 1);

        if (returnWhileSaving) {
          await tester.tap(find.byType(AdaptiveBackButton));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));
          // The page is still mounted during its outgoing transition, but
          // the selector is already the navigator's current route.
          expect(createContext.mounted, isTrue);
          expect(createRoute.isCurrent, isFalse);
        }
        manager.creation.complete(
          const HabitGroupData(
            uuid: 'created-group',
            name: 'New group',
            desc: '',
            sortPosition: 0,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(completed, !returnWhileSaving);
        if (returnWhileSaving) {
          expect(find.text('Modify Group'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('adaptive-modal-confirm')),
            findsNothing,
          );
          await tester.tap(
            find.byKey(const ValueKey('adaptive-modal-implied-close')),
          );
          await tester.pumpAndSettle();
          expect(completed, isTrue);
        }
      });
    }
  }

  for (final style in AdaptiveStyle.values) {
    testWidgets('group selector uses ${style.name} loading modal', (
      tester,
    ) async {
      final manager = _LoadingGroupManager();
      await tester.pumpWidget(
        AdaptiveStyleScope(
          override: style,
          child: MultiProvider(
            providers: [
              Provider<GroupManager>.value(value: manager),
              Provider<AppCachesViewModel>(create: (_) => AppCachesViewModel()),
              ChangeNotifierProvider<CustomColorHistoryViewModel>(
                create: (_) => CustomColorHistoryViewModel(),
              ),
              ChangeNotifierProvider<AppEventBus>(create: (_) => AppEventBus()),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showHabitGroupModifySelector(
                    context: context,
                    selectedHabitsData: const [],
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(find.bySubtype<AdaptiveModal>(), findsOneWidget);
      expect(
        find.byType(
          style == AdaptiveStyle.material
              ? CircularProgressIndicator
              : CupertinoActivityIndicator,
        ),
        findsOneWidget,
      );

      manager.loading.complete(GroupCollection.fromDBQueryResult([]));
      await tester.pumpAndSettle();
      expect(find.text('Create Group'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('adaptive-modal-implied-close')),
      );
      await tester.pumpAndSettle();
    });

    testWidgets(
      'group selector uses ${style.name} Group Edit modal structure',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 800);
        addTearDown(tester.view.reset);
        GroupModifySelectorResult? result;
        var completed = false;
        await tester.pumpWidget(
          AdaptiveStyleScope(
            override: style,
            child: MultiProvider(
              providers: [
                Provider<GroupManager>(create: (_) => _EmptyGroupManager()),
                Provider<AppCachesViewModel>(
                  create: (_) => AppCachesViewModel(),
                ),
                ChangeNotifierProvider<CustomColorHistoryViewModel>(
                  create: (_) => CustomColorHistoryViewModel(),
                ),
                ChangeNotifierProvider<AppEventBus>(
                  create: (_) => AppEventBus(),
                ),
              ],
              child: MaterialApp(
                builder: (context, child) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: const TextScaler.linear(2)),
                    child: child!,
                  ),
                ),
                home: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () async {
                      result = await showHabitGroupModifySelector(
                        context: context,
                        selectedHabitsData: const [],
                      );
                      completed = true;
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Modify Group'), findsOneWidget);
        expect(find.text('Create Group'), findsOneWidget);
        expect(
          tester
              .widget<AdaptiveModalNavigator<GroupModifySelectorResult?>>(
                find.bySubtype<AdaptiveModalNavigator>(),
              )
              .size
              .constraints,
          const BoxConstraints(minWidth: 560, maxWidth: 560, maxHeight: 720),
        );
        expect(
          tester
              .widget<AdaptiveModal>(find.bySubtype<AdaptiveModal>())
              .leadingAction,
          isNull,
        );
        expect(
          find.byKey(const ValueKey('adaptive-modal-implied-close')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('adaptive-modal-confirm')),
          findsNothing,
        );
        expect(
          find.byType(
            style == AdaptiveStyle.material ? ListTile : CupertinoListTile,
          ),
          findsWidgets,
        );
        expect(
          tester
              .getSize(find.byKey(const ValueKey('adaptive-modal-constraints')))
              .width,
          390,
        );
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Create Group'));
        await tester.pumpAndSettle();

        expect(find.text('Modify Group'), findsNothing);
        expect(
          find.byType(
            style == AdaptiveStyle.material
                ? TextFormField
                : CupertinoTextField,
          ),
          findsWidgets,
        );
        expect(
          find.byKey(const ValueKey('group-modify-create-save')),
          findsNothing,
        );
        expect(find.text('Save'), findsNothing);
        expect(
          find.byKey(const ValueKey('adaptive-modal-confirm')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('adaptive-modal-actions')),
          findsNothing,
        );
        expect(find.byType(AdaptiveBackButton), findsOneWidget);
        expect(
          tester
              .widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton))
              .type,
          AdaptiveBackButtonType.back,
        );
        expect(tester.takeException(), isNull);

        await tester.tap(find.byType(AdaptiveBackButton));
        await tester.pumpAndSettle();

        expect(find.text('Modify Group'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('adaptive-modal-confirm')),
          findsNothing,
        );
        expect(find.byType(AdaptiveBackButton), findsNothing);

        await tester.tap(
          find.byKey(const ValueKey('adaptive-modal-implied-close')),
        );
        await tester.pumpAndSettle();

        expect(completed, isTrue);
        expect(result, same(kGroupModifySelectorCancelled));
      },
    );

    testWidgets('group selector returns ${style.name} list selection', (
      tester,
    ) async {
      GroupModifySelectorResult? result;
      await tester.pumpWidget(
        AdaptiveStyleScope(
          override: style,
          child: MultiProvider(
            providers: [
              Provider<GroupManager>(create: (_) => _StaticGroupManager()),
              Provider<AppCachesViewModel>(create: (_) => AppCachesViewModel()),
              ChangeNotifierProvider<CustomColorHistoryViewModel>(
                create: (_) => CustomColorHistoryViewModel(),
              ),
              ChangeNotifierProvider<AppEventBus>(create: (_) => AppEventBus()),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result = await showHabitGroupModifySelector(
                      context: context,
                      selectedHabitsData: const [],
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.byType(AdaptiveCheckmark), findsNothing);
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();

      expect(result, isA<GroupModifySelectorSelected>());
      expect((result! as GroupModifySelectorSelected).groupId, 'group-2');

      result = null;
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Group'));
      await tester.pumpAndSettle();
      expect(result, same(kGroupModifySelectorRemoveGroup));
    });
  }

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
          getGroup: (id) => id == 'g1'
              ? const HabitGroupData(
                  uuid: 'g1',
                  name: 'Work',
                  desc: '',
                  sortPosition: 0,
                  icon: GroupIcon.work,
                  color: HabitColor.custom(0xff4488cc),
                )
              : null,
        );

        expect(handler.affectedHabits.length, 2);
        expect(handler.affectedHabits[0].uuid, 'h1');
        expect(handler.affectedHabits[0].name, 'Read');
        expect(handler.affectedHabits[0].oldGroupId, 'g1');
        expect(handler.affectedHabits[0].oldGroupName, 'Work');
        expect(handler.affectedHabits[0].oldGroupIcon, GroupIcon.work);
        expect(
          handler.affectedHabits[0].oldGroupColor,
          const HabitColor.custom(0xff4488cc),
        );
        expect(handler.affectedHabits[1].uuid, 'h2');
        expect(handler.affectedHabits[1].name, 'Write');
        expect(handler.affectedHabits[1].oldGroupId, isNull);
        expect(handler.affectedHabits[1].oldGroupColor, isNull);
        expect(handler.affectedHabits[1].oldGroupIcon, isNull);
      });
    });

    group('_buildSourceGroups', () {
      test('keeps distinct IDs with the same group name', () {
        final handler = HabitGroupModifyHandler(
          selectedData: [
            _habit(uuid: 'h1', groupId: 'g1'),
            _habit(uuid: 'h2', groupId: 'g2'),
          ],
          getGroupName: (_) => 'Same',
          targetGroupId: null,
        );
        expect(handler.sourceGroups.keys, ['g1', 'g2']);
        expect(handler.sourceGroups['g1']!.single.oldGroupName, 'Same');
        expect(handler.sourceGroups['g2']!.single.oldGroupName, 'Same');
      });
      test('groups habits by old group ID (target non-null)', () {
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
        expect(groups['g1']!.map((h) => h.name), containsAll(['Read', 'Sing']));
        expect(groups['g2']!.map((h) => h.name), ['Write']);
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
        expect(groups['g1']!.map((h) => h.name), ['Read']);
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
        expect(groups['g1']!.map((h) => h.name), ['Read']);
        expect(groups['g2']!.map((h) => h.name), ['Write']);
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

  group('Confirm page', () {
    for (final style in AdaptiveStyle.values) {
      testWidgets(
        'uses ${style.name} Group Edit modal actions and commits skip on confirm',
        (tester) async {
          const affected = [
            HabitGroupModifyItem(uuid: 'h1', name: 'Read', oldGroupId: null),
          ];
          bool? result;
          final persistedValues = <bool>[];

          await tester.pumpWidget(
            AdaptiveStyleScope(
              override: style,
              child: MaterialApp(
                home: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () async {
                      result = await pushHabitGroupModifyConfirmPage(
                        context: context,
                        affectedHabits: affected,
                        targetGroupId: 'g1',
                        targetGroupName: 'Work',
                        sourceGroups: const {},
                        skipFutureEnabled: false,
                        onSkipFutureChanged: persistedValues.add,
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          expect(find.bySubtype<AdaptiveModal>(), findsOneWidget);
          expect(
            find.byKey(const ValueKey('adaptive-modal-implied-close')),
            findsNothing,
          );
          expect(find.byType(AdaptiveBackButton), findsOneWidget);
          expect(
            find.byKey(const ValueKey('adaptive-modal-confirm')),
            findsOneWidget,
          );
          expect(
            find.byType(
              style == AdaptiveStyle.material ? Switch : CupertinoSwitch,
            ),
            findsOneWidget,
          );

          await tester.tap(find.text("Don't show again"));
          await tester.pump();
          expect(persistedValues, isEmpty);

          await tester.tap(
            find.byKey(const ValueKey('adaptive-modal-confirm')),
          );
          await tester.pumpAndSettle();
          expect(result, isTrue);
          expect(persistedValues, [true]);

          result = null;
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text("Don't show again"));
          await tester.pump();
          await tester.tap(find.byType(AdaptiveBackButton));
          await tester.pumpAndSettle();
          expect(result, isFalse);
          expect(persistedValues, [true]);
        },
      );
    }

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
                pushHabitGroupModifyConfirmPage(
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
      expect(
        find.byKey(const ValueKey('adaptive-modal-implied-close')),
        findsNothing,
      );
      expect(find.byType(AdaptiveBackButton), findsOneWidget);
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
                pushHabitGroupModifyConfirmPage(
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

      // Mixed case: confirmation should render without error.
      // Title fallback is 'Confirm' (same as button), so finds at least one.
      expect(find.text('Confirm'), findsAtLeast(1));
      expect(
        find.byKey(const ValueKey('adaptive-modal-implied-close')),
        findsNothing,
      );
      expect(find.byType(AdaptiveBackButton), findsOneWidget);
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
                pushHabitGroupModifyConfirmPage(
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

    testWidgets('preview separates same-named groups and ungrouped habits', (
      tester,
    ) async {
      final affected = [
        const HabitGroupModifyItem(
          uuid: 'h1',
          name: 'Read',
          oldGroupId: 'old-1',
          oldGroupName: 'Same',
        ),
        const HabitGroupModifyItem(
          uuid: 'h2',
          name: 'Write',
          oldGroupId: 'old-2',
          oldGroupName: 'Same',
        ),
        const HabitGroupModifyItem(uuid: 'h3', name: 'Draw'),
      ];

      await tester.pumpWidget(
        wrapApp(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                pushHabitGroupModifyConfirmPage(
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

      expect(find.text('Preview'), findsOneWidget);
      expect(find.textContaining('Read'), findsNothing);
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();
      expect(find.text('Same (1)'), findsNWidgets(2));
      expect(find.text('Read'), findsNothing);
      // A partially open tree collapses first; the next press expands all.
      await tester.tap(
        find.byKey(const ValueKey('group-modify-preview-toggle')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('group-modify-preview-toggle')),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Read'), findsOneWidget);
      expect(find.textContaining('Write'), findsOneWidget);
      expect(find.text('Same (1)'), findsNWidgets(2));
      await tester.tap(
        find.byKey(const ValueKey('group-modify-preview-group-old-1')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsNothing);
      expect(find.text('Write'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Draw'), 80);
      expect(find.text('No Group (1)'), findsOneWidget);
      expect(find.text('Draw'), findsOneWidget);
    });
  });

  testWidgets('group confirmation pushes inside the existing modal navigator', (
    tester,
  ) async {
    final rootObserver = _DialogCountingObserver();
    GroupModifySelectorResult? result;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<GroupManager>(create: (_) => _StaticGroupManager()),
          Provider<AppCachesViewModel>(create: (_) => AppCachesViewModel()),
          ChangeNotifierProvider<CustomColorHistoryViewModel>(
            create: (_) => CustomColorHistoryViewModel(),
          ),
          ChangeNotifierProvider<AppEventBus>(create: (_) => AppEventBus()),
        ],
        child: MaterialApp(
          navigatorObservers: [rootObserver],
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showHabitGroupModifySelector(
                  context: context,
                  selectedHabitsData: [
                    _habit(uuid: 'h1', name: 'Read', groupId: 'group-2'),
                  ],
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(rootObserver.popupPushes, 1);
    expect(find.text('Modify Group'), findsOneWidget);

    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey('group-modify-option-group-2')),
          )
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    await tester.tap(find.text('First'));
    await tester.pumpAndSettle();

    expect(rootObserver.popupPushes, 1);
    expect(find.text('Modify Group'), findsNothing);
    expect(find.text('Confirm'), findsAtLeast(1));
    expect(find.byType(AdaptiveBackButton), findsOneWidget);

    await tester.tap(find.byType(AdaptiveBackButton));
    await tester.pumpAndSettle();

    expect(rootObserver.popupPushes, 1);
    expect(find.text('Modify Group'), findsOneWidget);
    expect(result, isNull);
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey('group-modify-option-group-2')),
          )
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    await tester.tap(find.text('Remove Group'));
    await tester.pumpAndSettle();
    expect(find.text('Modify Group'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('adaptive-modal-confirm')));
    await tester.pumpAndSettle();
    expect((result! as GroupModifySelectorSelected).groupId, isNull);
  });
}

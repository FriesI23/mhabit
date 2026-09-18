// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_settings/_widgets/import_habits_confirm.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/group_manager.dart';
import 'package:mhabit/providers/workflow/habits_file_importer.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_adaptive_modal.dart';
import 'package:mhabit_adaptive_ui/src/material/material_adaptive_modal.dart';
import 'package:provider/provider.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('adapts import surface after resize on $platform', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 800);
      addTearDown(tester.view.reset);
      final importer = _TestImportRunner();

      await _pumpHost(tester, platform: platform, importer: importer);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(_presentation(tester, platform), AdaptiveModalPresentation.sheet);
      expect(find.text('Source: Loop Habit Tracker'), findsOneWidget);
      expect(find.byType(AdaptiveSwitchListTile), findsNWidgets(2));
      if (platform == TargetPlatform.iOS) {
        final closeButton = find.byKey(
          const ValueKey('adaptive-modal-implied-close'),
        );
        expect(closeButton, findsOneWidget);
        expect(
          tester.getCenter(closeButton).dx,
          greaterThan(
            tester
                .getCenter(find.byKey(const ValueKey('adaptive-modal-title')))
                .dx,
          ),
        );
        expect(
          find.byKey(const ValueKey('adaptive-modal-actions')),
          findsOneWidget,
        );
      } else {
        expect(
          find.byKey(const ValueKey('import-cancel-button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('adaptive-modal-actions')),
          findsOneWidget,
        );
      }

      tester.view.physicalSize = const Size(900, 900);
      await tester.pumpAndSettle();

      expect(_presentation(tester, platform), AdaptiveModalPresentation.dialog);
      await tester.tap(
        find.byKey(
          ValueKey(
            platform == TargetPlatform.iOS
                ? 'adaptive-modal-implied-close'
                : 'import-cancel-button',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySubtype<AdaptiveModal>(), findsNothing);
    });
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('keeps nested expansion and item results on $platform', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 1100);
      addTearDown(tester.view.reset);
      final importer = _TestImportRunner(deferHabits: true);
      await _pumpHost(tester, platform: platform, importer: importer);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      TreeSliver tree() =>
          tester.widget<TreeSliver>(find.byKey(const ValueKey('import-tree')));
      TreeSliverNode<Object?> node(String key) => key == 'import-preview'
          ? tree().tree.single
          : tree().tree.single.children.first;
      final collapsedHeight = tester
          .getSize(find.byKey(const ValueKey('adaptive-modal-constraints')))
          .height;
      expect(node('import-preview').isExpanded, isFalse);
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('import-preview')),
          matching: find.text('Import'),
        ),
      );
      await tester.pumpAndSettle();
      expect(node('import-group-0').isExpanded, isFalse);
      await tester.tap(find.byKey(const ValueKey('import-toggle-expansion')));
      await tester.pumpAndSettle();
      expect(node('import-preview').isExpanded, isFalse);
      tree().controller!.expandNode(node('import-preview'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Group A (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Habit A').hitTestable(), findsOneWidget);
      expect(
        tester
            .getSize(find.byKey(const ValueKey('adaptive-modal-constraints')))
            .height,
        greaterThan(collapsedHeight + 40),
      );

      for (final (label, status) in [
        ('Import', 'import-total-pending'),
        ('Group A (1)', 'import-group-0-pending'),
        ('Habit A', 'import-habit-0-pending'),
      ]) {
        expect(
          tester.getCenter(find.text(label)).dy,
          closeTo(tester.getCenter(find.byKey(ValueKey(status))).dy, 0.5),
          reason: '$label text and trailing icon must share a vertical center',
        );
        expect(
          tester.getCenter(find.byKey(ValueKey(status))).dx,
          closeTo(
            tester
                .getCenter(find.byKey(const ValueKey('import-total-pending')))
                .dx,
            0.5,
          ),
          reason: 'Every status icon must align in the last column',
        );
      }

      final toggle = find.byKey(const ValueKey('import-toggle-expansion'));
      expect(
        find.descendant(of: toggle, matching: find.byType(Tooltip)),
        findsNothing,
      );
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(node('import-preview').isExpanded, isFalse);
      expect(node('import-group-0').isExpanded, isFalse);
      expect(
        tester
            .getSize(find.byKey(const ValueKey('adaptive-modal-constraints')))
            .height,
        closeTo(collapsedHeight, 1),
      );
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(node('import-preview').isExpanded, isTrue);
      expect(node('import-group-0').isExpanded, isTrue);

      expect(
        find.byKey(const ValueKey('import-habit-0-pending')).hitTestable(),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('import-confirm-button')));
      await tester.pumpAndSettle();

      expect(
        find.text("Note: Import doesn't delete existing habits."),
        findsNothing,
      );
      expect(
        tester.getBottomLeft(find.byKey(const ValueKey('import-progress'))).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const ValueKey('import-preview'))).dy,
        ),
      );
      expect(node('import-preview').isExpanded, isTrue);
      expect(node('import-group-0').isExpanded, isTrue);
      expect(
        find.byKey(const ValueKey('import-habit-0-running')).hitTestable(),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('import-group-0-running')).hitTestable(),
        findsOneWidget,
      );
      // Collapsing the outer row must not reset its nested disclosure.
      tree().controller!.collapseNode(node('import-preview'));
      await tester.pumpAndSettle();
      tree().controller!.expandNode(node('import-preview'));
      await tester.pumpAndSettle();
      expect(node('import-group-0').isExpanded, isTrue);
      // A retained open child also makes toggle collapse when its parent is shut.
      tree().controller!.collapseNode(node('import-preview'));
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(node('import-preview').isExpanded, isFalse);
      expect(node('import-group-0').isExpanded, isFalse);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      // Manually closing every visible row must leave the next action as expand.
      tree().controller!.collapseNode(node('import-group-0'));
      tree().controller!.collapseNode(node('import-preview'));
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(node('import-group-0').isExpanded, isTrue);
      importer.completeHabits(success: 0, failed: 1);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('import-habit-0-failed')).hitTestable(),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('import-group-0-failed')).hitTestable(),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('import-total-failed')).hitTestable(),
        findsOneWidget,
      );
      expect(find.text('Habit A').hitTestable(), findsOneWidget);

      final completion = find.byKey(
        const ValueKey('import-completion-summary'),
      );
      expect(find.byKey(const ValueKey('import-progress')), findsNothing);
      expect(
        tester
            .getBottomLeft(
              find.byKey(const ValueKey('import-completion-divider')),
            )
            .dy,
        lessThanOrEqualTo(tester.getTopLeft(completion).dy),
      );
      expect(
        tester.getBottomLeft(completion).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const ValueKey('import-preview'))).dy,
        ),
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('import-confirm-content')),
          matching: completion,
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('adaptive-modal-title')),
          matching: completion,
        ),
        findsNothing,
      );
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(node('import-preview').isExpanded, isFalse);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('import-habit-0-failed')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets(
      'tree lazily builds a long import and supports scaled text on $platform',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 800);
        addTearDown(tester.view.reset);
        await _pumpHost(
          tester,
          platform: platform,
          importer: _TestImportRunner(),
          textScale: 2,
          habits: List.generate(
            300,
            (index) => {
              'name':
                  'Habit $index with a very long descriptive name that wraps',
              'group_id': 'group-a',
            },
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final scroll = tester.widget<CustomScrollView>(
          find.byKey(const ValueKey('adaptive-modal-scroll-body')),
        );
        scroll.controller!.jumpTo(scroll.controller!.position.maxScrollExtent);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('import-toggle-expansion')));
        await tester.pumpAndSettle();
        final tree = tester.widget<TreeSliver>(
          find.byKey(const ValueKey('import-tree')),
        );
        expect(tree.tree.single.children.single.children.length, 300);
        expect(find.byType(AdaptiveListTile).evaluate().length, lessThan(30));
        expect(find.byKey(const ValueKey('import-habit-299')), findsNothing);
        scroll.controller!.jumpTo(scroll.controller!.position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('import-habit-299')).hitTestable(),
          findsOneWidget,
        );
        expect(
          tester
              .getCenter(
                find.text(
                  'Habit 299 with a very long descriptive name that wraps',
                ),
              )
              .dy,
          closeTo(
            tester
                .getCenter(
                  find.byKey(const ValueKey('import-habit-299-pending')),
                )
                .dy,
            0.5,
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('publishes progress and blocks dismissal while importing', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(tester.view.reset);
    final importer = _TestImportRunner(deferHabits: true);

    await _pumpHost(tester, platform: TargetPlatform.iOS, importer: importer);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Include 1 habits'));
    await tester.tap(find.text('Include 1 groups'));
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('import-confirm-button')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(importer.habitImportCalls, 0);

    await tester.tap(find.text('Include 1 habits'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('import-confirm-button')));
    await tester.pumpAndSettle();

    expect(importer.habitImportCalls, 1);
    expect(find.byKey(const ValueKey('import-progress')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('adaptive-modal-implied-close')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('import-confirm-button')), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.bySubtype<AdaptiveModal>(), findsOneWidget);

    importer.completeHabits(success: 1, failed: 0);
    await tester.pumpAndSettle();
    expect(find.text('Complete import 1 habits'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('import-complete-button')));
    await tester.pumpAndSettle();
    expect(find.bySubtype<AdaptiveModal>(), findsNothing);
  });

  testWidgets('supports importing groups without habits', (tester) async {
    final importer = _TestImportRunner();
    await _pumpHost(
      tester,
      platform: TargetPlatform.android,
      importer: importer,
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Include 1 habits'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('import-confirm-button')));
    await tester.pumpAndSettle();

    expect(importer.groupImportCalls, 1);
    expect(importer.habitImportCalls, 0);
    expect(importer.lastHabitsData, isEmpty);
    expect(find.text('Completed import 1 groups'), findsOneWidget);
  });
}

Future<void> _pumpHost(
  WidgetTester tester, {
  required TargetPlatform platform,
  required _TestImportRunner importer,
  List<Object?> habits = const [
    <String, Object?>{'name': 'Habit A', 'group_id': 'group-a'},
  ],
  double textScale = 1,
}) => tester.pumpWidget(
  ChangeNotifierProvider<AppEventBus>(
    create: (_) => AppEventBus(),
    child: MaterialApp(
      theme: ThemeData(platform: platform),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showAppSettingImportHabitsConfirmDialog(
              context: context,
              habitsData: habits,
              habitCount: habits.length,
              importer: importer,
              providerName: 'Loop Habit Tracker',
              groupsData: const [
                <String, Object?>{'name': 'Group A', 'uuid': 'group-a'},
              ],
              groupCount: 1,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  ),
);

AdaptiveModalPresentation _presentation(
  WidgetTester tester,
  TargetPlatform platform,
) => platform == TargetPlatform.android
    ? tester
          .widget<MaterialAdaptiveModal>(find.byType(MaterialAdaptiveModal))
          .presentation
    : tester
          .widget<CupertinoAdaptiveModal>(find.byType(CupertinoAdaptiveModal))
          .presentation;

class _TestImportRunner extends HabitFileImportRunner {
  _TestImportRunner({this.deferHabits = false}) {
    attachAccess(_TestHabitAccess(this));
    attachGroupAccess(_TestGroupAccess());
  }

  final bool deferHabits;
  int groupImportCalls = 0;
  int habitImportCalls = 0;
  List<Object?> lastHabitsData = [];
  Completer<int>? _habitCompleter;

  @override
  Future<Map<String, GroupUUID>> importGroupsData(
    Iterable<Object?> jsonData, {
    required ImportMonitor monitor,
    bool listen = true,
  }) async {
    groupImportCalls++;
    return super.importGroupsData(jsonData, monitor: monitor, listen: listen);
  }

  @override
  Future<int> importHabitsData(
    Iterable<Object?> jsonData, {
    required ImportMonitor monitor,
    bool listen = true,
    Map<String, GroupUUID>? groupUuidMapping,
  }) async {
    habitImportCalls++;
    lastHabitsData = jsonData.toList();
    if (deferHabits) _habitCompleter = Completer<int>();
    return super.importHabitsData(
      lastHabitsData,
      monitor: monitor,
      listen: listen,
      groupUuidMapping: groupUuidMapping,
    );
  }

  void completeHabits({required int success, int failed = 0}) {
    _habitCompleter?.complete(success);
  }
}

class _TestHabitAccess implements HabitImportAccess {
  _TestHabitAccess(this.runner);
  final _TestImportRunner runner;

  @override
  int getImportHabitsCount(Iterable<Object?> jsonData) => jsonData.length;

  @override
  List<Future<void>> importHabitsData(
    Iterable<Object?> jsonData, {
    bool withRecords = true,
    Map<String, GroupUUID>? groupUuidMapping,
  }) => [for (final entry in jsonData) _import(entry)];

  Future<void> _import(Object? entry) async {
    final success =
        await (runner._habitCompleter?.future ??
            Future.value(runner.lastHabitsData.length));
    if (runner.lastHabitsData.indexOf(entry) >= success) {
      throw StateError('failed');
    }
  }
}

class _TestGroupAccess implements GroupImportAccess {
  @override
  int getImportGroupsCount(Iterable<Object?> jsonData) => jsonData.length;

  @override
  Future<Map<String, GroupUUID>> importGroupsData(
    Iterable<Object?> jsonData,
  ) async => {'group': 'imported-group'};
}

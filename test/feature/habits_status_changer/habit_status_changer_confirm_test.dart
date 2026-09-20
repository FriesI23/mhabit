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

import 'package:flutter/cupertino.dart' show CupertinoAlertDialog;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_repo_actions.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/habits_status_changer/_providers/habit_status_changer.dart';
import 'package:mhabit/pages/habits_status_changer/page.dart';
import 'package:mhabit/pages/habits_status_changer/widgets.dart';
import 'package:mhabit/providers/app_ui/app_compact_ui_switcher.dart';
import 'package:mhabit/providers/app_ui/app_custom_date_format.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/app_ui/app_first_day.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/adaptive_dialog.dart';
import '../../support/stub/habits_display_access.dart';

const _uuid = '11111111-1111-4111-8111-111111111111';

class _Access extends StubHabitStatusChangerAccess {
  _Access({
    bool existingRecord = true,
    HabitType habitType = HabitType.normal,
    HabitRecordStatus recordStatus = HabitRecordStatus.done,
  }) {
    final date = HabitDate.now();
    habit = HabitSummaryData(
      id: 1,
      uuid: _uuid,
      type: habitType,
      name: 'Test Habit',
      desc: '',
      color: const HabitColor.builtIn(HabitColorType.cc1),
      dailyGoal: 1,
      targetDays: 1,
      frequency: HabitFrequency.daily,
      startDate: date.subtractDays(1),
      status: HabitStatus.activated,
      sortPostion: 1,
      createTime: DateTime(2026),
    );
    if (existingRecord) {
      habit.addRecord(HabitSummaryRecord('record', date, recordStatus, 1));
    }
  }

  late final HabitSummaryData habit;
  final List<List<ChangeRecordStatusResult>> saves = [];

  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async =>
      (initedCollection ?? HabitSummaryDataCollection())
        ..addHabit(habit, forceAdd: true);

  @override
  Future<void> saveChangedHabitRecords({
    required Iterable<ChangeRecordStatusResult> records,
    BeforeHabitRecordReminderUpdateCb? beforeReminderUpdate,
  }) async {
    final saved = records.toList();
    saves.add(saved);
    await beforeReminderUpdate?.call(habit, saved);
  }
}

Future<void> _pumpTransitions(WidgetTester tester) async {
  await tester.pump();
  for (final duration in const [
    Duration(milliseconds: 350),
    Duration(milliseconds: 350),
    Duration(milliseconds: 350),
  ]) {
    await tester.pump(duration);
  }
}

Future<
  ({
    HabitStatusChangerViewModel vm,
    NavigatorState navigator,
    Future<String?> result,
  })
>
_pumpPage(WidgetTester tester, _Access access, TargetPlatform platform) async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel(const []);
  await profile.init();
  final customDate = AppCustomDateYmdHmsConfigViewModel()
    ..updateProfile(profile);
  final firstDay = AppFirstDayViewModel()..updateProfile(profile);
  final compactUi = AppCompactUISwitcherViewModel()..updateProfile(profile);
  final developer = AppDeveloperViewModel(global: Global());
  final appEvent = AppEventBus();
  addTearDown(() {
    appEvent.dispose();
    developer.dispose();
    compactUi.dispose();
    firstDay.dispose();
    customDate.dispose();
    profile.dispose();
  });
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileViewModel>.value(value: profile),
        Provider<HabitStatusChangerAccess>.value(value: access),
        ChangeNotifierProvider<AppCustomDateYmdHmsConfigViewModel>.value(
          value: customDate,
        ),
        ChangeNotifierProvider<AppFirstDayViewModel>.value(value: firstDay),
        ChangeNotifierProvider<AppCompactUISwitcherViewModel>.value(
          value: compactUi,
        ),
        ChangeNotifierProvider<AppDeveloperViewModel>.value(value: developer),
        ChangeNotifierProvider<AppEventBus>.value(value: appEvent),
      ],
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: const Scaffold(body: Text('Home')),
      ),
    ),
  );
  final navigator = Navigator.of(tester.element(find.text('Home')));
  final result = navigator.push<String>(
    MaterialPageRoute(
      builder: (_) => const HabitsStatusChangerPage(uuidList: [_uuid]),
    ),
  );
  await _pumpTransitions(tester);
  final vm = tester
      .element(find.byType(ConfirmButton))
      .read<HabitStatusChangerViewModel>();
  expect(vm.hasLoaded, isTrue);
  return (vm: vm, navigator: navigator, result: result);
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('$platform loads date bounds and keeps empty status', (
      tester,
    ) async {
      final page = await _pumpPage(
        tester,
        _Access(existingRecord: false),
        platform,
      );
      final previousDate = HabitDate.now().subtractDays(1);
      final picker = tester.widget<DatePickerTile>(find.byType(DatePickerTile));
      expect(picker.firstDate, previousDate);
      expect(page.vm.selectStatus, isNull);
      expect(
        tester
            .widget<SegmentedButton<RecordStatusChangerStatus>>(
              find.byType(SegmentedButton<RecordStatusChangerStatus>),
            )
            .selected,
        isEmpty,
      );

      final previousButton = find.descendant(
        of: find.byType(DatePickerTile),
        matching: find.byIcon(Icons.arrow_left_outlined),
      );
      await tester.tap(previousButton);
      await _pumpTransitions(tester);
      expect(page.vm.selectDate, previousDate);
      expect(page.vm.selectStatus, isNull);
    });

    testWidgets('$platform refreshes allowed status after initial load', (
      tester,
    ) async {
      final page = await _pumpPage(
        tester,
        _Access(existingRecord: false, habitType: HabitType.negative),
        platform,
      );
      expect(page.vm.selectStatus, isNull);
      expect(
        tester
            .widget<RecordStatusChangeTile>(find.byType(RecordStatusChangeTile))
            .allowedStatus,
        isNot(contains(RecordStatusChangerStatus.zero)),
      );
    });

    testWidgets('$platform resets skip selection when changing date', (
      tester,
    ) async {
      final page = await _pumpPage(
        tester,
        _Access(recordStatus: HabitRecordStatus.skip),
        platform,
      );
      final datePicker = find.byType(DatePickerTile);
      Set<RecordStatusChangerStatus> selected() => tester
          .widget<SegmentedButton<RecordStatusChangerStatus>>(
            find.byType(SegmentedButton<RecordStatusChangerStatus>),
          )
          .selected;
      AdaptiveIconButton deleteAction() => tester.widget<AdaptiveIconButton>(
        find.ancestor(
          of: find.byIcon(Icons.delete_outline),
          matching: find.byType(AdaptiveIconButton),
        ),
      );
      expect(page.vm.selectStatus, RecordStatusChangerStatus.skip);
      expect(selected(), {RecordStatusChangerStatus.skip});
      expect(deleteAction().onPressed, isNotNull);

      await tester.tap(
        find.descendant(
          of: datePicker,
          matching: find.byIcon(Icons.arrow_left_outlined),
        ),
      );
      await _pumpTransitions(tester);
      expect(page.vm.selectStatus, isNull);
      expect(selected(), isEmpty);
      expect(deleteAction().onPressed, isNull);

      await tester.tap(
        find.descendant(
          of: datePicker,
          matching: find.byIcon(Icons.arrow_right_outlined),
        ),
      );
      await _pumpTransitions(tester);
      expect(page.vm.selectStatus, RecordStatusChangerStatus.skip);
      expect(selected(), {RecordStatusChangerStatus.skip});
      expect(deleteAction().onPressed, isNotNull);
    });

    for (final outcome in ['cancel', 'barrier', 'confirm', 'no-record']) {
      testWidgets('$platform overwrite $outcome', (tester) async {
        final access = _Access(existingRecord: outcome != 'no-record');
        final page = await _pumpPage(tester, access, platform);
        page.vm.updateSelectStatus(RecordStatusChangerStatus.skip);
        await _pumpTransitions(tester);
        expect(page.vm.canSave, isTrue);
        tester
            .widget<ConfirmButton>(find.byType(ConfirmButton))
            .onConfirmPressed!();
        await _pumpTransitions(tester);
        if (outcome != 'no-record') {
          expect(
            find.byType(
              platform == TargetPlatform.iOS
                  ? CupertinoAlertDialog
                  : AlertDialog,
            ),
            findsOneWidget,
          );
          final l10n = L10n.of(tester.element(adaptiveDialogFinder))!;
          expect(
            find.text(l10n.batchCheckin_save_confirmDialog_title),
            findsOneWidget,
          );
          expect(
            find.text(l10n.batchCheckin_save_confirmDialog_body),
            findsOneWidget,
          );
          final confirm = adaptiveDialogActions(tester).last;
          expect(confirm.isDestructiveAction, isTrue);
          expect(confirm.isDefaultAction, isFalse);
          if (outcome == 'cancel') {
            await tester.tap(find.text('cancel'));
          } else if (outcome == 'barrier') {
            await tester.tapAt(const Offset(5, 5));
          } else {
            confirm.onPressed!();
            confirm.onPressed!();
          }
          await _pumpTransitions(tester);
        } else {
          expect(adaptiveDialogFinder, findsNothing);
        }
        if (outcome == 'confirm' || outcome == 'no-record') {
          expect(access.saves, hasLength(1));
          expect(access.saves.single.single.habit.uuid, _uuid);
          expect(page.vm.canSave, isFalse);
          final l10n = L10n.of(tester.element(find.byType(ConfirmButton)))!;
          expect(
            find.text(l10n.batchCheckin_completed_snackbar_text(1)),
            findsOneWidget,
          );
        } else {
          expect(access.saves, isEmpty);
          expect(page.vm.canSave, isTrue);
          expect(page.vm.selectStatus, RecordStatusChangerStatus.skip);
        }
        expect(find.byType(HabitsStatusChangerPage), findsOneWidget);
      });
    }

    for (final outcome in ['cancel', 'confirm', 'no-record']) {
      testWidgets('$platform delete check-ins $outcome', (tester) async {
        final access = _Access(existingRecord: outcome != 'no-record');
        final page = await _pumpPage(tester, access, platform);
        final deleteIcon = find.descendant(
          of: find.byType(HabitStatusChangerAppbar),
          matching: find.byIcon(Icons.delete_outline),
        );
        expect(deleteIcon, findsOneWidget);
        final delete = tester.widget<AdaptiveIconButton>(
          find.ancestor(
            of: deleteIcon,
            matching: find.byType(AdaptiveIconButton),
          ),
        );
        expect(
          find.descendant(
            of: find.byType(ConfirmButton),
            matching: find.byIcon(Icons.delete_outline),
          ),
          findsNothing,
        );
        if (outcome == 'no-record') {
          expect(delete.onPressed, isNull);
          return;
        }
        expect(delete.onPressed, isNotNull);
        await tester.tap(deleteIcon);
        await _pumpTransitions(tester);
        final l10n = L10n.of(tester.element(adaptiveDialogFinder))!;
        expect(
          find.text(l10n.habitRecord_deleteConfirmDialog_title(1)),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: adaptiveDialogFinder,
            matching: find.textContaining('${page.vm.selectDate.year}'),
          ),
          findsOneWidget,
        );
        expect(
          tester
              .widget<AdaptiveConfirmDialog>(find.byType(AdaptiveConfirmDialog))
              .content,
          isA<Text>(),
        );
        expect(adaptiveDialogActions(tester).last.isDestructiveAction, isTrue);
        if (outcome == 'cancel') {
          await tester.tap(find.text('cancel'));
        } else {
          adaptiveDialogActions(tester).last.onPressed!();
        }
        await _pumpTransitions(tester);
        expect(access.saves, hasLength(outcome == 'confirm' ? 1 : 0));
        expect(page.vm.deletableRecordCount, outcome == 'confirm' ? 0 : 1);
        if (outcome == 'confirm') {
          expect(access.saves.single.single.data.isDeleted, isTrue);
          expect(
            tester
                .widget<AdaptiveIconButton>(
                  find.ancestor(
                    of: deleteIcon,
                    matching: find.byType(AdaptiveIconButton),
                  ),
                )
                .onPressed,
            isNull,
          );
        }
      });
    }

    for (final trigger in ['button', 'back']) {
      for (final outcome in ['cancel', 'barrier', 'confirm']) {
        testWidgets('$platform unsaved close $trigger $outcome', (
          tester,
        ) async {
          final access = _Access();
          final page = await _pumpPage(tester, access, platform);
          page.vm.updateSelectStatus(RecordStatusChangerStatus.skip);
          await _pumpTransitions(tester);
          if (trigger == 'button') {
            tester
                .widget<HabitStatusChangerAppbar>(
                  find.byType(HabitStatusChangerAppbar),
                )
                .onCloseButtonPressed!();
          } else {
            await page.navigator.maybePop('back-result');
          }
          await _pumpTransitions(tester);
          expect(
            find.byType(
              platform == TargetPlatform.iOS
                  ? CupertinoAlertDialog
                  : AlertDialog,
            ),
            findsOneWidget,
          );
          final l10n = L10n.of(tester.element(adaptiveDialogFinder))!;
          expect(
            find.text(l10n.batchCheckin_close_confirmDialog_title),
            findsOneWidget,
          );
          expect(
            find.text(l10n.batchCheckin_close_confirmDialog_body),
            findsOneWidget,
          );
          expect(
            adaptiveDialogActions(tester).last.isDestructiveAction,
            isFalse,
          );
          if (outcome == 'cancel') {
            await tester.tap(find.text('cancel'));
          } else if (outcome == 'barrier') {
            await tester.tapAt(const Offset(5, 5));
          } else {
            await tester.tap(find.text('exit'));
          }
          await _pumpTransitions(tester);
          final shouldClose =
              outcome == 'confirm' ||
              (trigger == 'back' && outcome == 'barrier');
          if (shouldClose) {
            expect(find.byType(HabitsStatusChangerPage), findsNothing);
            expect(await page.result, trigger == 'back' ? 'back-result' : null);
          } else {
            expect(find.byType(HabitsStatusChangerPage), findsOneWidget);
            expect(page.vm.canSave, isTrue);
          }
          expect(access.saves, isEmpty);
        });
      }
    }

    testWidgets('$platform delayed close does not pop a newer route', (
      tester,
    ) async {
      final page = await _pumpPage(tester, _Access(), platform);
      var completed = false;
      page.result.then((_) => completed = true);
      tester
          .widget<HabitStatusChangerAppbar>(
            find.byType(HabitStatusChangerAppbar),
          )
          .onCloseButtonPressed!();
      page.navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Other page')),
        ),
      );
      await _pumpTransitions(tester);
      expect(find.text('Other page'), findsOneWidget);
      expect(completed, isFalse);
    });

    testWidgets('$platform unchanged page closes without confirmation', (
      tester,
    ) async {
      final page = await _pumpPage(tester, _Access(), platform);
      expect(page.vm.canSave, isFalse);
      tester
          .widget<HabitStatusChangerAppbar>(
            find.byType(HabitStatusChangerAppbar),
          )
          .onCloseButtonPressed!();
      await _pumpTransitions(tester);
      expect(adaptiveDialogFinder, findsNothing);
      expect(find.byType(HabitsStatusChangerPage), findsNothing);
      expect(await page.result, isNull);
    });
  }
}

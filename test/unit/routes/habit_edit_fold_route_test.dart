import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_daily_goal.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_display.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/routes/app_router.dart';
import 'package:mhabit/routes/helpers/habit_edit_helper.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

HabitForm _editForm(String uuid) => HabitForm(
  name: 'Existing habit',
  type: HabitType.normal,
  color: const HabitColor.builtIn(defaultHabitColorType),
  dailyGoal: HabitDailyGoalData(type: HabitType.normal),
  frequency: HabitFrequency.daily,
  startDate: HabitDate.dateTime(DateTime(2026, 1, 1)),
  targetDays: defaultHabitTargetDays,
  editMode: HabitDisplayEditMode.edit,
  editParams: HabitDisplayEditParams(
    uuid: uuid,
    createT: DateTime(2026, 1, 1),
    modifyT: DateTime(2026, 6, 1),
  ),
);

void main() {
  testWidgets(
    'habit edit extra survives time picker folding and window rebuilds',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1600, 1000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final features = ValueNotifier<List<DisplayFeature>>(const []);
      final adaptation = ValueNotifier((0.0, false));
      addTearDown(features.dispose);
      addTearDown(adaptation.dispose);
      final form = _editForm('edit-fold-regression');
      final receivedForms = <HabitForm>[];
      TimeOfDay? selected;
      final appFlow = AppFlowRouterBuilder()
        ..addHabitEdit(
          builder: (context, state) {
            final params = state.unpackHabitEdit();
            receivedForms.add(params.initForm);
            final size = MediaQuery.sizeOf(context);
            return Scaffold(
              body: Column(
                children: [
                  Text('${params.habitId}:$size'),
                  TextButton(
                    onPressed: () async {
                      selected = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 10, minute: 30),
                      );
                    },
                    child: const Text('Reminder time'),
                  ),
                ],
              ),
            );
          },
        );
      final router =
          (AppRouterBuilder()..addShellRoute(
                appFlow: appFlow,
                branches: [
                  BranchRouterBuilder()..addHabits(
                    builder: (context, _) => Scaffold(
                      body: TextButton(
                        onPressed: () => context.pushHabitEdit(
                          habitId: 'edit-fold-regression',
                          initForm: form,
                        ),
                        child: const Text('Edit habit'),
                      ),
                    ),
                  ),
                ],
                builder: (_, _, child) => child,
                branchBuilder: (_, _, shell) => shell,
              ))
              .build(home: AppRoute.habits);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => ValueListenableBuilder(
            valueListenable: features,
            builder: (context, value, _) => MediaQuery(
              data: MediaQuery.of(context).copyWith(displayFeatures: value),
              child: ValueListenableBuilder<(double, bool)>(
                valueListenable: adaptation,
                child: child,
                builder: (_, value, routing) =>
                    AdaptiveWindowControlLayoutScope(
                      hasWindowControlAvoidance: value.$2,
                      horizontalAvoidance: EdgeInsets.zero,
                      verticalAvoidance: EdgeInsets.zero,
                      horizontalSafeAreaAvoidance: EdgeInsets.zero,
                      verticalSafeAreaAvoidance: EdgeInsets.only(top: value.$1),
                      effectiveCornerRadii: BorderRadius.zero,
                      owner: WindowControlLayoutOwner.appBar,
                      child: AdaptiveWindowTopSafeArea(child: routing!),
                    ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit habit'));
      await tester.pumpAndSettle();
      expect(receivedForms, isNotEmpty);
      await tester.tap(find.text('Reminder time'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      final routingState = tester.state(
        find.byWidgetPredicate((widget) => widget is Router),
      );
      final pickerState = tester.state(find.byType(TimePickerDialog));
      features.value = const [
        DisplayFeature(
          bounds: Rect.fromLTWH(790, 0, 20, 1000),
          type: DisplayFeatureType.fold,
          state: DisplayFeatureState.postureHalfOpened,
        ),
      ];
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final geometry in [(16.0, false), (16.0, true), (0.0, false)]) {
        adaptation.value = geometry;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.state(find.byWidgetPredicate((widget) => widget is Router)),
          same(routingState),
        );
        expect(tester.state(find.byType(TimePickerDialog)), same(pickerState));
      }
      tester.view.physicalSize = const Size(430, 932);
      features.value = const [];
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(selected, const TimeOfDay(hour: 10, minute: 30));
      expect(receivedForms, everyElement(same(form)));
      expect(find.textContaining('edit-fold-regression:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

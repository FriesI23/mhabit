import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_color_type.dart';
import 'package:mhabit/pages/habit_edit/_widgets/habit_date_picker.dart';
import 'package:mhabit/providers/app_ui/app_first_day.dart';
import 'package:mhabit/utils/app_clock.dart';
import 'package:mhabit/widgets/_widgets/date_picker.dart';
import 'package:mhabit/widgets/_widgets/date_picker_custom.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:quiver/time.dart';

final _initial = DateTime.now().copyWith(
  day: 15,
  hour: 14,
  minute: 23,
  second: 45,
  millisecond: 678,
  microsecond: 321,
);

const _window = Size(951, 669);

Future<({Future<DateTime?> result})> _openPicker(
  WidgetTester tester, {
  required bool verticalFold,
  required bool useMaterial3,
  required double textScale,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _window;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final feature = DisplayFeature(
    bounds: verticalFold
        ? const Rect.fromLTWH(455, 0, 40, 669)
        : const Rect.fromLTWH(0, 315, 951, 40),
    type: DisplayFeatureType.fold,
    state: DisplayFeatureState.postureHalfOpened,
  );
  late Future<DateTime?> result;
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: useMaterial3),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          displayFeatures: [feature],
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () {
              result = showAdaptiveModalDialog<DateTime>(
                context: context,
                styleOverride: AdaptiveStyle.material,
                barrierDismissible: true,
                builder: (context) => HabitDatetimePickerDialog(
                  currentDateTime: _initial,
                  initialDate: _initial,
                  firstDate: DateTime(_initial.year - 1),
                  lastDate: DateTime(_initial.year + 1, 12, 31),
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                ),
              );
            },
            child: const Text('Open picker'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open picker'));
  await tester.pumpAndSettle();
  return (result: result);
}

void _expectContained(WidgetTester tester, Finder finder, Rect pane) {
  expect(finder, findsOneWidget);
  final bounds = tester.getRect(finder);
  expect(pane.inflate(0.5).contains(bounds.topLeft), isTrue, reason: '$bounds');
  expect(
    pane.inflate(0.5).contains(bounds.bottomRight),
    isTrue,
    reason: '$bounds',
  );
}

void main() {
  for (final initiallyFolded in [true, false]) {
    testWidgets(
      'production start-date keeps weekday override and selection through '
      '${initiallyFolded ? 'fold-flat-fold' : 'flat-fold-flat'}',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = _window;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        final originalClock = AppClock().clock;
        AppClock().setClock(Clock(() => _initial));
        addTearDown(() => AppClock().setClock(originalClock));

        MediaQueryData geometry(bool folded) => MediaQueryData(
          size: _window,
          displayFeatures: folded
              ? const [
                  DisplayFeature(
                    bounds: Rect.fromLTWH(455, 0, 40, 669),
                    type: DisplayFeatureType.fold,
                    state: DisplayFeatureState.postureHalfOpened,
                  ),
                ]
              : const [],
        );

        final media = ValueNotifier(geometry(initiallyFolded));
        addTearDown(media.dispose);
        late Future<DateTime?> result;
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => AppFirstDayViewModel(),
            child: MaterialApp(
              theme: ThemeData(useMaterial3: true),
              locale: const Locale('en'),
              localizationsDelegates: appLocalizationsDelegates,
              supportedLocales: L10n.supportedLocales,
              builder: (context, child) => ValueListenableBuilder(
                valueListenable: media,
                builder: (_, value, child) =>
                    MediaQuery(data: value, child: child!),
                child: child,
              ),
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () {
                      result = showHabitDatePickerDialog(
                        context: context,
                        date: _initial,
                        color: const HabitColor.builtIn(HabitColorType.cc1),
                      );
                    },
                    child: const Text('Open production picker'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open production picker'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('20'));
        await tester.pumpAndSettle();

        for (final folded in [!initiallyFolded, initiallyFolded]) {
          media.value = geometry(folded);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final calendar = find.byType(CalendarDatePicker);
          expect(calendar, findsOneWidget);
          expect(
            MaterialLocalizations.of(
              tester.element(calendar),
            ).firstDayOfWeekIndex,
            DateTime.monday,
          );
          expect(
            tester.widget<CalendarDatePicker>(calendar).initialDate,
            DateUtils.dateOnly(_initial.copyWith(day: 20)),
          );
        }

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(await result, _initial.copyWith(day: 20));
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final verticalFold in [true, false]) {
    for (final material3 in [false, true]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets(
          '${verticalFold ? 'vertical' : 'horizontal'} fold '
          'M${material3 ? 3 : 2} scale $scale keeps calendar and actions reachable',
          (tester) async {
            final opened = await _openPicker(
              tester,
              verticalFold: verticalFold,
              useMaterial3: material3,
              textScale: scale,
            );
            final pane = verticalFold
                ? const Rect.fromLTWH(0, 0, 455, 669)
                : const Rect.fromLTWH(0, 0, 951, 315);
            _expectContained(tester, find.byType(CalendarDatePicker), pane);
            _expectContained(tester, find.byType(DatePickerChipContent), pane);
            _expectContained(tester, find.text('OK'), pane);
            expect(tester.takeException(), isNull);

            await tester.tap(find.text('20'));
            await tester.pumpAndSettle();
            await tester.tap(find.text('OK'));
            await tester.pumpAndSettle();
            expect(await opened.result, _initial.copyWith(day: 20));
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('shortcut selection preserves the original time', (tester) async {
    final opened = await _openPicker(
      tester,
      verticalFold: true,
      useMaterial3: true,
      textScale: 1,
    );
    final picker = tester.widget<HabitDatetimePickerDialog>(
      find.byType(HabitDatetimePickerDialog),
    );
    await tester.ensureVisible(find.text('Today'));
    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(
      await opened.result,
      _initial.copyWith(
        year: picker.currentDate.year,
        month: picker.currentDate.month,
        day: picker.currentDate.day,
      ),
    );
  });

  testWidgets('cancel discards a calendar selection', (tester) async {
    final opened = await _openPicker(
      tester,
      verticalFold: false,
      useMaterial3: true,
      textScale: 1,
    );
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await opened.result, isNull);
  });
}

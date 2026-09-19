// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/custom_date_format.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';
import 'package:mhabit/providers/app_ui/app_theme.dart';
import 'package:mhabit/theme/color.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

class _Theme extends AppThemeViewModel {
  AppThemeType mode = AppThemeType.followSystem;
  int changes = 0;

  @override
  AppThemeType get themeType => mode;

  @override
  Future<void> setNewthemeType(AppThemeType value) async {
    mode = value;
    changes++;
    notifyListeners();
  }
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final locale in [
      const Locale('en'),
      const Locale('zh'),
      const Locale('de'),
    ]) {
      testWidgets('Display controls at narrow 2x $platform $locale', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final semantics = tester.ensureSemantics();
        try {
          final theme = _Theme();
          addTearDown(theme.dispose);
          var percentage = 50;
          var sliderChanges = 0;
          var firstDay = DateTime.monday;
          var colorTaps = 0;
          var dateTaps = 0;
          await tester.pumpWidget(
            ChangeNotifierProvider<AppThemeViewModel>.value(
              value: theme,
              child: MaterialApp(
                theme: ThemeData(platform: platform),
                locale: locale,
                localizationsDelegates: L10n.localizationsDelegates,
                supportedLocales: L10n.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                ),
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: StatefulBuilder(
                      builder: (context, setState) => AdaptiveListSection(
                        children: [
                          const AppSettingThemeModeTile(),
                          AppSettingThemeColorTile(
                            onPressed: () => colorTaps++,
                          ),
                          AppSettingFirstDayTile(
                            firstDay: firstDay,
                            onPressed: () async {
                              final result =
                                  await showAppSettingFirstDaySelectDialog(
                                    context: context,
                                    firstDay: firstDay,
                                  );
                              if (result != null) {
                                setState(() => firstDay = result);
                              }
                            },
                          ),
                          AppSettingDateDisplayFormatListTile(
                            config: const CustomDateYmdHmsConfig.withDefault(),
                            onPressed: () => dateTaps++,
                          ),
                          AppSettingCalbarOccupyTile(
                            currentPercentage: percentage,
                            normalPercentage: 50,
                            lessPercentage: 30,
                            morePercentage: 70,
                            onSelectionChanged: (value) => setState(() {
                              percentage = value;
                              sliderChanges++;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final context = tester.element(find.byType(AppSettingThemeModeTile));
          final l10n = L10n.of(context)!;
          if (platform == TargetPlatform.android) {
            await tester.tap(find.byKey(const ValueKey('theme-mode-control')));
            await tester.pumpAndSettle();
          }
          await tester.tap(find.text(l10n.common_appThemeMode_dark));
          await tester.pumpAndSettle();
          expect(theme.mode, AppThemeType.dark);
          expect(theme.changes, 1);
          await tester.tap(find.byType(AppSettingThemeColorTile));
          await tester.tap(find.byType(AppSettingDateDisplayFormatListTile));
          expect(colorTaps, 1);
          expect(dateTaps, 1);
          final slider = find.byType(
            platform == TargetPlatform.iOS ? CupertinoSlider : Slider,
          );
          await tester.ensureVisible(slider);
          await tester.drag(slider, const Offset(75, 0));
          await tester.pumpAndSettle();
          expect(percentage, greaterThan(50));
          expect(percentage % 5, 0);
          expect(sliderChanges, greaterThan(0));
          if (platform == TargetPlatform.iOS) {
            final node = tester.getSemantics(
              find.byKey(const ValueKey('calendar-occupancy-control')),
            );
            final before = percentage;
            final beforeChanges = sliderChanges;
            expect(node.getSemanticsData().value, '+${(before - 50) ~/ 5}');
            node.owner!.performAction(node.id, SemanticsAction.decrease);
            await tester.pumpAndSettle();
            expect(percentage, before - 5);
            expect(sliderChanges, beforeChanges + 1);
          }
          expect(tester.takeException(), isNull);
          // The legacy dialog layout belongs to the later Dialog slice.
          tester.view.physicalSize = const Size(800, 2400);
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.byType(AppSettingFirstDayTile));
          await tester.tap(find.byType(AppSettingFirstDayTile));
          await tester.pumpAndSettle();
          Navigator.of(
            tester.element(find.byType(AppSettingFirstDaySelectDialog)),
          ).pop();
          await tester.pumpAndSettle();
          expect(firstDay, DateTime.monday);
          await tester.tap(find.byType(AppSettingFirstDayTile));
          await tester.pumpAndSettle();
          final tuesday = find.byKey(const ValueKey('first-day-option-2'));
          await Scrollable.ensureVisible(
            tester.element(tuesday),
            alignment: 0.5,
          );
          await tester.pumpAndSettle();
          await tester.tap(tuesday);
          await tester.pumpAndSettle();
          expect(firstDay, DateTime.tuesday);
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      });
    }
  }
}

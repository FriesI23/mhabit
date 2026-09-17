import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_theme_color.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/pages/app_settings/_widgets/app_setting_theme_color.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final debug in [false, true]) {
      testWidgets('Theme color selection $platform debug $debug', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 1000);
        addTearDown(tester.view.reset);
        final developer = AppDeveloperViewModel(
          global: Global()..switchDevelopMode(debug),
        );
        addTearDown(developer.dispose);
        AppThemeColor? result;
        var completions = 0;
        await tester.pumpWidget(
          ChangeNotifierProvider<AppDeveloperViewModel>.value(
            value: developer,
            child: MaterialApp(
              theme: ThemeData(
                platform: platform,
                brightness: debug ? Brightness.dark : Brightness.light,
              ),
              locale: const Locale('de'),
              localizationsDelegates: L10n.localizationsDelegates,
              supportedLocales: L10n.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(debug ? 2 : 1)),
                child: Directionality(
                  textDirection: debug ? TextDirection.rtl : TextDirection.ltr,
                  child: child!,
                ),
              ),
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () async {
                      result = await showAppThemeColorChangerDialog(
                        context: context,
                        selectedColor: const PrimaryAppThemeColor(),
                      );
                      completions++;
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );
        Future<void> open() async {
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
        }

        await open();
        expect(find.byType(AdaptiveCheckmark), findsOneWidget);
        final rows = find.byType(AdaptiveListTile);
        final values = <AppThemeColor>[
          const SystemAppThemeColor(),
          const PrimaryAppThemeColor(),
          if (!Platform.isIOS) const DynamicAppThemeColor(),
          for (final type in HabitColorType.values)
            InternalAppThemeColor(colorType: type),
        ];
        expect(rows, findsNWidgets(values.length));
        for (final size in [
          const Size(320, 700),
          const Size(900, 400),
          const Size(1000, 1000),
        ]) {
          tester.view.physicalSize = size;
          await tester.pumpAndSettle();
          expect(completions, 0);
          expect(tester.takeException(), isNull);
        }
        for (var i = 0; i < values.length; i++) {
          if (i > 0) await open();
          final row = rows.at(i);
          await Scrollable.ensureVisible(tester.element(row), alignment: 0.5);
          await tester.pumpAndSettle();
          await tester.tap(row);
          await tester.pumpAndSettle();
          expect(result, values[i]);
          expect(completions, i + 1);
        }
        await open();
        await tester.tap(
          find.byKey(const ValueKey('adaptive-modal-implied-close')),
        );
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(completions, values.length + 1);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/custom_date_format.dart';
import 'package:mhabit/pages/app_date_format/page.dart';
import 'package:mhabit/providers/app_ui/app_custom_date_format.dart';
import 'package:mhabit/utils/app_clock.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:quiver/time.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('publishes each change immediately on $platform', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final viewModel = _TestDateFormatViewModel(
        const CustomDateYmdHmsConfig.withDefault(),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<AppCustomDateYmdHmsConfigViewModel>.value(
          value: viewModel,
          child: MaterialApp(
            theme: ThemeData(platform: platform),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => const AppDateFormatPage(),
                      ),
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

      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(AdaptiveSliverAppBar), findsOneWidget);
      expect(find.text('Save'), findsNothing);
      expect(find.byKey(const ValueKey('date-format-preview')), findsOneWidget);
      expect(find.byKey(const ValueKey('date-format-order')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('date-format-use-system')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('date-format-order')), findsOneWidget);
      expect(viewModel.changes.last.useSystemFormat, isFalse);
      if (platform == TargetPlatform.android) {
        expect(
          find.byType(SegmentedButton<YearMonthDayFormtEnum>),
          findsNothing,
        );
        await tester.tap(find.byKey(const ValueKey('date-format-order')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Month Day Year').last);
      await tester.pumpAndSettle();

      final leadingZero = find.text('Use leading zeros');
      await tester.ensureVisible(leadingZero);
      await tester.tap(leadingZero);
      await tester.pumpAndSettle();

      expect(viewModel.changes.last.useSystemFormat, isFalse);
      expect(
        viewModel.changes.last.ymdFormat,
        YearMonthDayFormtEnum.monthDayYear,
      );
      expect(viewModel.changes.last.useLeadingZero, isTrue);
    });
  }

  testWidgets('reads the app config directly', (tester) async {
    final viewModel = _TestDateFormatViewModel(
      const CustomDateYmdHmsConfig(
        ymdFormat: YearMonthDayFormtEnum.yearMonthDay,
        splitChar: DateSplitCharEnum.slash,
        twelveHoursOn: false,
        useSystemFormat: false,
      ),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<AppCustomDateYmdHmsConfigViewModel>.value(
        value: viewModel,
        child: const MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: AppDateFormatPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('date-format-order')), findsOneWidget);
    final useSystem = tester.widget<AdaptiveSwitchListTile>(
      find.byKey(const ValueKey('date-format-use-system')),
    );
    expect(useSystem.value, isFalse);
  });

  testWidgets('back keeps already published changes', (tester) async {
    final viewModel = _TestDateFormatViewModel(
      const CustomDateYmdHmsConfig.withDefault(),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<AppCustomDateYmdHmsConfigViewModel>.value(
        value: viewModel,
        child: MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => const AppDateFormatPage(),
                    ),
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
    await tester.tap(find.byKey(const ValueKey('date-format-use-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AdaptiveBackButton));
    await tester.pumpAndSettle();

    expect(viewModel.changes, hasLength(1));
    expect(viewModel.changes.single.useSystemFormat, isFalse);
  });

  testWidgets('preview refreshes every second', (tester) async {
    final appClock = AppClock();
    final originalClock = appClock.clock;
    var now = DateTime(2026, 9, 18, 10, 20, 30);
    appClock.setClock(Clock(() => now));
    addTearDown(() => appClock.setClock(originalClock));
    final viewModel = _TestDateFormatViewModel(
      const CustomDateYmdHmsConfig.withDefault(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppCustomDateYmdHmsConfigViewModel>.value(
        value: viewModel,
        child: const MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: AppDateFormatPage(),
        ),
      ),
    );

    final formatter = viewModel.config.getFormatter('en');
    expect(find.text(formatter.format(now)), findsOneWidget);

    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(formatter.format(now)), findsOneWidget);
  });
}

class _TestDateFormatViewModel extends AppCustomDateYmdHmsConfigViewModel {
  _TestDateFormatViewModel(this._config);

  CustomDateYmdHmsConfig _config;
  final List<CustomDateYmdHmsConfig> changes = [];

  @override
  CustomDateYmdHmsConfig get config => _config;

  @override
  Future<void> setNewConfig(CustomDateYmdHmsConfig newConfig) async {
    _config = newConfig;
    changes.add(newConfig);
    notifyListeners();
  }
}

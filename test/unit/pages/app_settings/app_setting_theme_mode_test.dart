// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';
import 'package:mhabit/providers/app_ui/app_theme.dart';
import 'package:mhabit/theme/color.dart';
import 'package:mhabit/widgets/_widgets/app_ui_layout_builder.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

class _TestThemeViewModel extends AppThemeViewModel {
  AppThemeType value = AppThemeType.followSystem;

  @override
  AppThemeType get themeType => value;

  @override
  Future<void> setNewthemeType(AppThemeType newThemeType) async {
    value = newThemeType;
    notifyListeners();
  }
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('theme mode layout follows viewport height on $platform', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final viewModel = _TestThemeViewModel();
      addTearDown(viewModel.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<AppThemeViewModel>.value(
          value: viewModel,
          child: MaterialApp(
            theme: ThemeData(platform: platform),
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: WindowSizeClassLayoutBuilder(
                  builder: (context, windowSize, child) =>
                      AppSettingThemeModeTile(
                        useSideBySideLayout:
                            windowSize.width >= WindowSizeClass.medium,
                      ),
                ),
              ),
            ),
          ),
        ),
      );
      final apple = platform == TargetPlatform.iOS;
      final tile = find.byType(AppSettingThemeModeTile);
      final control = find.byKey(const ValueKey('theme-mode-control'));
      expect(
        tester.widget<AppSettingThemeModeTile>(tile).useSideBySideLayout,
        isTrue,
      );
      if (apple) {
        expect(
          tester.getCenter(find.text('Theme Mode')).dy,
          closeTo(tester.getCenter(control).dy, 1),
        );
      }
      tester.view.physicalSize = const Size(1000, 400);
      await tester.pumpAndSettle();
      expect(
        tester.widget<AppSettingThemeModeTile>(tile).useSideBySideLayout,
        isFalse,
      );
      if (apple) {
        expect(
          tester.getBottomLeft(find.text('Theme Mode')).dy,
          lessThan(tester.getTopLeft(control).dy),
        );
      } else {
        await tester.tap(control);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(viewModel.value, AppThemeType.dark);
      tester.view.physicalSize = const Size(1000, 700);
      await tester.pumpAndSettle();
      expect(
        tester.widget<AppSettingThemeModeTile>(tile).useSideBySideLayout,
        isTrue,
      );
      if (apple) {
        expect(
          tester.getCenter(find.text('Theme Mode')).dy,
          closeTo(tester.getCenter(control).dy, 1),
        );
      }
      expect(viewModel.value, AppThemeType.dark);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Theme Mode can be changed in a localized app', (tester) async {
    const locale = Locale('zh');
    final viewModel = _TestThemeViewModel();
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppThemeViewModel>.value(
        value: viewModel,
        child: const MaterialApp(
          locale: locale,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: Scaffold(body: AppSettingThemeModeTile()),
        ),
      ),
    );

    final l10n = lookupL10n(locale);
    await tester.tap(find.byKey(const ValueKey('theme-mode-control')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.common_appThemeMode_dark));
    await tester.pumpAndSettle();
    expect(viewModel.value, AppThemeType.dark);
  });

  testWidgets('Theme Mode tile selects an exact mode', (tester) async {
    final viewModel = _TestThemeViewModel();
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppThemeViewModel>.value(
        value: viewModel,
        child: const MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: Scaffold(body: AppSettingThemeModeTile()),
        ),
      ),
    );

    expect(find.text('Auto'), findsOneWidget);
    expect(find.byType(MenuAnchor), findsOneWidget);
    expect(find.byType(SegmentedButton<AppThemeType>), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('theme-mode-control')),
        matching: find.text('Auto'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('theme-mode-control')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(viewModel.value, AppThemeType.dark);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('Theme Mode tile keeps the Apple segmented control', (
    tester,
  ) async {
    final viewModel = _TestThemeViewModel();
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppThemeViewModel>.value(
        value: viewModel,
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: const Scaffold(
            body: AppSettingThemeModeTile(useSideBySideLayout: true),
          ),
        ),
      ),
    );

    expect(
      find.byType(CupertinoSlidingSegmentedControl<AppThemeType>),
      findsOneWidget,
    );
    expect(find.byType(CupertinoMenuAnchor), findsNothing);
    expect(find.byType(MenuAnchor), findsNothing);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(viewModel.value, AppThemeType.dark);
  });
}

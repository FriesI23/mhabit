// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';
import 'package:mhabit/providers/app_ui/app_theme.dart';
import 'package:mhabit/theme/color.dart';
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
  const localizedLabels = <(Locale, String, String, String, String)>[
    (Locale('en'), 'Theme Mode', 'Follow System', 'Light Theme', 'Dark Theme'),
    (Locale('zh'), '主题模式', '跟随系统', '明亮主题', '黑暗主题'),
    (
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      '主題模式',
      '依照系統設定',
      '淺色主題',
      '深色主題',
    ),
  ];

  for (final entry in localizedLabels) {
    testWidgets('Theme Mode labels localize for ${entry.$1}', (tester) async {
      final viewModel = _TestThemeViewModel();
      addTearDown(viewModel.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<AppThemeViewModel>.value(
          value: viewModel,
          child: MaterialApp(
            locale: entry.$1,
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            home: const Scaffold(body: AppSettingThemeModeTile()),
          ),
        ),
      );

      expect(find.text(entry.$2), findsOneWidget);
      expect(find.text(entry.$3), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('theme-mode-control')));
      await tester.pumpAndSettle();
      expect(find.text(entry.$4), findsOneWidget);
      expect(find.text(entry.$5), findsOneWidget);
    });
  }

  testWidgets('Theme Mode tile selects an exact mode', (tester) async {
    final viewModel = _TestThemeViewModel();
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppThemeViewModel>.value(
        value: viewModel,
        child: const MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: Scaffold(body: AppSettingThemeModeTile()),
        ),
      ),
    );

    expect(find.text('Follow System'), findsOneWidget);
    final anchor = tester.widget<MenuAnchor>(find.byType(MenuAnchor));
    expect(anchor.animated, isTrue);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('theme-mode-control')),
        matching: find.text('Follow System'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('theme-mode-control')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark Theme'));
    await tester.pumpAndSettle();

    expect(viewModel.value, AppThemeType.dark);
    expect(find.text('Dark Theme'), findsOneWidget);
  });
}

// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'package:flutter/cupertino.dart';
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
    (Locale('en'), 'Theme Mode', 'Auto', 'Light', 'Dark'),
    (Locale('zh'), '主题模式', '自动', '浅色', '深色'),
    (
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      '主題模式',
      '自動',
      '淺色',
      '深色',
    ),
  ];

  final themeModeLabels = <Locale, (String, String, String)>{
    const Locale('ar'): ('فاتح', 'داكن', 'تلقائي'),
    const Locale('cs'): ('Světlý', 'Tmavý', 'Automaticky'),
    const Locale('de'): ('Hell', 'Dunkel', 'Automatisch'),
    const Locale('en'): ('Light', 'Dark', 'Auto'),
    const Locale('es'): ('Claro', 'Oscuro', 'Automático'),
    const Locale('eu'): ('Argia', 'Iluna', 'Automatikoa'),
    const Locale('fa'): ('روشن', 'تیره', 'خودکار'),
    const Locale('fr'): ('Clair', 'Sombre', 'Auto'),
    const Locale('he'): ('בהיר', 'כהה', 'אוטומטי'),
    const Locale('hu'): ('Világos', 'Sötét', 'Automatikus'),
    const Locale('it'): ('Chiaro', 'Scuro', 'Auto'),
    const Locale('ja'): ('ライト', 'ダーク', '自動'),
    const Locale('nb'): ('Lys', 'Mørk', 'Auto'),
    const Locale('nl'): ('Licht', 'Donker', 'Automatisch'),
    const Locale('pl'): ('Jasny', 'Ciemny', 'Automatyczny'),
    const Locale('pt'): ('Claro', 'Escuro', 'Automático'),
    const Locale('ru'): ('Светлая', 'Тёмная', 'Авто'),
    const Locale('tr'): ('Açık', 'Koyu', 'Otomatik'),
    const Locale('uk'): ('Світла', 'Темна', 'Авто'),
    const Locale('vi'): ('Sáng', 'Tối', 'Tự động'),
    const Locale('zh'): ('浅色', '深色', '自动'),
    const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'): (
      '淺色',
      '深色',
      '自動',
    ),
  };

  test('all supported locales use the exact short theme mode labels', () {
    expect(themeModeLabels.keys.toSet(), L10n.supportedLocales.toSet());
    for (final MapEntry(key: locale, value: labels)
        in themeModeLabels.entries) {
      final l10n = lookupL10n(locale);
      expect(
        (
          l10n.common_appThemeMode_light,
          l10n.common_appThemeMode_dark,
          l10n.common_appThemeMode_followSystem,
        ),
        labels,
        reason: locale.toLanguageTag(),
      );
    }
  });

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
      await tester.tap(find.byKey(const ValueKey('theme-mode-control')));
      await tester.pumpAndSettle();
      expect(find.text(entry.$3), findsWidgets);
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
          localizationsDelegates: L10n.localizationsDelegates,
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

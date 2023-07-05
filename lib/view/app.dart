// Copyright 2023 Fries_I23
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

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../common/consts.dart';
import '../common/global.dart';
import '../l10n/localizations.dart';
import '../model/global.dart';
import '../provider/app_compact_ui_switcher.dart';
import '../provider/app_custom_date_format.dart';
import '../provider/app_developer.dart';
import '../provider/app_first_day.dart';
import '../provider/app_reminder.dart';
import '../provider/app_theme.dart';
import '../provider/habit_date_change.dart';
import '../provider/habits_file_exporter.dart';
import '../provider/habits_file_importer.dart';
import '../reminders/notification_channel.dart';
import '../theme/color.dart';
import 'common/_widget.dart';
import 'page_habits_display.dart' show PageHabitsDisplay;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('------ App start ------');

    return MultiProvider(
      providers: [
        Provider<Global>(
          create: (context) => Global(),
        ),
        ChangeNotifierProvider<NotificationChannelData>(
          create: (context) => NotificationChannelData(),
        ),
        ChangeNotifierProvider<HabitDateChangeNotifier>(
          create: (context) => HabitDateChangeNotifier(),
        ),
        ChangeNotifierProxyProvider<Global, AppThemeViewModel>(
          create: (context) =>
              AppThemeViewModel(global: context.read<Global>()),
          update: (context, value, previous) => previous!..updateGlobal(value),
        ),
        ChangeNotifierProxyProvider<Global, AppCompactUISwitcherViewModel>(
          create: (context) =>
              AppCompactUISwitcherViewModel(global: context.read<Global>()),
          update: (context, value, previous) => previous!..updateGlobal(value),
        ),
        ChangeNotifierProxyProvider<Global, AppFirstDayViewModel>(
          create: (context) =>
              AppFirstDayViewModel(global: context.read<Global>()),
          update: (context, value, previous) => previous!..updateGlobal(value),
        ),
        ChangeNotifierProxyProvider<Global, AppCustomDateYmdHmsConfigViewModel>(
          create: (context) => AppCustomDateYmdHmsConfigViewModel(
              global: context.read<Global>()),
          update: (context, value, previous) => previous!..updateGlobal(value),
        ),
        ChangeNotifierProxyProvider2<Global, NotificationChannelData,
            AppReminderViewModel>(
          lazy: false,
          create: (context) =>
              AppReminderViewModel(global: context.read<Global>()),
          update: (context, global, channel, previous) => previous!
            ..updateGlobal(global)
            ..setNotificationChannelData(channel, l10n: L10n.of(context)),
        ),
        ChangeNotifierProxyProvider<Global, AppDeveloperViewModel>(
          create: (context) =>
              AppDeveloperViewModel(global: context.read<Global>()),
          update: (context, value, previous) => previous!..updateGlobal(value),
        ),
        ChangeNotifierProvider<HabitFileExporterViewModel>(
          create: (context) => HabitFileExporterViewModel(),
        ),
        ChangeNotifierProvider<HabitFileImporterViewModel>(
          create: (context) => HabitFileImporterViewModel(),
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<StatefulWidget> createState() => _AppView();
}

class _AppView extends State<AppView> {
  ThemeData _getLightThemeData(BuildContext context,
      {ColorScheme? dynamicColor}) {
    ColorScheme appColorLight = ColorScheme.fromSeed(
      seedColor: context.read<Global>().themeMainColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: dynamicColor ?? appColorLight,
      useMaterial3: true,
      extensions: [modifedLightCustomColors],
    );
  }

  ThemeData _getDartThemeData(BuildContext context,
      {ColorScheme? dynamicColor}) {
    ColorScheme appColorDark = ColorScheme.fromSeed(
      seedColor: context.read<Global>().themeMainColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: dynamicColor ?? appColorDark,
      useMaterial3: true,
      extensions: [darkCustomColors],
    );
  }

  @override
  Widget build(BuildContext context) {
    var homePage = const PageHabitsDisplay();

    return Selector<AppThemeViewModel, ThemeMode>(
      selector: (context, viewmodel) => viewmodel.matertialThemeType,
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, themeMode, child) => DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) => HabitDateChangeBuilder(
          interval: const Duration(seconds: 10),
          builder: (context) => MaterialApp(
            onGenerateTitle: (context) => L10n.of(context)?.appName ?? appName,
            scaffoldMessengerKey: snackbarKey,
            theme: _getLightThemeData(context, dynamicColor: lightDynamic),
            darkTheme: _getDartThemeData(context, dynamicColor: darkDynamic),
            themeMode: themeMode,
            home: child,
            localizationsDelegates: const [
              L10n.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale.fromSubtags(languageCode: 'en'),
              Locale.fromSubtags(languageCode: 'zh')
            ],
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
      child: homePage,
    );
  }
}

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
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../common/consts.dart';
import '../common/global.dart';
import '../extension/context_extensions.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../persistent/db_helper_builder.dart';
import '../persistent/profile/handler/app_language.dart';
import '../persistent/profile/handlers.dart';
import '../persistent/profile_builder.dart';
import '../persistent/profile_provider.dart';
import '../provider/app_debugger.dart';
import '../provider/app_language.dart';
import '../provider/app_reminder.dart';
import '../provider/app_theme.dart';
import '../theme/color.dart';
import 'common/_widget.dart';
import 'for_app/_widget.dart';
import 'page_habits_display.dart' show PageHabitsDisplay;

/// Note: [AppProviders] are use to build providers that need to be initialized
/// in [MaterialApp]. An important to note that, e.g., [Localizations] are
/// initialized within MaterialApp. Some feature that depend on these inherited
/// widgets can be initialized in [_AppPostInit].
class App extends StatelessWidget {
  static final _profileHandlers = <ProfileHandlerBuilder>[
    AppReminderProfileHandler.new,
    AppThemeTypeProfileHandler.new,
    AppThemeMainColorProfileHandler.new,
    CompactUISwitcherProfileHandler.new,
    DisplaySortModeProfileHandler.new,
    DisplayHabitsFilterProfileHandler.new,
    DisplayCalendarScrollModeProfileHandler.new,
    DisplayCalendartBarOccupyPrtProfileHandler.new,
    ShowDateFormatProfileHandler.new,
    FirstDayProfileHandler.new,
    HabitCellGestureModeProfileHandler.new,
    InputFillCacheProfileHandler.new,
    CollectLogswitcherProfileHandler.new,
    LoggingLevelProfileHandler.new,
    AppLanguageProfileHanlder.new,
  ];

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    appLog.debugger.info("App Running Now", ex: [DateTime.now()]);
    return ProfileBuilder(
      handlers: _profileHandlers,
      builder: (context, child) => DBHelperBuilder(
        builder: (context, child) => DateChanger(
          interval: const Duration(seconds: 10),
          builder: (context) => const AppProviders(child: AppView()),
        ),
      ),
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
      {ColorScheme? dynamicColor, required Color mainColor}) {
    final ColorScheme appColorLight = ColorScheme.fromSeed(
      seedColor: mainColor,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: dynamicColor ?? appColorLight,
      useMaterial3: true,
      extensions: [modifedLightCustomColors],
    );
  }

  ThemeData _getDartThemeData(BuildContext context,
      {ColorScheme? dynamicColor, required Color mainColor}) {
    final ColorScheme appColorDark = ColorScheme.fromSeed(
      seedColor: mainColor,
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
    const homePage = _AppPostInit(child: PageHabitsDisplay());

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) =>
          Selector<AppLanguageViewModel, Locale?>(
        selector: (context, vm) => vm.languange,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, language, child) =>
            Selector<AppThemeViewModel, Tuple2<ThemeMode, Color>>(
          selector: (context, viewmodel) =>
              Tuple2(viewmodel.matertialThemeType, viewmodel.mainColor),
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, appThemeArgs, child) {
            final themeMode = appThemeArgs.item1;
            final themeMainColor = appThemeArgs.item2;
            return MaterialApp(
              onGenerateTitle: (context) =>
                  L10n.of(context)?.appName ?? appName,
              scaffoldMessengerKey: snackbarKey,
              theme: _getLightThemeData(context,
                  dynamicColor: lightDynamic, mainColor: themeMainColor),
              darkTheme: _getDartThemeData(context,
                  dynamicColor: darkDynamic, mainColor: themeMainColor),
              themeMode: themeMode,
              locale: language,
              home: child,
              localizationsDelegates: const [
                L10n.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: appSupportedLocales,
              debugShowCheckedModeBanner: false,
            );
          },
          child: child,
        ),
        child: homePage,
      ),
    );
  }
}

class _AppPostInit extends SingleChildStatefulWidget {
  const _AppPostInit({required Widget child}) : super(child: child);

  @override
  State<StatefulWidget> createState() => _AppPostInitState();
}

class _AppPostInitState extends SingleChildState<_AppPostInit> {
  late bool inited;

  @override
  void initState() {
    super.initState();
    inited = false;
  }

  void onPostInitHandled(BuildContext context) {
    final l10n = L10n.of(context);
    appLog.build.info(context, ex: ["onPostInitHandled", l10n]);
    context
        .maybeRead<AppDebuggerViewModel>()
        ?.processDebuggingNotification(l10n);
    context.maybeRead<AppReminderViewModel>()?.processAppReminder(l10n);
    inited = true;
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    if (!inited) onPostInitHandled(context);
    return child!;
  }
}

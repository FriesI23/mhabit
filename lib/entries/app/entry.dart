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
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../common/flavor.dart';
import '../../extension/context_extensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../pages/habits_display/page.dart' show HabitsDisplayPage;
import '../../persistent/db_helper_builder.dart';
import '../../persistent/profile/handler/app_notify_config.dart';
import '../../persistent/profile/handlers.dart';
import '../../persistent/profile_builder.dart';
import '../../persistent/profile_provider.dart';
import '../../providers/app_debugger.dart';
import '../../providers/app_language.dart';
import '../../providers/app_reminder.dart';
import '../../providers/app_sync.dart';
import '../../providers/app_theme.dart';
import '../../reminders/notification_channel.dart';
import '../../theme/color.dart';
import '../../widgets/widgets.dart';
import '../app_error/entry.dart';
import '../common/app_root_view.dart';
import 'app_providers.dart';

/// Note: [AppProviders] are use to build providers that need to be initialized
/// in [MaterialApp]. An important to note that, e.g., [Localizations] are
/// initialized within MaterialApp. Some feature that depend on these inherited
/// widgets can be initialized in [_AppPostInit].
class AppEntry extends StatelessWidget {
  static const _profileHandlers = <ProfileHandlerBuilder>[
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
    AppSyncSwitchHandler.new,
    AppSyncServerConfigHandler.new,
    AppSyncFetchIntervalHandler.new,
    AppSyncExperimentalFeature.new,
    AppNotifyConfigProfileHandler.new,
  ];

  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    appLog.debugger.info("App Running Now", ex: [DateTime.now(), appFlavor]);
    return ProfileBuilder(
      handlers: _profileHandlers,
      errorBuilder: (details) => AppErrorEntry(errorDetails: details),
      builder: (context, child) => DBHelperBuilder(
        errorBuilder: (details) => AppErrorEntry(errorDetails: details),
        builder: (context, child) => DateChanger(
          interval: const Duration(seconds: 10),
          builder: (context) => const AppProviders(
            child:
                _AppEntry(homePage: _AppPostInit(child: HabitsDisplayPage())),
          ),
        ),
      ),
    );
  }
}

class _AppEntry extends StatelessWidget {
  final Widget homePage;

  const _AppEntry({required this.homePage});

  @override
  Widget build(BuildContext context) {
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
            final appColorLight = ColorScheme.fromSeed(
                seedColor: themeMainColor, brightness: Brightness.light);
            final appColorDark = ColorScheme.fromSeed(
                seedColor: themeMainColor, brightness: Brightness.dark);
            return AppRootView(
              themeMode: themeMode,
              themeMainColor: themeMainColor,
              language: language,
              lightThemeBuilder: () => ThemeData(
                  colorScheme: lightDynamic ?? appColorLight,
                  useMaterial3: true,
                  extensions: [modifedLightCustomColors]),
              darkThemeBuilder: () => ThemeData(
                  colorScheme: darkDynamic ?? appColorDark,
                  useMaterial3: true,
                  extensions: [darkCustomColors]),
              child: child,
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

  void _onL10nUpdate([L10n? l10n]) {
    context.maybeRead<NotificationChannelData>()?.onL10nUpdate(l10n);
    context.maybeRead<AppSyncViewModel>()?.onL10nUpdate(l10n);
  }

  @override
  void didChangeDependencies() {
    _onL10nUpdate(L10n.of(context));
    super.didChangeDependencies();
  }

  void onPostInitHandled(BuildContext context) {
    final l10n = L10n.of(context);
    appLog.build.info(context, ex: ["onPostInitHandled", l10n]);
    context
        .maybeRead<AppDebuggerViewModel>()
        ?.processDebuggingNotification(l10n);
    context.maybeRead<AppReminderViewModel>()?.processAppReminder(l10n);
    _onL10nUpdate(L10n.of(context));
    inited = true;
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    if (!inited) onPostInitHandled(context);
    return child!;
  }
}

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

import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '../../common/app_info.dart';
import '../../common/consts.dart';
import '../../common/flavor.dart';
import '../../common/utils.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/custom_color_extensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../models/app_sync_tasks.dart';
import '../../models/app_theme_color.dart';
import '../../models/habit_date.dart';
import '../../pages/common/widgets.dart';
import '../../pages/habits_display/_widgets/changelog_banner_sliver.dart';
import '../../pages/habits_display/page.dart' show HabitsDisplayPage;
import '../../providers/app_ui/app_debugger.dart';
import '../../providers/app_ui/app_language.dart';
import '../../providers/app_ui/app_theme.dart';
import '../../providers/support/animation_scale_sync.dart';
import '../../providers/workflow/app_reminder.dart';
import '../../providers/workflow/app_sync.dart';
import '../../providers/workflow/habits_manager.dart';
import '../../reminders/notification_channel.dart';
import '../../storage/db_helper_builder.dart';
import '../../storage/profile/handlers.dart';
import '../../storage/profile_builder.dart';
import '../../storage/profile_provider.dart';
import '../../theme/color.dart';
import '../../utils/app_clock.dart';
import '../../widgets/widgets.dart';
import '../app_error/entry.dart';
import '../common/app_root_view.dart';
import 'providers.dart';

/// Note: [AppProviders] are use to build providers that need to be initialized
/// in [MaterialApp]. An important to note that, e.g., [Localizations] are
/// initialized within MaterialApp. Some feature that depend on these inherited
/// widgets can be initialized in [AppPostInit].
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
    CustomColorHistoryProfileHandler.new,
    CollectLogswitcherProfileHandler.new,
    LoggingLevelProfileHandler.new,
    AppLanguageProfileHanlder.new,
    AppSyncSwitchHandler.new,
    AppSyncServerConfigHandler.new,
    AppSyncFetchIntervalHandler.new,
    HabitSearchExperimentalFeature.new,
    AppNotifyConfigProfileHandler.new,
    AppLaunchEntryProfileHandler.new,
    AppThemeColorProfileHandler.new,
    AppLastChangelogVersionProfileHandler.new,
  ];

  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    appLog.debugger.info("App Running Now", ex: [AppClock().now(), appFlavor]);
    return ProfileBuilder(
      handlers: _profileHandlers,
      errorBuilder: (details) => AppErrorEntry(errorDetails: details),
      builder: (context, child) => DBHelperBuilder(
        errorBuilder: (details) => AppErrorEntry(errorDetails: details),
        builder: (context, child) => DateChanger(
          interval: const Duration(seconds: 10),
          builder: (context) => const AppProviders(
            child: _AppEntry(homePage: AppPostInit(child: HabitsDisplayPage())),
          ),
        ),
      ),
    );
  }
}

class _AppEntry extends StatelessWidget {
  final Widget homePage;

  const _AppEntry({required this.homePage});

  String? getFontFamily() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
        final arch = AppInfo().linuxArchitecture;
        return switch (arch) {
          LinuxPlatformArchitecture.aarch64 => 'Roboto',
          _ => null,
        };
      default:
        return null;
    }
  }

  List<String>? getFontFamilyFallbacks() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
        final arch = AppInfo().linuxArchitecture;
        return switch (arch) {
          LinuxPlatformArchitecture.aarch64 => const [
            'Ubuntu',
            'Cantarell',
            'DejaVu Sans',
            'Liberation Sans',
            'Arial',
            'Noto Color Emoji',
            'Noto Sans CJK SC',
            'Noto Sans CJK TC',
            'Noto Sans CJK JP',
            'Noto Sans CJK KR',
          ],
          _ => null,
        };
      default:
        return null;
    }
  }

  Color? getThemeColor(
    AppThemeColor themeColor, {
    Color? themeMainColor,
    ColorScheme? dynamicScheme,
    CustomColors? customColor,
  }) {
    switch (themeColor) {
      case SystemAppThemeColor():
        return null;
      case PrimaryAppThemeColor():
        return appDefaultThemeMainColor;
      case DynamicAppThemeColor():
        final colorData = dynamicScheme?.primary.toARGB32();
        return colorData != null ? Color(colorData) : themeMainColor;
      case InternalAppThemeColor():
        final colorType = themeColor.colorType;
        return customColor?.getBuiltInColor(colorType) ?? themeMainColor;
      default:
        return themeMainColor;
    }
  }

  ColorScheme? getSystemLightColor() => switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => ColorScheme.fromSeed(
      seedColor: appDefaultThemeMainColor,
      brightness: Brightness.light,
      surface: Colors.white,
    ),
    _ => null,
  };

  ColorScheme? getSystemDarkColor() => switch (defaultTargetPlatform) {
    TargetPlatform.android => ColorScheme.fromSeed(
      seedColor: appDefaultThemeMainColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF0F0F0F),
    ),
    TargetPlatform.iOS => ColorScheme.fromSeed(
      seedColor: appDefaultThemeMainColor,
      brightness: Brightness.dark,
      surface: Colors.black,
    ),
    TargetPlatform.macOS => ColorScheme.fromSeed(
      seedColor: appDefaultThemeMainColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1E1E),
    ),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final fontFamily = getFontFamily();
    final fontFamilyFallbacks = getFontFamilyFallbacks();
    final pageTransitionsTheme = PageTransitionsTheme(
      builders: {
        ...const PageTransitionsTheme().builders,
        if (AppInfo().shouldEnablePredictBackPage())
          TargetPlatform.android:
              const CustomPredictiveBackPageTransitionsBuilder(),
      },
    );
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => Builder(
        builder: (context) {
          final language = context.select<AppLanguageViewModel, Locale?>(
            (vm) => vm.languange,
          );
          final (themeMode, themeColor, themeMainColor) = context
              .select<AppThemeViewModel, (AppThemeType, AppThemeColor, Color)>(
                (vm) => (vm.themeType, vm.themeColor, vm.mainColor),
              );
          final disableAnimations = context.select<AnimationScaleSync, bool>(
            (vm) => vm.disableAnimations,
          );
          return AppRootView(
            themeMode: transToMaterialThemeType(themeMode),
            language: language,
            disableAnimations: disableAnimations,
            lightThemeBuilder: () {
              final customColor = lightCustomColors;
              final mainColor = getThemeColor(
                themeColor,
                themeMainColor: themeMainColor,
                dynamicScheme: lightDynamic,
                customColor: customColor,
              );
              return ThemeData(
                fontFamily: fontFamily,
                fontFamilyFallback: fontFamilyFallbacks,
                pageTransitionsTheme: pageTransitionsTheme,
                brightness: mainColor == null ? Brightness.light : null,
                colorScheme: mainColor != null
                    ? ColorScheme.fromSeed(
                        seedColor: mainColor,
                        brightness: Brightness.light,
                      )
                    : getSystemLightColor(),
                useMaterial3: true,
                extensions: [customColor],
              );
            },
            darkThemeBuilder: () {
              final customColor = darkCustomColors;
              final mainColor = getThemeColor(
                themeColor,
                themeMainColor: themeMainColor,
                dynamicScheme: darkDynamic,
                customColor: customColor,
              );
              return ThemeData(
                fontFamily: fontFamily,
                fontFamilyFallback: fontFamilyFallbacks,
                pageTransitionsTheme: pageTransitionsTheme,
                brightness: mainColor == null ? Brightness.dark : null,
                colorScheme: mainColor != null
                    ? ColorScheme.fromSeed(
                        seedColor: mainColor,
                        brightness: Brightness.dark,
                      )
                    : getSystemDarkColor(),
                useMaterial3: true,
                extensions: [customColor],
              );
            },
            child: ChangelogBanner(child: homePage),
          );
        },
      ),
    );
  }
}

final class _AppSyncPostInitBridge {
  StreamSubscription<AppSyncNeedConfirmEvent>? _confirmSub;
  AppLifecycleListener? _lifecycleListener;
  AppSyncSettingsAccess? _settings;
  AppSyncTriggerAccess? _trigger;
  Stopwatch? _pauseStopwatch;

  void sync(
    BuildContext context, {
    required L10n? l10n,
    required Future<bool> Function(WebDavConfigTaskChecklist) onNeedCheck,
  }) {
    context.maybeRead<AppSyncWorkflowAccess>()?.onL10nUpdate(l10n);
    _updateConfirmSubscription(context, onNeedCheck: onNeedCheck);
    _updateLifecycleListener(context);
  }

  void dispose() {
    _confirmSub?.cancel();
    _lifecycleListener?.dispose();
  }

  void _updateConfirmSubscription(
    BuildContext context, {
    required Future<bool> Function(WebDavConfigTaskChecklist) onNeedCheck,
  }) {
    _confirmSub?.cancel();
    final appSync = context.maybeRead<AppSyncWorkflowAccess>();
    _confirmSub = appSync?.confirmEvents.listen(
      (event) => switch (event) {
        AppSyncNeedConfirmEvent<WebDavConfigTaskChecklist>() => onNeedCheck(
          event.checklist,
        ).then(event.complete),
        _ => kDebugMode ? debugPrint("Unhandled event: $event") : null,
      },
    );
  }

  void _onPaused() {
    _pauseStopwatch?.stop();
    _pauseStopwatch = Stopwatch()..start();
    appLog.appsync.debug("AppSyncLifecycleBridge", ex: ["App Paused"]);
  }

  void _onRestarted() {
    Duration? stopDuration;
    final stopwatch = _pauseStopwatch;
    if (stopwatch != null && stopwatch.isRunning) {
      stopwatch.stop();
      stopDuration = stopwatch.elapsed;
      _pauseStopwatch = null;
      appLog.appsync.debug(
        "AppSyncLifecycleBridge",
        ex: ["App Resumed from Paused", stopDuration],
      );
    }
    final interval = _settings?.fetchInterval.t;
    if (interval != null && stopDuration != null) {
      final window = Duration(microseconds: interval.inMicroseconds ~/ 2);
      appLog.appsync.debug(
        "AppSyncLifecycleBridge",
        ex: ["Try re-sync after resumed", stopDuration, window],
      );
      if (stopDuration > window) {
        _trigger?.delayedStartTaskOnce(delay: kAppSyncDelayDuration3);
      }
    }
  }

  void _updateLifecycleListener(BuildContext context) {
    final settings = context.maybeRead<AppSyncSettingsAccess>();
    final trigger = context.maybeRead<AppSyncTriggerAccess>();
    if (identical(_settings, settings) && identical(_trigger, trigger)) return;

    _lifecycleListener?.dispose();
    _settings = settings;
    _trigger = trigger;
    if (settings == null || trigger == null) {
      _lifecycleListener = null;
      return;
    }

    _lifecycleListener = AppLifecycleListener(
      onPause: _onPaused,
      onRestart: _onRestarted,
    );
  }
}

bool _isDesktopReminderDateChangeEnabled() => switch (defaultTargetPlatform) {
  TargetPlatform.linux ||
  TargetPlatform.macOS ||
  TargetPlatform.windows => true,
  _ => false,
};

final class _HabitReminderPostInitBridge {
  HabitsDisplayAccess? _access;
  AppLifecycleListener? _lifecycleListener;
  DateChangeNotifier? _dateChangeNotifier;
  HabitDate? _lastDateTime;
  String? _lastTzName;

  void sync(BuildContext context) {
    final access = context.maybeRead<HabitsDisplayAccess>();
    final dateChangeNotifier = _isDesktopReminderDateChangeEnabled()
        ? context.maybeRead<DateChangeNotifier>()
        : null;
    if (identical(_access, access) &&
        identical(_dateChangeNotifier, dateChangeNotifier)) {
      return;
    }

    _lifecycleListener?.dispose();
    _dateChangeNotifier?.removeListener(_onDateChangeDetected);
    _access = access;
    _dateChangeNotifier = dateChangeNotifier;
    if (access == null) {
      _lifecycleListener = null;
      _lastDateTime = null;
      _lastTzName = null;
      return;
    }

    _lifecycleListener = AppLifecycleListener(onRestart: _onRestarted);
    if (dateChangeNotifier == null) {
      _lastDateTime = null;
      _lastTzName = null;
      return;
    }

    _lastDateTime = dateChangeNotifier.dateTime;
    _lastTzName = dateChangeNotifier.tzName;
    dateChangeNotifier.addListener(_onDateChangeDetected);
  }

  void dispose() {
    _lifecycleListener?.dispose();
    _dateChangeNotifier?.removeListener(_onDateChangeDetected);
  }

  void _onRestarted() {
    _access?.refreshHabitReminders(
      params: const HabitReminderRefreshParams.restart(),
    );
  }

  void _onDateChangeDetected() {
    final access = _access;
    final dateChangeNotifier = _dateChangeNotifier;
    if (access == null || dateChangeNotifier == null) return;

    final dateChanged = dateChangeNotifier.dateTime != _lastDateTime;
    final tzChanged = dateChangeNotifier.tzName != _lastTzName;
    if (!(dateChanged || tzChanged)) return;

    _lastDateTime = dateChangeNotifier.dateTime;
    _lastTzName = dateChangeNotifier.tzName;
    access.refreshHabitReminders(
      params: const HabitReminderRefreshParams.dateChange(),
    );
  }
}

class AppPostInit extends SingleChildStatefulWidget {
  const AppPostInit({required Widget child, super.key}) : super(child: child);

  @override
  State<StatefulWidget> createState() => _AppPostInitState();
}

class _AppPostInitState extends SingleChildState<AppPostInit> {
  final _appSyncBridge = _AppSyncPostInitBridge();
  final _habitReminderBridge = _HabitReminderPostInitBridge();
  bool _didHandlePostInit = false;

  void _syncL10n([L10n? l10n]) {
    context.maybeRead<NotificationChannelData>()?.onL10nUpdate(l10n);
    _habitReminderBridge.sync(context);
    _appSyncBridge.sync(
      context,
      l10n: l10n,
      onNeedCheck: _onWebDavAppSyncUserConfirmNeedCheck,
    );
  }

  Future<bool> _onWebDavAppSyncUserConfirmNeedCheck(
    WebDavConfigTaskChecklist checklist,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => checklist.isEmptyDir
          ? const AppSyncWebDavNewServerConfirmDialog()
          : const AppSyncWebDavOldServerConfirmDialog(),
    ).then((value) => value ?? false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncL10n(L10n.of(context));
  }

  @override
  void dispose() {
    _habitReminderBridge.dispose();
    _appSyncBridge.dispose();
    super.dispose();
  }

  void _handlePostInit(BuildContext context) {
    final l10n = L10n.of(context);
    final reminderContent = AppReminderContent.maybeFromL10n(l10n);
    appLog.build.info(context, ex: ["onPostInitHandled", l10n]);
    context.maybeRead<AppDebuggerViewModel>()?.processDebuggingNotification(
      l10n,
    );
    context.maybeRead<AppReminderAccess>()?.processTrigger(
      const AppReminderTrigger.startup(),
      content: reminderContent,
    );
    context.maybeRead<HabitsDisplayAccess>()?.refreshHabitReminders(
      params: const HabitReminderRefreshParams.startup(),
    );
    _syncL10n(l10n);
    _didHandlePostInit = true;

    final handler = context
        .read<ProfileViewModel>()
        .getHandler<AppLastChangelogVersionProfileHandler>();
    final currentVersion = AppInfo().changelogVersion;
    final lastVersion = handler?.get();

    if (lastVersion != currentVersion) {
      handler?.set(currentVersion);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showChangelogBanner(context, version: currentVersion);
      });
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    if (!_didHandlePostInit) _handlePostInit(context);
    return child!;
  }
}

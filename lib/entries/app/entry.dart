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
import 'package:go_router/go_router.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '../../common/app_info.dart';
import '../../common/flavor.dart';
import '../../common/utils.dart';
import '../../extensions/context_extensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../models/app_entry.dart';
import '../../models/app_sync_tasks.dart';
import '../../models/app_theme_color.dart';
import '../../models/habit_date.dart';
import '../../pages/app_about/page.dart' show AppAboutPage;
import '../../pages/app_debugger/page.dart' show AppDebuggerPage;
import '../../pages/app_notify_config/page.dart' show AppNotifyConfigPage;
import '../../pages/app_settings/page.dart' show AppSettingPage;
import '../../pages/app_sync/page.dart' show AppSyncPage;
import '../../pages/common/widgets.dart';
import '../../pages/expermental_features/page.dart'
    show ExpermentalFeaturesPage;
import '../../pages/group_manage/page.dart' show GroupManagePage;
import '../../pages/habit_detail/page.dart' show HabitDetailPage;
import '../../pages/habit_edit/page.dart' show HabitEditPage;
import '../../pages/habits_display/page.dart' show HabitsPage, TodayPage;
import '../../pages/habits_status_changer/page.dart'
    show HabitsStatusChangerPage;
import '../../providers/app_ui/app_debugger.dart';
import '../../providers/app_ui/app_developer.dart';
import '../../providers/app_ui/app_language.dart';
import '../../providers/app_ui/app_launch_entry.dart';
import '../../providers/app_ui/app_theme.dart';
import '../../providers/support/animation_scale_sync.dart';
import '../../providers/workflow/app_reminder.dart';
import '../../providers/workflow/app_sync.dart';
import '../../providers/workflow/habits_manager.dart';
import '../../reminders/notification_channel.dart';
import '../../routes/app_router.dart';
import '../../routes/helpers/group_manage_helper.dart';
import '../../routes/helpers/habit_create_helper.dart';
import '../../routes/helpers/habit_detail_helper.dart';
import '../../routes/helpers/habit_edit_helper.dart';
import '../../routes/helpers/habits_status_changer_helper.dart';
import '../../storage/db_helper_builder.dart';
import '../../storage/profile/handlers.dart';
import '../../storage/profile_builder.dart';
import '../../storage/profile_provider.dart';
import '../../theme/app_theme_builder.dart';
import '../../theme/color.dart';
import '../../utils/app_clock.dart';
import '../../widgets/widgets.dart';
import '../app_error/entry.dart';
import '../common/app_root_view.dart';
import 'providers.dart';
import 'shell.dart';

typedef _AppInitialNavigationConfig = ({AppRoute home, int initialBranchIndex});

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
    DisplayGroupModeProfileHandler.new,
    GroupExpandTimerDelayProfileHandler.new,
    DisplayCalendarScrollModeProfileHandler.new,
    DisplayCalendartBarOccupyPrtProfileHandler.new,
    ShowDateFormatProfileHandler.new,
    FirstDayProfileHandler.new,
    HabitCellGestureModeProfileHandler.new,
    InputFillCacheProfileHandler.new,
    AppFlagsProfileHandler.new,
    CustomColorHistoryProfileHandler.new,
    CollectLogswitcherProfileHandler.new,
    LoggingLevelProfileHandler.new,
    AppLanguageProfileHanlder.new,
    AppSyncSwitchHandler.new,
    AppSyncServerConfigHandler.new,
    AppSyncFetchIntervalHandler.new,
    HabitSearchExperimentalFeature.new,
    HabitGroupingExperimentalFeature.new,
    AppNotifyConfigProfileHandler.new,
    AppLaunchEntryProfileHandler.new,
    AppThemeColorProfileHandler.new,
    AppLastChangelogVersionProfileHandler.new,
    NaturalSortExperimentalFeature.new,
    AdaptiveStyleOverrideProfileHandler.new,
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
          builder: (context) => const AppProviders(child: _AppEntry()),
        ),
      ),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  late final AppNavigationCoordinator _navigationCoordinator;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final launchEntry = context.read<AppLaunchEntryViewModel>().launchEntry;
    final config = switch (launchEntry) {
      AppEntrys.habitToday => (home: AppRoute.today, initialBranchIndex: 1),
      AppEntrys.undefined ||
      AppEntrys.habitDisplay => (home: AppRoute.habits, initialBranchIndex: 0),
    };
    _router = _buildRouter(config);
  }

  GoRouter _buildRouter(_AppInitialNavigationConfig config) {
    final branches = [
      BranchRouterBuilder()
        ..addHabits(builder: (_, _) => const HabitsPage())
        ..addHabitDetail(
          builder: (_, state) {
            final (:habitUUID, :color, :summaryAdapter) = state
                .unpackHabitDetail();
            return Provider.value(
              value: summaryAdapter,
              child: HabitDetailPage(habitUUID: habitUUID, color: color),
            );
          },
        ),
      BranchRouterBuilder()..addToday(builder: (_, _) => const TodayPage()),
    ];
    final branchObservers = [
      for (final _ in branches) AdaptiveBranchRouteObserver(),
    ];
    final appFlow = AppFlowRouterBuilder()
      ..addHabitCreate(
        builder: (_, state) {
          final (:initForm) = state.unpackHabitCreate();
          return HabitEditPage(initForm: initForm);
        },
      )
      ..addHabitEdit(
        builder: (_, state) {
          final (habitId: _, initForm: initForm) = state.unpackHabitEdit();
          return HabitEditPage(initForm: initForm);
        },
      );
    final appFlowObserver = AdaptiveBranchRouteObserver();
    final appChromeNavigatorKey = GlobalKey<NavigatorState>();
    _navigationCoordinator = AppNavigationCoordinator(
      branchObservers: branchObservers,
      appFlowObserver: appFlowObserver,
      appChromeNavigatorKey: appChromeNavigatorKey,
      initialIndex: config.initialBranchIndex,
    );
    return (AppRouterBuilder()
          ..addSettings(builder: (_, _) => const AppSettingPage())
          ..addSettingsAbout(builder: (_, _) => const AppAboutPage())
          ..addSettingsSync(builder: (_, _) => const AppSyncPage())
          ..addSettingsNotify(builder: (_, _) => const AppNotifyConfigPage())
          ..addExperimental(builder: (_, _) => const ExpermentalFeaturesPage())
          ..addDebugger(builder: (_, _) => const AppDebuggerPage())
          ..addGroupManage(
            builder: (_, state) {
              final (:selectedGroupId) = state.unpackGroupManage();
              return GroupManagePage(initialGroupUUID: selectedGroupId);
            },
          )
          ..addHabitsStatus(
            builder: (_, state) {
              final (:uuidList) = state.unpackHabitsStatusChanger();
              return HabitsStatusChangerPage(uuidList: uuidList);
            },
          )
          ..addShellRoute(
            appFlow: appFlow,
            branchObservers: branchObservers,
            branches: branches,
            navigatorKey: appChromeNavigatorKey,
            observers: [appFlowObserver],
            builder: (context, state, child) => ChangelogBanner(
              child: AppPostInit(
                child: AppNavigationShell(
                  coordinator: _navigationCoordinator,
                  child: child,
                ),
              ),
            ),
            branchBuilder: (context, state, navigationShell) {
              _navigationCoordinator.attachTabShell(navigationShell);
              return navigationShell;
            },
          ))
        .build(home: config.home);
  }

  @override
  void dispose() {
    _router.dispose();
    _navigationCoordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          final adaptiveStyleOverride = context
              .select<AppDeveloperViewModel, AdaptiveStyle?>(
                (vm) => vm.adaptiveStyleOverride,
              );
          return AdaptiveStyleScope(
            override: adaptiveStyleOverride,
            child: AppRootView.router(
              themeMode: transToMaterialThemeType(themeMode),
              language: language,
              disableAnimations: disableAnimations,
              lightThemeBuilder: () => const AppThemeBuilder().buildLight(
                themeColor: themeColor,
                themeMainColor: themeMainColor,
                dynamicScheme: lightDynamic,
              ),
              darkThemeBuilder: () => const AppThemeBuilder().buildDark(
                themeColor: themeColor,
                themeMainColor: themeMainColor,
                dynamicScheme: darkDynamic,
              ),
              config: _router,
            ),
          );
        },
      ),
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

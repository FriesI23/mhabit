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
import '../../pages/common/widgets.dart';
import '../../pages/habits_display/page.dart' show HabitsDisplayPage;
import '../../providers/app_debugger.dart';
import '../../providers/app_language.dart';
import '../../providers/app_reminder.dart';
import '../../providers/app_sync.dart';
import '../../providers/app_theme.dart';
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
    HabitSearchExperimentalFeature.new,
    AppNotifyConfigProfileHandler.new,
    AppLaunchEntryProfileHandler.new,
    AppThemeColorProfileHandler.new,
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

  String? getFontFamily() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
        final arch = AppInfo().linuxArchitecture;
        return switch (arch) {
          LinuxPlatformArchitecture.aarch64 => 'Roboto',
          _ => null
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
          _ => null
        };
      default:
        return null;
    }
  }

  Color? getThemeColor(AppThemeColor themeColor,
      {Color? themeMainColor,
      ColorScheme? dynamicScheme,
      CustomColors? customColor}) {
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
        return customColor?.getColor(colorType) ?? themeMainColor;
      default:
        return themeMainColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontFamily = getFontFamily();
    final fontFamilyFallbacks = getFontFamilyFallbacks();
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => Builder(
        builder: (context) {
          final language = context
              .select<AppLanguageViewModel, Locale?>((vm) => vm.languange);
          final (themeMode, themeColor, themeMainColor) = context
              .select<AppThemeViewModel, (AppThemeType, AppThemeColor, Color)>(
                  (vm) => (vm.themeType, vm.themeColor, vm.mainColor));
          return AppRootView(
            themeMode: transToMaterialThemeType(themeMode),
            language: language,
            lightThemeBuilder: () {
              final customColor = modifedLightCustomColors;
              final mainColor = getThemeColor(themeColor,
                  themeMainColor: themeMainColor,
                  dynamicScheme: lightDynamic,
                  customColor: customColor);
              return ThemeData(
                  fontFamily: fontFamily,
                  fontFamilyFallback: fontFamilyFallbacks,
                  brightness: mainColor == null ? Brightness.light : null,
                  colorScheme: mainColor != null
                      ? ColorScheme.fromSeed(
                          seedColor: mainColor, brightness: Brightness.light)
                      : null,
                  useMaterial3: true,
                  extensions: [customColor]);
            },
            darkThemeBuilder: () {
              final customColor = darkCustomColors;
              final mainColor = getThemeColor(themeColor,
                  themeMainColor: themeMainColor,
                  dynamicScheme: darkDynamic,
                  customColor: customColor);
              return ThemeData(
                  fontFamily: fontFamily,
                  fontFamilyFallback: fontFamilyFallbacks,
                  brightness: mainColor == null ? Brightness.dark : null,
                  colorScheme: mainColor != null
                      ? ColorScheme.fromSeed(
                          seedColor: mainColor, brightness: Brightness.dark)
                      : null,
                  useMaterial3: true,
                  extensions: [customColor]);
            },
            child: homePage,
          );
        },
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
  StreamSubscription<AppSyncNeedConfirmEvent>? _confirmSub;

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

  void _onConfirmSubscriptionUpdate() {
    _confirmSub?.cancel();
    _confirmSub = context
        .maybeRead<AppSyncViewModel>()
        ?.appSyncTask
        .confirmEvents
        .listen((event) => switch (event) {
              AppSyncNeedConfirmEvent<WebDavConfigTaskChecklist>() =>
                _onWebDavAppSyncUserConfirmNeedCheck(event.checklist)
                    .then(event.complete),
              _ => kDebugMode ? debugPrint("Unhandled event: $event") : null
            });
  }

  Future<bool> _onWebDavAppSyncUserConfirmNeedCheck(
      WebDavConfigTaskChecklist checklist) {
    return showDialog<bool>(
      context: context,
      builder: (context) => checklist.isEmptyDir
          ? const AppSyncWebDavNewServerConfirmDialog()
          : const AppSyncWebDavOldServerConfirmDialog(),
    ).then((value) => value ?? false);
  }

  @override
  void didChangeDependencies() {
    _onL10nUpdate(L10n.of(context));
    _onConfirmSubscriptionUpdate();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _confirmSub?.cancel();
    super.dispose();
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

// Copyright 2025 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/cupertino.dart'
    show CupertinoUserInterfaceLevel, CupertinoUserInterfaceLevelData;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:provider/provider.dart';

import '../../common/app_info.dart';
import '../../common/consts.dart';
import '../../common/global.dart';
import '../../extensions/desktop_window_chrome_extensions.dart';
import '../../l10n/localizations.dart';
import '../../models/app_desktop_bar_mode.dart';
import '../../widgets/_widgets/app_window_title_bar_binding.dart';
import '../../widgets/widgets.dart';

typedef AppRootThemeBuilder = ThemeData Function(BuildContext context);

/// Shared window-level decision for Material themes and Cupertino system colors.
CupertinoUserInterfaceLevelData appWindowInterfaceLevel(BuildContext context) =>
    switch (defaultTargetPlatform) {
      TargetPlatform.iOS =>
        AdaptiveWindowControlLayoutScope.maybeOf(
                  context,
                )?.hasWindowControlAvoidance ==
                true
            ? CupertinoUserInterfaceLevelData.elevated
            : CupertinoUserInterfaceLevelData.base,
      _ => CupertinoUserInterfaceLevelData.base,
    };

class AppRootView extends StatelessWidget {
  final ThemeMode themeMode;
  final Locale? language;
  final Widget? child;
  final GoRouter? routerConfig;
  final AppRootThemeBuilder? lightThemeBuilder;
  final AppRootThemeBuilder? darkThemeBuilder;
  final bool disableAnimations;
  final TextDirection? textDirectionOverride;
  final AdaptiveStyle? adaptiveStyleOverride;

  const AppRootView({
    super.key,
    required this.themeMode,
    this.language,
    this.lightThemeBuilder,
    this.darkThemeBuilder,
    this.child,
    this.disableAnimations = false,
    this.textDirectionOverride,
    this.adaptiveStyleOverride,
  }) : routerConfig = null;

  const AppRootView.router({
    super.key,
    required this.themeMode,
    this.language,
    this.lightThemeBuilder,
    this.darkThemeBuilder,
    required GoRouter config,
    this.disableAnimations = false,
    this.textDirectionOverride,
    this.adaptiveStyleOverride,
  }) : child = null,
       routerConfig = config;

  const AppRootView.withDefault({
    super.key,
    this.themeMode = ThemeMode.system,
    this.language,
    this.lightThemeBuilder,
    this.darkThemeBuilder,
    this.child,
    this.disableAnimations = false,
    this.textDirectionOverride,
    this.adaptiveStyleOverride,
  }) : routerConfig = null;

  @override
  Widget build(BuildContext context) {
    return Consumer<DesktopWindowChrome?>(
      // Native geometry updates only rebuild the layout boundary.
      builder: (_, chrome, child) => AdaptiveWindowControlLayout(
        platformLayout: chrome?.adaptiveLayout,
        usesRectangularDisplay: AppInfo().usesRectangularIPhoneDisplay,
        child: child!,
      ),
      child: _AppRootMaterialApp(
        themeMode: themeMode,
        language: language,
        routerConfig: routerConfig,
        lightThemeBuilder: lightThemeBuilder,
        darkThemeBuilder: darkThemeBuilder,
        disableAnimations: disableAnimations,
        textDirectionOverride: textDirectionOverride,
        adaptiveStyleOverride: adaptiveStyleOverride,
        child: child,
      ),
    );
  }
}

/// Builds the app beneath [AdaptiveWindowControlLayout], where its scope is
/// available for resolving the window-level theme.
class _AppRootMaterialApp extends StatelessWidget {
  final ThemeMode themeMode;
  final Locale? language;
  final Widget? child;
  final GoRouter? routerConfig;
  final AppRootThemeBuilder? lightThemeBuilder;
  final AppRootThemeBuilder? darkThemeBuilder;
  final bool disableAnimations;
  final TextDirection? textDirectionOverride;
  final AdaptiveStyle? adaptiveStyleOverride;

  const _AppRootMaterialApp({
    required this.themeMode,
    required this.language,
    required this.child,
    required this.routerConfig,
    required this.lightThemeBuilder,
    required this.darkThemeBuilder,
    required this.disableAnimations,
    required this.textDirectionOverride,
    required this.adaptiveStyleOverride,
  });

  bool get _useRouter => routerConfig != null;

  Widget _builder(BuildContext context, Widget? child) {
    final adaptiveTheme = AppAdaptiveUiTheme.of(context);
    return AppAdaptiveUiTheme(
      data: adaptiveTheme.copyWith(
        style: adaptiveStyleOverride ?? adaptiveTheme.style,
      ),
      child: _AppWindowView(
        disableAnimations: disableAnimations,
        textDirectionOverride: textDirectionOverride,
        child: UnfocusOnTap(child: child),
      ),
    );
  }

  String _onGenerateTitle(BuildContext context) =>
      L10n.of(context)?.appName ?? appName;

  @override
  Widget build(BuildContext context) {
    final lightTheme = lightThemeBuilder?.call(context);
    final darkTheme = darkThemeBuilder?.call(context);

    Widget routerApp() => MaterialApp.router(
      routerConfig: routerConfig!,
      onGenerateTitle: _onGenerateTitle,
      scaffoldMessengerKey: snackbarKey,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: language,
      shortcuts: WidgetsApp.defaultShortcuts,
      actions: WidgetsApp.defaultActions,
      builder: _builder,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      debugShowCheckedModeBanner: false,
    );
    Widget homeApp() => MaterialApp(
      onGenerateTitle: _onGenerateTitle,
      navigatorKey: navigatorKey,
      navigatorObservers: [currentRouteObserver],
      scaffoldMessengerKey: snackbarKey,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: language,
      shortcuts: WidgetsApp.defaultShortcuts,
      actions: WidgetsApp.defaultActions,
      builder: _builder,
      home: child,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      debugShowCheckedModeBanner: false,
    );
    return _useRouter ? routerApp() : homeApp();
  }
}

/// Window composition is kept separate from routing and application content.
class _AppWindowView extends StatelessWidget {
  const _AppWindowView({
    required this.disableAnimations,
    required this.textDirectionOverride,
    required this.child,
  });

  final bool disableAnimations;
  final TextDirection? textDirectionOverride;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final content = CupertinoUserInterfaceLevel(
      data: appWindowInterfaceLevel(context),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations:
              disableAnimations || MediaQuery.disableAnimationsOf(context),
        ),
        child: AdaptiveWindowTopSafeArea(child: child),
      ),
    );
    final window = switch (context._desktopBarMode) {
      AppDesktopBarMode.fused => _AppFusedWindowView(child: content),
      AppDesktopBarMode.separate => _AppSeparateWindowView(child: content),
      null => content,
    };
    return switch (textDirectionOverride) {
      final direction? => Directionality(
        textDirection: direction,
        child: window,
      ),
      null => window,
    };
  }
}

class _AppFusedWindowView extends StatelessWidget {
  const _AppFusedWindowView({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      AppWindowInteractionBinding(child: child);
}

class _AppSeparateWindowView extends StatelessWidget {
  const _AppSeparateWindowView({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _AppSeparateBarTheme(child: AppWindowTitleBarBinding(child: child));
}

class _AppSeparateBarTheme extends StatelessWidget {
  const _AppSeparateBarTheme({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fixedBackground = context._fixedMaterialAppBarBackground;
    final adaptiveTheme = AppAdaptiveUiTheme.of(context);
    // Keep both wrappers mounted when the UI style changes. Navigator, focus
    // and search state must not depend on whether the theme is overridden.
    return Theme(
      data: switch (fixedBackground) {
        true => theme._withFixedAppBarBackground,
        false => theme,
      },
      child: AppAdaptiveUiTheme(
        data: adaptiveTheme.copyWith(
          appBarTheme: adaptiveTheme.appBarTheme.copyWith(
            materialFixedScrollBackground: fixedBackground,
          ),
        ),
        child: child,
      ),
    );
  }
}

extension _AppWindowPresentationContext on BuildContext {
  /// Native platform policy does not follow the adaptive style override.
  AppDesktopBarMode? get _desktopBarMode => kIsWeb
      ? null
      : switch (defaultTargetPlatform) {
          TargetPlatform.macOS => AppDesktopBarMode.fused,
          TargetPlatform.windows => AppDesktopBarMode.separate,
          _ => null,
        };

  bool get _fixedMaterialAppBarBackground =>
      switch ((_desktopBarMode, AdaptiveStyle.of(this))) {
        (AppDesktopBarMode.separate, AdaptiveStyle.material) => true,
        _ => false,
      };
}

extension _IndependentAppBarTheme on ThemeData {
  ThemeData get _withFixedAppBarBackground => copyWith(
    appBarTheme: appBarTheme.copyWith(
      backgroundColor: WidgetStateProperty.resolveAs<Color>(
        appBarTheme.backgroundColor ?? colorScheme.surface,
        const <WidgetState>{},
      ),
      surfaceTintColor: Colors.transparent,
    ),
  );
}

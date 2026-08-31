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

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../common/app_info.dart';
import '../../common/consts.dart';
import '../../common/global.dart';
import '../../l10n/localizations.dart';
import '../../widgets/widgets.dart';

typedef AppRootThemeBuilder = ThemeData Function();

class AppRootView extends StatelessWidget {
  final ThemeMode themeMode;
  final Locale? language;
  final Widget? child;
  final GoRouter? routerConfig;
  final AppRootThemeBuilder? lightThemeBuilder;
  final AppRootThemeBuilder? darkThemeBuilder;
  final AppRootThemeBuilder? elevatedDarkThemeBuilder;
  final bool disableAnimations;
  final TextDirection? textDirectionOverride;

  const AppRootView({
    super.key,
    required this.themeMode,
    this.language,
    this.lightThemeBuilder,
    this.darkThemeBuilder,
    this.elevatedDarkThemeBuilder,
    this.child,
    this.disableAnimations = false,
    this.textDirectionOverride,
  }) : routerConfig = null;

  const AppRootView.router({
    super.key,
    required this.themeMode,
    this.language,
    this.lightThemeBuilder,
    this.darkThemeBuilder,
    this.elevatedDarkThemeBuilder,
    required GoRouter config,
    this.disableAnimations = false,
    this.textDirectionOverride,
  }) : child = null,
       routerConfig = config;

  const AppRootView.withDefault({
    super.key,
    this.themeMode = ThemeMode.system,
    this.language,
    this.lightThemeBuilder,
    this.darkThemeBuilder,
    this.elevatedDarkThemeBuilder,
    this.child,
    this.disableAnimations = false,
    this.textDirectionOverride,
  }) : routerConfig = null;

  @override
  Widget build(BuildContext context) {
    return AdaptiveWindowControlLayout(
      usesRectangularDisplay: AppInfo().usesRectangularIPhoneDisplay,
      child: _AppRootMaterialApp(
        themeMode: themeMode,
        language: language,
        routerConfig: routerConfig,
        lightThemeBuilder: lightThemeBuilder,
        darkThemeBuilder: darkThemeBuilder,
        elevatedDarkThemeBuilder: elevatedDarkThemeBuilder,
        disableAnimations: disableAnimations,
        textDirectionOverride: textDirectionOverride,
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
  final AppRootThemeBuilder? elevatedDarkThemeBuilder;
  final bool disableAnimations;
  final TextDirection? textDirectionOverride;

  const _AppRootMaterialApp({
    required this.themeMode,
    required this.language,
    required this.child,
    required this.routerConfig,
    required this.lightThemeBuilder,
    required this.darkThemeBuilder,
    required this.elevatedDarkThemeBuilder,
    required this.disableAnimations,
    required this.textDirectionOverride,
  });

  bool get _useRouter => routerConfig != null;

  Widget _builder(BuildContext context, Widget? child) {
    final content = MediaQuery(
      data: MediaQuery.of(context).copyWith(
        disableAnimations:
            disableAnimations || MediaQuery.disableAnimationsOf(context),
      ),
      child: UnfocusOnTap(child: child),
    );
    final textDirection = textDirectionOverride;
    return textDirection == null
        ? content
        : Directionality(textDirection: textDirection, child: content);
  }

  String _onGenerateTitle(BuildContext context) =>
      L10n.of(context)?.appName ?? appName;

  @override
  Widget build(BuildContext context) {
    final layout = AdaptiveWindowControlLayoutScope.maybeOf(context);
    final effectiveDarkThemeBuilder = switch ((
      defaultTargetPlatform,
      layout?.hasWindowControlAvoidance,
    )) {
      (TargetPlatform.iOS, true) =>
        elevatedDarkThemeBuilder ?? darkThemeBuilder,
      _ => darkThemeBuilder,
    };
    final lightTheme = lightThemeBuilder?.call();
    final darkTheme = effectiveDarkThemeBuilder?.call();

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

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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../common/app_info.dart';
import '../../common/consts.dart';
import '../../common/global.dart';
import '../../l10n/localizations.dart';
import '../../widgets/widgets.dart';

class AppRootView extends StatelessWidget {
  final ThemeMode themeMode;
  final Locale? language;
  final Widget? child;
  final GoRouter? routerConfig;
  final ThemeData Function()? lightThemeBuilder;
  final ThemeData Function()? darkThemeBuilder;
  final bool disableAnimations;
  final TextDirection? textDirectionOverride;

  const AppRootView({
    super.key,
    required this.themeMode,
    this.language,
    this.lightThemeBuilder,
    this.darkThemeBuilder,
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
    this.child,
    this.disableAnimations = false,
    this.textDirectionOverride,
  }) : routerConfig = null;

  bool get _useRouter => routerConfig != null;

  Widget _builder(BuildContext context, Widget? child) {
    final content = MediaQuery(
      data: MediaQuery.of(context).copyWith(
        disableAnimations:
            disableAnimations || MediaQuery.disableAnimationsOf(context),
      ),
      child: AdaptiveWindowControlLayout(
        usesRectangularDisplay: AppInfo().usesRectangularIPhoneDisplay,
        child: UnfocusOnTap(child: child),
      ),
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
    final lightTheme = lightThemeBuilder?.call();
    final darkTheme = darkThemeBuilder?.call();

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

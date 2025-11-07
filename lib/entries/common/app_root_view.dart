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

import '../../common/consts.dart';
import '../../common/global.dart';
import '../../l10n/localizations.dart';

class AppRootView extends StatelessWidget {
  final ThemeMode themeMode;
  final Color themeMainColor;
  final Locale? language;
  final Widget? child;
  final ThemeData Function()? lightThemeBuilder;
  final ThemeData Function()? darkThemeBuilder;

  const AppRootView({
    super.key,
    required this.themeMode,
    required this.themeMainColor,
    this.language,
    this.lightThemeBuilder,
    this.darkThemeBuilder,
    this.child,
  });

  const AppRootView.withDefault({
    super.key,
    this.themeMode = ThemeMode.system,
    this.themeMainColor = appDefaultThemeMainColor,
    this.language,
    this.lightThemeBuilder,
    this.darkThemeBuilder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => L10n.of(context)?.appName ?? appName,
      navigatorKey: navigatorKey,
      navigatorObservers: [currentRouteObserver],
      scaffoldMessengerKey: snackbarKey,
      theme: lightThemeBuilder?.call(),
      darkTheme: darkThemeBuilder?.call(),
      themeMode: themeMode,
      locale: language,
      shortcuts: WidgetsApp.defaultShortcuts,
      actions: WidgetsApp.defaultActions,
      home: child,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}

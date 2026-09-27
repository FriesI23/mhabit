// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../providers/app_ui/app_theme.dart';
import '../../../theme/color.dart';

class AppSettingsButton extends StatelessWidget {
  const AppSettingsButton({super.key, required this.onPressed, this.tooltip});

  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => AdaptiveIconButton(
    onPressed: onPressed,
    tooltip: tooltip,
    icon: const AppSettingsIcon(),
  );
}

class AppSettingsIcon extends StatelessWidget {
  const AppSettingsIcon({super.key, this.selected = true}) : style = null;

  const AppSettingsIcon.material({super.key, this.selected = true})
    : style = AdaptiveStyle.material;

  const AppSettingsIcon.apple({super.key, this.selected = true})
    : style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final bool selected;

  @override
  Widget build(BuildContext context) =>
      switch (style ?? AdaptiveStyle.of(context)) {
        AdaptiveStyle.material => Icon(
          selected ? Icons.settings : Icons.settings_outlined,
        ),
        AdaptiveStyle.apple => Icon(
          selected ? CupertinoIcons.settings_solid : CupertinoIcons.settings,
        ),
      };
}

class AppThemeModeIcon extends StatelessWidget {
  const AppThemeModeIcon({super.key, this.themeType}) : style = null;

  const AppThemeModeIcon.material({super.key, this.themeType})
    : style = AdaptiveStyle.material;

  const AppThemeModeIcon.apple({super.key, this.themeType})
    : style = AdaptiveStyle.apple;

  final AppThemeType? themeType;
  final AdaptiveStyle? style;

  @override
  Widget build(BuildContext context) {
    final effectiveThemeType =
        themeType ??
        context.select<AppThemeViewModel, AppThemeType>((vm) => vm.themeType);
    return switch (style ?? AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => Icon(switch (effectiveThemeType) {
        AppThemeType.light => Icons.light_mode_rounded,
        AppThemeType.dark => Icons.dark_mode_rounded,
        AppThemeType.unknown ||
        AppThemeType.followSystem => Icons.hdr_auto_rounded,
      }),
      AdaptiveStyle.apple => Icon(switch (effectiveThemeType) {
        AppThemeType.light => CupertinoIcons.sun_max_fill,
        AppThemeType.dark => CupertinoIcons.moon_fill,
        AppThemeType.unknown ||
        AppThemeType.followSystem => CupertinoIcons.circle_lefthalf_fill,
      }),
    };
  }
}

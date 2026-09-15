// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../providers/app_ui/app_theme.dart';
import '../../../theme/color.dart';

class AppSettingThemeModeTile extends StatelessWidget {
  const AppSettingThemeModeTile({super.key, this.useSideBySideLayout = false});

  final bool useSideBySideLayout;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final themeType = context.select<AppThemeViewModel, AppThemeType>(
      (vm) => vm.themeType,
    );
    final title = l10n.appSetting_appThemeModeTile_titleText;
    final labels = {
      for (final type in AppThemeType.values) type: _label(type, l10n),
    };
    final onChanged = context.read<AppThemeViewModel>().setNewthemeType;
    final visibleLabels = {
      for (final type in const [
        AppThemeType.followSystem,
        AppThemeType.light,
        AppThemeType.dark,
      ])
        type: labels[type]!,
    };
    final value = themeType == AppThemeType.unknown
        ? AppThemeType.followSystem
        : themeType;
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => AdaptiveChoiceListTile<AppThemeType>.material(
        title: Text(title),
        controlKey: const ValueKey('theme-mode-control'),
        labels: visibleLabels,
        value: value,
        onChanged: onChanged,
        config: const AdaptiveChoiceListTileConfig.choice(),
      ),
      AdaptiveStyle.apple => AdaptiveChoiceListTile<AppThemeType>.apple(
        title: Text(title),
        controlKey: const ValueKey('theme-mode-control'),
        labels: visibleLabels,
        value: value,
        onChanged: onChanged,
        config: AdaptiveChoiceListTileConfig(
          segmented: useSideBySideLayout
              ? AdaptiveChoiceLayout.responsive
              : AdaptiveChoiceLayout.stacked,
        ),
      ),
    };
  }

  String _label(AppThemeType type, L10n l10n) => switch (type) {
    AppThemeType.light => l10n.common_appThemeMode_light,
    AppThemeType.dark => l10n.common_appThemeMode_dark,
    AppThemeType.unknown ||
    AppThemeType.followSystem => l10n.common_appThemeMode_followSystem,
  };
}

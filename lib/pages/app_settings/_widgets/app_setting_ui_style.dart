// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../models/app_adaptive_style_mode.dart';
import '../../../models/app_apple_sidebar_style_mode.dart';
import '../../../providers/app_ui/app_theme.dart';
import '../../../widgets/widgets.dart';

class AppSettingUiStyleTile extends StatelessWidget {
  const AppSettingUiStyleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final value = context.select<AppThemeViewModel, AppAdaptiveStyleMode>(
      (vm) => vm.adaptiveStyleMode,
    );
    return WindowSizeClassLayoutBuilder(
      builder: (context, windowSize, child) =>
          AdaptiveChoiceListTile<AppAdaptiveStyleMode>(
            title: Text(l10n.appSetting_uiStyle_titleText),
            controlKey: const ValueKey('settings-ui-style-control'),
            value: value,
            labels: {
              AppAdaptiveStyleMode.automatic: l10n.appSetting_uiStyle_automatic,
              AppAdaptiveStyleMode.material: l10n.appSetting_uiStyle_material,
              AppAdaptiveStyleMode.apple: l10n.appSetting_uiStyle_apple,
            },
            onChanged: context.read<AppThemeViewModel>().setAdaptiveStyleMode,
            config: AdaptiveChoiceListTileConfig.choice(
              segmented: windowSize.width >= WindowSizeClass.medium
                  ? AdaptiveChoiceLayout.responsive
                  : AdaptiveChoiceLayout.stacked,
            ),
          ),
    );
  }
}

/// The Sidebar appearance control for display settings.
///
/// The caller owns visibility based on the active UI style.
class AppSettingAppleSidebarStyleTile extends StatelessWidget {
  const AppSettingAppleSidebarStyleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final value = context.select<AppThemeViewModel, AppAppleSidebarStyleMode>(
      (vm) => vm.appleSidebarStyleMode,
    );
    return WindowSizeClassLayoutBuilder(
      builder: (context, windowSize, child) =>
          AdaptiveChoiceListTile<AppAppleSidebarStyleMode>(
            title: Text(l10n.appSetting_appleSidebarStyle_titleText),
            controlKey: const ValueKey('settings-apple-sidebar-style-control'),
            value: value,
            labels: {
              AppAppleSidebarStyleMode.automatic:
                  l10n.appSetting_uiStyle_automatic,
              AppAppleSidebarStyleMode.os26:
                  l10n.appSetting_appleSidebarStyle_inset,
              AppAppleSidebarStyleMode.os27:
                  l10n.appSetting_appleSidebarStyle_edge,
            },
            onChanged: context
                .read<AppThemeViewModel>()
                .setAppleSidebarStyleMode,
            config: AdaptiveChoiceListTileConfig.choice(
              segmented: windowSize.width >= WindowSizeClass.medium
                  ? AdaptiveChoiceLayout.responsive
                  : AdaptiveChoiceLayout.stacked,
            ),
          ),
    );
  }
}

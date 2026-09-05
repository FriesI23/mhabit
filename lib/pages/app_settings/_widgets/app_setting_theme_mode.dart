// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../providers/app_ui/app_theme.dart';
import '../../../theme/color.dart';

class AppSettingThemeModeTile extends StatelessWidget {
  const AppSettingThemeModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final themeType = context.select<AppThemeViewModel, AppThemeType>(
      (vm) => vm.themeType,
    );
    return ListTile(
      title: Text(l10n.appSetting_appThemeModeTile_titleText),
      trailing: MenuAnchor(
        animated: true,
        menuChildren: [
          for (final type in const [
            AppThemeType.followSystem,
            AppThemeType.light,
            AppThemeType.dark,
          ])
            MenuItemButton(
              leadingIcon: Opacity(
                opacity: type == themeType ? 1 : 0,
                child: const Icon(Icons.check),
              ),
              onPressed: () =>
                  context.read<AppThemeViewModel>().setNewthemeType(type),
              child: Text(_label(type, l10n)),
            ),
        ],
        builder: (context, controller, child) => TextButton.icon(
          key: const ValueKey('theme-mode-control'),
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_drop_down),
          label: Text(_label(themeType, l10n)),
        ),
      ),
    );
  }

  String _label(AppThemeType type, L10n l10n) => switch (type) {
    AppThemeType.light => l10n.common_appThemeMode_light,
    AppThemeType.dark => l10n.common_appThemeMode_dark,
    AppThemeType.unknown ||
    AppThemeType.followSystem => l10n.common_appThemeMode_followSystem,
  };
}

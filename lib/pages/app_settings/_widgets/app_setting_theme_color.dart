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

import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/consts.dart';
import '../../../extensions/custom_color_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/app_theme_color.dart';
import '../../../models/habit_form.dart';
import '../../../providers/app_developer.dart';
import '../../../providers/app_theme.dart';
import '../../../theme/color.dart';

Future<AppThemeColor?> showAppThemeColorChangerDialog({
  required BuildContext context,
  AppThemeColor? selectedColor,
}) async {
  return showDialog<AppThemeColor>(
    context: context,
    builder: (context) =>
        AppSettingThemeColorChoosenDialog(selectedColor: selectedColor),
  );
}

class AppSettingThemeColorTile extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppSettingThemeColorTile({super.key, this.onPressed});

  String buildSubTitleText(AppThemeColor themeColor, [L10n? l10n]) {
    switch (themeColor) {
      case SystemAppThemeColor():
        return l10n?.common_appThemeColor_system ?? "System";
      case PrimaryAppThemeColor():
        return l10n?.common_appThemeColor_primary ?? "Primary";
      case DynamicAppThemeColor():
        return l10n?.common_appThemeColor_dynamic ?? "Dynamic";
      case InternalAppThemeColor():
        final colorType = themeColor.colorType;
        return HabitColorType.getColorName(colorType, l10n);
      default:
        if (kDebugMode) {
          throw UnsupportedError("Unsupport theme color $themeColor");
        }
        return "<UNKNOWN>";
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = context.select<AppThemeViewModel, AppThemeColor>(
      (vm) => vm.themeColor,
    );
    final l10n = L10n.of(context);
    return ListTile(
      title: Text(
        l10n?.appSetting_appThemeColorTile_titleText ?? "Theme Color",
      ),
      subtitle: Text(buildSubTitleText(themeColor, l10n)),
      trailing: AppSettingThemeColorContainer(
        child: ColoredBox(color: Theme.of(context).colorScheme.primary),
      ),
      onTap: onPressed,
    );
  }
}

class AppSettingThemeColorContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double size;

  const AppSettingThemeColorContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(4),
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: padding,
      child: ClipOval(child: child),
    );
  }
}

class AppSettingThemeColorChoosenDialog extends StatelessWidget {
  final AppThemeColor? selectedColor;

  const AppSettingThemeColorChoosenDialog({super.key, this.selectedColor});

  @override
  Widget build(BuildContext context) {
    final debug = context.select<AppDeveloperViewModel, bool>(
      (vm) => vm.isInDevelopMode,
    );
    final l10n = L10n.of(context);
    return SimpleDialog(
      title: Text(
        l10n?.appSetting_appThemeColorChosenDiloag_titleText ??
            "Choose Theme Color",
      ),
      children: [
        _SystemChosenOption(
          isSelected: selectedColor is SystemAppThemeColor,
          debug: debug,
        ),
        _PrimaryChosenOption(
          isSelected: selectedColor is PrimaryAppThemeColor,
          debug: debug,
        ),
        if (!Platform.isIOS)
          _DynamicChosenOption(
            isSelected: selectedColor is DynamicAppThemeColor,
            debug: debug,
          ),
        ...HabitColorType.values.map((e) {
          bool isSelected(AppThemeColor? themeColor) {
            if (themeColor is! InternalAppThemeColor) return false;
            return themeColor.colorType == e;
          }

          return _InternalChosenOption(
            colorType: e,
            isSelected: isSelected(selectedColor),
            debug: debug,
          );
        }),
      ],
    );
  }
}

class _SystemChosenOption extends StatelessWidget {
  final bool isSelected;
  final bool debug;

  const _SystemChosenOption({required this.isSelected, this.debug = false});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      title: Text(l10n?.common_appThemeColor_system ?? "System"),
      subtitle: debug ? Text("${Theme.of(context).colorScheme.primary}") : null,
      leading: const AppSettingThemeColorContainer(child: SizedBox.expand()),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () => Navigator.of(context).pop(const SystemAppThemeColor()),
    );
  }
}

class _PrimaryChosenOption extends StatelessWidget {
  final bool isSelected;
  final bool debug;

  const _PrimaryChosenOption({required this.isSelected, this.debug = false});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      title: Text(l10n?.common_appThemeColor_primary ?? "Primary"),
      subtitle: debug ? Text("$appDefaultThemeMainColor") : null,
      leading: const AppSettingThemeColorContainer(
        child: ColoredBox(color: appDefaultThemeMainColor),
      ),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () => Navigator.of(context).pop(const PrimaryAppThemeColor()),
    );
  }
}

class _DynamicChosenOption extends StatelessWidget {
  final bool isSelected;
  final bool debug;

  const _DynamicChosenOption({required this.isSelected, this.debug = false});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final child = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            primaryColor,
            Colors.yellow.withValues(alpha: 0.8).harmonizeWith(primaryColor),
            Colors.blue.withValues(alpha: 0.8).harmonizeWith(primaryColor),
            primaryColor,
          ],
        ),
      ),
    );
    final sb = StringBuffer();
    if (debug) sb.writeln(primaryColor);
    switch (defaultTargetPlatform) {
      case TargetPlatform.android || TargetPlatform.fuchsia:
        sb.write(
          l10n?.appSetting_appThemeColorChosenDialog_subTitleText_android,
        );
      case TargetPlatform.macOS:
        sb.write(l10n?.appSetting_appThemeColorChosenDialog_subTitleText_macos);
      case TargetPlatform.windows:
        sb.write(l10n?.appSetting_appThemeColorChosenDialog_subTitleText_linux);
      case TargetPlatform.linux:
        sb.write(l10n?.appSetting_appThemeColorChosenDialog_subTitleText_linux);
      default:
    }
    return ListTile(
      title: Text(l10n?.common_appThemeColor_dynamic ?? "Dynamic"),
      subtitle: Text(sb.toString()),
      leading: AppSettingThemeColorContainer(child: child),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () => Navigator.of(context).pop(const DynamicAppThemeColor()),
    );
  }
}

class _InternalChosenOption extends StatelessWidget {
  final HabitColorType colorType;
  final bool isSelected;
  final bool debug;

  const _InternalChosenOption({
    required this.colorType,
    required this.isSelected,
    this.debug = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final color = Theme.of(
      context,
    ).extension<CustomColors>()?.getColor(colorType);
    return ListTile(
      title: Text(HabitColorType.getColorName(colorType, l10n)),
      subtitle: debug ? Text("$color") : null,
      leading: AppSettingThemeColorContainer(
        child: ColoredBox(color: color ?? Colors.transparent),
      ),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () => Navigator.of(
        context,
      ).pop(InternalAppThemeColor(colorType: colorType)),
    );
  }
}

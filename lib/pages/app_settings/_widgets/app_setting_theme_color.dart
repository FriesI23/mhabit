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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.g.dart';
import '../../../models/app_theme_color.dart';
import '../../../models/habit_form.dart';
import '../../../providers/app_theme.dart';

class AppSettingThemeColorTile extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppSettingThemeColorTile({
    super.key,
    this.onPressed,
  });

  String buildSubTitleText(AppThemeColor themeColor, [L10n? l10n]) {
    switch (themeColor) {
      case SystemAppThemeColor():
        return "System";
      case PrimaryAppThemeColor():
        return "Primary";
      case DynamicAppThemeColor():
        return "Dynamic";
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
    final themeColor =
        context.select<AppThemeViewModel, AppThemeColor>((vm) => vm.themeColor);

    return ListTile(
      title: Text("Theme Color"),
      subtitle: Text(buildSubTitleText(themeColor)),
      trailing:
          CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary),
      onTap: onPressed,
    );
  }
}

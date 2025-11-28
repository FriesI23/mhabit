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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../providers/app_theme.dart';
import '../../../theme/color.dart';

class AppThemeSwitchButton extends StatelessWidget {
  const AppThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final themeType =
        context.select<AppThemeViewModel, AppThemeType>((vm) => vm.themeType);
    final icon = switch (themeType) {
      AppThemeType.light => const Icon(Icons.light_mode_rounded),
      AppThemeType.dark => const Icon(Icons.dark_mode_rounded),
      _ => const Icon(MdiIcons.themeLightDark)
    };
    return IconButton(
        onPressed: () =>
            context.read<AppThemeViewModel>().onTapChangeThemeType(brightness),
        icon: icon);
  }
}

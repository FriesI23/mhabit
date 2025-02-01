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
import 'package:provider/provider.dart';

import '../../provider/app_sync.dart';

enum AppSyncServerDeleteButtonStyle { normal, fullsreen }

class AppSyncServerDeleteButton extends StatelessWidget {
  final AppSyncServerDeleteButtonStyle style;
  final VoidCallback? onPressed;

  const AppSyncServerDeleteButton({
    super.key,
    required this.style,
    this.onPressed,
  });

  const AppSyncServerDeleteButton.normal({super.key, this.onPressed})
      : style = AppSyncServerDeleteButtonStyle.normal;

  const AppSyncServerDeleteButton.fullscreen({super.key, this.onPressed})
      : style = AppSyncServerDeleteButtonStyle.fullsreen;

  TextButtonThemeData buildTextButtonTheme(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;
    final iconColor = WidgetStatePropertyAll(color);
    final buttonStyle = theme.textButtonTheme.style
            ?.copyWith(iconColor: iconColor, foregroundColor: iconColor) ??
        ButtonStyle(iconColor: iconColor, foregroundColor: iconColor);
    return TextButtonThemeData(style: buttonStyle);
  }

  OutlinedButtonThemeData buildOutlineButtonTheme(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;
    final iconColorStat = WidgetStatePropertyAll(color);
    final sideStat =
        WidgetStatePropertyAll(BorderSide(width: 0.8, color: color));
    final buttonStyle = theme.outlinedButtonTheme.style?.copyWith(
            iconColor: iconColorStat,
            foregroundColor: iconColorStat,
            side: sideStat) ??
        ButtonStyle(
            iconColor: iconColorStat,
            foregroundColor: iconColorStat,
            side: sideStat);
    return OutlinedButtonThemeData(style: buttonStyle);
  }

  Widget _buildNormlButton(BuildContext context, bool canDelete) =>
      TextButtonTheme(
        data: buildTextButtonTheme(context),
        child: TextButton(
          onPressed: canDelete ? onPressed : null,
          child: const Text('delete'),
        ),
      );

  Widget _buildFullscreenButton(BuildContext context, bool canDelete) =>
      ListTile(
        title: OutlinedButtonTheme(
          data: buildOutlineButtonTheme(context),
          child: OutlinedButton.icon(
            onPressed: canDelete ? onPressed : null,
            label: const Text('delete'),
            icon: const Icon(Icons.delete_outline),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final canDelete =
        context.select<AppSyncViewModel, bool>((vm) => vm.serverConfig != null);
    return Visibility(
      visible: canDelete,
      child: switch (style) {
        AppSyncServerDeleteButtonStyle.normal =>
          _buildNormlButton(context, canDelete),
        AppSyncServerDeleteButtonStyle.fullsreen =>
          _buildFullscreenButton(context, canDelete),
      },
    );
  }
}

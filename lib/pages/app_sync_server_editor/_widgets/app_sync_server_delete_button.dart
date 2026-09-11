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

import '../../../l10n/localizations.dart';
import '../../../widgets/widgets.dart';
import '../_providers/app_sync_server_form.dart';

class AppSyncServerDeleteButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppSyncServerDeleteButton({super.key, this.onPressed});

  TextButtonThemeData buildTextButtonTheme(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;
    final iconColor = WidgetStatePropertyAll(color);
    final buttonStyle =
        theme.textButtonTheme.style?.copyWith(
          iconColor: iconColor,
          foregroundColor: iconColor,
        ) ??
        ButtonStyle(iconColor: iconColor, foregroundColor: iconColor);
    return TextButtonThemeData(style: buttonStyle);
  }

  Widget _buildDeleteText(BuildContext context) => Text(
    L10n.of(
          context,
        )?.confirmDialog_confirm_text(NormalizeConfirmDialogType.delete.name) ??
        'delete',
  );

  @override
  Widget build(BuildContext context) {
    final canDelete = context.select<AppSyncServerFormViewModel, bool>(
      (vm) => vm.serverConfig != null,
    );
    return Visibility(
      visible: canDelete,
      child: TextButtonTheme(
        data: buildTextButtonTheme(context),
        child: TextButton(
          onPressed: canDelete ? onPressed : null,
          child: _buildDeleteText(context),
        ),
      ),
    );
  }
}

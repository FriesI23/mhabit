// Copyright 2026 Fries_I23
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

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../providers/app_ui/app_caches.dart';
import '../../../widgets/widgets.dart';

class AppSettingOpenSystemLanguageTile extends StatelessWidget {
  const AppSettingOpenSystemLanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      title: Text(
        l10n?.appSetting_openSystemLanguageTile_titleText ??
            "System Language Settings",
      ),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => _onTap(context),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    if (Platform.isMacOS) {
      final caches = context.read<AppCachesViewModel>();
      if (!caches.appFlagSkipOpenSystemLanguageConfirm) {
        final skipLabel = L10n.of(context)?.common_dontShowAgain;
        final l10n = L10n.of(context);
        final result = await showConfirmDialog(
          context: context,
          title: Text(
            l10n?.appSetting_openSystemLanguageTile_dialogTitle ??
                "Open System Language Settings",
          ),
          subtitle: SingleChildScrollView(
            child: ThematicMarkdownBlock(
              data:
                  l10n?.appSetting_openSystemLanguageTile_macosDialogContent ??
                  "Due to macOS limitations, the app language cannot be changed directly. "
                      "To switch languages, follow these steps:\n\n"
                      "1. Open **System Settings > General > Language & Region**\n"
                      "2. Add this app in the **Applications** list and choose a language",
              selectable: false,
            ),
          ),
          confirmTextBuilder: (context) {
            final l10n = L10n.of(context);
            return Text(l10n?.confirmDialog_confirm_text('open') ?? 'Open');
          },
          cancelTextBuilder: (context) {
            final l10n = L10n.of(context);
            return Text(l10n?.confirmDialog_cancel_text ?? 'Cancel');
          },
          skipOnConfirm: true,
          skipInitiallyEnabled: false,
          skipLabel: skipLabel,
        );

        if (result != true) return;
        if (context.mounted) {
          await caches.updateAppFlagSkipOpenSystemLanguageConfirm(true);
        }
      }
    }

    if (!context.mounted) return;
    AppSettings.openAppSettings(type: AppSettingsType.appLocale);
  }
}

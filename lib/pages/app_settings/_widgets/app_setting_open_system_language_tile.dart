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

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import '../../../l10n/localizations.dart';

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
      onTap: () {
        AppSettings.openAppSettings(type: AppSettingsType.appLocale);
      },
    );
  }
}

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

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import '../../../l10n/localizations.dart';
import '../../page_app_notify_config.dart' as app_notify_config;

class AppSettingNotifyTile extends StatelessWidget {
  const AppSettingNotifyTile({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) return const _AndroidAppSettingNotifyTile();
    return const _AppSettingNotifyTile();
  }
}

class _AndroidAppSettingNotifyTile extends StatelessWidget {
  const _AndroidAppSettingNotifyTile();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      title: Text(l10n?.appSetting_notify_titleTile ?? "Notifications"),
      subtitle: l10n != null
          ? Text(l10n.appSetting_notify_subtitleTile_android)
          : null,
      onTap: () {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      },
    );
  }
}

class _AppSettingNotifyTile extends StatelessWidget {
  const _AppSettingNotifyTile();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      title: Text(l10n?.appSetting_notify_titleTile ?? "Notifications"),
      subtitle: l10n != null ? Text(l10n.appSetting_notify_subtitleTile) : null,
      onTap: () => app_notify_config.naviToNotifyConfigPage(context: context),
    );
  }
}

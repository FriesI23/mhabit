// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import '../../../l10n/localizations.dart';
import '../../../models/app_reminder_config.dart';

class AppSettingReminderTile extends StatefulWidget {
  final AppReminderConfig config;
  final ValueChanged<bool>? onSwitchButtonChanged;
  final ValueChanged<TimeOfDay>? onTimePicked;

  const AppSettingReminderTile({
    super.key,
    required this.config,
    this.onSwitchButtonChanged,
    this.onTimePicked,
  });

  @override
  State<AppSettingReminderTile> createState() => _AppSettingReminderTileState();
}

class _AppSettingReminderTileState extends State<AppSettingReminderTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);
    return ListTile(
      title: l10n != null
          ? Text(l10n.appSetting_dailyReminder_titleText)
          : const Text("Daily reminder"),
      subtitle: widget.config.timeOfDay != null
          ? Text(
              widget.config.timeOfDay!.format(context),
              style: widget.config.enabled
                  ? null
                  : TextStyle(color: theme.colorScheme.outlineVariant),
            )
          : null,
      trailing: Switch(
        value: widget.config.enabled,
        onChanged: widget.onSwitchButtonChanged,
      ),
      onTap: () async {
        final result = await showTimePicker(
          context: context,
          initialTime:
              widget.config.timeOfDay ??
              AppReminderConfig.dailyNight.timeOfDay!,
        );
        if (!mounted || result == null) return;
        widget.onTimePicked?.call(result);
      },
    );
  }
}

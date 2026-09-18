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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

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
    final style = AdaptiveStyle.of(context);
    final title = l10n?.appSetting_dailyReminder_titleText ?? 'Daily reminder';
    return AdaptiveListTile(
      title: Text(title),
      subtitle: widget.config.timeOfDay != null
          ? Text(
              widget.config.timeOfDay!.format(context),
              style: widget.config.enabled || style == AdaptiveStyle.apple
                  ? null
                  : TextStyle(color: theme.colorScheme.outlineVariant),
            )
          : null,
      trailing: Semantics(
        container: true,
        label: title,
        child: switch (style) {
          AdaptiveStyle.material => Switch(
            value: widget.config.enabled,
            onChanged: widget.onSwitchButtonChanged,
          ),
          AdaptiveStyle.apple => CupertinoSwitch(
            value: widget.config.enabled,
            onChanged: widget.onSwitchButtonChanged,
          ),
        },
      ),
      onTap: () async {
        final initialTime =
            widget.config.timeOfDay ?? AppReminderConfig.dailyNight.timeOfDay!;
        final result = await switch (style) {
          AdaptiveStyle.material => showTimePicker(
            context: context,
            initialTime: initialTime,
          ),
          AdaptiveStyle.apple => showCupertinoModalPopup<TimeOfDay>(
            context: context,
            semanticsDismissible: true,
            builder: (context) =>
                _AppleReminderTimePicker(initialTime: initialTime),
          ),
        };
        if (!mounted || result == null) return;
        widget.onTimePicked?.call(result);
      },
    );
  }
}

class _AppleReminderTimePicker extends StatefulWidget {
  const _AppleReminderTimePicker({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_AppleReminderTimePicker> createState() =>
      _AppleReminderTimePickerState();
}

class _AppleReminderTimePickerState extends State<_AppleReminderTimePicker> {
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) => PopScope<TimeOfDay>(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop || ModalRoute.of(context)?.isCurrent != true) return;
      Navigator.of(context).pop(result ?? _selectedTime);
    },
    child: ColoredBox(
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 216,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            initialDateTime: DateTime(
              2000,
              1,
              1,
              widget.initialTime.hour,
              widget.initialTime.minute,
            ),
            use24hFormat: MediaQuery.alwaysUse24HourFormatOf(context),
            onDateTimeChanged: (value) =>
                _selectedTime = TimeOfDay.fromDateTime(value),
          ),
        ),
      ),
    ),
  );
}

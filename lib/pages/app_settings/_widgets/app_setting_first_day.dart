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
import 'package:intl/intl.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../common/consts.dart';
import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';

Future<int?> showAppSettingFirstDaySelectDialog({
  required BuildContext context,
  int? firstDay,
}) async {
  return showAdaptiveSheet<int>(
    context: context,
    builder: (context) =>
        AppSettingFirstDaySelectDialog(initFirstday: firstDay),
  );
}

class AppSettingFirstDayTile extends StatelessWidget {
  final int firstDay;
  final VoidCallback? onPressed;

  const AppSettingFirstDayTile({
    super.key,
    required this.firstDay,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AdaptiveListTile.navigation(
      title: l10n != null
          ? Text(l10n.appSetting_firstDayOfWeek_titleText)
          : const Text("First day of week"),
      subtitle: Text(
        DateFormat.EEEE(
          l10n?.localeName,
        ).format(getProtoDateWithFirstDay(firstDay)),
      ),
      onTap: onPressed,
    );
  }
}

class AppSettingFirstDaySelectDialog extends StatelessWidget {
  final int? initFirstday;

  const AppSettingFirstDaySelectDialog({super.key, this.initFirstday});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final formatter = DateFormat.EEEE(l10n?.localeName);
    return AdaptiveModal(
      size: const AdaptiveModalSize.constrained(),
      title: Text(
        l10n?.appSetting_firstDayOfWeekDialog_titleText ??
            'Show first day of week',
      ),
      body: AdaptiveListSection(
        appleTransparent: true,
        padding: EdgeInsets.zero,
        children: [
          for (var day = DateTime.monday; day <= DateTime.sunday; day++)
            Semantics(
              key: ValueKey('first-day-option-$day'),
              selected: initFirstday == day,
              child: _FirstDayOption(
                label:
                    formatter.format(getProtoDateWithFirstDay(day)) +
                    (day == defaultFirstDay
                        ? l10n?.appSetting_firstDayOfWeekDialog_defaultText ??
                              ' (Default)'
                        : ''),
                selected: initFirstday == day,
                onTap: () => Navigator.of(context).pop(day),
              ),
            ),
        ],
      ),
    );
  }
}

class _FirstDayOption extends StatelessWidget {
  const _FirstDayOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AdaptiveListTile(
    title: Text(label),
    trailing: selected ? const AdaptiveCheckmark() : null,
    onTap: onTap,
  );
}

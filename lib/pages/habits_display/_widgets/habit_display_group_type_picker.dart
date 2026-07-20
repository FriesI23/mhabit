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

import 'package:flutter/material.dart';

import '../../../common/consts.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_group_display.dart';
import '../../../storage/profile/handlers/display_group_mode.dart';
import '../../../widgets/widgets.dart';
import '../_providers/habits_grouping.dart';

Future<DisplayGroupModeOption?> showHabitDisplayGroupTypePickerDialog({
  required BuildContext context,
  HabitDisplayGroupType? groupType,
  HabitDisplaySortDirection? groupDirection,
}) async {
  return showDialog<DisplayGroupModeOption>(
    context: context,
    builder: (context) => HabitDisplayGroupTypePickerDialog(
      groupType: groupType,
      groupDirection: groupDirection,
    ),
  );
}

class HabitDisplayGroupTypePickerDialog extends StatefulWidget {
  final DisplayGroupModeOption initGroupOption;

  const HabitDisplayGroupTypePickerDialog({
    super.key,
    HabitDisplayGroupType? groupType,
    HabitDisplaySortDirection? groupDirection,
  }) : initGroupOption = (groupType, groupDirection);

  @override
  State<StatefulWidget> createState() => _HabitDisplayGroupTypePickerDialog();
}

class _HabitDisplayGroupTypePickerDialog
    extends State<HabitDisplayGroupTypePickerDialog> {
  late DisplayGroupModeOption _crtGroupOption;

  @override
  void initState() {
    super.initState();
    _crtGroupOption = widget.initGroupOption;
  }

  void _onRadioTapChanged(HabitDisplayGroupType? value) {
    setState(() {
      _crtGroupOption = (value, _crtGroupOption.$2);
    });
  }

  HabitDisplayGroupType? get crtGroupType => _crtGroupOption.$1;
  HabitDisplaySortDirection? get crtGroupDirection => _crtGroupOption.$2;

  HabitDisplaySortDirection get crtShowDirectionWithDefault =>
      crtGroupDirection ?? defaultSortDirection;

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> buildGroupTypeRadioListTiles(BuildContext context) =>
        HabitDisplayGroupType.menuOrderedList.map(
          (groupType) => _GroupTypeRadioListTile(
            groupType: groupType,
            groupDirection: crtShowDirectionWithDefault,
          ),
        );

    return AlertDialog(
      scrollable: true,
      title: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.habitDisplay_groupTypeDialog_title)
            : const Text('Group Sort'),
      ),
      contentPadding: const EdgeInsets.only(bottom: 24, top: 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioGroup<HabitDisplayGroupType?>(
            groupValue: crtGroupType,
            onChanged: _onRadioTapChanged,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NoneGroupingRadioListTile(
                  groupDirection: crtShowDirectionWithDefault,
                ),
                ...buildGroupTypeRadioListTiles(context),
              ],
            ),
          ),
          const Divider(),
          CheckboxListTile(
            title: L10nBuilder(
              builder: (context, l10n) => l10n != null
                  ? Text(l10n.habitDisplay_sort_reverseText)
                  : const Text("Reverse"),
            ),
            value: crtGroupDirection == HabitDisplaySortDirection.desc,
            enabled: crtGroupType != null,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              final newGroupDirection = value == true
                  ? HabitDisplaySortDirection.desc
                  : HabitDisplaySortDirection.asc;
              setState(() {
                _crtGroupOption = (_crtGroupOption.$1, newGroupDirection);
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: L10nBuilder(
            builder: (context, l10n) => l10n != null
                ? Text(l10n.habitDisplay_groupTypeDialog_cancel)
                : const Text('cancel'),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _crtGroupOption);
          },
          child: L10nBuilder(
            builder: (context, l10n) => l10n != null
                ? Text(l10n.habitDisplay_groupTypeDialog_confirm)
                : const Text('confirm'),
          ),
        ),
      ],
    );
  }
}

class _NoneGroupingRadioListTile extends StatelessWidget {
  final HabitDisplaySortDirection groupDirection;

  const _NoneGroupingRadioListTile({required this.groupDirection});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return RadioListTile<HabitDisplayGroupType?>(
      title: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.habitDisplay_groupTypeDialog_none)
            : const Text('Flat'),
      ),
      secondary: Icon(
        HabitsGroupingViewModel.getIcon(null, groupDirection),
        color: colorScheme.outline,
      ),
      value: null,
    );
  }
}

class _GroupTypeRadioListTile extends StatelessWidget {
  final HabitDisplayGroupType groupType;
  final HabitDisplaySortDirection groupDirection;

  const _GroupTypeRadioListTile({
    required this.groupType,
    required this.groupDirection,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<HabitDisplayGroupType?>(
      title: Text(
        HabitsGroupingViewModel.getTitle(
          groupType,
          null,
          l10n: L10n.of(context),
        ),
      ),
      secondary: Icon(
        HabitsGroupingViewModel.getIcon(groupType, groupDirection),
      ),
      value: groupType,
    );
  }
}

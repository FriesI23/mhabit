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
import 'package:tuple/tuple.dart';

import '../../common/consts.dart';
import '../../l10n/localizations.dart';
import '../../model/habit_display.dart';
import '../../providers/habits_sort.dart';
import '../../widgets/widgets.dart';

typedef SortMenuOption
    = Tuple2<HabitDisplaySortType?, HabitDisplaySortDirection?>;

Future<SortMenuOption?> showHabitDisplaySortTypePickerDialog({
  required BuildContext context,
  HabitDisplaySortType? sortType,
  HabitDisplaySortDirection? sortDirection,
}) async {
  return showDialog<SortMenuOption>(
    context: context,
    builder: (context) => HabitDisplaySortTypePickerDialog(
      sortType: sortType,
      sortDirection: sortDirection,
    ),
  );
}

class HabitDisplaySortTypePickerDialog extends StatefulWidget {
  final SortMenuOption initSortOption;

  HabitDisplaySortTypePickerDialog({
    super.key,
    HabitDisplaySortType? sortType,
    HabitDisplaySortDirection? sortDirection,
  }) : initSortOption = Tuple2(sortType, sortDirection);

  @override
  State<StatefulWidget> createState() => _HabitDisplaySortTypePickerDialog();
}

class _HabitDisplaySortTypePickerDialog
    extends State<HabitDisplaySortTypePickerDialog> {
  late SortMenuOption _crtSortOption;

  @override
  void initState() {
    super.initState();
    _crtSortOption = widget.initSortOption;
  }

  void _onRadioTapChanged(HabitDisplaySortType? value) {
    if (value == null) return;
    setState(() {
      _crtSortOption = Tuple2(value, _crtSortOption.item2);
    });
  }

  HabitDisplaySortType? get crtSortType => _crtSortOption.item1;
  HabitDisplaySortDirection? get crtSortDirection => _crtSortOption.item2;

  HabitDisplaySortDirection get crtShowDirecitonWithDefault =>
      crtSortDirection ?? defaultSortDirection;

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> buildSortTypeRadioListTiles(BuildContext context) =>
        HabitDisplaySortType.menuOrderedList.map(
          (sortType) => _SortTypeRadioListTile(
            sortType: sortType,
            sortDirection: crtShowDirecitonWithDefault,
            crtSortType: crtSortType,
            onChanged: _onRadioTapChanged,
          ),
        );

    return AlertDialog(
      scrollable: true,
      title: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.habitDisplay_sortTypeDialog_title)
            : const Text('Sort'),
      ),
      contentPadding: const EdgeInsets.only(bottom: 24, top: 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...buildSortTypeRadioListTiles(context),
          const Divider(),
          CheckboxListTile(
            title: L10nBuilder(
              builder: (context, l10n) => l10n != null
                  ? Text(l10n.habitDisplay_sort_reverseText)
                  : const Text("Reverse"),
            ),
            value: crtSortDirection == HabitDisplaySortDirection.desc,
            enabled: crtSortType != HabitDisplaySortType.manual,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              final newSortDirection = value == true
                  ? HabitDisplaySortDirection.desc
                  : HabitDisplaySortDirection.asc;
              setState(() {
                _crtSortOption = Tuple2(_crtSortOption.item1, newSortDirection);
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
                ? Text(l10n.habitDisplay_sortTypeDialog_cancel)
                : const Text('cancel'),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _crtSortOption);
          },
          child: L10nBuilder(
            builder: (context, l10n) => l10n != null
                ? Text(l10n.habitDisplay_sortTypeDialog_confirm)
                : const Text('confirm'),
          ),
        )
      ],
    );
  }
}

class _SortTypeRadioListTile extends StatelessWidget {
  final HabitDisplaySortType sortType;
  final HabitDisplaySortDirection sortDirection;
  final HabitDisplaySortType? crtSortType;
  final ValueChanged<HabitDisplaySortType?>? onChanged;

  const _SortTypeRadioListTile({
    required this.sortType,
    required this.sortDirection,
    this.crtSortType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<HabitDisplaySortType>(
      title: Text(
        HabitsSortViewModel.getSortTitle(sortType, null,
            l10n: L10n.of(context)),
      ),
      secondary: Icon(
        HabitsSortViewModel.getSortIcon(sortType, sortDirection),
      ),
      value: sortType,
      groupValue: crtSortType,
      onChanged: onChanged,
    );
  }
}

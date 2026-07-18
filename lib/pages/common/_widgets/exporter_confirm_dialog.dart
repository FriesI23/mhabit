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

Future<Set<ExporterConfirmResultType>?> showExporterConfirmDialog({
  required BuildContext context,
  int exportHabitsNumber = 0,
  int exportGroupsNumber = 0,
  bool exportAll = false,
}) async {
  return showDialog<Set<ExporterConfirmResultType>>(
    context: context,
    builder: (context) => ExporterConfirmDialog(
      exportHabitsNumber: exportHabitsNumber,
      exportGroupsNumber: exportGroupsNumber,
      exportAll: exportAll,
    ),
  );
}

enum ExporterConfirmResultType { habit, records, groups }

class ExporterConfirmDialog extends StatefulWidget {
  final int exportHabitsNumber;
  final int exportGroupsNumber;
  final bool exportAll;

  const ExporterConfirmDialog({
    super.key,
    this.exportHabitsNumber = 0,
    this.exportGroupsNumber = 0,
    this.exportAll = false,
  });

  @override
  State<ExporterConfirmDialog> createState() => _ExporterConfirmDialogState();
}

class _ExporterConfirmDialogState extends State<ExporterConfirmDialog> {
  bool exportRecord = true;
  bool exportGroups = true;

  @override
  Widget build(BuildContext context) {
    Widget buildTitle(BuildContext context) {
      final l10n = L10n.of(context);
      if (widget.exportAll) {
        return Text(
          l10n?.exportConfirmDialog_title_exportAll ?? "Export all habits?",
        );
      } else {
        return Text(
          l10n?.exportConfirmDialog_title_exportMulti(
                widget.exportHabitsNumber,
              ) ??
              "Export habits?",
        );
      }
    }

    final l10n = L10n.of(context);
    final hasGroups = widget.exportGroupsNumber > 0;
    final showHabitCount = widget.exportHabitsNumber > 0;
    return AlertDialog(
      title: buildTitle(context),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: l10n != null
                ? Text(
                    showHabitCount
                        ? l10n.exportConfirmDialog_tile_includeRecords(
                            widget.exportHabitsNumber,
                          )
                        : l10n.exportConfirmDialog_option_includeRecords,
                  )
                : const Text('include records'),
            value: exportRecord,
            onChanged: (value) => setState(() {
              exportRecord = !exportRecord;
            }),
          ),
          if (hasGroups)
            CheckboxListTile(
              title: l10n != null
                  ? Text(
                      l10n.exportConfirmDialog_tile_includeGroups(
                        widget.exportGroupsNumber,
                      ),
                    )
                  : Text('Include ${widget.exportGroupsNumber} groups'),
              value: exportGroups,
              onChanged: (value) => setState(() {
                exportGroups = !exportGroups;
              }),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.maybePop(context),
          child: l10n != null
              ? Text(l10n.exportConfirmDialog_cancel_buttonText)
              : const Text("cancel"),
        ),
        TextButton(
          onPressed: () {
            final result = <ExporterConfirmResultType>{
              ExporterConfirmResultType.habit,
              if (exportRecord) ExporterConfirmResultType.records,
              if (exportGroups) ExporterConfirmResultType.groups,
            };
            Navigator.pop(context, result);
          },
          child: l10n != null
              ? Text(l10n.exportConfirmDialog_confirm_buttonText)
              : const Text("export"),
        ),
      ],
    );
  }
}

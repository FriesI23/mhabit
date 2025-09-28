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

import '../../l10n/localizations.dart';

Future<ExporterConfirmResultType?> showExporterConfirmDialog({
  required BuildContext context,
  int exportHabitsNumber = 0,
  bool exportAll = false,
}) async {
  return showDialog<ExporterConfirmResultType>(
    context: context,
    builder: (context) => ExporterConfirmDialog(
      exportHabitsNumber: exportHabitsNumber,
      exportAll: exportAll,
    ),
  );
}

enum ExporterConfirmResultType {
  basic,
  withRecords,
}

class ExporterConfirmDialog extends StatefulWidget {
  final int exportHabitsNumber;
  final bool exportAll;

  const ExporterConfirmDialog({
    super.key,
    this.exportHabitsNumber = 0,
    this.exportAll = false,
  });

  @override
  State<ExporterConfirmDialog> createState() => _ExporterConfirmDialogState();
}

class _ExporterConfirmDialogState extends State<ExporterConfirmDialog> {
  bool exportRecord = true;

  @override
  Widget build(BuildContext context) {
    Widget buildTitle(BuildContext context) {
      final l10n = L10n.of(context);
      if (widget.exportAll) {
        return Text(
            l10n?.exportConfirmDialog_title_exportAll ?? "Export all habits?");
      } else {
        return Text(l10n?.exportConfirmDialog_title_exportMulti(
                widget.exportHabitsNumber) ??
            "Export habits?");
      }
    }

    final l10n = L10n.of(context);
    return AlertDialog(
      title: buildTitle(context),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: l10n != null
                ? Text(l10n.exportConfirmDialog_option_includeRecords)
                : const Text("include records"),
            value: exportRecord,
            onChanged: (value) => setState(() {
              exportRecord = !exportRecord;
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
            if (exportRecord) {
              Navigator.pop(context, ExporterConfirmResultType.withRecords);
            } else {
              Navigator.pop(context, ExporterConfirmResultType.basic);
            }
          },
          child: l10n != null
              ? Text(l10n.exportConfirmDialog_confirm_buttonText)
              : const Text("export"),
        )
      ],
    );
  }
}

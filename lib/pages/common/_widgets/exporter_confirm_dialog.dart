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

Future<Set<ExporterConfirmResultType>?> showExporterConfirmDialog({
  required BuildContext context,
  int exportHabitsNumber = 0,
  int exportGroupsNumber = 0,
  bool exportAll = false,
}) => showAdaptiveSheet<Set<ExporterConfirmResultType>>(
  context: context,
  presentationOverride: AdaptiveModalPresentation.dialog,
  builder: (_) => ExporterConfirmDialog(
    exportHabitsNumber: exportHabitsNumber,
    exportGroupsNumber: exportGroupsNumber,
    exportAll: exportAll,
  ),
);

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

  void _confirm() => Navigator.pop(context, <ExporterConfirmResultType>{
    ExporterConfirmResultType.habit,
    if (exportRecord) ExporterConfirmResultType.records,
    if (exportGroups) ExporterConfirmResultType.groups,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final title = widget.exportAll
        ? (l10n?.exportConfirmDialog_title_exportAll ?? 'Export all habits?')
        : (l10n?.exportConfirmDialog_title_exportMulti(
                widget.exportHabitsNumber,
              ) ??
              'Export habits?');
    final recordsLabel = l10n == null
        ? 'include records'
        : widget.exportHabitsNumber > 0
        ? l10n.exportConfirmDialog_tile_includeRecords(
            widget.exportHabitsNumber,
          )
        : l10n.exportConfirmDialog_option_includeRecords;
    final groupsLabel =
        l10n?.exportConfirmDialog_tile_includeGroups(
          widget.exportGroupsNumber,
        ) ??
        'Include ${widget.exportGroupsNumber} groups';
    final cancelLabel = l10n?.exportConfirmDialog_cancel_buttonText ?? 'cancel';
    final confirmLabel =
        l10n?.exportConfirmDialog_confirm_buttonText ?? 'export';
    final options = <Widget>[
      AdaptiveSwitchListTile(
        key: const ValueKey('export-records'),
        title: Text(recordsLabel),
        value: exportRecord,
        onChanged: (value) => setState(() => exportRecord = value),
      ),
      if (widget.exportGroupsNumber > 0)
        AdaptiveSwitchListTile(
          key: const ValueKey('export-groups'),
          title: Text(groupsLabel),
          value: exportGroups,
          onChanged: (value) => setState(() => exportGroups = value),
        ),
    ];

    final style = AdaptiveStyle.of(context);
    return AdaptiveModal.simple(
      size: const AdaptiveModalSize.constrained(minWidth: 320),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: style == AdaptiveStyle.apple
                ? TextAlign.center
                : TextAlign.start,
            style: switch (style) {
              AdaptiveStyle.material =>
                DialogTheme.of(context).titleTextStyle ??
                    Theme.of(context).textTheme.headlineSmall,
              AdaptiveStyle.apple => CupertinoTheme.of(
                context,
              ).textTheme.navTitleTextStyle,
            },
          ),
          const SizedBox(height: 16),
          switch (style) {
            AdaptiveStyle.material => Column(
              mainAxisSize: MainAxisSize.min,
              children: options,
            ),
            AdaptiveStyle.apple => AdaptiveListSection(
              appleTransparent: true,
              padding: EdgeInsets.zero,
              children: options,
            ),
          },
        ],
      ),
      actions: switch (style) {
        AdaptiveStyle.material => [
          TextButton(
            onPressed: () => Navigator.maybePop(context),
            child: Text(cancelLabel),
          ),
          TextButton(onPressed: _confirm, child: Text(confirmLabel)),
        ],
        AdaptiveStyle.apple => [
          CupertinoButton(
            onPressed: () => Navigator.maybePop(context),
            child: Text(cancelLabel),
          ),
          CupertinoButton(onPressed: _confirm, child: Text(confirmLabel)),
        ],
      },
    );
  }
}

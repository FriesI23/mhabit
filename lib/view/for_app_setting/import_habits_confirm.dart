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
import 'package:provider/provider.dart';

import '../../l10n/localizations.dart';
import '../../provider/habits_file_importer.dart';

Future<void> showAppSettingImportHabitsConfirmDialog({
  required BuildContext context,
  required Iterable<Object?> habitsData,
  required int habitCount,
  required HabitFileImporterViewModel importer,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: importer),
      ],
      child: AppSettingImportHabitsConfirmDialog(
        data: habitsData,
        habitCount: habitCount,
      ),
    ),
  );
}

class AppSettingImportHabitsConfirmDialog extends StatefulWidget {
  final Iterable<Object?> data;
  final int habitCount;

  const AppSettingImportHabitsConfirmDialog(
      {super.key, required this.data, this.habitCount = 0});

  @override
  State<StatefulWidget> createState() => _AppSettingImportHabitsConfirmDialog();
}

class _AppSettingImportHabitsConfirmDialog
    extends State<AppSettingImportHabitsConfirmDialog> {
  bool _confirmed = false;
  bool _completed = false;
  int completeCount = 0;
  int totalCount = 0;

  void confirmed() {
    _confirmed = true;
  }

  void _whenHabitLoad(int count, int total) {
    if (!mounted) return;
    setState(() {
      completeCount = count;
      totalCount = total;
    });
  }

  void _whenAllHabitsLoad(int total) async {
    if (!mounted) return;
    setState(() {
      _completed = true;
    });
  }

  void _onConfirmButtonPressed() {
    if (!mounted || _confirmed) return;
    final dataImporter = context.read<HabitFileImporterViewModel>();
    if (!dataImporter.mounted) return;
    final result = dataImporter.importHabitsData(
      widget.data,
      whenloadHabit: _whenHabitLoad,
      whenloadAllHabits: _whenAllHabitsLoad,
    );
    if (!result) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(confirmed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    Widget buildTitle(BuildContext context) {
      if (_completed) {
        return Text(
          l10n?.appSetting_importDialog_completeTitle(totalCount) ??
              "Completed  $completeCount/$totalCount",
        );
      } else if (_confirmed) {
        return Text(
          l10n?.appSetting_importDialog_importingTitle(
                  completeCount, totalCount) ??
              "Imported $completeCount/$totalCount",
        );
      } else {
        return Text(
          l10n?.appSetting_importDialog_confirmTitle(widget.habitCount) ??
              "Confirm import ${widget.habitCount} habits?",
        );
      }
    }

    return AlertDialog(
      title: buildTitle(context),
      content: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        firstChild: Text(l10n?.appSetting_importDialog_confirmSubtitle ?? ''),
        secondChild: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 20),
          child: LinearProgressIndicator(
            value: totalCount > 0 ? completeCount / totalCount : null,
          ),
        ),
        crossFadeState:
            !_confirmed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      ),
      actionsAlignment: _completed ? MainAxisAlignment.center : null,
      actions: [
        if (_completed)
          TextButton.icon(
            onPressed: () => Navigator.maybeOf(context)?.maybePop(),
            icon: const Icon(Icons.close),
            label: l10n != null
                ? Text(l10n.appSetting_importDialog_complete_closeLabel)
                : const Text('close'),
          ),
        if (!_completed)
          TextButton(
            onPressed:
                !_confirmed ? () => Navigator.of(context).maybePop() : null,
            child: l10n != null
                ? Text(l10n.appSetting_importDialog_confirm_cancelText)
                : const Text('cancel'),
          ),
        if (!_completed)
          TextButton(
            onPressed: !_confirmed ? _onConfirmButtonPressed : null,
            child: l10n != null
                ? Text(l10n.appSetting_importDialog_confirm_confirmText)
                : const Text('confirm'),
          )
      ],
    );
  }
}

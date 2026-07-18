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

import '../../../common/types.dart';
import '../../../l10n/localizations.dart';
import '../../../models/app_event.dart';
import '../../../providers/workflow/app_event.dart';
import '../../../providers/workflow/habits_file_importer.dart';

Future<void> showAppSettingImportHabitsConfirmDialog({
  required BuildContext context,
  required Iterable<Object?> habitsData,
  required int habitCount,
  required HabitFileImportRunner importer,
  String? providerName,
  Iterable<Object?>? groupsData,
  int groupCount = 0,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => MultiProvider(
      providers: [ChangeNotifierProvider.value(value: importer)],
      child: AppSettingImportHabitsConfirmDialog(
        data: habitsData,
        habitCount: habitCount,
        providerName: providerName,
        groupsData: groupsData,
        groupCount: groupCount,
      ),
    ),
  );
}

class AppSettingImportHabitsConfirmDialog extends StatefulWidget {
  final Iterable<Object?> data;
  final int habitCount;
  final String? providerName;
  final Iterable<Object?>? groupsData;
  final int groupCount;

  const AppSettingImportHabitsConfirmDialog({
    super.key,
    required this.data,
    this.habitCount = 0,
    this.providerName,
    this.groupsData,
    this.groupCount = 0,
  });

  @override
  State<StatefulWidget> createState() => _AppSettingImportHabitsConfirmDialog();
}

class _AppSettingImportHabitsConfirmDialog
    extends State<AppSettingImportHabitsConfirmDialog> {
  bool _confirmed = false;
  bool _completed = false;
  bool _importHabits = true;
  bool _importGroups = true;
  int _habitComplete = 0, _habitFailed = 0, _habitTotal = 0;
  int _groupComplete = 0, _groupFailed = 0, _groupTotal = 0;

  int get _currentCount =>
      _habitComplete + _habitFailed + _groupComplete + _groupFailed;
  int get _totalCount => _habitTotal + _groupTotal;

  void _whenHabitLoad(int count, int failed, int total) {
    if (!mounted) return;
    setState(() {
      _habitComplete = count;
      _habitFailed = failed;
      _habitTotal = total;
    });
  }

  void _whenAllHabitsLoad(int count, int failed, int total) {
    if (!mounted) return;
    _habitComplete = count;
    _habitFailed = failed;
    _habitTotal = total;
    context.read<AppEventBus>().push(
      const ReloadDataEvent(
        msg: "appt_settings.import._whenAllHabitsLoad",
        clearSnackBar: true,
        trace: {
          AppEventPageSource.appSetting: {AppEventFunctionSource.habitImport},
        },
      ),
    );
    setState(() {
      _completed = true;
    });
  }

  void _onConfirmButtonPressed() async {
    if (!mounted || _confirmed) return;
    final dataImporter = context.read<HabitFileImportRunner>();
    if (!dataImporter.mounted) return;

    final importGroups = _importGroups && widget.groupsData != null;
    final importHabits = _importHabits;

    setState(() {
      _confirmed = true;
      if (importGroups) _groupTotal = widget.groupCount;
      if (importHabits) _habitTotal = widget.habitCount;
    });

    // Step 1: Import groups first to build the UUID mapping.
    Map<String, GroupUUID>? groupMapping;
    if (importGroups) {
      try {
        groupMapping = await dataImporter.importGroupsData(widget.groupsData!);
        _groupComplete = widget.groupCount;
      } catch (_) {
        _groupFailed = widget.groupCount;
      }
      if (mounted) setState(() {});
    }

    // Step 2: Import habits with the group UUID mapping.
    final task = dataImporter.importHabitsData(
      importHabits ? widget.data : [],
      whenloadHabit: _whenHabitLoad,
      whenloadAllHabits: _whenAllHabitsLoad,
      groupUuidMapping: groupMapping,
    );
    if (task == null) {
      if (!mounted) return;
      Navigator.of(context).maybePop();
      return;
    }
  }

  Widget _buildConfirmContent(BuildContext context, L10n? l10n) {
    final hasGroups =
        widget.groupsData != null && widget.groupsData!.isNotEmpty;

    final subtitle =
        l10n?.appSetting_importDialog_confirmSubtitle ??
        'Note: Import doesn\'t delete existing habits.';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.providerName != null) ...[
          Text(
            l10n?.appSetting_importConfirmDialog_sourceLabel(
                  widget.providerName!,
                ) ??
                'Source: ${widget.providerName}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
        ],
        const SizedBox(height: 8),
        CheckboxListTile(
          title: l10n != null
              ? Text(
                  l10n.appSetting_importDialog_tile_includeHabits(
                    widget.habitCount,
                  ),
                )
              : Text('Include ${widget.habitCount} habits'),
          value: _importHabits,
          onChanged: _confirmed
              ? null
              : (v) => setState(() => _importHabits = v!),
          dense: true,
        ),
        if (hasGroups)
          CheckboxListTile(
            title: l10n != null
                ? Text(
                    l10n.appSetting_importDialog_tile_includeGroups(
                      widget.groupCount,
                    ),
                  )
                : Text('Include ${widget.groupCount} groups'),
            value: _importGroups,
            onChanged: _confirmed
                ? null
                : (v) => setState(() => _importGroups = v!),
            dense: true,
          ),
        const SizedBox(height: 4),
        Text(subtitle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    Widget buildTitle(BuildContext context) {
      if (_completed) {
        final parts = <String>[];
        if (_habitTotal > 0) {
          parts.add(
            l10n?.appSetting_importDialog_completeTitle(_habitComplete) ??
                'Completed import $_habitComplete habits',
          );
        }
        if (_groupTotal > 0) {
          parts.add(
            l10n?.appSetting_importDialog_completeTitleGroups(_groupComplete) ??
                'Completed import $_groupComplete groups',
          );
        }
        return Text(parts.join('\n'));
      } else if (_confirmed) {
        return Text(
          l10n?.appSetting_importDialog_importingTitle(
                _currentCount,
                _totalCount,
              ) ??
              "Importing $_currentCount/$_totalCount",
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
        firstChild: _buildConfirmContent(context, l10n),
        secondChild: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 20),
          child: LinearProgressIndicator(
            value: _totalCount > 0 ? _currentCount / _totalCount : null,
          ),
        ),
        crossFadeState: !_confirmed
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
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
            onPressed: !_confirmed
                ? () => Navigator.of(context).maybePop()
                : null,
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
          ),
      ],
    );
  }
}

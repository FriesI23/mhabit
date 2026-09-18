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
import 'package:provider/provider.dart';

import '../../../common/types.dart';
import '../../../extensions/group_icon_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/app_event.dart';
import '../../../models/group_export.dart';
import '../../../models/habit_color.dart';
import '../../../models/habit_color_type.dart';
import '../../../models/habit_export.dart';
import '../../../providers/workflow/app_event.dart';
import '../../../providers/workflow/habits_file_importer.dart';
import '../../common/widgets.dart';

Future<void> showAppSettingImportHabitsConfirmDialog({
  required BuildContext context,
  required Iterable<Object?> habitsData,
  required int habitCount,
  required HabitFileImportRunner importer,
  String? providerName,
  Iterable<Object?>? groupsData,
  int groupCount = 0,
}) => showAdaptiveSheet<void>(
  context: context,
  barrierDismissible: false,
  enableDrag: false,
  showDragHandle: false,
  builder: (_) => ChangeNotifierProvider<HabitFileImportRunner>.value(
    value: importer,
    child: AppSettingImportHabitsConfirmDialog(
      data: habitsData,
      habitCount: habitCount,
      providerName: providerName,
      groupsData: groupsData,
      groupCount: groupCount,
    ),
  ),
);

class AppSettingImportHabitsConfirmDialog extends StatefulWidget {
  const AppSettingImportHabitsConfirmDialog({
    super.key,
    required this.data,
    this.habitCount = 0,
    this.providerName,
    this.groupsData,
    this.groupCount = 0,
  });

  final Iterable<Object?> data;
  final int habitCount;
  final String? providerName;
  final Iterable<Object?>? groupsData;
  final int groupCount;

  @override
  State<AppSettingImportHabitsConfirmDialog> createState() =>
      _AppSettingImportHabitsConfirmDialogState();
}

class _AppSettingImportHabitsConfirmDialogState
    extends State<AppSettingImportHabitsConfirmDialog> {
  late final _habitMonitor = ImportMonitor(_habits.length);
  late final _groupMonitor = ImportMonitor(_groups.length);
  late final List<Object?> _habits = List.unmodifiable(widget.data);
  late final List<Object?> _groups = List.unmodifiable(
    widget.groupsData ?? const [],
  );

  bool _confirmed = false;
  bool _completed = false;
  bool _importHabits = true;
  bool _importGroups = true;

  bool get _hasGroups => _groups.isNotEmpty;
  bool get _canImport =>
      (_importHabits && _habits.isNotEmpty) || (_importGroups && _hasGroups);
  int get _habitTotal => _importHabits ? _habitMonitor.total : 0;
  int get _groupTotal => _importGroups ? _groupMonitor.total : 0;
  int get _currentCount => _habitMonitor.processed + _groupMonitor.processed;
  int get _totalCount => _habitTotal + _groupTotal;

  @override
  void initState() {
    super.initState();
    _habitMonitor.addListener(_onProgress);
    _groupMonitor.addListener(_onProgress);
  }

  void _onProgress() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _habitMonitor.dispose();
    _groupMonitor.dispose();
    super.dispose();
  }

  void _completeImport() {
    if (!mounted) return;
    context.read<AppEventBus>().push(
      const ReloadDataEvent(
        msg: 'appt_settings.import._completeImport',
        clearSnackBar: true,
        trace: {
          AppEventPageSource.appSetting: {AppEventFunctionSource.habitImport},
        },
      ),
    );
    setState(() => _completed = true);
  }

  void _onConfirmButtonPressed() async {
    if (!mounted || _confirmed || !_canImport) return;
    final dataImporter = context.read<HabitFileImportRunner>();
    if (!dataImporter.mounted) return;

    final importGroups = _importGroups && _hasGroups;
    final importHabits = _importHabits;

    setState(() => _confirmed = true);
    Map<String, GroupUUID>? groupMapping;
    if (importGroups) {
      groupMapping = await dataImporter.importGroupsData(
        _groups,
        monitor: _groupMonitor,
      );
      if (!mounted) return;
    }
    if (importHabits) {
      await dataImporter.importHabitsData(
        _habits,
        monitor: _habitMonitor,
        groupUuidMapping: groupMapping,
      );
    }
    _completeImport();
  }

  void _close() {
    if (_confirmed && !_completed) return;
    Navigator.maybeOf(context)?.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final style = AdaptiveStyle.of(context);
    final cancelLabel =
        l10n?.appSetting_importDialog_confirm_cancelText ?? 'Cancel';
    final closeLabel =
        l10n?.appSetting_importDialog_complete_closeLabel ?? 'Close';
    final confirmLabel =
        l10n?.appSetting_importDialog_confirm_confirmText ?? 'Import';
    final actions = switch (style) {
      AdaptiveStyle.material => switch ((_confirmed, _completed)) {
        (_, true) => <Widget>[
          TextButton.icon(
            key: const ValueKey('import-complete-button'),
            onPressed: _close,
            icon: const Icon(Icons.close),
            label: Text(closeLabel),
          ),
        ],
        (false, false) => <Widget>[
          TextButton(
            key: const ValueKey('import-cancel-button'),
            onPressed: _close,
            child: Text(cancelLabel),
          ),
          TextButton(
            key: const ValueKey('import-confirm-button'),
            onPressed: _canImport ? _onConfirmButtonPressed : null,
            child: Text(confirmLabel),
          ),
        ],
        (true, false) => const <Widget>[],
      },
      AdaptiveStyle.apple =>
        _confirmed && !_completed
            ? const <Widget>[]
            : <Widget>[
                CupertinoButton(
                  key: ValueKey(
                    _completed
                        ? 'import-complete-button'
                        : 'import-confirm-button',
                  ),
                  onPressed: _completed
                      ? _close
                      : _canImport
                      ? _onConfirmButtonPressed
                      : null,
                  child: Text(_completed ? closeLabel : confirmLabel),
                ),
              ],
    };

    return PopScope<void>(
      canPop: !_confirmed || _completed,
      child: AdaptiveModal.slivers(
        title: _ImportTitle(
          completed: _completed,
          confirmed: _confirmed,
          habitCount: widget.habitCount,
          currentCount: _currentCount,
          totalCount: _totalCount,
        ),
        actions: actions,
        automaticallyImplyCloseButton:
            style == AdaptiveStyle.apple && !_confirmed,
        onCloseRequested: _close,
        size: const AdaptiveModalSize.constrained(maxHeight: 720),
        slivers: [
          _ImportContent(
            providerName: widget.providerName,
            habits: _habits,
            groups: _groups,
            habitMonitor: _habitMonitor,
            groupMonitor: _groupMonitor,
            importHabits: _importHabits,
            importGroups: _importGroups,
            confirmed: _confirmed,
            completed: _completed,
            onHabitsChanged: (value) => setState(() => _importHabits = value),
            onGroupsChanged: (value) => setState(() => _importGroups = value),
          ),
        ],
      ),
    );
  }
}

class _ImportOptionTile extends StatelessWidget {
  const _ImportOptionTile({
    required this.title,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final bool selected;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => AdaptiveSwitchListTile(
    title: Text(title),
    value: selected,
    onChanged: onChanged,
  );
}

class _ImportPreview extends StatelessWidget {
  const _ImportPreview({
    required this.habits,
    required this.groups,
    required this.habitStatuses,
    required this.groupStatuses,
    required this.importHabits,
    required this.importGroups,
  });

  final List<Object?> habits;
  final List<Object?> groups;
  final List<ImportItemStatus> habitStatuses;
  final List<ImportItemStatus> groupStatuses;
  final bool importHabits;
  final bool importGroups;

  String? _text(Object? data, String key) {
    if (data is! Map) return null;
    final value = data[key];
    return value is String ? value : null;
  }

  int? _integer(Object? data, String key) {
    if (data is! Map) return null;
    final value = data[key];
    return value is int ? value : null;
  }

  // Group and habit backups share these three color keys. Parse only preview
  // fields: malformed import rows must still be shown and handled by importer.
  HabitColor? _color(Object? data) {
    final custom = _integer(data, HabitExportDataKey.customColor);
    final validCustom = custom != null && custom >= 0 && custom <= 0xffffffff
        ? custom
        : null;
    final rawType = _integer(data, HabitExportDataKey.color);
    final type = rawType == null
        ? null
        : HabitColorType.getFromDBCode(rawType, withDefault: null);
    if (validCustom == null && type == null) return null;
    return HabitColor.fromRaw(
      colorType: type ?? HabitColorType.cc1,
      customColor: validCustom,
      customColorTinted: _integer(data, HabitExportDataKey.customColorTinted),
    );
  }

  ImportItemStatus? _aggregate(Iterable<ImportItemStatus> statuses) {
    if (statuses.isEmpty) return null;
    if (statuses.every((s) => s == ImportItemStatus.pending)) {
      return ImportItemStatus.pending;
    }
    if (statuses.any(
      (s) => s == ImportItemStatus.pending || s == ImportItemStatus.running,
    )) {
      return ImportItemStatus.running;
    }
    return statuses.contains(ImportItemStatus.failed)
        ? ImportItemStatus.failed
        : ImportItemStatus.succeeded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final groupIndexes = <String, int>{};
    for (final (index, group) in groups.indexed) {
      final uuid = _text(group, GroupExportDataKey.uuid);
      if (uuid != null && uuid.isNotEmpty) groupIndexes[uuid] = index;
    }
    final members = List.generate(groups.length + 1, (_) => <int>[]);
    for (final (index, habit) in habits.indexed) {
      members[groupIndexes[_text(habit, HabitExportDataKey.groupId)] ??
              groups.length]
          .add(index);
    }
    Widget? statusIcon(String id, Iterable<ImportItemStatus> statuses) {
      final status = _aggregate(statuses);
      return status == null ? null : _ImportStatusIcon(status: status, id: id);
    }

    return SliverHabitGroupTree(
      treeKey: const ValueKey('import-tree'),
      expansionToggleKey: const ValueKey('import-toggle-expansion'),
      root: HabitGroupTreeEntry(
        id: 'import-preview',
        title: Text(l10n?.appSetting_import_titleText ?? 'Import'),
        trailing: statusIcon('import-total', [
          if (importGroups) ...groupStatuses,
          if (importHabits) ...habitStatuses,
        ]),
      ),
      groups: [
        for (final (group, indexes) in members.indexed)
          if (group < groups.length || indexes.isNotEmpty)
            HabitGroupTreeEntry(
              id: 'import-group-$group',
              isUngrouped: group >= groups.length,
              color: group < groups.length ? _color(groups[group]) : null,
              icon: group < groups.length
                  ? _integer(
                      groups[group],
                      GroupExportDataKey.icon,
                    )?.toGroupIcon
                  : null,
              title: Text(
                '${group < groups.length ? (_text(groups[group], GroupExportDataKey.name) ?? '#${group + 1}') : (l10n?.habitEdit_groupPicker_noGroup ?? 'No Group')} (${indexes.length})',
              ),
              trailing: statusIcon('import-group-$group', [
                if (importGroups && group < groups.length) groupStatuses[group],
                if (importHabits)
                  for (final index in indexes) habitStatuses[index],
              ]),
              children: [
                for (final index in indexes)
                  HabitGroupTreeEntry(
                    id: 'import-habit-$index',
                    color: _color(habits[index]),
                    title: Text(
                      _text(habits[index], HabitExportDataKey.name) ??
                          '#${index + 1}',
                    ),
                    trailing: importHabits
                        ? _ImportStatusIcon(
                            status: habitStatuses[index],
                            id: 'import-habit-$index',
                          )
                        : null,
                  ),
              ],
            ),
      ],
    );
  }
}

class _ImportTitle extends StatelessWidget {
  const _ImportTitle({
    required this.completed,
    required this.confirmed,
    required this.habitCount,
    required this.currentCount,
    required this.totalCount,
  });

  final bool completed;
  final bool confirmed;
  final int habitCount;
  final int currentCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    if (completed) {
      return Text(l10n?.appSetting_import_titleText ?? 'Import');
    }
    if (confirmed) {
      return Text(
        l10n?.appSetting_importDialog_importingTitle(
              currentCount,
              totalCount,
            ) ??
            'Importing $currentCount/$totalCount',
      );
    }
    return Text(
      l10n?.appSetting_importDialog_confirmTitle(habitCount) ??
          'Confirm import $habitCount habits?',
    );
  }
}

class _ImportCompletion extends StatelessWidget {
  const _ImportCompletion({
    required this.habitTotal,
    required this.habitComplete,
    required this.groupTotal,
    required this.groupComplete,
  });

  final int habitTotal;
  final int habitComplete;
  final int groupTotal;
  final int groupComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    final parts = <String>[];
    if (habitTotal > 0) {
      parts.add(
        l10n?.appSetting_importDialog_completeTitle(habitComplete) ??
            'Completed import $habitComplete habits',
      );
    }
    if (groupTotal > 0) {
      parts.add(
        l10n?.appSetting_importDialog_completeTitleGroups(groupComplete) ??
            'Completed import $groupComplete groups',
      );
    }
    return Text(
      parts.join('\n'),
      key: const ValueKey('import-completion-summary'),
    );
  }
}

class _ImportProgress extends StatelessWidget {
  const _ImportProgress({required this.currentCount, required this.totalCount});

  final int currentCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? currentCount / totalCount : null;
    final indicator = LinearProgressIndicator(
      key: const ValueKey('import-progress'),
      value: progress,
      minHeight: AdaptiveStyle.of(context) == AdaptiveStyle.apple ? 4 : null,
      borderRadius: AdaptiveStyle.of(context) == AdaptiveStyle.apple
          ? const BorderRadius.all(Radius.circular(2))
          : null,
      color: AdaptiveStyle.of(context) == AdaptiveStyle.apple
          ? CupertinoTheme.of(context).primaryColor
          : null,
      backgroundColor: AdaptiveStyle.of(context) == AdaptiveStyle.apple
          ? CupertinoColors.quaternarySystemFill.resolveFrom(context)
          : null,
    );
    return Padding(
      key: const ValueKey('import-progress-content'),
      padding: const EdgeInsetsDirectional.symmetric(vertical: 20),
      child: indicator,
    );
  }
}

class _ImportContent extends StatelessWidget {
  const _ImportContent({
    required this.providerName,
    required this.habits,
    required this.groups,
    required this.habitMonitor,
    required this.groupMonitor,
    required this.importHabits,
    required this.importGroups,
    required this.confirmed,
    required this.completed,
    required this.onHabitsChanged,
    required this.onGroupsChanged,
  });

  final String? providerName;
  final List<Object?> habits;
  final List<Object?> groups;
  final ImportMonitor habitMonitor;
  final ImportMonitor groupMonitor;
  final bool importHabits;
  final bool importGroups;
  final bool confirmed;
  final bool completed;
  final ValueChanged<bool> onHabitsChanged;
  final ValueChanged<bool> onGroupsChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    final subtitle =
        l10n?.appSetting_importDialog_confirmSubtitle ??
        'Note: Import doesn\'t delete existing habits.';
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            key: const ValueKey('import-confirm-content'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (providerName case final providerName?) ...[
                Text(
                  l10n?.appSetting_importConfirmDialog_sourceLabel(
                        providerName,
                      ) ??
                      'Source: $providerName',
                  style: switch (AdaptiveStyle.of(context)) {
                    AdaptiveStyle.material => Theme.of(
                      context,
                    ).textTheme.bodySmall,
                    AdaptiveStyle.apple =>
                      CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                        color: CupertinoColors.secondaryLabel.resolveFrom(
                          context,
                        ),
                      ),
                  },
                ),
                const SizedBox(height: 8),
              ],
              AdaptiveListSection(
                appleTransparent: true,
                padding: EdgeInsets.zero,
                children: [
                  _ImportOptionTile(
                    title: l10n != null
                        ? l10n.appSetting_importDialog_tile_includeHabits(
                            habitMonitor.total,
                          )
                        : 'Include ${habitMonitor.total} habits',
                    selected: importHabits,
                    onChanged: confirmed ? null : onHabitsChanged,
                  ),
                  if (groupMonitor.total > 0)
                    _ImportOptionTile(
                      title: l10n != null
                          ? l10n.appSetting_importDialog_tile_includeGroups(
                              groupMonitor.total,
                            )
                          : 'Include ${groupMonitor.total} groups',
                      selected: importGroups,
                      onChanged: confirmed ? null : onGroupsChanged,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (confirmed)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (completed) ...[
                      const Divider(key: ValueKey('import-completion-divider')),
                      _ImportCompletion(
                        habitTotal: importHabits ? habitMonitor.total : 0,
                        habitComplete: habitMonitor.succeeded,
                        groupTotal: importGroups ? groupMonitor.total : 0,
                        groupComplete: groupMonitor.succeeded,
                      ),
                    ] else
                      _ImportProgress(
                        currentCount:
                            habitMonitor.processed + groupMonitor.processed,
                        totalCount:
                            (importHabits ? habitMonitor.total : 0) +
                            (importGroups ? groupMonitor.total : 0),
                      ),
                  ],
                )
              else
                Text(subtitle),
              const SizedBox(height: 8),
            ],
          ),
        ),
        _ImportPreview(
          habits: habits,
          groups: groups,
          habitStatuses: habitMonitor.statuses,
          groupStatuses: groupMonitor.statuses,
          importHabits: importHabits,
          importGroups: importGroups,
        ),
      ],
    );
  }
}

class _ImportStatusIcon extends StatelessWidget {
  const _ImportStatusIcon({required this.status, required this.id});

  final ImportItemStatus status;
  final String id;

  @override
  Widget build(BuildContext context) {
    final apple = AdaptiveStyle.of(context) == AdaptiveStyle.apple;
    final icon = switch (status) {
      ImportItemStatus.pending =>
        apple ? CupertinoIcons.circle : Icons.radio_button_unchecked,
      ImportItemStatus.running =>
        apple ? CupertinoIcons.arrow_2_circlepath : Icons.sync,
      ImportItemStatus.succeeded =>
        apple ? CupertinoIcons.check_mark_circled : Icons.check_circle_outline,
      ImportItemStatus.failed =>
        apple ? CupertinoIcons.exclamationmark_circle : Icons.error_outline,
    };
    return Icon(icon, key: ValueKey('$id-${status.name}'), size: 20);
  }
}

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

import '../../../common/consts.dart' show defaultGroupIcon;
import '../../../extensions/custom_color_extensions.dart';
import '../../../extensions/group_icon_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_group.dart';
import '../../../theme/color.dart' show CustomColors;

class GroupManageList extends StatefulWidget {
  final List<HabitGroupData> groups;
  final Set<String> selectedUUIDs;
  final bool selectionMode;
  final void Function(String uuid) onTap;
  final void Function(String uuid) onLongPress;
  final void Function(String uuid) onEdit;
  final void Function(String uuid) onDelete;

  const GroupManageList({
    super.key,
    required this.groups,
    required this.selectedUUIDs,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<GroupManageList> createState() => _GroupManageListState();
}

class _GroupManageListState extends State<GroupManageList> {
  final _listKey = GlobalKey<SliverAnimatedListState>();
  late List<HabitGroupData> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.groups);
  }

  @override
  void didUpdateWidget(covariant GroupManageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _diffLists(oldWidget.groups, widget.groups);
  }

  void _diffLists(List<HabitGroupData> oldList, List<HabitGroupData> newList) {
    final oldUUIDs = oldList.map((g) => g.uuid).toSet();
    final newUUIDs = newList.map((g) => g.uuid).toSet();

    for (final entry in _items.asMap().entries.toList().reversed) {
      if (newUUIDs.contains(entry.value.uuid)) continue;
      final i = entry.key;
      final removed = _items.removeAt(i);
      _listKey.currentState?.removeItem(
        i,
        (context, animation) => _buildAnimatedItem(removed, animation),
      );
    }

    for (final entry in newList.asMap().entries) {
      if (oldUUIDs.contains(entry.value.uuid)) continue;
      final i = entry.key;
      _items.insert(i, entry.value);
      _listKey.currentState?.insertItem(i);
    }

    // Sync existing items with latest data (handles edits — same UUIDs,
    // different content — which add/remove alone would miss).
    final newByUUID = {for (final g in newList) g.uuid: g};
    _items.asMap().forEach((i, item) {
      final updated = newByUUID[item.uuid];
      if (updated != null) _items[i] = updated;
    });
  }

  Widget _buildAnimatedItem(HabitGroupData group, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(opacity: animation, child: _buildTile(group)),
    );
  }

  Widget _buildTile(HabitGroupData group) {
    return _GroupManageTile(
      group: group,
      isSelected: widget.selectedUUIDs.contains(group.uuid),
      selectionMode: widget.selectionMode,
      onTap: () => widget.onTap(group.uuid),
      onLongPress: () => widget.onLongPress(group.uuid),
      onEdit: () => widget.onEdit(group.uuid),
      onDelete: () => widget.onDelete(group.uuid),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: _listKey,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        return _buildAnimatedItem(_items[index], animation);
      },
    );
  }
}

class _GroupManageTile extends StatelessWidget {
  final HabitGroupData group;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _GroupManageTile({
    required this.group,
    this.isSelected = false,
    this.selectionMode = false,
    this.onTap,
    this.onLongPress,
    this.onEdit,
    this.onDelete,
  });

  Color? _resolveTileColor(BuildContext context) {
    final color = group.color;
    if (color == null) return null;
    final customColors = Theme.of(context).extension<CustomColors>();
    if (customColors == null) return null;
    return customColors.getColor(
      color,
      brightness: Theme.of(context).brightness,
    );
  }

  Widget _buildLeading(BuildContext context) => Icon(
    group.icon?.iconData ?? defaultGroupIcon,
    color: _resolveTileColor(context),
  );

  Widget? _buildSubtitle() => group.desc.isNotEmpty
      ? Text(group.desc, maxLines: 1, overflow: TextOverflow.ellipsis)
      : null;

  Widget _buildTrailing(BuildContext context) => selectionMode
      ? Checkbox(value: isSelected, onChanged: (_) => onTap?.call())
      : PopupMenuButton<String>(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
              case 'delete':
                onDelete?.call();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(
                  L10n.of(context)?.habitEdit_saveButton_text ?? 'Edit',
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(
                  L10n.of(context)?.groupManage_deleteDialog_confirm ??
                      'Delete',
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      selected: selectionMode && isSelected,
      selectedTileColor: colorScheme.primaryContainer.withAlpha(77),
      selectedColor: colorScheme.onPrimaryContainer,
      leading: _buildLeading(context),
      title: Text(group.name),
      subtitle: _buildSubtitle(),
      trailing: _buildTrailing(context),
      onTap: onTap,
      onLongPress: selectionMode ? null : onLongPress,
    );
  }
}

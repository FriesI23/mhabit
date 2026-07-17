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
import '../../../models/habit_group.dart';
import '../../../theme/color.dart' show CustomColors;

class GroupManageGrid extends StatefulWidget {
  final List<HabitGroupData> groups;
  final Set<String> selectedUUIDs;
  final bool selectionMode;
  final void Function(String uuid) onTap;
  final void Function(String uuid) onLongPress;
  final void Function(String uuid) onEdit;
  final void Function(String uuid) onDelete;

  const GroupManageGrid({
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
  State<GroupManageGrid> createState() => _GroupManageGridState();
}

class _GroupManageGridState extends State<GroupManageGrid> {
  final _gridKey = GlobalKey<SliverAnimatedGridState>();
  late List<HabitGroupData> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.groups);
  }

  @override
  void didUpdateWidget(covariant GroupManageGrid oldWidget) {
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
      _gridKey.currentState?.removeItem(
        i,
        (context, animation) => _buildAnimatedItem(removed, animation),
      );
    }

    for (final entry in newList.asMap().entries) {
      if (oldUUIDs.contains(entry.value.uuid)) continue;
      final i = entry.key;
      _items.insert(i, entry.value);
      _gridKey.currentState?.insertItem(i);
    }

    // Sync existing items with latest data (handles edits — same UUIDs,
    // different content — which add/remove alone would miss).
    final newByUUID = {for (final g in newList) g.uuid: g};
    _items.asMap().forEach((i, item) {
      final updated = newByUUID[item.uuid];
      if (updated != null) _items[i] = updated;
    });
  }

  Widget _buildAnimatedItem(
    HabitGroupData group,
    Animation<double> animation,
  ) => SizeTransition(
    sizeFactor: animation,
    child: FadeTransition(
      opacity: animation,
      child: _GroupGridCard(
        group: group,
        selectedUUIDs: widget.selectedUUIDs,
        selectionMode: widget.selectionMode,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onEdit: widget.onEdit,
        onDelete: widget.onDelete,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedGrid(
      key: _gridKey,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisExtent: 100,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        return _buildAnimatedItem(_items[index], animation);
      },
    );
  }
}

class _GroupGridCard extends StatelessWidget {
  final HabitGroupData group;
  final Set<String> selectedUUIDs;
  final bool selectionMode;
  final void Function(String uuid) onTap;
  final void Function(String uuid) onLongPress;
  final void Function(String uuid) onEdit;
  final void Function(String uuid) onDelete;

  const _GroupGridCard({
    required this.group,
    required this.selectedUUIDs,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  );

  Color? _resolveTileColor(BuildContext context, HabitGroupData data) {
    final color = data.color;
    if (color == null) return null;
    final customColors = Theme.of(context).extension<CustomColors>();
    if (customColors == null) return null;
    return customColors.getColor(
      color,
      brightness: Theme.of(context).brightness,
    );
  }

  Widget _buildHeader(BuildContext context, bool isSelected) => Row(
    children: [
      Icon(
        group.icon?.iconData ?? defaultGroupIcon,
        size: 20,
        color: _resolveTileColor(context, group),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          group.name,
          style: Theme.of(context).textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (selectionMode)
        Checkbox(value: isSelected, onChanged: (_) => onTap(group.uuid))
      else
        PopupMenuButton<String>(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          iconSize: 20,
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit(group.uuid);
              case 'delete':
                onDelete(group.uuid);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Delete'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
    ],
  );

  Widget? _buildDescription(BuildContext context, ColorScheme colorScheme) =>
      group.desc.isEmpty
      ? null
      : Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            group.desc,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedUUIDs.contains(group.uuid);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: _shape,
      clipBehavior: Clip.antiAlias,
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      child: InkWell(
        borderRadius: _shape.borderRadius.resolve(null),
        onTap: () => onTap(group.uuid),
        onLongPress: selectionMode ? null : () => onLongPress(group.uuid),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isSelected),
              ?_buildDescription(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }
}

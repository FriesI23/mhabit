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

mixin _GroupManageSliverMixin<T extends StatefulWidget> on State<T> {
  late List<HabitGroupData> _items;

  void sliverRemoveItem(
    int index,
    Widget Function(BuildContext, Animation<double>) builder,
  );

  void sliverInsertItem(int index);

  Widget buildAnimatedItem(HabitGroupData group, Animation<double> animation);

  void handleGroupsUpdate(
    List<HabitGroupData> oldList,
    List<HabitGroupData> newList,
  ) {
    _diffLists(oldList, newList);
    _syncOrder(newList);
  }

  void _diffLists(List<HabitGroupData> oldList, List<HabitGroupData> newList) {
    final oldUUIDs = oldList.map((g) => g.uuid).toSet();
    final newUUIDs = newList.map((g) => g.uuid).toSet();

    for (final entry in _items.asMap().entries.toList().reversed) {
      if (newUUIDs.contains(entry.value.uuid)) continue;
      final i = entry.key;
      final removed = _items.removeAt(i);
      sliverRemoveItem(
        i,
        (context, animation) => buildAnimatedItem(removed, animation),
      );
    }

    for (final entry in newList.asMap().entries) {
      if (oldUUIDs.contains(entry.value.uuid)) continue;
      final i = entry.key;
      _items.insert(i, entry.value);
      sliverInsertItem(i);
    }

    final newByUUID = {for (final g in newList) g.uuid: g};
    _items.asMap().forEach((i, item) {
      final updated = newByUUID[item.uuid];
      if (updated != null) _items[i] = updated;
    });
  }

  void _syncOrder(List<HabitGroupData> newOrder) {
    if (_items.length != newOrder.length) {
      _items = List.of(newOrder);
      return;
    }
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].uuid != newOrder[i].uuid) {
        final newByUUID = {for (final g in newOrder) g.uuid: g};
        _items = List.generate(
          newOrder.length,
          (i) => newByUUID[newOrder[i].uuid]!,
        );
        return;
      }
    }
  }
}

class GroupManageGrid extends StatefulWidget {
  final List<HabitGroupData> groups;
  final Set<String> selectedUUIDs;
  final bool selectionMode;
  final int selectedCount;
  final void Function(String uuid) onTap;
  final void Function(String uuid) onLongPress;
  final void Function(String uuid) onEdit;
  final void Function(String uuid) onDelete;

  const GroupManageGrid({
    super.key,
    required this.groups,
    required this.selectedUUIDs,
    required this.selectionMode,
    required this.selectedCount,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<GroupManageGrid> createState() => _GroupManageGridState();
}

class _GroupManageGridState extends State<GroupManageGrid>
    with _GroupManageSliverMixin {
  final _gridKey = GlobalKey<SliverAnimatedGridState>();

  @override
  void sliverRemoveItem(
    int index,
    Widget Function(BuildContext, Animation<double>) builder,
  ) => _gridKey.currentState?.removeItem(index, builder);

  @override
  void sliverInsertItem(int index) => _gridKey.currentState?.insertItem(index);

  @override
  Widget buildAnimatedItem(HabitGroupData group, Animation<double> animation) =>
      SizeTransition(
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
  void initState() {
    super.initState();
    _items = List.of(widget.groups);
  }

  @override
  void didUpdateWidget(covariant GroupManageGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    final groupsChanged = oldWidget.groups != widget.groups;
    if (groupsChanged) handleGroupsUpdate(oldWidget.groups, widget.groups);
    if (groupsChanged ||
        oldWidget.selectionMode != widget.selectionMode ||
        oldWidget.selectedCount != widget.selectedCount) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => SliverAnimatedGrid(
    key: _gridKey,
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 300,
      mainAxisExtent: 100,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    initialItemCount: _items.length,
    itemBuilder: (context, index, animation) =>
        buildAnimatedItem(_items[index], animation),
  );
}

class GroupManageList extends StatefulWidget {
  final List<HabitGroupData> groups;
  final Set<String> selectedUUIDs;
  final bool selectionMode;
  final int selectedCount;
  final void Function(String uuid) onTap;
  final void Function(String uuid) onLongPress;
  final void Function(String uuid) onEdit;
  final void Function(String uuid) onDelete;

  const GroupManageList({
    super.key,
    required this.groups,
    required this.selectedUUIDs,
    required this.selectionMode,
    required this.selectedCount,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<GroupManageList> createState() => _GroupManageListState();
}

class _GroupManageListState extends State<GroupManageList>
    with _GroupManageSliverMixin {
  final _listKey = GlobalKey<SliverAnimatedListState>();

  @override
  void sliverRemoveItem(
    int index,
    Widget Function(BuildContext, Animation<double>) builder,
  ) => _listKey.currentState?.removeItem(index, builder);

  @override
  void sliverInsertItem(int index) => _listKey.currentState?.insertItem(index);

  @override
  Widget buildAnimatedItem(HabitGroupData group, Animation<double> animation) =>
      SizeTransition(
        sizeFactor: animation,
        child: FadeTransition(
          opacity: animation,
          child: _GroupManageTile(
            group: group,
            isSelected: widget.selectedUUIDs.contains(group.uuid),
            selectionMode: widget.selectionMode,
            onTap: () => widget.onTap(group.uuid),
            onLongPress: () => widget.onLongPress(group.uuid),
            onEdit: () => widget.onEdit(group.uuid),
            onDelete: () => widget.onDelete(group.uuid),
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.groups);
  }

  @override
  void didUpdateWidget(covariant GroupManageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final groupsChanged = oldWidget.groups != widget.groups;
    if (groupsChanged) handleGroupsUpdate(oldWidget.groups, widget.groups);
    if (groupsChanged ||
        oldWidget.selectionMode != widget.selectionMode ||
        oldWidget.selectedCount != widget.selectedCount) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => SliverAnimatedList(
    key: _listKey,
    initialItemCount: _items.length,
    itemBuilder: (context, index, animation) =>
        buildAnimatedItem(_items[index], animation),
  );
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

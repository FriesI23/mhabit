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
import 'package:provider/provider.dart';

import '../../../common/consts.dart' show defaultGroupIcon;
import '../../../extensions/custom_color_extensions.dart';
import '../../../extensions/group_icon_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_group.dart';
import '../../../models/habit_group_display.dart';
import '../../../theme/color.dart' show CustomColors;
import '../../../widgets/widgets.dart';
import '../_providers/group_manage.dart';

/// Owns local item list and drag callbacks shared by [GroupManageGrid] and
/// [GroupManageList].  States create one instance and delegate to it.
class _GroupManageDragHandler {
  static const scrollDirection = Axis.vertical;

  static bool isSameItem(HabitGroupData a, HabitGroupData b) =>
      a.uuid == b.uuid;

  static Widget proxyDecorator(
    Widget child,
    int index,
    Animation<double> animation,
  ) => Material(type: MaterialType.transparency, child: child);

  _GroupManageDragHandler({required List<HabitGroupData> initialGroups}) {
    items = List.of(initialGroups);
  }

  late List<HabitGroupData> items;

  void syncGroups(
    List<HabitGroupData> oldGroups,
    List<HabitGroupData> newGroups,
  ) {
    if (oldGroups != newGroups) items = List.of(newGroups);
  }

  List<HabitGroupData> resolveNonDraggable(bool isManual) =>
      isManual ? [] : List.of(items);

  void onReorderStart(
    int index,
    GroupManageViewModel vm,
    bool isManual,
    bool selectionMode,
  ) {
    if (isManual && !selectionMode) vm.enterSelectionMode(items[index].uuid);
  }

  void onReorder(int oldIndex, int newIndex, GroupManageViewModel vm) {
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    if (vm.selectionMode) vm.exitSelectionMode();
    vm.onGroupReorderComplete(items.map((g) => g.uuid).toList());
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

class _GroupManageGridState extends State<GroupManageGrid> {
  late final _handler = _GroupManageDragHandler(initialGroups: widget.groups);

  @override
  void didUpdateWidget(covariant GroupManageGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handler.syncGroups(oldWidget.groups, widget.groups);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<GroupManageViewModel>();
    final isManual = vm.effectiveSortType == HabitDisplayGroupType.manual;

    return SliverReorderableAnimatedList<HabitGroupData>.grid(
      scrollDirection: _GroupManageDragHandler.scrollDirection,
      items: _handler.items,
      isSameItem: _GroupManageDragHandler.isSameItem,
      itemBuilder: (context, index) => _GroupGridCard(
        key: ValueKey(_handler.items[index].uuid),
        group: _handler.items[index],
        selectedUUIDs: widget.selectedUUIDs,
        selectionMode: widget.selectionMode,
        onTap: widget.onTap,
        onLongPress: isManual && !widget.selectionMode
            ? null
            : widget.onLongPress,
        onEdit: widget.onEdit,
        onDelete: widget.onDelete,
      ),
      sliverGridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisExtent: 100,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      proxyDecorator: _GroupManageDragHandler.proxyDecorator,
      onReorderStart: (index) =>
          _handler.onReorderStart(index, vm, isManual, widget.selectionMode),
      onReorder: (oldIndex, newIndex) => setState(() {
        _handler.onReorder(oldIndex, newIndex, vm);
      }),
      nonDraggableItems: _handler.resolveNonDraggable(isManual),
    );
  }
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

class _GroupManageListState extends State<GroupManageList> {
  late final _handler = _GroupManageDragHandler(initialGroups: widget.groups);

  @override
  void didUpdateWidget(covariant GroupManageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handler.syncGroups(oldWidget.groups, widget.groups);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<GroupManageViewModel>();
    final isManual = vm.effectiveSortType == HabitDisplayGroupType.manual;

    return SliverReorderableAnimatedList<HabitGroupData>(
      scrollDirection: _GroupManageDragHandler.scrollDirection,
      items: _handler.items,
      isSameItem: _GroupManageDragHandler.isSameItem,
      itemBuilder: (context, index) => _GroupManageTile(
        key: ValueKey(_handler.items[index].uuid),
        group: _handler.items[index],
        isSelected: widget.selectedUUIDs.contains(_handler.items[index].uuid),
        selectionMode: widget.selectionMode,
        onTap: () => widget.onTap(_handler.items[index].uuid),
        onLongPress: isManual && !widget.selectionMode
            ? null
            : () => widget.onLongPress(_handler.items[index].uuid),
        onEdit: () => widget.onEdit(_handler.items[index].uuid),
        onDelete: () => widget.onDelete(_handler.items[index].uuid),
      ),
      proxyDecorator: _GroupManageDragHandler.proxyDecorator,
      onReorderStart: (index) =>
          _handler.onReorderStart(index, vm, isManual, widget.selectionMode),
      onReorder: (oldIndex, newIndex) => setState(() {
        _handler.onReorder(oldIndex, newIndex, vm);
      }),
      nonDraggableItems: _handler.resolveNonDraggable(isManual),
    );
  }
}

class _GroupGridCard extends StatelessWidget {
  final HabitGroupData group;
  final Set<String> selectedUUIDs;
  final bool selectionMode;
  final void Function(String uuid) onTap;
  final void Function(String uuid)? onLongPress;
  final void Function(String uuid) onEdit;
  final void Function(String uuid) onDelete;

  const _GroupGridCard({
    super.key,
    required this.group,
    required this.selectedUUIDs,
    required this.selectionMode,
    required this.onTap,
    this.onLongPress,
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
        onLongPress: (selectionMode || onLongPress == null)
            ? null
            : () => onLongPress!(group.uuid),
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
    super.key,
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

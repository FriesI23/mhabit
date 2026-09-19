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

part of 'group_manage_items.dart';

class GroupManageListItem extends StatefulWidget {
  const GroupManageListItem({
    super.key,
    required this.index,
    required this.group,
    required this.isSelected,
    required this.selectionMode,
    required this.showDragHandle,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final HabitGroupData group;
  final bool isSelected;
  final bool selectionMode;
  final bool showDragHandle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<GroupManageListItem> createState() => _GroupManageListItemState();
}

class _GroupManageListItemState extends State<GroupManageListItem> {
  final _actionsController = GroupManageItemMenuController();

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectionMode && widget.isSelected;
    return Semantics(
      selected: widget.selectionMode ? widget.isSelected : null,
      child: switch (AdaptiveStyle.of(context)) {
        AdaptiveStyle.material => _MaterialGroupListItem(
          actionsController: _actionsController,
          index: widget.index,
          group: widget.group,
          selected: selected,
          selectionMode: widget.selectionMode,
          showDragHandle: widget.showDragHandle,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
        ),
        AdaptiveStyle.apple => _AppleGroupListItem(
          actionsController: _actionsController,
          index: widget.index,
          group: widget.group,
          selected: selected,
          selectionMode: widget.selectionMode,
          showDragHandle: widget.showDragHandle,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onEdit: widget.onEdit,
          onDelete: widget.onDelete,
        ),
      },
    );
  }
}

class _MaterialGroupListItem extends StatelessWidget {
  const _MaterialGroupListItem({
    required this.actionsController,
    required this.index,
    required this.group,
    required this.selected,
    required this.selectionMode,
    required this.showDragHandle,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  final GroupManageItemMenuController actionsController;
  final int index;
  final HabitGroupData group;
  final bool selected;
  final bool selectionMode;
  final bool showDragHandle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onSecondaryTapDown: (details) =>
          actionsController.openAtGlobalPosition(details.globalPosition),
      onLongPress: onLongPress,
      child: Material(
        color: selected
            ? colors.primaryContainer.withAlpha(77)
            : Colors.transparent,
        child: ListTileTheme.merge(
          textColor: selected ? colors.onPrimaryContainer : null,
          iconColor: selected ? colors.onPrimaryContainer : null,
          child: AdaptiveListTile.material(
            leading: _GroupIndicator(group: group, selected: selected),
            trailing: MaterialGroupManageItemActions(
              controller: actionsController,
              index: index,
              showDragHandle: showDragHandle,
              selectionMode: selectionMode,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
            title: Text(group.name),
            subtitle: group.desc.isEmpty
                ? null
                : Text(
                    group.desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class _AppleGroupListItem extends StatelessWidget {
  const _AppleGroupListItem({
    required this.actionsController,
    required this.index,
    required this.group,
    required this.selected,
    required this.selectionMode,
    required this.showDragHandle,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  final GroupManageItemMenuController actionsController;
  final int index;
  final HabitGroupData group;
  final bool selected;
  final bool selectionMode;
  final bool showDragHandle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onSecondaryTapDown: (details) =>
        actionsController.openAtGlobalPosition(details.globalPosition),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ColoredBox(
          color: _appleItemSurface(context, selected: selected),
          child: GestureDetector(
            onLongPress: onLongPress,
            child: AdaptiveListTile.apple(
              leading: _GroupIndicator(group: group, selected: selected),
              trailing: AppleGroupManageItemActions(
                controller: actionsController,
                index: index,
                showDragHandle: showDragHandle,
                selectionMode: selectionMode,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
              title: Text(group.name),
              subtitle: group.desc.isEmpty
                  ? null
                  : Text(
                      group.desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              onTap: onTap,
            ),
          ),
        ),
      ),
    ),
  );
}

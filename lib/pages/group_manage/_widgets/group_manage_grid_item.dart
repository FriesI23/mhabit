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

class GroupManageGridItem extends StatefulWidget {
  const GroupManageGridItem({
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
  State<GroupManageGridItem> createState() => _GroupManageGridItemState();
}

class _GroupManageGridItemState extends State<GroupManageGridItem> {
  final _actionsController = GroupManageItemMenuController();

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectionMode && widget.isSelected;
    return Semantics(
      selected: widget.selectionMode ? widget.isSelected : null,
      child: switch (AdaptiveStyle.of(context)) {
        AdaptiveStyle.material => _MaterialGroupGridItem(
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
        AdaptiveStyle.apple => _AppleGroupGridItem(
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

class _MaterialGroupGridItem extends StatelessWidget {
  const _MaterialGroupGridItem({
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
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        clipBehavior: Clip.antiAlias,
        color: selected
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _GroupGridContent(
              group: group,
              selected: selected,
              trailing: MaterialGroupManageItemActions(
                controller: actionsController,
                index: index,
                showDragHandle: showDragHandle,
                selectionMode: selectionMode,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
              titleStyle: Theme.of(context).textTheme.titleSmall!,
              descriptionStyle: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppleGroupGridItem extends StatelessWidget {
  const _AppleGroupGridItem({
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
    final theme = CupertinoTheme.of(context);
    return GestureDetector(
      onSecondaryTapDown: (details) =>
          actionsController.openAtGlobalPosition(details.globalPosition),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: _appleItemSurface(context, selected: selected),
            child: GestureDetector(
              onLongPress: onLongPress,
              child: CupertinoInkWell(
                onActivate: onTap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: _GroupGridContent(
                      group: group,
                      selected: selected,
                      trailing: AppleGroupManageItemActions(
                        controller: actionsController,
                        index: index,
                        showDragHandle: showDragHandle,
                        selectionMode: selectionMode,
                        onEdit: onEdit,
                        onDelete: onDelete,
                      ),
                      titleStyle: theme.textTheme.textStyle,
                      descriptionStyle: theme.textTheme.textStyle.copyWith(
                        fontSize: 13,
                        color: CupertinoColors.secondaryLabel.resolveFrom(
                          context,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupGridContent extends StatelessWidget {
  const _GroupGridContent({
    required this.group,
    required this.selected,
    required this.trailing,
    required this.titleStyle,
    required this.descriptionStyle,
  });
  final HabitGroupData group;
  final bool selected;
  final Widget trailing;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          _GroupIndicator(group: group, selected: selected),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              group.name,
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing,
        ],
      ),
      if (group.desc.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            group.desc,
            style: descriptionStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ],
  );
}

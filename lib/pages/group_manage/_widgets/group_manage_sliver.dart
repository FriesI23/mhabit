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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/consts.dart' show defaultGroupIcon;
import '../../../extensions/custom_color_extensions.dart';
import '../../../extensions/group_icon_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/app_event.dart';
import '../../../models/habit_group.dart';
import '../../../models/habit_group_display.dart';
import '../../../providers/workflow/app_event.dart';
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
  ) {
    return Builder(
      builder: (context) => Material(
        elevation: 8,
        shadowColor: Colors.black38,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        surfaceTintColor: Colors.transparent,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: child,
      ),
    );
  }

  _GroupManageDragHandler({required List<HabitGroupData> initialGroups}) {
    items = List.of(initialGroups);
  }

  late List<HabitGroupData> items;
  late GroupManageViewModel _vm;

  void attach(GroupManageViewModel vm) => _vm = vm;

  GroupManageViewModel get vm => _vm;

  bool get isManualSort =>
      _vm.effectiveSortType == HabitDisplayGroupType.manual;

  void syncGroups(
    List<HabitGroupData> oldGroups,
    List<HabitGroupData> newGroups,
  ) {
    if (oldGroups != newGroups) items = List.of(newGroups);
  }

  List<HabitGroupData> resolveNonDraggable({bool? isManual}) =>
      (isManual ?? isManualSort) ? [] : List.of(items);

  void onReorderStart(int index, bool selectionMode, {bool? isManual}) {
    // Enter selection mode simultaneously when the drag starts (via either
    // drag-handle click or long-press).  Use [listen: false] to avoid a
    // [notifyListeners] during the drag setup, which would interfere with
    // the drag animation.
    if (!selectionMode && (isManual ?? isManualSort) && index < items.length) {
      _vm.enterSelectionMode(items[index].uuid);
    }
  }

  void onReorder(int oldIndex, int newIndex) {
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    // Keep selection mode active after drag completes.
    _vm.onGroupReorderComplete(items.map((g) => g.uuid).toList());
  }
}

class GroupManageGrid extends StatefulWidget {
  final List<HabitGroupData> groups;
  final Set<String> selectedUUIDs;
  final bool selectionMode;
  final int selectedCount;
  final void Function(String uuid) onTap;
  final void Function(String uuid) onEdit;
  final void Function(String uuid) onDelete;

  const GroupManageGrid({
    super.key,
    required this.groups,
    required this.selectedUUIDs,
    required this.selectionMode,
    required this.selectedCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<GroupManageGrid> createState() => _GroupManageGridState();
}

class _GroupManageGridState extends State<GroupManageGrid> {
  late final _handler = _GroupManageDragHandler(initialGroups: widget.groups);

  @override
  void initState() {
    super.initState();
    _handler.attach(context.read<GroupManageViewModel>());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newVm = context.read<GroupManageViewModel>();
    if (_handler.vm != newVm) _handler.attach(newVm);
  }

  @override
  void didUpdateWidget(covariant GroupManageGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handler.syncGroups(oldWidget.groups, widget.groups);
  }

  @override
  Widget build(BuildContext context) {
    final showHandle = _handler.isManualSort && !_isMobilePlatform;

    return SliverReorderableAnimatedList<HabitGroupData>.grid(
      scrollDirection: _GroupManageDragHandler.scrollDirection,
      items: _handler.items,
      isSameItem: _GroupManageDragHandler.isSameItem,
      itemBuilder: (context, index) => _GroupGridCard(
        index: index,
        key: ValueKey(_handler.items[index].uuid),
        group: _handler.items[index],
        selectedUUIDs: widget.selectedUUIDs,
        selectionMode: widget.selectionMode,
        showDragHandle: showHandle,
        onTap: widget.onTap,
        // Long-press drag is handled by the package's
        // [ReorderableGridDelayedDragStartListener]; selection mode entry is
        // handled in [_GroupManageDragHandler.onReorderStart] instead.
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
          _handler.onReorderStart(index, widget.selectionMode),
      onReorder: (oldIndex, newIndex) => setState(() {
        _handler.onReorder(oldIndex, newIndex);
        context.read<AppEventBus>().push(
          const GroupChangedEvent(
            msg: "group_manage.onGroupReorderComplete",
            trace: {
              AppEventPageSource.groupManage: {
                AppEventFunctionSource.groupChanged,
              },
            },
          ),
        );
      }),
      nonDraggableItems: _handler.resolveNonDraggable(),
    );
  }
}

class GroupManageList extends StatefulWidget {
  final List<HabitGroupData> groups;
  final Set<String> selectedUUIDs;
  final bool selectionMode;
  final int selectedCount;
  final void Function(String uuid) onTap;
  final void Function(String uuid) onEdit;
  final void Function(String uuid) onDelete;

  const GroupManageList({
    super.key,
    required this.groups,
    required this.selectedUUIDs,
    required this.selectionMode,
    required this.selectedCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<GroupManageList> createState() => _GroupManageListState();
}

class _GroupManageListState extends State<GroupManageList> {
  late final _handler = _GroupManageDragHandler(initialGroups: widget.groups);

  @override
  void initState() {
    super.initState();
    _handler.attach(context.read<GroupManageViewModel>());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newVm = context.read<GroupManageViewModel>();
    if (_handler.vm != newVm) _handler.attach(newVm);
  }

  @override
  void didUpdateWidget(covariant GroupManageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handler.syncGroups(oldWidget.groups, widget.groups);
  }

  @override
  Widget build(BuildContext context) {
    final showHandle = _handler.isManualSort && !_isMobilePlatform;

    return SliverReorderableAnimatedList<HabitGroupData>(
      scrollDirection: _GroupManageDragHandler.scrollDirection,
      items: _handler.items,
      isSameItem: _GroupManageDragHandler.isSameItem,
      itemBuilder: (context, index) => _GroupManageTile(
        index: index,
        key: ValueKey(_handler.items[index].uuid),
        group: _handler.items[index],
        isSelected: widget.selectedUUIDs.contains(_handler.items[index].uuid),
        selectionMode: widget.selectionMode,
        showDragHandle: showHandle,
        onTap: () => widget.onTap(_handler.items[index].uuid),
        // Long-press drag is handled by the package's
        // [ReorderableGridDelayedDragStartListener]; selection mode entry is
        // handled in [_GroupManageDragHandler.onReorderStart] instead.
        onEdit: () => widget.onEdit(_handler.items[index].uuid),
        onDelete: () => widget.onDelete(_handler.items[index].uuid),
      ),
      proxyDecorator: _GroupManageDragHandler.proxyDecorator,
      onReorderStart: (index) =>
          _handler.onReorderStart(index, widget.selectionMode),
      onReorder: (oldIndex, newIndex) => setState(() {
        _handler.onReorder(oldIndex, newIndex);
        context.read<AppEventBus>().push(
          const GroupChangedEvent(
            msg: "group_manage.onGroupReorderComplete",
            trace: {
              AppEventPageSource.groupManage: {
                AppEventFunctionSource.groupChanged,
              },
            },
          ),
        );
      }),
      nonDraggableItems: _handler.resolveNonDraggable(),
    );
  }
}

class _GroupGridCard extends StatelessWidget {
  final int index;
  final HabitGroupData group;
  final Set<String> selectedUUIDs;
  final bool selectionMode;
  final bool showDragHandle;
  final void Function(String uuid) onTap;
  final void Function(String uuid) onEdit;
  final void Function(String uuid) onDelete;

  const _GroupGridCard({
    super.key,
    required this.index,
    required this.group,
    required this.selectedUUIDs,
    required this.selectionMode,
    this.showDragHandle = false,
    required this.onTap,
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
      _SelectionIndicator(
        selectionMode: selectionMode,
        isSelected: isSelected,
        groupIcon: group.icon?.iconData ?? defaultGroupIcon,
        iconColor: _resolveTileColor(context, group),
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
      _TrailingAction(
        index: index,
        showDragHandle: showDragHandle,
        selectionMode: selectionMode,
        onEdit: () => onEdit(group.uuid),
        onDelete: () => onDelete(group.uuid),
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

  void _showContextMenu(BuildContext context, TapDownDetails details) {
    showMenu<_GroupAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: _popupMenuItems(
        context,
        onEdit: () => onEdit(group.uuid),
        onDelete: () => onDelete(group.uuid),
      ),
    ).then((value) {
      if (value != null) {
        _handleMenuSelected(
          value,
          onEdit: () => onEdit(group.uuid),
          onDelete: () => onDelete(group.uuid),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedUUIDs.contains(group.uuid);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onSecondaryTapDown: (d) => _showContextMenu(context, d),
      child: Card(
        shape: _shape,
        clipBehavior: Clip.antiAlias,
        color: isSelected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        child: InkWell(
          borderRadius: _shape.borderRadius.resolve(null),
          onTap: () => onTap(group.uuid),

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
      ),
    );
  }
}

enum _GroupAction { edit, delete }

List<PopupMenuEntry<_GroupAction>> _popupMenuItems(
  BuildContext context, {
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) => [
  PopupMenuItem(
    value: _GroupAction.edit,
    child: ListTile(
      leading: const Icon(Icons.edit_outlined),
      title: Text(L10n.of(context)?.groupManage_menu_edit ?? 'Edit'),
      dense: true,
      contentPadding: EdgeInsets.zero,
    ),
  ),
  PopupMenuItem(
    value: _GroupAction.delete,
    child: ListTile(
      leading: const Icon(Icons.delete_outline),
      title: Text(L10n.of(context)?.groupManage_menu_delete ?? 'Delete'),
      dense: true,
      contentPadding: EdgeInsets.zero,
    ),
  ),
];

void _handleMenuSelected(
  _GroupAction value, {
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  switch (value) {
    case _GroupAction.edit:
      onEdit?.call();
    case _GroupAction.delete:
      onDelete?.call();
  }
}

/// Unified trailing action area — always 24×24.
///
/// Shows a drag handle when [showDragHandle] is true, nothing in selection
/// mode, or a PopupMenu otherwise.
class _TrailingAction extends StatelessWidget {
  final int index;
  final bool showDragHandle;
  final bool selectionMode;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TrailingAction({
    required this.index,
    required this.showDragHandle,
    required this.selectionMode,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (showDragHandle) return DragHandleButton(index: index);
    if (selectionMode) return const SizedBox.square(dimension: 40.0);
    return PopupMenuButton<_GroupAction>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      onSelected: (v) =>
          _handleMenuSelected(v, onEdit: onEdit, onDelete: onDelete),
      itemBuilder: _buildMenuItems,
    );
  }

  List<PopupMenuEntry<_GroupAction>> _buildMenuItems(BuildContext context) =>
      _popupMenuItems(context, onEdit: onEdit, onDelete: onDelete);
}

/// Selection indicator that always occupies a fixed 24×24 area.
///
/// When [selectionMode] is false, shows the group icon.
/// When [selectionMode] is true and [isSelected] is false, shows the group icon.
/// When selected, shows a filled circle with a check mark.
/// Uses [AnimatedSwitcher] for smooth transitions.
class _SelectionIndicator extends StatelessWidget {
  final bool selectionMode;
  final bool isSelected;
  final IconData groupIcon;
  final Color? iconColor;

  const _SelectionIndicator({
    required this.selectionMode,
    required this.isSelected,
    required this.groupIcon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final showCircle = selectionMode && isSelected;
    return SizedBox(
      width: 24,
      height: 24,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: showCircle
            ? Container(
                key: const ValueKey('selected'),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              )
            : Icon(
                key: const ValueKey('icon'),
                groupIcon,
                color: iconColor,
                size: 24,
              ),
      ),
    );
  }
}

/// Whether the current platform is iOS or Android (mobile).
bool get _isMobilePlatform =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android;

class _GroupManageTile extends StatelessWidget {
  final int index;
  final HabitGroupData group;
  final bool isSelected;
  final bool selectionMode;
  final bool showDragHandle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _GroupManageTile({
    super.key,
    required this.index,
    required this.group,
    this.isSelected = false,
    this.selectionMode = false,
    this.showDragHandle = false,
    this.onTap,
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

  Widget _buildLeading(BuildContext context) => _SelectionIndicator(
    selectionMode: selectionMode,
    isSelected: isSelected,
    groupIcon: group.icon?.iconData ?? defaultGroupIcon,
    iconColor: _resolveTileColor(context),
  );

  Widget? _buildSubtitle() => group.desc.isNotEmpty
      ? Text(group.desc, maxLines: 1, overflow: TextOverflow.ellipsis)
      : null;

  Widget _buildTrailing(BuildContext context) => _TrailingAction(
    index: index,
    showDragHandle: showDragHandle,
    selectionMode: selectionMode,
    onEdit: onEdit,
    onDelete: onDelete,
  );

  void _showContextMenu(BuildContext context, TapDownDetails details) {
    showMenu<_GroupAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: _popupMenuItems(context, onEdit: onEdit, onDelete: onDelete),
    ).then((value) {
      if (value != null) {
        _handleMenuSelected(value, onEdit: onEdit, onDelete: onDelete);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onSecondaryTapDown: (d) => _showContextMenu(context, d),
      child: ListTile(
        selected: selectionMode && isSelected,
        selectedTileColor: colorScheme.primaryContainer.withAlpha(77),
        selectedColor: colorScheme.onPrimaryContainer,
        leading: _buildLeading(context),
        title: Text(group.name),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailing(context),
        onTap: onTap,
      ),
    );
  }
}

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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../extensions/target_platform_extensions.dart';
import '../../../models/habit_group.dart';
import '../../../models/habit_group_display.dart';
import '../../../widgets/widgets.dart';
import '../_providers/group_manage.dart';
import 'group_manage_items.dart';

/// Owns local item list and drag callbacks shared by [GroupManageGrid] and
/// [GroupManageList]. States create one instance and delegate to it.
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
      builder: (context) => switch (AdaptiveStyle.of(context)) {
        AdaptiveStyle.apple => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
        AdaptiveStyle.material => Material(
          elevation: 8,
          shadowColor: Colors.black38,
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          surfaceTintColor: Colors.transparent,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: child,
        ),
      },
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
    // drag-handle click or long-press). Use [listen: false] to avoid a
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

  /// Returns a long-press callback for non-draggable items (non-manual sort),
  /// or `null` when the reorder list handles long-press via drag (manual sort).
  VoidCallback? resolveLongPressCallback(int index, bool selectionMode) {
    if (isManualSort) return null;
    if (selectionMode) return null;

    void onLongPress() {
      if (index >= 0 && index < items.length) {
        _vm.enterSelectionMode(items[index].uuid);
      }
    }

    return onLongPress;
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
    final showHandle =
        _handler.isManualSort &&
        !DeviceContext.of(context).platform.isMobileOperatingSystem;

    return SliverReorderableAnimatedList<HabitGroupData>.grid(
      scrollDirection: _GroupManageDragHandler.scrollDirection,
      items: _handler.items,
      isSameItem: _GroupManageDragHandler.isSameItem,
      itemBuilder: (context, index) => GroupManageGridItem(
        index: index,
        key: ValueKey(_handler.items[index].uuid),
        group: _handler.items[index],
        isSelected: widget.selectedUUIDs.contains(_handler.items[index].uuid),
        selectionMode: widget.selectionMode,
        showDragHandle: showHandle,
        onTap: () => widget.onTap(_handler.items[index].uuid),
        onLongPress: _handler.resolveLongPressCallback(
          index,
          widget.selectionMode,
        ),
        onEdit: () => widget.onEdit(_handler.items[index].uuid),
        onDelete: () => widget.onDelete(_handler.items[index].uuid),
      ),
      sliverGridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisExtent:
            100 +
            (MediaQuery.textScalerOf(context).scale(16) - 16).clamp(
                  0,
                  double.infinity,
                ) *
                2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      proxyDecorator: _GroupManageDragHandler.proxyDecorator,
      onReorderStart: (index) =>
          _handler.onReorderStart(index, widget.selectionMode),
      onReorder: (oldIndex, newIndex) => setState(() {
        _handler.onReorder(oldIndex, newIndex);
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
    final showHandle =
        _handler.isManualSort &&
        !DeviceContext.of(context).platform.isMobileOperatingSystem;

    return SliverReorderableAnimatedList<HabitGroupData>(
      scrollDirection: _GroupManageDragHandler.scrollDirection,
      items: _handler.items,
      isSameItem: _GroupManageDragHandler.isSameItem,
      itemBuilder: (context, index) => GroupManageListItem(
        index: index,
        key: ValueKey(_handler.items[index].uuid),
        group: _handler.items[index],
        isSelected: widget.selectedUUIDs.contains(_handler.items[index].uuid),
        selectionMode: widget.selectionMode,
        showDragHandle: showHandle,
        onTap: () => widget.onTap(_handler.items[index].uuid),
        onLongPress: _handler.resolveLongPressCallback(
          index,
          widget.selectionMode,
        ),
        onEdit: () => widget.onEdit(_handler.items[index].uuid),
        onDelete: () => widget.onDelete(_handler.items[index].uuid),
      ),
      proxyDecorator: _GroupManageDragHandler.proxyDecorator,
      onReorderStart: (index) =>
          _handler.onReorderStart(index, widget.selectionMode),
      onReorder: (oldIndex, newIndex) => setState(() {
        _handler.onReorder(oldIndex, newIndex);
      }),
      nonDraggableItems: _handler.resolveNonDraggable(),
    );
  }
}

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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../l10n/localizations.dart';
import '../../../widgets/widgets.dart';

class GroupManageItemMenuController {
  final menuController = MenuController();
  final anchorKey = GlobalKey();

  void openAtGlobalPosition(Offset globalPosition) {
    final renderObject = anchorKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;
    menuController.open(position: renderObject.globalToLocal(globalPosition));
  }
}

class MaterialGroupManageItemActions extends StatelessWidget {
  const MaterialGroupManageItemActions({
    super.key,
    required this.controller,
    required this.index,
    required this.showDragHandle,
    required this.selectionMode,
    required this.onEdit,
    required this.onDelete,
  });

  final GroupManageItemMenuController controller;
  final int index;
  final bool showDragHandle;
  final bool selectionMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static List<Widget> buildMenuChildren(
    BuildContext context, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) => [
    MenuItemButton(
      leadingIcon: const Icon(Icons.edit_outlined),
      onPressed: onEdit,
      child: Text(L10n.of(context)?.groupManage_menu_edit ?? 'Edit'),
    ),
    MenuItemButton(
      leadingIcon: const Icon(Icons.delete_outline),
      onPressed: onDelete,
      child: Text(L10n.of(context)?.groupManage_menu_delete ?? 'Delete'),
    ),
  ];

  @override
  Widget build(BuildContext context) => MenuAnchor(
    controller: controller.menuController,
    animated: true,
    menuChildren: buildMenuChildren(
      context,
      onEdit: onEdit,
      onDelete: onDelete,
    ),
    builder: (context, menuController, child) => KeyedSubtree(
      key: controller.anchorKey,
      child: showDragHandle
          ? DragHandleButton(index: index)
          : selectionMode
          ? const SizedBox.square(dimension: 40)
          : IconButton(
              tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
              onPressed: () => menuController.isOpen
                  ? menuController.close()
                  : menuController.open(),
              icon: const Icon(Icons.more_vert),
            ),
    ),
  );
}

class AppleGroupManageItemActions extends StatelessWidget {
  const AppleGroupManageItemActions({
    super.key,
    required this.controller,
    required this.index,
    required this.showDragHandle,
    required this.selectionMode,
    required this.onEdit,
    required this.onDelete,
  });

  final GroupManageItemMenuController controller;
  final int index;
  final bool showDragHandle;
  final bool selectionMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static List<Widget> buildMenuChildren(
    BuildContext context, {
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) => [
    CupertinoMenuItem(
      leading: const Icon(CupertinoIcons.pencil),
      onPressed: onEdit,
      child: Text(L10n.of(context)?.groupManage_menu_edit ?? 'Edit'),
    ),
    CupertinoMenuItem(
      leading: const Icon(
        CupertinoIcons.trash,
        color: CupertinoColors.systemRed,
      ),
      onPressed: onDelete,
      child: Text(
        L10n.of(context)?.groupManage_menu_delete ?? 'Delete',
        style: const TextStyle(color: CupertinoColors.systemRed),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) => CupertinoMenuAnchor(
    controller: controller.menuController,
    menuChildren: buildMenuChildren(
      context,
      onEdit: onEdit,
      onDelete: onDelete,
    ),
    builder: (context, menuController, child) => KeyedSubtree(
      key: controller.anchorKey,
      child: showDragHandle
          ? ReorderableGridDragStartListener(
              index: index,
              child: const SizedBox.square(
                dimension: 44,
                child: Icon(CupertinoIcons.line_horizontal_3),
              ),
            )
          : selectionMode
          ? const SizedBox.square(dimension: 44)
          : CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => menuController.isOpen
                  ? menuController.close()
                  : menuController.open(),
              child: const Icon(CupertinoIcons.ellipsis),
            ),
    ),
  );
}

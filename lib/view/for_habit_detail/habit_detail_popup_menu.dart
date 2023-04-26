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

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../extension/custom_color_extensions.dart';
import '../../l10n/localizations.dart';
import '../../model/habit_form.dart';
import '../../theme/color.dart';

enum _PopupItemEnum {
  unarchive,
  archive,
  delete,
  export,
}

class HabitDetailPopupMenuButton extends StatelessWidget {
  final bool isArchived;
  final HabitColorType? colorType;
  final VoidCallback? onUnarchiveButtonPressed;
  final VoidCallback? onArchiveButtonPressed;
  final VoidCallback? onDeleteButtonPressed;
  final VoidCallback? onExportButtonPress;

  const HabitDetailPopupMenuButton({
    super.key,
    required this.isArchived,
    this.colorType,
    this.onUnarchiveButtonPressed,
    this.onArchiveButtonPressed,
    this.onDeleteButtonPressed,
    this.onExportButtonPress,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorData = themeData.extension<CustomColors>();
    final l10n = L10n.of(context);

    var color = colorType != null
        ? colorData?.getColor(colorType!)
        : Colors.transparent;

    return PopupMenuButton<_PopupItemEnum>(
      padding: EdgeInsets.zero,
      icon: Icon(Icons.adaptive.more, color: color),
      onSelected: (value) {
        switch (value) {
          case _PopupItemEnum.unarchive:
            onUnarchiveButtonPressed?.call();
            break;
          case _PopupItemEnum.archive:
            onArchiveButtonPressed?.call();
            break;
          case _PopupItemEnum.delete:
            onDeleteButtonPressed?.call();
            break;
          case _PopupItemEnum.export:
            onExportButtonPress?.call();
            break;
        }
      },
      itemBuilder: (context) => <PopupMenuItem<_PopupItemEnum>>[
        if (isArchived)
          PopupMenuItem<_PopupItemEnum>(
            value: _PopupItemEnum.unarchive,
            child: ListTile(
              title: l10n != null
                  ? Text(l10n.habitDetail_editPopMenu_unarchive)
                  : const Text("Unarchive"),
              leading: const Icon(Icons.unarchive_rounded),
            ),
          ),
        if (!isArchived)
          PopupMenuItem<_PopupItemEnum>(
            value: _PopupItemEnum.archive,
            child: ListTile(
              title: l10n != null
                  ? Text(l10n.habitDetail_editPopMenu_archive)
                  : const Text("Archive"),
              leading: const Icon(Icons.archive_outlined),
            ),
          ),
        PopupMenuItem<_PopupItemEnum>(
          value: _PopupItemEnum.export,
          child: ListTile(
            title: l10n != null
                ? Text(l10n.habitDetail_editPopMenu_export)
                : const Text("Export"),
            leading: const Icon(MdiIcons.export),
          ),
        ),
        PopupMenuItem<_PopupItemEnum>(
          value: _PopupItemEnum.delete,
          child: ListTile(
            title: l10n != null
                ? Text(l10n.habitDetail_editPopMenu_delete)
                : const Text("Delete"),
            leading: const Icon(Icons.delete_outline),
          ),
        ),
      ],
    );
  }
}

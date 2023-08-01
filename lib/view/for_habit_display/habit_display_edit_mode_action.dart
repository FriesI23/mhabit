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

enum EditModeActionItemCell {
  edit,
  archive,
  unarchive,
  delete,
  exportall,
  selectall,
  clone,
}

enum EditModeActionItemShowStatus {
  button,
  popupitem,
}

class EditModeActionItemConfig {
  final EditModeActionItemCell type;
  final EditModeActionItemShowStatus showStatus;
  final bool visible;
  final IconData icon;
  final String text;
  final VoidCallback? callback;

  const EditModeActionItemConfig({
    required this.type,
    required this.showStatus,
    this.visible = true,
    required this.icon,
    required this.text,
    this.callback,
  });

  const EditModeActionItemConfig.edit(
      {this.showStatus = EditModeActionItemShowStatus.button,
      this.visible = true,
      this.text = '',
      this.callback})
      : type = EditModeActionItemCell.edit,
        icon = Icons.edit_rounded;

  const EditModeActionItemConfig.archive(
      {this.showStatus = EditModeActionItemShowStatus.button,
      this.visible = true,
      this.text = '',
      this.callback})
      : type = EditModeActionItemCell.archive,
        icon = Icons.archive_outlined;

  const EditModeActionItemConfig.unarchive(
      {this.showStatus = EditModeActionItemShowStatus.button,
      this.visible = true,
      this.text = '',
      this.callback})
      : type = EditModeActionItemCell.unarchive,
        icon = Icons.unarchive_rounded;

  const EditModeActionItemConfig.delete(
      {this.showStatus = EditModeActionItemShowStatus.popupitem,
      this.visible = true,
      this.text = '',
      this.callback})
      : type = EditModeActionItemCell.delete,
        icon = MdiIcons.delete;

  const EditModeActionItemConfig.selectall(
      {this.showStatus = EditModeActionItemShowStatus.popupitem,
      this.visible = true,
      this.text = '',
      this.callback})
      : type = EditModeActionItemCell.selectall,
        icon = MdiIcons.selectAll;

  const EditModeActionItemConfig.exportall(
      {this.showStatus = EditModeActionItemShowStatus.popupitem,
      this.visible = true,
      this.text = '',
      this.callback})
      : type = EditModeActionItemCell.exportall,
        icon = MdiIcons.export;

  const EditModeActionItemConfig.clone(
      {this.showStatus = EditModeActionItemShowStatus.popupitem,
      this.visible = true,
      this.text = '',
      this.callback})
      : type = EditModeActionItemCell.clone,
        icon = Icons.copy_rounded;
}

class HabitDisplayAppBarEditModeActions extends StatelessWidget {
  final Duration buttonSwitchAnimateDuration;
  final List<EditModeActionItemConfig> actionConfigs;

  const HabitDisplayAppBarEditModeActions({
    super.key,
    this.buttonSwitchAnimateDuration = Duration.zero,
    this.actionConfigs = const [],
  });

  List<PopupMenuItem<EditModeActionItemCell>> _getPopupItemList(
      BuildContext context) {
    PopupMenuItem<EditModeActionItemCell> getPopupItem(
      BuildContext context,
      EditModeActionItemConfig config,
    ) {
      return PopupMenuItem<EditModeActionItemCell>(
        value: config.type,
        child: ListTile(
          title: Text(config.text),
          leading: Icon(config.icon),
        ),
      );
    }

    List<PopupMenuItem<EditModeActionItemCell>> children = [];
    for (var config in actionConfigs) {
      if (config.showStatus == EditModeActionItemShowStatus.popupitem &&
          config.visible) {
        children.add(getPopupItem(context, config));
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildActionButton(
      BuildContext context,
      EditModeActionItemConfig config,
    ) {
      return AnimatedSwitcher(
        duration: buttonSwitchAnimateDuration,
        switchInCurve: Curves.easeInQuart,
        child: config.visible
            ? _EditModeActionItemButton(config: config)
            : const SizedBox(),
      );
    }

    List<Widget> children = [];
    for (var config in actionConfigs) {
      if (config.showStatus == EditModeActionItemShowStatus.button) {
        children.add(buildActionButton(context, config));
      }
    }

    return Row(
      children: [
        ...children,
        PopupMenuButton<EditModeActionItemCell>(
          padding: EdgeInsets.zero,
          onSelected: (value) {
            for (var config in actionConfigs) {
              if (config.type == value) {
                config.callback?.call();
                break;
              }
            }
          },
          itemBuilder: (context) => _getPopupItemList(context),
        ),
      ],
    );
  }
}

class _EditModeActionItemButton extends StatelessWidget {
  final EditModeActionItemConfig config;

  const _EditModeActionItemButton({required this.config});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: config.callback,
      icon: Icon(config.icon),
      tooltip: config.text,
    );
  }
}

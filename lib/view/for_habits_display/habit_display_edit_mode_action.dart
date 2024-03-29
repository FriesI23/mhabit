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

import '../common/_widget.dart';

enum EditModeActionItemCell {
  edit,
  archive,
  unarchive,
  delete,
  exportall,
  selectall,
  clone,
}

class EditModeActionItemConfig
    extends AppbarActionItemConfig<EditModeActionItemCell> {
  const EditModeActionItemConfig({
    required super.type,
    required super.status,
    super.visible = true,
    required super.icon,
    required super.text,
    super.callback,
  });

  const EditModeActionItemConfig.edit(
      {super.status = AppbarActionShowStatus.button,
      super.visible = true,
      super.text = '',
      super.callback})
      : super(
          type: EditModeActionItemCell.edit,
          icon: Icons.edit_rounded,
        );

  const EditModeActionItemConfig.archive(
      {super.status = AppbarActionShowStatus.button,
      super.visible = true,
      super.text = '',
      super.callback})
      : super(
          type: EditModeActionItemCell.archive,
          icon: Icons.archive_outlined,
        );

  const EditModeActionItemConfig.unarchive(
      {super.status = AppbarActionShowStatus.button,
      super.visible = true,
      super.text = '',
      super.callback})
      : super(
          type: EditModeActionItemCell.unarchive,
          icon: Icons.unarchive_rounded,
        );

  const EditModeActionItemConfig.delete(
      {super.status = AppbarActionShowStatus.popupitem,
      super.visible = true,
      super.text = '',
      super.callback})
      : super(
          type: EditModeActionItemCell.delete,
          icon: MdiIcons.delete,
        );

  const EditModeActionItemConfig.selectall(
      {super.status = AppbarActionShowStatus.popupitem,
      super.visible = true,
      super.text = '',
      super.callback})
      : super(
          type: EditModeActionItemCell.selectall,
          icon: MdiIcons.selectAll,
        );

  const EditModeActionItemConfig.exportall(
      {super.status = AppbarActionShowStatus.popupitem,
      super.visible = true,
      super.text = '',
      super.callback})
      : super(
          type: EditModeActionItemCell.exportall,
          icon: MdiIcons.export,
        );

  const EditModeActionItemConfig.clone(
      {super.status = AppbarActionShowStatus.popupitem,
      super.visible = true,
      super.text = '',
      super.callback})
      : super(
          type: EditModeActionItemCell.clone,
          icon: Icons.copy_rounded,
        );

  @override
  bool shouldShow(AppbarActionShowStatus s) {
    switch (s) {
      case AppbarActionShowStatus.button:
        return status == s;
      case AppbarActionShowStatus.popupitem:
        return status == s && visible;
    }
  }
}

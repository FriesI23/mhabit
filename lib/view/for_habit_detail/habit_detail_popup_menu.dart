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

enum DetailAppbarActionItemCell {
  edit,
  unarchive,
  archive,
  delete,
  export,
  clone,
}

class DetailAppbarActionItemConfig
    extends AppbarActionItemConfig<DetailAppbarActionItemCell> {
  DetailAppbarActionItemConfig(
      {required super.type,
      required super.status,
      super.visible = true,
      required super.icon,
      required super.text,
      super.color,
      super.callback});

  const DetailAppbarActionItemConfig.unarchive(
      {super.status = AppbarActionShowStatus.popupitem,
      super.visible = true,
      super.text = '',
      super.color,
      super.callback})
      : super(
          type: DetailAppbarActionItemCell.unarchive,
          icon: Icons.unarchive_rounded,
        );

  const DetailAppbarActionItemConfig.edit(
      {super.status = AppbarActionShowStatus.button,
      super.visible = true,
      super.text = '',
      super.color,
      super.callback})
      : super(
          type: DetailAppbarActionItemCell.edit,
          icon: Icons.edit_rounded,
        );

  const DetailAppbarActionItemConfig.archive(
      {super.status = AppbarActionShowStatus.popupitem,
      super.visible = true,
      super.text = '',
      super.color,
      super.callback})
      : super(
          type: DetailAppbarActionItemCell.archive,
          icon: Icons.archive_outlined,
        );

  const DetailAppbarActionItemConfig.delete(
      {super.status = AppbarActionShowStatus.popupitem,
      super.visible = true,
      super.text = '',
      super.color,
      super.callback})
      : super(
          type: DetailAppbarActionItemCell.delete,
          icon: Icons.delete_outline,
        );

  const DetailAppbarActionItemConfig.export(
      {super.status = AppbarActionShowStatus.popupitem,
      super.visible = true,
      super.text = '',
      super.color,
      super.callback})
      : super(
          type: DetailAppbarActionItemCell.export,
          icon: MdiIcons.export,
        );

  const DetailAppbarActionItemConfig.clone(
      {super.status = AppbarActionShowStatus.popupitem,
      super.visible = true,
      super.text = '',
      super.color,
      super.callback})
      : super(
          type: DetailAppbarActionItemCell.clone,
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

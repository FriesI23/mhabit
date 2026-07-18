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

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'common.dart';
import 'group.dart';

part 'group_export.g.dart';

/// JSON backup export/import keys for Group.
///
/// Mirrors the export-relevant entries in [GroupDBCellKey]
/// (`lib/storage/db/handlers/group.dart`).
/// Excludes id, createT, modifyT, status — these are internal DB fields.
/// Includes uuid for in-file habit↔group association; import assigns a new uuid.
class GroupExportDataKey {
  static const String uuid = 'uuid';
  static const String name = 'name';
  static const String desc = 'desc';
  static const String icon = 'icon';
  static const String color = 'color';
  static const String customColor = 'custom_color';
  static const String customColorTinted = 'custom_color_tinted';
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
@CopyWith(skipFields: true)
class GroupExportData implements JsonAdaptor {
  @JsonKey(name: GroupExportDataKey.uuid)
  final String? uuid;
  @JsonKey(name: GroupExportDataKey.name)
  final String? name;
  @JsonKey(name: GroupExportDataKey.desc)
  final String? desc;
  @JsonKey(name: GroupExportDataKey.icon)
  final int? icon;
  @JsonKey(name: GroupExportDataKey.color)
  final int? color;
  @JsonKey(name: GroupExportDataKey.customColor)
  final int? customColor;
  @JsonKey(name: GroupExportDataKey.customColorTinted)
  final int? customColorTinted;

  const GroupExportData({
    this.uuid,
    this.name,
    this.desc,
    this.icon,
    this.color,
    this.customColor,
    this.customColorTinted,
  });

  /// Builds an export object from a DB cell, preserving the original uuid
  /// for in-file habit↔group association only — import assigns new UUIDs.
  factory GroupExportData.fromGroupDBCell(GroupDBCell cell) {
    return GroupExportData(
      uuid: cell.uuid,
      name: cell.name,
      desc: cell.desc,
      icon: cell.icon,
      color: cell.color,
      customColor: cell.customColor,
      customColorTinted: cell.customColorTinted,
    );
  }

  factory GroupExportData.fromJson(dynamic json) =>
      _$GroupExportDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GroupExportDataToJson(this);
}

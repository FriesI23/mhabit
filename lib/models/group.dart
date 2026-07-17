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

import '../common/types.dart';
import '../storage/db/db_cell.dart';

part 'group.g.dart';

class GroupDBCellKey {
  static const String id = 'id_';
  static const String createT = 'create_t';
  static const String modifyT = 'modify_t';
  static const String uuid = 'uuid';
  static const String name = 'name';
  static const String desc = 'desc';
  static const String icon = 'icon';
  static const String color = 'color';
  static const String customColor = 'custom_color';
  static const String customColorTinted = 'custom_color_tinted';
  static const String status = 'status';

  /// `color`/`customColor`/`customColorTinted` always travel together as one
  /// semantic unit — mirrors [HabitDBCellKey.colorKeys].
  static const List<String> colorKeys = [color, customColor, customColorTinted];

  /// Subset of [colorKeys]: only the nullable fields that must be explicitly
  /// cleared when switching back to a built-in color.
  static const List<String> nullableColorKeys = [
    customColor,
    customColorTinted,
  ];
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
@CopyWith(skipFields: true)
class GroupDBCell with DBCell {
  @JsonKey(name: GroupDBCellKey.id)
  final DBID? id;
  @JsonKey(name: GroupDBCellKey.createT)
  final int? createT;
  @JsonKey(name: GroupDBCellKey.modifyT)
  final int? modifyT;
  @JsonKey(name: GroupDBCellKey.uuid)
  final String? uuid;
  @JsonKey(name: GroupDBCellKey.name)
  final String? name;
  @JsonKey(name: GroupDBCellKey.desc)
  final String? desc;
  @JsonKey(name: GroupDBCellKey.icon, includeIfNull: true)
  final int? icon;
  @JsonKey(name: GroupDBCellKey.color, includeIfNull: true)
  final int? color;
  @JsonKey(name: GroupDBCellKey.customColor, includeIfNull: true)
  final int? customColor;
  @JsonKey(name: GroupDBCellKey.customColorTinted, includeIfNull: true)
  final int? customColorTinted;
  @JsonKey(name: GroupDBCellKey.status)
  final int? status;

  const GroupDBCell({
    this.id,
    this.createT,
    this.modifyT,
    this.uuid,
    this.name,
    this.desc,
    this.icon,
    this.color,
    this.customColor,
    this.customColorTinted,
    this.status,
  });

  factory GroupDBCell.fromJson(Map<String, Object?> cell) =>
      _$GroupDBCellFromJson(cell);

  @override
  Map<String, Object?> toJson() => _$GroupDBCellToJson(this);
}

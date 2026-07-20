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

import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import '../common/consts.dart';
import '../common/enums.dart';
import '../common/types.dart';
import '../extensions/group_icon_extensions.dart';
import 'group.dart';
import 'habit_color.dart';
import 'habit_color_type.dart';

/// DB status codes for groups.
///
/// Mirrors [GroupDBCell.status].
@JsonEnum(valueField: 'code')
enum GroupStatus implements EnumWithDBCode<GroupStatus> {
  unknown(code: 0),
  active(code: 1),
  deleted(code: 2);

  final int code;

  const GroupStatus({required this.code});

  @override
  int get dbCode => code;

  static GroupStatus? getFromDBCode(
    int dbCode, {
    GroupStatus? withDefault = GroupStatus.unknown,
  }) => GroupStatus.values.byDBCode(dbCode, withDefault: withDefault);
}

/// Preset group icons.
enum GroupIcon {
  folder,
  work,
  fitness,
  study,
  home,
  star,
  music,
  finance,
  meditation,
  health,
}

/// Domain-layer model for a habit group.
///
/// Extracts and normalises raw [GroupDBCell] fields at construction time,
/// following the same pattern as [HabitSummaryData].
class HabitGroupData {
  final GroupUUID uuid;
  final String name;
  final String desc;

  /// Preset icon, or `null` when no icon is configured.
  final GroupIcon? icon;

  /// Normalised colour, or `null` when no colour is configured.
  final HabitColor? color;

  final GroupStatus status;

  /// When the group was created, or `null` when unavailable
  /// (e.g. group not yet persisted).
  final DateTime? createT;

  /// When the group was last modified, or `null` when unavailable.
  final DateTime? modifyT;

  const HabitGroupData({
    required this.uuid,
    required this.name,
    required this.desc,
    this.icon,
    this.color,
    this.status = GroupStatus.active,
    this.createT,
    this.modifyT,
  });

  /// Builds from a raw DB cell, converting colour fields, icon code point,
  /// and normalising nullable strings.
  factory HabitGroupData.fromDBQueryCell(GroupDBCell cell) {
    return HabitGroupData(
      uuid: cell.uuid!,
      name: cell.name ?? '',
      desc: cell.desc ?? '',
      icon: cell.icon?.toGroupIcon,
      color: _buildColor(cell),
      status: GroupStatus.getFromDBCode(cell.status ?? 1) ?? GroupStatus.active,
      createT: cell.createT != null
          ? DateTime.fromMillisecondsSinceEpoch(cell.createT! * onSecondMS)
          : null,
      modifyT: cell.modifyT != null
          ? DateTime.fromMillisecondsSinceEpoch(cell.modifyT! * onSecondMS)
          : null,
    );
  }

  static HabitColor? _buildColor(GroupDBCell cell) {
    final c = cell.customColor;
    if (c != null) {
      return HabitColor.custom(
        c,
        tinted: cell.customColorTinted == null || cell.customColorTinted != 0,
      );
    }
    final t = cell.color;
    if (t != null) {
      return HabitColor.builtIn(HabitColorType.getFromDBCode(t)!);
    }
    return null;
  }

  bool get isActive => status == GroupStatus.active;

  bool get isDeleted => status == GroupStatus.deleted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is HabitGroupData && uuid == other.uuid);

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() =>
      'HabitGroupData('
      'uuid: $uuid, name: $name, icon: $icon, color: $color, '
      'createT: $createT, modifyT: $modifyT)';
}

/// Domain-layer collection of [HabitGroupData] that converts raw [GroupDBCell]
/// cells at construction time.
///
/// Analogous to [HabitSummaryDataCollection] but read-only: the collection is
/// a snapshot constructed from DB query results and is not mutated after
/// creation.
class GroupCollection {
  final List<HabitGroupData> _groups;

  GroupCollection._(this._groups);

  /// Builds from DB query results, converting each cell to [HabitGroupData]
  /// at construction time.
  factory GroupCollection.fromDBQueryResult(List<GroupDBCell> cells) {
    return GroupCollection._(
      cells.map(HabitGroupData.fromDBQueryCell).toList(),
    );
  }

  /// Returns the group with the given [uuid], or `null` if not found.
  HabitGroupData? getByUUID(String? uuid) {
    if (uuid == null) return null;
    return _groups.firstWhereOrNull((g) => g.uuid == uuid);
  }

  /// Returns an unmodifiable snapshot of all groups for UI consumption.
  List<HabitGroupData> toList() => List.unmodifiable(_groups);
}

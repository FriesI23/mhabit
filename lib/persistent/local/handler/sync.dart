// Copyright 2025 Fries_I23
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

import '../../../common/types.dart';
import '../db_cell.dart';
import '../db_helper.dart';
import '../table.dart';
import 'habit.dart';
import 'record.dart';

part 'sync.g.dart';

class SyncDbCellKey {
  static const id = 'id_';
  static const createT = 'create_t';
  static const modifyT = 'modify_t';
  static const habitUUID = 'habit_uuid';
  static const recordUUID = 'record_uuid';
  static const dirty = 'dirty';
  static const lastConfigUUID = 'last_config_uuid';
  static const lastSesionUUID = 'last_session_uuid';
  static const lastMark = 'last_mark';
}

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
@CopyWith(skipFields: true)
class SyncDBCell with DBCell {
  @JsonKey(name: SyncDbCellKey.id)
  final DBID? id;
  @JsonKey(name: SyncDbCellKey.createT)
  final int? createT;
  @JsonKey(name: SyncDbCellKey.modifyT)
  final int? modifyT;
  @JsonKey(name: SyncDbCellKey.habitUUID)
  final HabitUUID? habitUUID;
  @JsonKey(name: SyncDbCellKey.recordUUID)
  final HabitUUID? recordUUID;
  @JsonKey(name: SyncDbCellKey.dirty)
  final int? dirty;
  @JsonKey(name: SyncDbCellKey.lastConfigUUID)
  final String? lastConfigUUID;
  @JsonKey(name: SyncDbCellKey.lastSesionUUID)
  final String? lastSesionUUID;
  @JsonKey(name: SyncDbCellKey.lastMark)
  final String? lastMark;

  const SyncDBCell({
    this.id,
    this.createT,
    this.modifyT,
    this.habitUUID,
    this.recordUUID,
    this.dirty,
    this.lastConfigUUID,
    this.lastSesionUUID,
    this.lastMark,
  });

  SyncDBCell.genFromRecord(RecordDBCell cell)
      : this(recordUUID: cell.uuid, dirty: 1);

  SyncDBCell.genFromHabit(HabitDBCell cell)
      : this(habitUUID: cell.uuid, dirty: 1);

  factory SyncDBCell.fromJson(JsonMap cell) => _$SyncDBCellFromJson(cell);

  @override
  Map<String, Object?> toJson() => _$SyncDBCellToJson(this);
}

class SyncDBHelper extends DBHelperHandler {
  const SyncDBHelper(super.helper);

  @override
  String get table => TableName.sync;

  static const _loadAllHabitsSyncInfoColumns = [
    SyncDbCellKey.id,
    SyncDbCellKey.habitUUID,
    SyncDbCellKey.recordUUID,
    SyncDbCellKey.lastConfigUUID,
    SyncDbCellKey.lastMark,
    SyncDbCellKey.dirty,
  ];

  Future<Iterable<SyncDBCell>> loadAllHabitsSyncInfo(
      {List<String> columns = _loadAllHabitsSyncInfoColumns}) async {
    final result = await db.query(
      table,
      distinct: true,
      columns: columns,
      where: "${SyncDbCellKey.habitUUID} IS NOT NULL "
          "AND ${SyncDbCellKey.recordUUID} IS NULL",
    );
    return result.map(SyncDBCell.fromJson);
  }
}

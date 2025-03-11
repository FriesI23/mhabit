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

import 'dart:convert';
import 'dart:io';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:simple_webdav_client/dav.dart';
import 'package:simple_webdav_client/error.dart';

import '../../common/types.dart';
import '../../extension/webdav_extensions.dart';
import '../../persistent/local/handler/habit.dart';
import '../../persistent/local/handler/record.dart';
import '../../persistent/local/handler/sync.dart';
import '../common.dart';
import '../habit_form.dart';
import '../habit_freq.dart';
import '../habit_reminder.dart';
import 'webdav_app_sync_subtasks.dart';

part 'webdav_app_sync_models.g.dart';

abstract interface class WebDavAppSyncCellInfo {
  WebDavAppSyncInfoStatus get status;
  bool get includeDirtyMark;
  bool get isNeedDownload;
  bool get isNeedUpload;
}

abstract class _WebDavAppSyncCellInfo implements WebDavAppSyncCellInfo {
  Uri? serverPath;
  String? eTagFromServer;
  String? eTagFromLocal;

  bool _includeDirtyMark;
  WebDavAppSyncInfoStatus _status;

  _WebDavAppSyncCellInfo(
      {required bool isDirty, required WebDavAppSyncInfoStatus status})
      : _includeDirtyMark = isDirty,
        _status = status;

  @override
  WebDavAppSyncInfoStatus get status => _status;

  set status(WebDavAppSyncInfoStatus newStatus) {
    if (_status != newStatus) _status = WebDavAppSyncInfoStatus.both;
  }

  @override
  bool get includeDirtyMark => _includeDirtyMark;

  void makeDirty() => _includeDirtyMark = true;

  @override
  bool get isNeedDownload =>
      status == WebDavAppSyncInfoStatus.server ||
      eTagFromLocal != eTagFromServer;

  @override
  bool get isNeedUpload =>
      status == WebDavAppSyncInfoStatus.local || includeDirtyMark;
}

class WebDavAppSyncHabitInfo extends _WebDavAppSyncCellInfo {
  final HabitUUID uuid;

  WebDavAppSyncHabitInfo({
    required this.uuid,
    required super.status,
    super.isDirty = false,
  });

  @override
  String toString() => "WebDavAppSyncCellInfo(uuid=$uuid, status=$status, "
      "sEtag=$eTagFromServer, cEtag=$eTagFromLocal, spath=$serverPath"
      ")";
}

class WebDavAppSyncRecordInfo extends _WebDavAppSyncCellInfo {
  final HabitUUID parentUUID;
  final HabitRecordUUID uuid;

  WebDavAppSyncRecordInfo({
    required this.parentUUID,
    required this.uuid,
    required super.status,
    super.isDirty = false,
  });

  @override
  String toString() =>
      "WebDavAppSyncRecordInfo(uuid=$uuid, puuid=$parentUUID status=$status, "
      "sEtag=$eTagFromServer, cEtag=$eTagFromLocal, spath=$serverPath"
      ")";
}

class WebDavResourceContainer {
  final Uri path;
  final String? etag;

  const WebDavResourceContainer({
    required this.path,
    this.etag,
  });

  factory WebDavResourceContainer.fromResource(WebDavStdResource resource,
      {Uri? overridePath}) {
    assert(resource.error == null);
    final getetag = resource.getetag;
    if (getetag.error != null) throw getetag.error!;
    if (getetag.status != HttpStatus.ok) {
      throw WebDavStdResError(
          "Resouce ${resource.path}'s dav:getetag status error, "
          "prop=${getetag.toDebugString()}");
    }
    return WebDavResourceContainer(
      path: overridePath ?? resource.path,
      etag: resource.getetag.value,
    );
  }

  HabitUUID? get habitUUID {
    final filename = path.pathSegments.lastOrNull;
    if (filename == null || filename.isEmpty) return null;
    return reAppSyncHabitFileName.firstMatch(filename)?.group(1);
  }

  HabitRecordUUID? get recordUUID {
    final filename = path.pathSegments.lastOrNull;
    if (filename == null || filename.isEmpty) return null;
    return reAppSyncRecordFileName.firstMatch(filename)?.group(1);
  }

  @override
  String toString() => 'WebDavResourceContainer(path=$path, etag=<$etag>)';
}

class WebDavSyncRecordKey {
  static const String recordDate = 'record_date';
  static const String recordType = 'record_type';
  static const String recordValue = 'record_value';
  static const String createT = 'create_t';
  static const String modifyT = 'modify_t';
  static const String uuid = 'uuid';
  static const String parentUUID = 'parent_uuid';
  static const String reason = 'reason';
  static const String convertType = '_convert_type';
}

@JsonSerializable(
    fieldRename: FieldRename.snake,
    includeIfNull: true,
    ignoreUnannotated: true)
@CopyWith(skipFields: true)
class WebDavSyncRecordData implements JsonAdaptor {
  static const _convertType = 'record_';

  @JsonKey(name: WebDavSyncRecordKey.recordDate)
  final int? recordDate;
  @JsonKey(name: WebDavSyncRecordKey.recordType)
  final int? recordType;
  @JsonKey(name: WebDavSyncRecordKey.recordValue)
  final num? recordValue;
  @JsonKey(name: WebDavSyncRecordKey.createT)
  final int? createT;
  @JsonKey(name: WebDavSyncRecordKey.modifyT)
  final int? modifyT;
  @JsonKey(name: WebDavSyncRecordKey.uuid)
  final HabitRecordUUID? uuid;
  @JsonKey(name: WebDavSyncRecordKey.parentUUID)
  final HabitUUID? parentUUID;
  @JsonKey(name: WebDavSyncRecordKey.reason)
  final String? reason;

  final String? etag;

  const WebDavSyncRecordData({
    this.recordDate,
    this.recordType,
    this.recordValue,
    this.createT,
    this.modifyT,
    this.uuid,
    this.parentUUID,
    this.reason,
    this.etag,
  });

  WebDavSyncRecordData.fromRecordDBCell(RecordDBCell cell, {this.etag})
      : recordDate = cell.recordDate,
        recordType = cell.recordType,
        recordValue = cell.recordValue,
        createT = cell.createT,
        modifyT = cell.modifyT,
        uuid = cell.uuid,
        parentUUID = cell.parentUUID,
        reason = cell.reason;

  factory WebDavSyncRecordData.fromJson(JsonMap json) {
    assert(json.remove(WebDavSyncRecordKey.convertType) == _convertType);
    return _$WebDavSyncRecordDataFromJson(json);
  }

  RecordDBCell toRecordDBCell() => RecordDBCell(
        recordDate: recordDate,
        recordType: recordType,
        recordValue: recordValue,
        createT: createT,
        modifyT: modifyT,
        uuid: uuid,
        parentUUID: parentUUID,
        reason: reason,
      );

  @override
  JsonMap toJson() => _$WebDavSyncRecordDataToJson(this)
    ..[WebDavSyncRecordKey.convertType] = _convertType;

  SyncDBCell genSyncDBCell({String? configId, String? sessionId}) => SyncDBCell(
      recordUUID: uuid,
      dirty: 0,
      lastMark: etag,
      lastConfigUUID: configId,
      lastSesionUUID: sessionId);

  void validated() {
    if (recordDate != null) {
      HabitRecordDate.fromEpochDay(recordDate!);
    }
    if (recordType != null &&
        HabitRecordStatus.getFromDBCode(recordType!) ==
            HabitRecordStatus.unknown) {
      throw TypeError();
    }
  }

  @override
  String toString() => "WebDavSyncRecordData${toJson()..['etag'] = etag}";
}

class WebDavSyncHabitKey {
  static const String uuid = 'uuid';
  static const String createT = 'create_t';
  static const String modifyT = 'modify_t';
  static const String type = 'type';
  static const String status = 'status';
  static const String name = 'name';
  static const String desc = 'desc';
  static const String color = 'color';
  static const String dailyGoal = 'daily_goal';
  static const String dailyGoalUnit = 'daily_goal_unit';
  static const String dailyGoalExtra = 'daily_goal_extra';
  static const String freqType = 'freq_type';
  static const String freqCustom = 'freq_custom';
  static const String reminder = 'reminder';
  static const String reminderQuest = 'reminder_quest';
  static const String startDate = 'start_date';
  static const String targetDays = 'target_days';
  static const String sortPosition = 'sort_position';
  static const String records = 'records';
  static const String convertType = '_convert_type';
}

@JsonSerializable(
    fieldRename: FieldRename.snake,
    includeIfNull: true,
    ignoreUnannotated: true)
@CopyWith(skipFields: true)
class WebDavSyncHabitData implements JsonAdaptor {
  static const _convertType = 'habit_';

  @JsonKey(name: WebDavSyncHabitKey.uuid)
  final String? uuid;
  @JsonKey(name: WebDavSyncHabitKey.createT)
  final int? createT;
  @JsonKey(name: WebDavSyncHabitKey.modifyT)
  final int? modifyT;
  @JsonKey(name: WebDavSyncHabitKey.type)
  final int? type;
  @JsonKey(name: WebDavSyncHabitKey.status)
  final int? status;
  @JsonKey(name: WebDavSyncHabitKey.name)
  final String? name;
  @JsonKey(name: WebDavSyncHabitKey.desc)
  final String? desc;
  @JsonKey(name: WebDavSyncHabitKey.color)
  final int? color;
  @JsonKey(name: WebDavSyncHabitKey.dailyGoal)
  final num? dailyGoal;
  @JsonKey(name: WebDavSyncHabitKey.dailyGoalUnit)
  final String? dailyGoalUnit;
  @JsonKey(name: WebDavSyncHabitKey.dailyGoalExtra)
  final num? dailyGoalExtra;
  @JsonKey(name: WebDavSyncHabitKey.freqType)
  final int? freqType;
  @JsonKey(name: WebDavSyncHabitKey.freqCustom)
  final String? freqCustom;
  @JsonKey(name: WebDavSyncHabitKey.reminder)
  final String? reminder;
  @JsonKey(name: WebDavSyncHabitKey.reminderQuest)
  final String? reminderQuest;
  @JsonKey(name: WebDavSyncHabitKey.startDate)
  final int? startDate;
  @JsonKey(name: WebDavSyncHabitKey.targetDays)
  final int? targetDays;
  @JsonKey(name: WebDavSyncHabitKey.sortPosition)
  final HabitSortPostion? sortPostion;

  final List<WebDavSyncRecordData> records;
  final String? etag;

  const WebDavSyncHabitData({
    this.uuid,
    this.createT,
    this.modifyT,
    this.type,
    this.status,
    this.name,
    this.desc,
    this.color,
    this.dailyGoal,
    this.dailyGoalUnit,
    this.dailyGoalExtra,
    this.freqType,
    this.freqCustom,
    this.reminder,
    this.reminderQuest,
    this.startDate,
    this.targetDays,
    this.sortPostion,
    this.records = const [],
    this.etag,
  });

  WebDavSyncHabitData.fromHabitDBCell(HabitDBCell cell,
      {this.etag, this.records = const []})
      : uuid = cell.uuid,
        createT = cell.createT,
        modifyT = cell.modifyT,
        type = cell.type,
        status = cell.status,
        name = cell.name,
        desc = cell.desc,
        color = cell.color,
        dailyGoal = cell.dailyGoal,
        dailyGoalUnit = cell.dailyGoalUnit,
        dailyGoalExtra = cell.dailyGoalExtra,
        freqType = cell.freqType,
        freqCustom = cell.freqCustom,
        reminder = cell.remindCustom,
        reminderQuest = cell.remindQuestion,
        startDate = cell.startDate,
        targetDays = cell.targetDays,
        sortPostion = cell.sortPosition;

  factory WebDavSyncHabitData.fromJson(JsonMap json) {
    assert(json.remove(WebDavSyncHabitKey.convertType) == _convertType);
    return _$WebDavSyncHabitDataFromJson(json);
  }

  HabitDBCell toHabitDBCell() => HabitDBCell(
        uuid: uuid,
        createT: createT,
        modifyT: modifyT,
        type: type,
        status: status,
        name: name,
        desc: desc,
        color: color,
        dailyGoal: dailyGoal,
        dailyGoalUnit: dailyGoalUnit,
        dailyGoalExtra: dailyGoalExtra,
        freqType: freqType,
        freqCustom: freqCustom,
        remindCustom: reminder,
        remindQuestion: reminderQuest,
        startDate: startDate,
        targetDays: targetDays,
        sortPosition: sortPostion,
      );

  @override
  JsonMap toJson() => _$WebDavSyncHabitDataToJson(this)
    ..[WebDavSyncHabitKey.convertType] = _convertType;

  SyncDBCell genSyncDBCell({String? configId, String? sessionId}) => SyncDBCell(
      habitUUID: uuid,
      dirty: 0,
      lastMark: etag,
      lastConfigUUID: configId,
      lastSesionUUID: sessionId);

  void validate() {
    if (type != null && HabitType.getFromDBCode(type!) == HabitType.unknown) {
      throw TypeError();
    }
    if (color != null &&
        HabitColorType.getFromDBCode(color!, withDefault: null) == null) {
      throw TypeError();
    }
    if (freqType != null) {
      HabitFrequency.fromJson(
          {"type": freqType!, "args": jsonDecode(freqCustom!)});
    }
    if (startDate != null) {
      HabitStartDate.fromEpochDay(startDate!);
    }
    if (status != null &&
        HabitStatus.getFromDBCode(status!) == HabitStatus.unknown) {
      throw TypeError();
    }
    if (reminder != null) {
      HabitReminder.fromJson(jsonDecode(reminder!));
    }
    for (var record in records) {
      record.validated();
    }
  }

  @override
  String toString() => "WebDavSyncHabitData${toJson()..['etag'] = etag}";
}

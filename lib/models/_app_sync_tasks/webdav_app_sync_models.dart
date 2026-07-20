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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mhabit_proxy_annotation/proxy_annotation.dart';
import 'package:retry/retry.dart';
import 'package:simple_webdav_client/dav.dart';
import 'package:simple_webdav_client/error.dart';

import '../../annotations/json_annotations.dart';
import '../../common/types.dart';
import '../../extensions/webdav_extensions.dart';
import '../../logging/helper.dart';
import '../../storage/db/handlers/habit.dart';
import '../../storage/db/handlers/record.dart';
import '../../storage/db/handlers/sync.dart';
import '../common.dart';
import '../group.dart';
import '../habit_color.dart';
import '../habit_form.dart';
import '../habit_freq.dart';
import '../habit_reminder.dart';
import '../progress_percent.dart';
import 'app_sync_task.dart';

part 'webdav_app_sync_models.g.dart';

String? encodeSyncExtras(Map<String, dynamic>? unknown) {
  if (unknown == null || unknown.isEmpty) return null;
  return jsonEncode(unknown);
}

Map<String, dynamic>? decodeSyncExtras(String? raw) {
  if (raw == null) return null;
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> && decoded.isNotEmpty
        ? decoded
        : null;
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? captureSyncUnknown(JsonMap json, Set<String> knownKeys) {
  final unknownKeys = json.keys.where((k) => !knownKeys.contains(k));
  final unknown = <String, dynamic>{};
  var count = 0;
  for (final k in unknownKeys) {
    unknown[k] = json[k];
    count++;
  }
  return count > 0 ? unknown : null;
}

/// Existing keys win ([putIfAbsent] semantics).
void mergeSyncUnknown(JsonMap target, Map<String, dynamic>? unknown) {
  if (unknown == null) return;
  for (final entry in unknown.entries) {
    target.putIfAbsent(entry.key, () => entry.value);
  }
}

/// Matches a habit JSON file name, e.g. 'habit-xxx-yyy-zzz.json'
final reAppSyncHabitFileName = RegExp(r'^habit-([^/]+)\.json$');

/// Matches a habit record directory name, e.g. 'habit-xxx-yyy-zzz'
final reAppSyncHabitRecordRootDirName = RegExp(r'^habit-([^/]+)$');

/// Matches a year-based directory name (4 digits), e.g. '2025'
final reAppSyncRecordDirName = RegExp(r'^\d{4}$');

/// Matches a record JSON file name, e.g. 'record-xxx-yyy-zzz.json'
final reAppSyncRecordFileName = RegExp(r'^record-([^/]+)\.json$');

/// Matches a group JSON file name, e.g. 'group-xxx-yyy-zzz.json'
final reAppSyncGroupFileName = RegExp(r'^group-([^/]+)\.json$');

enum WebDavAppSyncInfoStatus { server, local, both }

abstract interface class WebDavAppSyncCellInfo {
  WebDavAppSyncInfoStatus get status;
  bool get includeDirtyMark;
  bool get isNeedDownload;
  bool get isNeedUpload;
}

abstract class _WebDavAppSyncCellInfo implements WebDavAppSyncCellInfo {
  final String configUUID;
  Uri? serverPath;
  String? eTagFromServer;
  String? eTagFromLocal;
  String? lastConfgUUID;

  bool _includeDirtyMark;
  WebDavAppSyncInfoStatus _status;

  _WebDavAppSyncCellInfo({
    required this.configUUID,
    required bool isDirty,
    required WebDavAppSyncInfoStatus status,
  }) : _includeDirtyMark = isDirty,
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
  bool get isNeedDownload => switch (status) {
    WebDavAppSyncInfoStatus.server => true,
    WebDavAppSyncInfoStatus.local => false,
    WebDavAppSyncInfoStatus.both => eTagFromLocal != eTagFromServer,
  };

  @override
  bool get isNeedUpload => switch (status) {
    WebDavAppSyncInfoStatus.server => false,
    WebDavAppSyncInfoStatus.local => true,
    WebDavAppSyncInfoStatus.both =>
      includeDirtyMark || configUUID != lastConfgUUID,
  };
}

class WebDavResourceContainer {
  final Uri path;
  final String? etag;

  const WebDavResourceContainer({required this.path, this.etag});

  factory WebDavResourceContainer.fromResource(
    WebDavStdResource resource, {
    Uri? overridePath,
  }) {
    assert(resource.error == null);

    void checkProp(WebDavResourceProp prop) {
      if (prop.error != null) throw prop.error!;
      if (prop.status != HttpStatus.ok) {
        throw WebDavStdResError(
          "Resouce ${resource.path}'s "
          "${prop.namespace}:${prop.name} status error, "
          "prop=${prop.toDebugString()}",
        );
      }
    }

    final getetag = resource.getetag;
    if (getetag != null) checkProp(getetag);
    return WebDavResourceContainer(
      path: overridePath ?? resource.path,
      etag: resource.getetag?.value,
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

  HabitUUID? get groupUUID {
    final filename = path.pathSegments.lastOrNull;
    if (filename == null || filename.isEmpty) return null;
    return reAppSyncGroupFileName.firstMatch(filename)?.group(1);
  }

  @override
  String toString() => 'WebDavResourceContainer(path=$path, etag=<$etag>)';
}

abstract interface class WebDavConfigTaskChecklist {
  bool get needCreateHabitsDir;
  bool get needCreateWarningFile;
  bool get isEmptyDir;

  factory WebDavConfigTaskChecklist.dirChecker({
    required bool needCreateHabitsDir,
    required bool needCreateWarningFile,
  }) => switch ((needCreateHabitsDir, needCreateWarningFile)) {
    (true, true) => const WebDavConfigTaskChecklistDirImpl(
      needCreateHabitsDir: true,
      needCreateWarningFile: true,
    ),
    (_, _) => WebDavConfigTaskChecklistDirImpl(
      needCreateHabitsDir: needCreateHabitsDir,
      needCreateWarningFile: needCreateWarningFile,
    ),
  };
}

final class WebDavConfigTaskChecklistDirImpl
    implements WebDavConfigTaskChecklist {
  @override
  final bool needCreateHabitsDir;

  @override
  final bool needCreateWarningFile;

  const WebDavConfigTaskChecklistDirImpl({
    required this.needCreateHabitsDir,
    required this.needCreateWarningFile,
  });

  @override
  bool get isEmptyDir => needCreateHabitsDir && needCreateWarningFile;

  @override
  String toString() =>
      'WebDavConfigTaskChecklistDirImpl('
      'needCreateHabitsDir=$needCreateHabitsDir, '
      'needCreateReadme=$needCreateWarningFile'
      ')';
}

// #region habits
class WebDavSyncRecordKey {
  static const String recordDate = 'record_date';
  static const String recordType = 'record_type';
  static const String recordValue = 'record_value';
  static const String createT = 'create_t';
  static const String modifyT = 'modify_t';
  static const String uuid = 'uuid';
  static const String parentUUID = 'parent_uuid';
  static const String reason = 'reason';
  static const String sessionId = 'sessionId';
  static const String convertType = '_convert_type';
}

/// More model design refs:
/// [Server/Record](docs/webdav_sync_design.md#server)
@JsonSerializable(
  fieldRename: FieldRename.snake,
  includeIfNull: true,
  ignoreUnannotated: true,
)
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
  @JsonKey(name: WebDavSyncRecordKey.sessionId)
  final String? sessionId;

  final int? dirty;

  const WebDavSyncRecordData({
    this.recordDate,
    this.recordType,
    this.recordValue,
    this.createT,
    this.modifyT,
    this.uuid,
    this.parentUUID,
    this.reason,
    this.sessionId,
    this.dirty,
  });

  WebDavSyncRecordData.fromRecordDBCell(
    RecordDBCell cell, {
    this.dirty,
    this.sessionId,
  }) : recordDate = cell.recordDate,
       recordType = cell.recordType,
       recordValue = cell.recordValue,
       createT = cell.createT,
       modifyT = cell.modifyT,
       uuid = cell.uuid,
       parentUUID = cell.parentUUID,
       reason = cell.reason;

  factory WebDavSyncRecordData.fromJson(JsonMap json) {
    assert(
      json.isNotEmpty
          ? json[WebDavSyncRecordKey.convertType] == _convertType
          : true,
    );
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
  JsonMap toJson() =>
      _$WebDavSyncRecordDataToJson(this)
        ..[WebDavSyncRecordKey.convertType] = _convertType;

  SyncDBCell genSyncDBCell({String? configId}) => SyncDBCell(
    recordUUID: uuid,
    dirty: dirty ?? 0,
    lastMark: sessionId,
    lastConfigUUID: configId,
    lastSesionUUID: sessionId,
  );

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
  String toString() => "WebDavSyncRecordData${toJson()..['dirty'] = dirty}";
}

/// WebDAV sync keys. Mirrors color-related entries in [HabitDBCellKey]
/// (`lib/storage/db/handlers/habit.dart`) and `HabitExportDataKey`
/// (`lib/models/habit_export.dart`).
///
/// {@macro habit_color_keys_relationship}
///
/// Single source of truth for JSON keys; [WebDavSyncHabitKeys] derives from this.
class WebDavSyncHabitKey {
  static const String uuid = 'uuid';
  static const String createT = 'create_t';
  static const String modifyT = 'modify_t';
  static const String type = 'type';
  static const String status = 'status';
  static const String name = 'name';
  static const String desc = 'desc';
  static const String color = 'color';
  static const String customColor = 'custom_color';
  static const String customColorTinted = 'custom_color_tinted';
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
  static const String groupId = 'group_id';
  static const String sessionId = 'sessionId';
  static const String records = 'records';
  static const String convertType = '_convert_type';
  static const String schemaVersion = '_schema_version';
}

/// When adding a new sync-payload field, add a static const to
/// [WebDavSyncHabitKey] first, then add an enum entry here.
enum WebDavSyncHabitKeys {
  uuid(WebDavSyncHabitKey.uuid),
  createT(WebDavSyncHabitKey.createT),
  modifyT(WebDavSyncHabitKey.modifyT),
  type(WebDavSyncHabitKey.type),
  status(WebDavSyncHabitKey.status),
  name(WebDavSyncHabitKey.name),
  desc(WebDavSyncHabitKey.desc),
  color(WebDavSyncHabitKey.color),
  customColor(WebDavSyncHabitKey.customColor),
  customColorTinted(WebDavSyncHabitKey.customColorTinted),
  dailyGoal(WebDavSyncHabitKey.dailyGoal),
  dailyGoalUnit(WebDavSyncHabitKey.dailyGoalUnit),
  dailyGoalExtra(WebDavSyncHabitKey.dailyGoalExtra),
  freqType(WebDavSyncHabitKey.freqType),
  freqCustom(WebDavSyncHabitKey.freqCustom),
  reminder(WebDavSyncHabitKey.reminder),
  reminderQuest(WebDavSyncHabitKey.reminderQuest),
  startDate(WebDavSyncHabitKey.startDate),
  targetDays(WebDavSyncHabitKey.targetDays),
  sortPosition(WebDavSyncHabitKey.sortPosition),
  groupId(WebDavSyncHabitKey.groupId),
  sessionId(WebDavSyncHabitKey.sessionId),
  records(WebDavSyncHabitKey.records),
  convertType(WebDavSyncHabitKey.convertType),
  schemaVersion(WebDavSyncHabitKey.schemaVersion);

  const WebDavSyncHabitKeys(this.jsonKey);

  final String jsonKey;

  static final Set<String> allKnownKeys = Set.unmodifiable(
    WebDavSyncHabitKeys.values.map((e) => e.jsonKey),
  );
}

/// Sync-payload (wire) encoding of [HabitColor]: unlike [HabitColor.dbColorType],
/// a custom color encodes `color` as `null` rather than the `cc1` placeholder,
/// so the payload's color-range validation naturally skips custom colors.
/// This is a [WebDavSyncHabitData]-specific wire quirk, not a property of
/// [HabitColor] itself, so it stays local to this file.
extension on HabitColor {
  int? get _syncColorCode => switch (this) {
    BuiltInHabitColor(colorType: final t) => t.dbCode,
    CustomHabitColor() => null,
  };

  int? get _syncCustomColor => switch (this) {
    BuiltInHabitColor() => null,
    CustomHabitColor(argb: final a) => a,
  };

  int? get _syncCustomColorTinted => switch (this) {
    BuiltInHabitColor() => null,
    CustomHabitColor(tinted: final t) => t ? 1 : 0,
  };
}

/// More model design refs:
/// [Server/Habit](docs/webdav_sync_design.md#server)
@JsonSerializable(
  fieldRename: FieldRename.snake,
  includeIfNull: true,
  ignoreUnannotated: true,
)
@CopyWith(skipFields: true)
class WebDavSyncHabitData implements JsonAdaptor {
  static const _convertType = 'habit_';

  /// Bump this whenever this class's JSON field shape changes in a way that
  /// older clients need to distinguish (see
  /// docs/design/draft/20260619-webdav-sync-schema-version.md).
  static const int currentSchemaVersion = 2;

  @JsonKey(name: WebDavSyncHabitKey.schemaVersion, defaultValue: 1)
  final int schemaVersion;

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
  @JsonKey(name: WebDavSyncHabitKey.customColor)
  final int? customColor;
  @JsonKey(name: WebDavSyncHabitKey.customColorTinted)
  final int? customColorTinted;
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
  @JsonKey(name: WebDavSyncHabitKey.groupId)
  final String? groupId;
  @JsonKey(name: WebDavSyncHabitKey.sessionId)
  final String? sessionId;
  @JsonKey(
    name: WebDavSyncHabitKey.records,
    toJson: _recordsToJson,
    fromJson: _recordsFromJson,
  )
  final Map<HabitRecordUUID, WebDavSyncRecordData> records;

  final String? etag;
  final int? dirty;
  final int? dirtyTotal;

  /// Runtime bucket for JSON keys not recognized by the current schema.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic>? unknown;

  static List<List> _recordsToJson(
    Map<HabitRecordUUID, WebDavSyncRecordData> records,
  ) => const NormalizingListConverter().toJson(
    records.values.map((e) => e.toJson()),
  );

  static Map<HabitRecordUUID, WebDavSyncRecordData> _recordsFromJson(
    List json,
  ) => Map.fromEntries(
    const NormalizingListConverter()
        .fromJson(json.map((e) => e as List).toList())
        .map((e) => WebDavSyncRecordData.fromJson(Map.of(e)))
        .map((e) => e.uuid != null ? MapEntry(e.uuid!, e) : null)
        .nonNulls,
  );

  WebDavSyncHabitData({
    this.schemaVersion = 1,
    this.uuid,
    this.createT,
    this.modifyT,
    this.type,
    this.status,
    this.name,
    this.desc,
    this.color,
    this.customColor,
    this.customColorTinted,
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
    this.groupId,
    this.sessionId,
    this.records = const {},
    this.etag,
    this.dirty,
    this.dirtyTotal,
  });

  factory WebDavSyncHabitData.fromHabitDBCell(
    HabitDBCell cell, {
    String? etag,
    int? dirty,
    int? dirtyTotal,
    String? sessionId,
    Map<HabitRecordUUID, WebDavSyncRecordData> records = const {},
    Map<String, dynamic>? unknown,
  }) {
    final habitColor = HabitColor.fromRaw(
      colorType: cell.customColor != null
          ? HabitColorType.cc1
          : HabitColorType.getFromDBCode(cell.color!)!,
      customColor: cell.customColor,
      customColorTinted: cell.customColorTinted,
    );
    final data = WebDavSyncHabitData(
      schemaVersion: currentSchemaVersion,
      uuid: cell.uuid,
      createT: cell.createT,
      modifyT: cell.modifyT,
      type: cell.type,
      status: cell.status,
      name: cell.name,
      desc: cell.desc,
      color: habitColor._syncColorCode,
      customColor: habitColor._syncCustomColor,
      customColorTinted: habitColor._syncCustomColorTinted,
      dailyGoal: cell.dailyGoal,
      dailyGoalUnit: cell.dailyGoalUnit,
      dailyGoalExtra: cell.dailyGoalExtra,
      freqType: cell.freqType,
      freqCustom: cell.freqCustom,
      reminder: cell.remindCustom,
      reminderQuest: cell.remindQuestion,
      startDate: cell.startDate,
      targetDays: cell.targetDays,
      sortPostion: cell.sortPosition,
      groupId: cell.groupId,
      etag: etag,
      dirty: dirty,
      dirtyTotal: dirtyTotal,
      sessionId: sessionId,
      records: records,
    );
    if (unknown != null && unknown.isNotEmpty) {
      data.unknown = unknown;
    }
    return data;
  }

  factory WebDavSyncHabitData.fromJson(JsonMap json) {
    assert(
      json.isNotEmpty
          ? json[WebDavSyncHabitKey.convertType] == _convertType
          : true,
    );
    final data = _$WebDavSyncHabitDataFromJson(json);
    data.unknown = captureSyncUnknown(json, WebDavSyncHabitKeys.allKnownKeys);
    return data;
  }

  HabitDBCell toHabitDBCell() {
    // Sync payload may lack color; fall back to cc1 to avoid null crash.
    final habitColor = HabitColor.fromRaw(
      colorType: customColor != null
          ? HabitColorType.cc1
          : HabitColorType.getFromDBCode(color ?? HabitColorType.cc1.dbCode)!,
      customColor: customColor,
      customColorTinted: customColorTinted,
    );
    return HabitDBCell(
      uuid: uuid,
      createT: createT,
      modifyT: modifyT,
      type: type,
      status: status,
      name: name,
      desc: desc,
      color: habitColor.dbColorType.dbCode,
      customColor: habitColor.dbCustomColor,
      customColorTinted: habitColor.dbCustomColorTinted,
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
      groupId: groupId,
      syncExtras: encodeSyncExtras(unknown),
    );
  }

  @override
  JsonMap toJson() {
    final json = _$WebDavSyncHabitDataToJson(this)
      ..[WebDavSyncHabitKey.convertType] = _convertType;
    if (schemaVersion <= 1) json.remove(WebDavSyncHabitKey.schemaVersion);
    mergeSyncUnknown(json, unknown);
    return json;
  }

  SyncDBCell genSyncDBCell({String? configId}) => SyncDBCell(
    habitUUID: uuid,
    dirty: dirty ?? 0,
    dirtyTotal: dirtyTotal ?? 0,
    lastMark: sessionId,
    lastMark2: etag,
    lastConfigUUID: configId,
    lastSesionUUID: sessionId,
  );

  void validate() {
    if (type != null && HabitType.getFromDBCode(type!) == HabitType.unknown) {
      throw TypeError();
    }
    if (color != null &&
        HabitColorType.getFromDBCode(color!, withDefault: null) == null) {
      throw TypeError();
    }
    if (freqType != null) {
      HabitFrequency.fromJson({
        "type": freqType!,
        "args": jsonDecode(freqCustom!),
      });
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
    for (var record in records.values) {
      record.validated();
    }
  }

  @override
  String toString() =>
      "WebDavSyncHabitData${toJson()
        ..['etag'] = etag
        ..['dirty'] = dirty
        ..['dirtyTotal'] = dirtyTotal
        ..['records'] = '...(length=${records.length})'}";
}

class WebDavAppSyncHabitInfo extends _WebDavAppSyncCellInfo {
  final HabitUUID uuid;

  WebDavAppSyncHabitInfo({
    required super.configUUID,
    required this.uuid,
    required super.status,
    super.isDirty = false,
  });

  @override
  String toString() =>
      "WebDavAppSyncCellInfo(uuid=$uuid, status=$status, "
      "sEtag=<$eTagFromServer>, cEtag=<$eTagFromLocal>, "
      "configId=$configUUID, lastConfigId=$lastConfgUUID, "
      "spath=$serverPath"
      ")";
}
// #endregion

// #region group
class WebDavAppSyncGroupInfo extends _WebDavAppSyncCellInfo {
  final HabitUUID uuid;

  WebDavAppSyncGroupInfo({
    required super.configUUID,
    required this.uuid,
    required super.status,
    super.isDirty = false,
  });
}

class WebDavSyncGroupKey {
  static const String uuid = 'uuid';
  static const String createT = 'create_t';
  static const String modifyT = 'modify_t';
  static const String name = 'name';
  static const String desc = 'desc';
  static const String icon = 'icon';
  static const String color = 'color';
  static const String customColor = 'custom_color';
  static const String customColorTinted = 'custom_color_tinted';
  static const String status = 'status';
  static const String sessionId = 'sessionId';
  static const String schemaVersion = '_schema_version';
  static const String convertType = '_convert_type';
}

enum WebDavSyncGroupKeys {
  uuid(WebDavSyncGroupKey.uuid),
  createT(WebDavSyncGroupKey.createT),
  modifyT(WebDavSyncGroupKey.modifyT),
  name(WebDavSyncGroupKey.name),
  desc(WebDavSyncGroupKey.desc),
  icon(WebDavSyncGroupKey.icon),
  color(WebDavSyncGroupKey.color),
  customColor(WebDavSyncGroupKey.customColor),
  customColorTinted(WebDavSyncGroupKey.customColorTinted),
  status(WebDavSyncGroupKey.status),
  sessionId(WebDavSyncGroupKey.sessionId),
  schemaVersion(WebDavSyncGroupKey.schemaVersion),
  convertType(WebDavSyncGroupKey.convertType);

  final String jsonKey;
  const WebDavSyncGroupKeys(this.jsonKey);

  static final Set<String> allKnownKeys = Set.unmodifiable(
    WebDavSyncGroupKeys.values.map((e) => e.jsonKey),
  );
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  includeIfNull: true,
  ignoreUnannotated: true,
)
@CopyWith(skipFields: true)
class WebDavSyncGroupData implements JsonAdaptor {
  static const _convertType = 'group_';
  static const int currentSchemaVersion = 1;

  @JsonKey(
    name: WebDavSyncGroupKey.schemaVersion,
    defaultValue: currentSchemaVersion,
  )
  final int schemaVersion;
  @JsonKey(name: WebDavSyncGroupKey.uuid)
  final String? uuid;
  @JsonKey(name: WebDavSyncGroupKey.createT)
  final int? createT;
  @JsonKey(name: WebDavSyncGroupKey.modifyT)
  final int? modifyT;
  @JsonKey(name: WebDavSyncGroupKey.name)
  final String? name;
  @JsonKey(name: WebDavSyncGroupKey.desc)
  final String? desc;
  @JsonKey(name: WebDavSyncGroupKey.icon)
  final int? icon;
  @JsonKey(name: WebDavSyncGroupKey.color)
  final int? color;
  @JsonKey(name: WebDavSyncGroupKey.customColor)
  final int? customColor;
  @JsonKey(name: WebDavSyncGroupKey.customColorTinted)
  final int? customColorTinted;
  @JsonKey(name: WebDavSyncGroupKey.status)
  final int? status;
  @JsonKey(name: WebDavSyncGroupKey.sessionId)
  final String? sessionId;

  final String? etag;
  final int? dirty;
  final int? dirtyTotal;

  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic>? unknown;

  WebDavSyncGroupData({
    this.schemaVersion = currentSchemaVersion,
    this.uuid,
    this.createT,
    this.modifyT,
    this.name,
    this.desc,
    this.icon,
    this.color,
    this.customColor,
    this.customColorTinted,
    this.status,
    this.sessionId,
    this.etag,
    this.dirty,
    this.dirtyTotal,
    this.unknown,
  });

  /// Constructs [WebDavSyncGroupData] from a [GroupDBCell].
  ///
  /// Color encoding reuses the HabitColor sync codec extensions
  /// (`_syncColorCode` / `_syncCustomColor` / `_syncCustomColorTinted`).
  /// When the group has no color (both [GroupDBCell.color] and
  /// [GroupDBCell.customColor] are `null`), all three wire color fields
  /// are left `null` — groups may legitimately have no color, unlike habits.
  factory WebDavSyncGroupData.fromGroupDBCell(
    GroupDBCell cell, {
    String? etag,
    int? dirty,
    int? dirtyTotal,
    String? sessionId,
    Map<String, dynamic>? unknown,
  }) {
    final groupColor = cell.color == null && cell.customColor == null
        ? null
        : HabitColor.fromRaw(
            colorType: cell.customColor != null
                ? HabitColorType.cc1
                : HabitColorType.getFromDBCode(cell.color!)!,
            customColor: cell.customColor,
            customColorTinted: cell.customColorTinted,
          );
    return WebDavSyncGroupData(
      schemaVersion: currentSchemaVersion,
      uuid: cell.uuid,
      createT: cell.createT,
      modifyT: cell.modifyT,
      name: cell.name,
      desc: cell.desc,
      icon: cell.icon,
      color: groupColor?._syncColorCode,
      customColor: groupColor?._syncCustomColor,
      customColorTinted: groupColor?._syncCustomColorTinted,
      status: cell.status,
      sessionId: sessionId,
      etag: etag,
      dirty: dirty,
      dirtyTotal: dirtyTotal,
    );
  }

  /// Deserializes Group sync data from JSON.
  ///
  /// Uses [captureSyncUnknown] to capture unknown fields, ensuring round-trip compatibility.
  factory WebDavSyncGroupData.fromJson(JsonMap json) {
    final data = _$WebDavSyncGroupDataFromJson(json);
    data.unknown = captureSyncUnknown(json, WebDavSyncGroupKeys.allKnownKeys);
    return data;
  }

  /// Converts to [GroupDBCell] for writing to the local DB.
  GroupDBCell toGroupDBCell() {
    final groupColor = color == null && customColor == null
        ? null
        : HabitColor.fromRaw(
            colorType: customColor != null
                ? HabitColorType.cc1
                : HabitColorType.getFromDBCode(color!)!,
            customColor: customColor,
            customColorTinted: customColorTinted,
          );
    return GroupDBCell(
      uuid: uuid,
      createT: createT,
      modifyT: modifyT,
      name: name,
      desc: desc,
      icon: icon,
      color: groupColor?.dbColorType.dbCode,
      customColor: groupColor?.dbCustomColor,
      customColorTinted: groupColor?.dbCustomColorTinted,
      status: status,
    );
  }

  /// Serializes to JSON for upload to WebDAV.
  @override
  JsonMap toJson() {
    final json = _$WebDavSyncGroupDataToJson(this)
      ..[WebDavSyncGroupKey.convertType] = _convertType;
    mergeSyncUnknown(json, unknown);
    return json;
  }

  /// Produces a [SyncDBCell] for the mh_sync table.
  SyncDBCell genSyncDBCell({String? configId}) => SyncDBCell(
    groupUUID: uuid,
    dirty: dirty ?? 0,
    dirtyTotal: dirtyTotal ?? 0,
    lastMark: sessionId,
    lastMark2: etag,
    lastConfigUUID: configId,
    lastSesionUUID: sessionId,
  );

  /// Data validation.
  ///
  /// Does not enforce non-empty name at this layer -- empty names are allowed
  /// to align with Habit behavior. Empty-name interception is handled at the
  /// GUI and GroupManager business layer.
  void validate() {
    // Schema version check (reserved)
    // Name etc. not validated at data layer
  }
}
// #endregion

class WebDavAppSyncPathBuilder {
  final Uri root;

  final Uri habitsDir;
  final Uri warningFile;

  static Uri _buildPath(Uri root, String path, {bool isDir = false}) {
    return root.replace(
      pathSegments: [
        ...root.pathSegments.where((e) => e.isNotEmpty),
        path,
        if (isDir) '',
      ],
    );
  }

  WebDavAppSyncPathBuilder(Uri root)
    : root = _buildPath(root, '', isDir: true),
      habitsDir = _buildPath(root, 'habits', isDir: true),
      warningFile = _buildPath(
        root,
        '!!!_WARNING_DO_NOT_MODIFY_BY_HAND_!!!',
        isDir: false,
      );

  WebDavAppSyncHabitPathBuilder habit(HabitUUID uuid) =>
      WebDavAppSyncHabitPathBuilder(uuid, habitsDir);

  /// Group file path builder.
  ///
  /// Group JSON files live under /habits/ with the naming convention
  /// group-{uuid}.json, co-located with habit-{uuid}.json.
  Uri group(HabitUUID uuid) => habitsDir.resolve('group-$uuid.json');
}

class WebDavAppSyncHabitPathBuilder {
  final HabitUUID uuid;
  final Uri habitsDir;

  final Uri habitFile;

  static Uri _buildHabitFile(Uri base, HabitUUID uuid) {
    return base.replace(
      pathSegments: [
        ...base.pathSegments.where((e) => e.isNotEmpty),
        'habit-$uuid.json',
      ],
    );
  }

  WebDavAppSyncHabitPathBuilder(this.uuid, this.habitsDir)
    : habitFile = _buildHabitFile(habitsDir, uuid);
}

@Proxy(HttpClient, useAnnotatedName: true)
class HttpClientForWebDav extends _$HttpClientForWebDavProxy {
  final RetryOptions? connectRetryOptions;

  WeakReference<AppSyncTask>? _context;

  HttpClientForWebDav({this.connectRetryOptions}) : super(HttpClient());

  HttpClientForWebDav.fromClient(super.base, {this.connectRetryOptions});

  AppSyncTask? get context => _context?.target;

  set context(AppSyncTask? newContext) =>
      _context = (newContext != null ? WeakReference(newContext) : null);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    final connectRetryOptions = this.connectRetryOptions;
    if (connectRetryOptions == null) {
      return super
          .openUrl(method, url)
          .then(
            (request) => HttpClientRequestWebDav(
              request,
              context,
              connectRetryOptions: connectRetryOptions,
            ),
          );
    }

    final warningRetryCount = connectRetryOptions.maxAttempts ~/ 2;
    var crtRetryCount = 0;
    var needRetry = true;
    return connectRetryOptions.retry(
      () => super
          .openUrl(method, url)
          .then(
            (request) => HttpClientRequestWebDav(
              request,
              context,
              connectRetryOptions: connectRetryOptions,
            ),
          ),
      retryIf: (e) =>
          needRetry && (e is SocketException || e is TimeoutException),
      onRetry: (e) {
        if (context?.isCancalling == true) {
          needRetry = false;
          return;
        }
        crtRetryCount += 1;
        if (crtRetryCount >= warningRetryCount) {
          appLog.network.warn(
            "HttpClientForWebDav.openUrl",
            ex: ["retry", crtRetryCount, method, url],
            error: e,
          );
        } else {
          appLog.network.info(
            "HttpClientForWebDav.openUrl",
            ex: ["retry", crtRetryCount, method, url, e],
          );
        }
      },
    );
  }
}

@Proxy(HttpClientRequest, useAnnotatedName: true)
class HttpClientRequestWebDav extends _$HttpClientRequestWebDavProxy {
  final RetryOptions? connectRetryOptions;

  WeakReference<AppSyncTask>? _context;

  HttpClientRequestWebDav(
    super.base,
    AppSyncTask? context, {
    this.connectRetryOptions,
  }) {
    this.context = context;
  }

  AppSyncTask? get context => _context?.target;

  set context(AppSyncTask? newContext) =>
      _context = (newContext != null ? WeakReference(newContext) : null);

  @override
  Future<HttpClientResponse> close() {
    final connectRetryOptions = this.connectRetryOptions;
    if (connectRetryOptions == null) return super.close();
    final warningRetryCount = connectRetryOptions.maxAttempts ~/ 2;
    var crtRetryCount = 0;
    var needRetry = true;
    return connectRetryOptions.retry(
      () => super.close(),
      retryIf: (e) =>
          needRetry && (e is SocketException || e is TimeoutException),
      onRetry: (e) {
        if (context?.isCancalling == true) {
          needRetry = false;
          return;
        }
        crtRetryCount += 1;
        if (crtRetryCount >= warningRetryCount) {
          appLog.network.warn(
            "HttpClientRequestWebDav.close",
            ex: ["retry", crtRetryCount, method, uri, headers],
            error: e,
          );
        } else {
          appLog.network.info(
            "HttpClientRequestWebDav.close",
            ex: ["retry", crtRetryCount, method, uri, headers, e],
          );
        }
      },
    );
  }
}

abstract interface class WebDavProgressController {
  void onHabitComplete(HabitUUID uuid);
  bool initHabitProgress(Iterable<HabitUUID> habits, {bool override = false});
  void clearHabitProgress();

  factory WebDavProgressController({
    void Function(num? percentage)? onPercentageChanged,
  }) => WebDavProgressControllerImpl(onPercentageChanged: onPercentageChanged);
}

final class WebDavProgressControllerImpl implements WebDavProgressController {
  final habitProgressMap = <HabitUUID, ProgressPercentChanger>{};
  ProgressPercent? habitProgress;

  final void Function(num? percentage)? onPercentageChanged;

  WebDavProgressControllerImpl({this.onPercentageChanged});

  num? get percentage => habitProgress?.percentage;

  @override
  void onHabitComplete(HabitUUID uuid) {
    final habitProgress = this.habitProgress;
    if (habitProgress == null) return;
    habitProgressMap[uuid]?.toComplete();
    onPercentageChanged?.call(percentage);
  }

  @override
  bool initHabitProgress(Iterable<HabitUUID> habits, {bool override = false}) {
    if (habitProgress != null && !override) return false;
    final entries = habits
        .map((e) => MapEntry(e, ProgressPercentChanger()))
        .toList();
    habitProgressMap
      ..clear()
      ..addEntries(entries);
    habitProgress = ProgressPercent.merge(entries.map((e) => e.value));
    onPercentageChanged?.call(percentage);
    return true;
  }

  @override
  void clearHabitProgress() {
    habitProgressMap.clear();
    habitProgress = null;
    onPercentageChanged?.call(percentage);
  }
}

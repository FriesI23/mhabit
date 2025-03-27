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
import 'package:retry/retry.dart';
import 'package:simple_webdav_client/dav.dart';
import 'package:simple_webdav_client/error.dart';

import '../../annotation/proxy_annotation.dart';
import '../../common/types.dart';
import '../../extension/webdav_extensions.dart';
import '../../logging/helper.dart';
import '../../persistent/local/handler/habit.dart';
import '../../persistent/local/handler/record.dart';
import '../../persistent/local/handler/sync.dart';
import '../common.dart';
import '../habit_form.dart';
import '../habit_freq.dart';
import '../habit_reminder.dart';
import '../progress_percent.dart';
import 'app_sync_task.dart';

part 'webdav_app_sync_models.g.dart';

final reAppSyncHabitFileName = RegExp(r'^habit-([^/]+)\.json$');
final reAppSyncHabitRecordRootDirName = RegExp(r'^habit-([^/]+)$');
final reAppSyncRecordDirName = RegExp(r'^\d{4}$');
final reAppSyncRecordFileName = RegExp(r'^record-([^/]+)\.json$');

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

  _WebDavAppSyncCellInfo(
      {required this.configUUID,
      required bool isDirty,
      required WebDavAppSyncInfoStatus status})
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
  bool get isNeedDownload => switch (status) {
        WebDavAppSyncInfoStatus.server => true,
        WebDavAppSyncInfoStatus.local => false,
        WebDavAppSyncInfoStatus.both => eTagFromLocal != eTagFromServer,
      };

  @override
  bool get isNeedUpload => switch (status) {
        WebDavAppSyncInfoStatus.server => false,
        WebDavAppSyncInfoStatus.local => true,
        WebDavAppSyncInfoStatus.both => includeDirtyMark ||
            configUUID != lastConfgUUID ||
            eTagFromLocal == null,
      };
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
  String toString() => "WebDavAppSyncCellInfo(uuid=$uuid, status=$status, "
      "sEtag=<$eTagFromServer>, cEtag=<$eTagFromLocal>, "
      "configId=$configUUID, lastConfigId=$lastConfgUUID, "
      "spath=$serverPath"
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

abstract interface class WebDavConfigTaskChecklist {
  bool get needCreateHabitsDir;
  bool get needCreateWarningFile;
  bool get isEmptyDir;

  factory WebDavConfigTaskChecklist.dirChecker(
          {required bool needCreateHabitsDir,
          required bool needCreateWarningFile}) =>
      switch ((needCreateHabitsDir, needCreateWarningFile)) {
        (true, true) => const WebDavConfigTaskChecklistDirImpl(
            needCreateHabitsDir: true, needCreateWarningFile: true),
        (_, _) => WebDavConfigTaskChecklistDirImpl(
            needCreateHabitsDir: needCreateHabitsDir,
            needCreateWarningFile: needCreateWarningFile)
      };
}

final class WebDavConfigTaskChecklistDirImpl
    implements WebDavConfigTaskChecklist {
  @override
  final bool needCreateHabitsDir;

  @override
  final bool needCreateWarningFile;

  const WebDavConfigTaskChecklistDirImpl(
      {required this.needCreateHabitsDir, required this.needCreateWarningFile});

  @override
  bool get isEmptyDir => needCreateHabitsDir && needCreateWarningFile;

  @override
  String toString() => 'WebDavConfigTaskChecklistDirImpl('
      'needCreateHabitsDir=$needCreateHabitsDir, '
      'needCreateReadme=$needCreateWarningFile'
      ')';
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
  static const String sessionId = 'sessionId';
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

  WebDavSyncRecordData.fromRecordDBCell(RecordDBCell cell,
      {this.dirty, this.sessionId})
      : recordDate = cell.recordDate,
        recordType = cell.recordType,
        recordValue = cell.recordValue,
        createT = cell.createT,
        modifyT = cell.modifyT,
        uuid = cell.uuid,
        parentUUID = cell.parentUUID,
        reason = cell.reason;

  factory WebDavSyncRecordData.fromJson(JsonMap json) {
    assert(json.isNotEmpty
        ? json[WebDavSyncHabitKey.convertType] == _convertType
        : true);
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

  SyncDBCell genSyncDBCell({String? configId}) => SyncDBCell(
      recordUUID: uuid,
      dirty: dirty ?? 0,
      lastMark: sessionId,
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
  String toString() => "WebDavSyncRecordData${toJson()..['dirty'] = dirty}";
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
  static const String sessionId = 'sessionId';
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
  @JsonKey(name: WebDavSyncHabitKey.sessionId)
  final String? sessionId;
  @JsonKey(
      name: WebDavSyncHabitKey.records,
      toJson: _recordsToJson,
      fromJson: _recordsFromJson)
  final Map<HabitRecordUUID, WebDavSyncRecordData> records;

  final String? etag;
  final int? dirty;

  static List<JsonMap> _recordsToJson(
          Map<HabitRecordUUID, WebDavSyncRecordData> records) =>
      records.values.map((e) => e.toJson()).toList();

  static Map<HabitRecordUUID, WebDavSyncRecordData> _recordsFromJson(
          List json) =>
      Map.fromEntries(json
          .map((e) => WebDavSyncRecordData.fromJson(Map.of(e)))
          .map((e) => e.uuid != null ? MapEntry(e.uuid!, e) : null)
          .whereNotNull());

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
    this.sessionId,
    this.records = const {},
    this.etag,
    this.dirty,
  });

  WebDavSyncHabitData.fromHabitDBCell(HabitDBCell cell,
      {this.etag, this.dirty, this.sessionId, this.records = const {}})
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
    assert(json.isNotEmpty
        ? json[WebDavSyncHabitKey.convertType] == _convertType
        : true);
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

  SyncDBCell genSyncDBCell({String? configId}) => SyncDBCell(
      habitUUID: uuid,
      dirty: dirty ?? 0,
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
    for (var record in records.values) {
      record.validated();
    }
  }

  @override
  String toString() => "WebDavSyncHabitData${toJson()
    ..['etag'] = etag
    ..['dirty'] = dirty
    ..['records'] = '...(length=${records.length})'}";
}

class WebDavAppSyncPathBuilder {
  final Uri root;

  final Uri habitsDir;
  final Uri warningFile;

  static Uri _buildPath(Uri root, String path, {bool isDir = false}) {
    return root.replace(pathSegments: [
      ...root.pathSegments.where((e) => e.isNotEmpty),
      path,
      if (isDir) ''
    ]);
  }

  WebDavAppSyncPathBuilder(Uri root)
      : root = _buildPath(root, '', isDir: true),
        habitsDir = _buildPath(root, 'habits', isDir: true),
        warningFile = _buildPath(root, '!!!_WARNING_DO_NOT_MODIFY_BY_HAND_!!!',
            isDir: false);

  WebDavAppSyncHabitPathBuilder habit(HabitUUID uuid) =>
      WebDavAppSyncHabitPathBuilder(uuid, habitsDir);
}

class WebDavAppSyncHabitPathBuilder {
  final HabitUUID uuid;
  final Uri habitsDir;

  final Uri habitFile;

  static Uri _buildHabitFile(Uri base, HabitUUID uuid) {
    return base.replace(pathSegments: [
      ...base.pathSegments.where((e) => e.isNotEmpty),
      'habit-$uuid.json'
    ]);
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
      return super.openUrl(method, url).then((request) =>
          HttpClientRequestWebDav(request, context,
              connectRetryOptions: connectRetryOptions));
    }

    final warningRetryCount = connectRetryOptions.maxAttempts ~/ 2;
    var crtRetryCount = 0;
    var needRetry = true;
    return connectRetryOptions.retry(
      () => super.openUrl(method, url).then((request) =>
          HttpClientRequestWebDav(request, context,
              connectRetryOptions: connectRetryOptions)),
      retryIf: (e) =>
          needRetry && (e is SocketException || e is TimeoutException),
      onRetry: (e) {
        if (context?.isCancalling == true) {
          needRetry = false;
          return;
        }
        crtRetryCount += 1;
        if (crtRetryCount >= warningRetryCount) {
          appLog.network.warn("HttpClientForWebDav.openUrl",
              ex: ["retry", crtRetryCount, method, url], error: e);
        } else {
          appLog.network.info("HttpClientForWebDav.openUrl",
              ex: ["retry", crtRetryCount, method, url, e]);
        }
      },
    );
  }
}

@Proxy(HttpClientRequest, useAnnotatedName: true)
class HttpClientRequestWebDav extends _$HttpClientRequestWebDavProxy {
  final RetryOptions? connectRetryOptions;

  WeakReference<AppSyncTask>? _context;

  HttpClientRequestWebDav(super.base, AppSyncTask? context,
      {this.connectRetryOptions}) {
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
          appLog.network.warn("HttpClientRequestWebDav.close",
              ex: ["retry", crtRetryCount, method, uri, headers], error: e);
        } else {
          appLog.network.info("HttpClientRequestWebDav.close",
              ex: ["retry", crtRetryCount, method, uri, headers, e]);
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
  }) =>
      WebDavProgressControllerImpl(onPercentageChanged: onPercentageChanged);
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
    final entries =
        habits.map((e) => MapEntry(e, ProgressPercentChanger())).toList();
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

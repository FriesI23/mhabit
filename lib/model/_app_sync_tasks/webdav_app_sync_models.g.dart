// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webdav_app_sync_models.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WebDavSyncRecordDataCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// WebDavSyncRecordData(...).copyWith(id: 12, name: "My name")
  /// ````
  WebDavSyncRecordData call({
    int? recordDate,
    int? recordType,
    num? recordValue,
    int? createT,
    int? modifyT,
    String? uuid,
    String? parentUUID,
    String? reason,
    String? sessionId,
    String? etag,
    int? dirty,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWebDavSyncRecordData.copyWith(...)`.
class _$WebDavSyncRecordDataCWProxyImpl
    implements _$WebDavSyncRecordDataCWProxy {
  const _$WebDavSyncRecordDataCWProxyImpl(this._value);

  final WebDavSyncRecordData _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// WebDavSyncRecordData(...).copyWith(id: 12, name: "My name")
  /// ````
  WebDavSyncRecordData call({
    Object? recordDate = const $CopyWithPlaceholder(),
    Object? recordType = const $CopyWithPlaceholder(),
    Object? recordValue = const $CopyWithPlaceholder(),
    Object? createT = const $CopyWithPlaceholder(),
    Object? modifyT = const $CopyWithPlaceholder(),
    Object? uuid = const $CopyWithPlaceholder(),
    Object? parentUUID = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? etag = const $CopyWithPlaceholder(),
    Object? dirty = const $CopyWithPlaceholder(),
  }) {
    return WebDavSyncRecordData(
      recordDate: recordDate == const $CopyWithPlaceholder()
          ? _value.recordDate
          // ignore: cast_nullable_to_non_nullable
          : recordDate as int?,
      recordType: recordType == const $CopyWithPlaceholder()
          ? _value.recordType
          // ignore: cast_nullable_to_non_nullable
          : recordType as int?,
      recordValue: recordValue == const $CopyWithPlaceholder()
          ? _value.recordValue
          // ignore: cast_nullable_to_non_nullable
          : recordValue as num?,
      createT: createT == const $CopyWithPlaceholder()
          ? _value.createT
          // ignore: cast_nullable_to_non_nullable
          : createT as int?,
      modifyT: modifyT == const $CopyWithPlaceholder()
          ? _value.modifyT
          // ignore: cast_nullable_to_non_nullable
          : modifyT as int?,
      uuid: uuid == const $CopyWithPlaceholder()
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String?,
      parentUUID: parentUUID == const $CopyWithPlaceholder()
          ? _value.parentUUID
          // ignore: cast_nullable_to_non_nullable
          : parentUUID as String?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String?,
      etag: etag == const $CopyWithPlaceholder()
          ? _value.etag
          // ignore: cast_nullable_to_non_nullable
          : etag as String?,
      dirty: dirty == const $CopyWithPlaceholder()
          ? _value.dirty
          // ignore: cast_nullable_to_non_nullable
          : dirty as int?,
    );
  }
}

extension $WebDavSyncRecordDataCopyWith on WebDavSyncRecordData {
  /// Returns a callable class that can be used as follows: `instanceOfWebDavSyncRecordData.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$WebDavSyncRecordDataCWProxy get copyWith =>
      _$WebDavSyncRecordDataCWProxyImpl(this);
}

abstract class _$WebDavSyncHabitDataCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// WebDavSyncHabitData(...).copyWith(id: 12, name: "My name")
  /// ````
  WebDavSyncHabitData call({
    String? uuid,
    int? createT,
    int? modifyT,
    int? type,
    int? status,
    String? name,
    String? desc,
    int? color,
    num? dailyGoal,
    String? dailyGoalUnit,
    num? dailyGoalExtra,
    int? freqType,
    String? freqCustom,
    String? reminder,
    String? reminderQuest,
    int? startDate,
    int? targetDays,
    num? sortPostion,
    String? sessionId,
    List<WebDavSyncRecordData>? records,
    String? etag,
    int? dirty,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWebDavSyncHabitData.copyWith(...)`.
class _$WebDavSyncHabitDataCWProxyImpl implements _$WebDavSyncHabitDataCWProxy {
  const _$WebDavSyncHabitDataCWProxyImpl(this._value);

  final WebDavSyncHabitData _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// WebDavSyncHabitData(...).copyWith(id: 12, name: "My name")
  /// ````
  WebDavSyncHabitData call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? createT = const $CopyWithPlaceholder(),
    Object? modifyT = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? desc = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? dailyGoal = const $CopyWithPlaceholder(),
    Object? dailyGoalUnit = const $CopyWithPlaceholder(),
    Object? dailyGoalExtra = const $CopyWithPlaceholder(),
    Object? freqType = const $CopyWithPlaceholder(),
    Object? freqCustom = const $CopyWithPlaceholder(),
    Object? reminder = const $CopyWithPlaceholder(),
    Object? reminderQuest = const $CopyWithPlaceholder(),
    Object? startDate = const $CopyWithPlaceholder(),
    Object? targetDays = const $CopyWithPlaceholder(),
    Object? sortPostion = const $CopyWithPlaceholder(),
    Object? sessionId = const $CopyWithPlaceholder(),
    Object? records = const $CopyWithPlaceholder(),
    Object? etag = const $CopyWithPlaceholder(),
    Object? dirty = const $CopyWithPlaceholder(),
  }) {
    return WebDavSyncHabitData(
      uuid: uuid == const $CopyWithPlaceholder()
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String?,
      createT: createT == const $CopyWithPlaceholder()
          ? _value.createT
          // ignore: cast_nullable_to_non_nullable
          : createT as int?,
      modifyT: modifyT == const $CopyWithPlaceholder()
          ? _value.modifyT
          // ignore: cast_nullable_to_non_nullable
          : modifyT as int?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as int?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as int?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      desc: desc == const $CopyWithPlaceholder()
          ? _value.desc
          // ignore: cast_nullable_to_non_nullable
          : desc as String?,
      color: color == const $CopyWithPlaceholder()
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as int?,
      dailyGoal: dailyGoal == const $CopyWithPlaceholder()
          ? _value.dailyGoal
          // ignore: cast_nullable_to_non_nullable
          : dailyGoal as num?,
      dailyGoalUnit: dailyGoalUnit == const $CopyWithPlaceholder()
          ? _value.dailyGoalUnit
          // ignore: cast_nullable_to_non_nullable
          : dailyGoalUnit as String?,
      dailyGoalExtra: dailyGoalExtra == const $CopyWithPlaceholder()
          ? _value.dailyGoalExtra
          // ignore: cast_nullable_to_non_nullable
          : dailyGoalExtra as num?,
      freqType: freqType == const $CopyWithPlaceholder()
          ? _value.freqType
          // ignore: cast_nullable_to_non_nullable
          : freqType as int?,
      freqCustom: freqCustom == const $CopyWithPlaceholder()
          ? _value.freqCustom
          // ignore: cast_nullable_to_non_nullable
          : freqCustom as String?,
      reminder: reminder == const $CopyWithPlaceholder()
          ? _value.reminder
          // ignore: cast_nullable_to_non_nullable
          : reminder as String?,
      reminderQuest: reminderQuest == const $CopyWithPlaceholder()
          ? _value.reminderQuest
          // ignore: cast_nullable_to_non_nullable
          : reminderQuest as String?,
      startDate: startDate == const $CopyWithPlaceholder()
          ? _value.startDate
          // ignore: cast_nullable_to_non_nullable
          : startDate as int?,
      targetDays: targetDays == const $CopyWithPlaceholder()
          ? _value.targetDays
          // ignore: cast_nullable_to_non_nullable
          : targetDays as int?,
      sortPostion: sortPostion == const $CopyWithPlaceholder()
          ? _value.sortPostion
          // ignore: cast_nullable_to_non_nullable
          : sortPostion as num?,
      sessionId: sessionId == const $CopyWithPlaceholder()
          ? _value.sessionId
          // ignore: cast_nullable_to_non_nullable
          : sessionId as String?,
      records: records == const $CopyWithPlaceholder() || records == null
          ? _value.records
          // ignore: cast_nullable_to_non_nullable
          : records as List<WebDavSyncRecordData>,
      etag: etag == const $CopyWithPlaceholder()
          ? _value.etag
          // ignore: cast_nullable_to_non_nullable
          : etag as String?,
      dirty: dirty == const $CopyWithPlaceholder()
          ? _value.dirty
          // ignore: cast_nullable_to_non_nullable
          : dirty as int?,
    );
  }
}

extension $WebDavSyncHabitDataCopyWith on WebDavSyncHabitData {
  /// Returns a callable class that can be used as follows: `instanceOfWebDavSyncHabitData.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$WebDavSyncHabitDataCWProxy get copyWith =>
      _$WebDavSyncHabitDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebDavSyncRecordData _$WebDavSyncRecordDataFromJson(
        Map<String, dynamic> json) =>
    WebDavSyncRecordData(
      recordDate: (json['record_date'] as num?)?.toInt(),
      recordType: (json['record_type'] as num?)?.toInt(),
      recordValue: json['record_value'] as num?,
      createT: (json['create_t'] as num?)?.toInt(),
      modifyT: (json['modify_t'] as num?)?.toInt(),
      uuid: json['uuid'] as String?,
      parentUUID: json['parent_uuid'] as String?,
      reason: json['reason'] as String?,
      sessionId: json['sessionId'] as String?,
    );

Map<String, dynamic> _$WebDavSyncRecordDataToJson(
        WebDavSyncRecordData instance) =>
    <String, dynamic>{
      'record_date': instance.recordDate,
      'record_type': instance.recordType,
      'record_value': instance.recordValue,
      'create_t': instance.createT,
      'modify_t': instance.modifyT,
      'uuid': instance.uuid,
      'parent_uuid': instance.parentUUID,
      'reason': instance.reason,
      'sessionId': instance.sessionId,
    };

WebDavSyncHabitData _$WebDavSyncHabitDataFromJson(Map<String, dynamic> json) =>
    WebDavSyncHabitData(
      uuid: json['uuid'] as String?,
      createT: (json['create_t'] as num?)?.toInt(),
      modifyT: (json['modify_t'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      name: json['name'] as String?,
      desc: json['desc'] as String?,
      color: (json['color'] as num?)?.toInt(),
      dailyGoal: json['daily_goal'] as num?,
      dailyGoalUnit: json['daily_goal_unit'] as String?,
      dailyGoalExtra: json['daily_goal_extra'] as num?,
      freqType: (json['freq_type'] as num?)?.toInt(),
      freqCustom: json['freq_custom'] as String?,
      reminder: json['reminder'] as String?,
      reminderQuest: json['reminder_quest'] as String?,
      startDate: (json['start_date'] as num?)?.toInt(),
      targetDays: (json['target_days'] as num?)?.toInt(),
      sortPostion: json['sort_position'] as num?,
      sessionId: json['sessionId'] as String?,
    );

Map<String, dynamic> _$WebDavSyncHabitDataToJson(
        WebDavSyncHabitData instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'create_t': instance.createT,
      'modify_t': instance.modifyT,
      'type': instance.type,
      'status': instance.status,
      'name': instance.name,
      'desc': instance.desc,
      'color': instance.color,
      'daily_goal': instance.dailyGoal,
      'daily_goal_unit': instance.dailyGoalUnit,
      'daily_goal_extra': instance.dailyGoalExtra,
      'freq_type': instance.freqType,
      'freq_custom': instance.freqCustom,
      'reminder': instance.reminder,
      'reminder_quest': instance.reminderQuest,
      'start_date': instance.startDate,
      'target_days': instance.targetDays,
      'sort_position': instance.sortPostion,
      'sessionId': instance.sessionId,
    };

// **************************************************************************
// ProxyGenerator
// **************************************************************************

class _$HttpClientFroWebDavProxy implements HttpClient {
  final HttpClient _base;

  _$HttpClientFroWebDavProxy(this._base);

  @override
  Future<HttpClientRequest> open(
          String method, String host, int port, String path) =>
      _base.open(method, host, port, path);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _base.openUrl(method, url);

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      _base.get(host, port, path);

  @override
  Future<HttpClientRequest> getUrl(Uri url) => _base.getUrl(url);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      _base.post(host, port, path);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => _base.postUrl(url);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      _base.put(host, port, path);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => _base.putUrl(url);

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      _base.delete(host, port, path);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => _base.deleteUrl(url);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      _base.patch(host, port, path);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) => _base.patchUrl(url);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      _base.head(host, port, path);

  @override
  Future<HttpClientRequest> headUrl(Uri url) => _base.headUrl(url);

  @override
  void addCredentials(
          Uri url, String realm, HttpClientCredentials credentials) =>
      _base.addCredentials(url, realm, credentials);

  @override
  void addProxyCredentials(String host, int port, String realm,
          HttpClientCredentials credentials) =>
      _base.addProxyCredentials(host, port, realm, credentials);

  @override
  void close({bool force = false}) => _base.close(force: force);

  @override
  Duration get idleTimeout => _base.idleTimeout;

  @override
  set idleTimeout(Duration value) => _base.idleTimeout = value;

  @override
  Duration? get connectionTimeout => _base.connectionTimeout;

  @override
  set connectionTimeout(Duration? value) => _base.connectionTimeout = value;

  @override
  int? get maxConnectionsPerHost => _base.maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int? value) => _base.maxConnectionsPerHost = value;

  @override
  bool get autoUncompress => _base.autoUncompress;

  @override
  set autoUncompress(bool value) => _base.autoUncompress = value;

  @override
  String? get userAgent => _base.userAgent;

  @override
  set userAgent(String? value) => _base.userAgent = value;

  @override
  set authenticate(Future<bool> Function(Uri, String, String?)? value) =>
      _base.authenticate = value;

  @override
  set connectionFactory(
          Future<ConnectionTask<Socket>> Function(Uri, String?, int?)? value) =>
      _base.connectionFactory = value;

  @override
  set findProxy(String Function(Uri)? value) => _base.findProxy = value;

  @override
  set authenticateProxy(
          Future<bool> Function(String, int, String, String?)? value) =>
      _base.authenticateProxy = value;

  @override
  set badCertificateCallback(
          bool Function(X509Certificate, String, int)? value) =>
      _base.badCertificateCallback = value;

  @override
  set keyLog(dynamic Function(String)? value) => _base.keyLog = value;
}

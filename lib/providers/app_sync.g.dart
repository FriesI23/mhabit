// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file
// ignore_for_file: type=lint


part of 'app_sync.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AppSyncContainerCWProxy<T extends AppSyncTask<R>,
    R extends AppSyncTaskResult> {
  AppSyncContainer<T, R> id(String id);

  AppSyncContainer<T, R> task(T task);

  AppSyncContainer<T, R> startTime(DateTime? startTime);

  AppSyncContainer<T, R> endedTime(DateTime? endedTime);

  AppSyncContainer<T, R> result(R? result);

  AppSyncContainer<T, R> loggerReplay(ReplaySubject<LogEvent>? loggerReplay);

  AppSyncContainer<T, R> filePath(String? filePath);

  AppSyncContainer<T, R> percentage(num? percentage);

  AppSyncContainer<T, R> loggerStreamer(
      ReplayAppLoggerStreamer<AppLoggerMessage>? loggerStreamer);

  AppSyncContainer<T, R> notification(NotiAppSyncProvider? notification);

  AppSyncContainer<T, R> logEventCallback(
      void Function(LogEvent) logEventCallback);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AppSyncContainer<T,R>(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AppSyncContainer<T,R>(...).copyWith(id: 12, name: "My name")
  /// ````
  AppSyncContainer<T, R> call({
    String id,
    T task,
    DateTime? startTime,
    DateTime? endedTime,
    R? result,
    ReplaySubject<LogEvent>? loggerReplay,
    String? filePath,
    num? percentage,
    ReplayAppLoggerStreamer<AppLoggerMessage>? loggerStreamer,
    NotiAppSyncProvider? notification,
    void Function(LogEvent) logEventCallback,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAppSyncContainer.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAppSyncContainer.copyWith.fieldName(...)`
class _$AppSyncContainerCWProxyImpl<T extends AppSyncTask<R>,
    R extends AppSyncTaskResult> implements _$AppSyncContainerCWProxy<T, R> {
  const _$AppSyncContainerCWProxyImpl(this._value);

  final AppSyncContainer<T, R> _value;

  @override
  AppSyncContainer<T, R> id(String id) => this(id: id);

  @override
  AppSyncContainer<T, R> task(T task) => this(task: task);

  @override
  AppSyncContainer<T, R> startTime(DateTime? startTime) =>
      this(startTime: startTime);

  @override
  AppSyncContainer<T, R> endedTime(DateTime? endedTime) =>
      this(endedTime: endedTime);

  @override
  AppSyncContainer<T, R> result(R? result) => this(result: result);

  @override
  AppSyncContainer<T, R> loggerReplay(ReplaySubject<LogEvent>? loggerReplay) =>
      this(loggerReplay: loggerReplay);

  @override
  AppSyncContainer<T, R> filePath(String? filePath) => this(filePath: filePath);

  @override
  AppSyncContainer<T, R> percentage(num? percentage) =>
      this(percentage: percentage);

  @override
  AppSyncContainer<T, R> loggerStreamer(
          ReplayAppLoggerStreamer<AppLoggerMessage>? loggerStreamer) =>
      this(loggerStreamer: loggerStreamer);

  @override
  AppSyncContainer<T, R> notification(NotiAppSyncProvider? notification) =>
      this(notification: notification);

  @override
  AppSyncContainer<T, R> logEventCallback(
          void Function(LogEvent) logEventCallback) =>
      this(logEventCallback: logEventCallback);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AppSyncContainer<T,R>(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AppSyncContainer<T,R>(...).copyWith(id: 12, name: "My name")
  /// ````
  AppSyncContainer<T, R> call({
    Object? id = const $CopyWithPlaceholder(),
    Object? task = const $CopyWithPlaceholder(),
    Object? startTime = const $CopyWithPlaceholder(),
    Object? endedTime = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
    Object? loggerReplay = const $CopyWithPlaceholder(),
    Object? filePath = const $CopyWithPlaceholder(),
    Object? percentage = const $CopyWithPlaceholder(),
    Object? loggerStreamer = const $CopyWithPlaceholder(),
    Object? notification = const $CopyWithPlaceholder(),
    Object? logEventCallback = const $CopyWithPlaceholder(),
  }) {
    return AppSyncContainer<T, R>._copyWith(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      task: task == const $CopyWithPlaceholder()
          ? _value.task
          // ignore: cast_nullable_to_non_nullable
          : task as T,
      startTime: startTime == const $CopyWithPlaceholder()
          ? _value.startTime
          // ignore: cast_nullable_to_non_nullable
          : startTime as DateTime?,
      endedTime: endedTime == const $CopyWithPlaceholder()
          ? _value.endedTime
          // ignore: cast_nullable_to_non_nullable
          : endedTime as DateTime?,
      result: result == const $CopyWithPlaceholder()
          ? _value.result
          // ignore: cast_nullable_to_non_nullable
          : result as R?,
      loggerReplay: loggerReplay == const $CopyWithPlaceholder()
          ? _value.loggerReplay
          // ignore: cast_nullable_to_non_nullable
          : loggerReplay as ReplaySubject<LogEvent>?,
      filePath: filePath == const $CopyWithPlaceholder()
          ? _value.filePath
          // ignore: cast_nullable_to_non_nullable
          : filePath as String?,
      percentage: percentage == const $CopyWithPlaceholder()
          ? _value.percentage
          // ignore: cast_nullable_to_non_nullable
          : percentage as num?,
      loggerStreamer: loggerStreamer == const $CopyWithPlaceholder()
          ? _value.loggerStreamer
          // ignore: cast_nullable_to_non_nullable
          : loggerStreamer as ReplayAppLoggerStreamer<AppLoggerMessage>?,
      notification: notification == const $CopyWithPlaceholder()
          ? _value.notification
          // ignore: cast_nullable_to_non_nullable
          : notification as NotiAppSyncProvider?,
      logEventCallback: logEventCallback == const $CopyWithPlaceholder()
          ? _value.logEventCallback
          // ignore: cast_nullable_to_non_nullable
          : logEventCallback as void Function(LogEvent),
    );
  }
}

extension $AppSyncContainerCopyWith<T extends AppSyncTask<R>,
    R extends AppSyncTaskResult> on AppSyncContainer<T, R> {
  /// Returns a callable class that can be used as follows: `instanceOfAppSyncContainer.copyWith(...)` or like so:`instanceOfAppSyncContainer.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AppSyncContainerCWProxy<T, R> get copyWith =>
      _$AppSyncContainerCWProxyImpl<T, R>(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file

part of 'app_sync.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AppSyncContainerCWProxy<
  T extends AppSyncTask<R>,
  R extends AppSyncTaskResult
> {
  AppSyncContainer<T, R> id(String id);

  AppSyncContainer<T, R> task(T task);

  AppSyncContainer<T, R> startTime(DateTime? startTime);

  AppSyncContainer<T, R> endedTime(DateTime? endedTime);

  AppSyncContainer<T, R> result(R? result);

  AppSyncContainer<T, R> loggerReplay(ReplaySubject<LogEvent>? loggerReplay);

  AppSyncContainer<T, R> filePath(String? filePath);

  AppSyncContainer<T, R> percentage(num? percentage);

  AppSyncContainer<T, R> loggerStreamer(
    ReplayAppLoggerStreamer<AppLoggerMessage>? loggerStreamer,
  );

  AppSyncContainer<T, R> notification(NotiAppSyncProvider? notification);

  AppSyncContainer<T, R> logEventCallback(
    void Function(LogEvent) logEventCallback,
  );

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AppSyncContainer<T,R>(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AppSyncContainer<T,R>(...).copyWith(id: 12, name: "My name")
  /// ```
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

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAppSyncContainer.copyWith(...)` or call `instanceOfAppSyncContainer.copyWith.fieldName(value)` for a single field.
class _$AppSyncContainerCWProxyImpl<
  T extends AppSyncTask<R>,
  R extends AppSyncTaskResult
>
    implements _$AppSyncContainerCWProxy<T, R> {
  const _$AppSyncContainerCWProxyImpl(this._value);

  final AppSyncContainer<T, R> _value;

  @override
  AppSyncContainer<T, R> id(String id) => call(id: id);

  @override
  AppSyncContainer<T, R> task(T task) => call(task: task);

  @override
  AppSyncContainer<T, R> startTime(DateTime? startTime) =>
      call(startTime: startTime);

  @override
  AppSyncContainer<T, R> endedTime(DateTime? endedTime) =>
      call(endedTime: endedTime);

  @override
  AppSyncContainer<T, R> result(R? result) => call(result: result);

  @override
  AppSyncContainer<T, R> loggerReplay(ReplaySubject<LogEvent>? loggerReplay) =>
      call(loggerReplay: loggerReplay);

  @override
  AppSyncContainer<T, R> filePath(String? filePath) => call(filePath: filePath);

  @override
  AppSyncContainer<T, R> percentage(num? percentage) =>
      call(percentage: percentage);

  @override
  AppSyncContainer<T, R> loggerStreamer(
    ReplayAppLoggerStreamer<AppLoggerMessage>? loggerStreamer,
  ) => call(loggerStreamer: loggerStreamer);

  @override
  AppSyncContainer<T, R> notification(NotiAppSyncProvider? notification) =>
      call(notification: notification);

  @override
  AppSyncContainer<T, R> logEventCallback(
    void Function(LogEvent) logEventCallback,
  ) => call(logEventCallback: logEventCallback);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AppSyncContainer<T,R>(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AppSyncContainer<T,R>(...).copyWith(id: 12, name: "My name")
  /// ```
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
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      task: task == const $CopyWithPlaceholder() || task == null
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
      logEventCallback:
          logEventCallback == const $CopyWithPlaceholder() ||
              logEventCallback == null
          ? _value.logEventCallback
          // ignore: cast_nullable_to_non_nullable
          : logEventCallback as void Function(LogEvent),
    );
  }
}

extension $AppSyncContainerCopyWith<
  T extends AppSyncTask<R>,
  R extends AppSyncTaskResult
>
    on AppSyncContainer<T, R> {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAppSyncContainer.copyWith(...)` or `instanceOfAppSyncContainer.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AppSyncContainerCWProxy<T, R> get copyWith =>
      _$AppSyncContainerCWProxyImpl<T, R>(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

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

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AppSyncContainer<T,R>(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AppSyncContainer<T,R>(...).copyWith(id: 12, name: "My name")
  /// ````
  AppSyncContainer<T, R> call({
    String? id,
    T? task,
    DateTime? startTime,
    DateTime? endedTime,
    R? result,
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
  }) {
    return AppSyncContainer<T, R>(
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

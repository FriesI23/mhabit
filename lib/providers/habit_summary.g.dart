// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file

part of 'habit_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$_HabitsSortableCacheCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// _HabitsSortableCache(...).copyWith(id: 12, name: "My name")
  /// ```
  _HabitsSortableCache call({
    HabitDisplaySortType sortType,
    HabitDisplaySortDirection sortDirection,
    HabitsDisplayFilter filter,
    List<HabitSortCache<dynamic>> lastSortedDataCache,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOf_HabitsSortableCache.copyWith(...)`.
class _$_HabitsSortableCacheCWProxyImpl
    implements _$_HabitsSortableCacheCWProxy {
  const _$_HabitsSortableCacheCWProxyImpl(this._value);

  final _HabitsSortableCache _value;

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// _HabitsSortableCache(...).copyWith(id: 12, name: "My name")
  /// ```
  _HabitsSortableCache call({
    Object? sortType = const $CopyWithPlaceholder(),
    Object? sortDirection = const $CopyWithPlaceholder(),
    Object? filter = const $CopyWithPlaceholder(),
    Object? lastSortedDataCache = const $CopyWithPlaceholder(),
  }) {
    return _HabitsSortableCache(
      sortType: sortType == const $CopyWithPlaceholder() || sortType == null
          ? _value.sortType
          // ignore: cast_nullable_to_non_nullable
          : sortType as HabitDisplaySortType,
      sortDirection:
          sortDirection == const $CopyWithPlaceholder() || sortDirection == null
          ? _value.sortDirection
          // ignore: cast_nullable_to_non_nullable
          : sortDirection as HabitDisplaySortDirection,
      filter: filter == const $CopyWithPlaceholder() || filter == null
          ? _value.filter
          // ignore: cast_nullable_to_non_nullable
          : filter as HabitsDisplayFilter,
      lastSortedDataCache:
          lastSortedDataCache == const $CopyWithPlaceholder() ||
              lastSortedDataCache == null
          ? _value.lastSortedDataCache
          // ignore: cast_nullable_to_non_nullable
          : lastSortedDataCache as List<HabitSortCache<dynamic>>,
    );
  }
}

extension _$_HabitsSortableCacheCopyWith on _HabitsSortableCache {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOf_HabitsSortableCache.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$_HabitsSortableCacheCWProxy get copyWith =>
      _$_HabitsSortableCacheCWProxyImpl(this);
}

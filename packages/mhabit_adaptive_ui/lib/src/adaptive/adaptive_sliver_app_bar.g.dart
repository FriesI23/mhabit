// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adaptive_sliver_app_bar.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AppBarStylesCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// AppBarStyles(...).copyWith(id: 12, name: "My name")
  /// ```
  AppBarStyles call({AppBarMaterialStyle? material, AppBarAppleStyle? apple});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAppBarStyles.copyWith(...)`.
class _$AppBarStylesCWProxyImpl implements _$AppBarStylesCWProxy {
  const _$AppBarStylesCWProxyImpl(this._value);

  final AppBarStyles _value;

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// AppBarStyles(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  AppBarStyles call({
    Object? material = const $CopyWithPlaceholder(),
    Object? apple = const $CopyWithPlaceholder(),
  }) {
    return AppBarStyles(
      material: material == const $CopyWithPlaceholder()
          ? _value.material
          // ignore: cast_nullable_to_non_nullable
          : material as AppBarMaterialStyle?,
      apple: apple == const $CopyWithPlaceholder()
          ? _value.apple
          // ignore: cast_nullable_to_non_nullable
          : apple as AppBarAppleStyle?,
    );
  }
}

extension $AppBarStylesCopyWith on AppBarStyles {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAppBarStyles.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$AppBarStylesCWProxy get copyWith => _$AppBarStylesCWProxyImpl(this);
}

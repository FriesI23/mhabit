// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_bar_material_style.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AppBarMaterialStyleCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// AppBarMaterialStyle(...).copyWith(id: 12, name: "My name")
  /// ```
  AppBarMaterialStyle call({
    bool centerTitle,
    bool floating,
    bool snap,
    bool pinned,
    bool forceElevated,
    double? scrolledUnderElevation,
    Color? shadowColor,
    Color? backgroundColor,
    Color? surfaceTintColor,
    PreferredSizeWidget? bottom,
    EdgeInsetsDirectional windowControlEdgePadding,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAppBarMaterialStyle.copyWith(...)`.
class _$AppBarMaterialStyleCWProxyImpl implements _$AppBarMaterialStyleCWProxy {
  const _$AppBarMaterialStyleCWProxyImpl(this._value);

  final AppBarMaterialStyle _value;

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// AppBarMaterialStyle(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  AppBarMaterialStyle call({
    Object? centerTitle = const $CopyWithPlaceholder(),
    Object? floating = const $CopyWithPlaceholder(),
    Object? snap = const $CopyWithPlaceholder(),
    Object? pinned = const $CopyWithPlaceholder(),
    Object? forceElevated = const $CopyWithPlaceholder(),
    Object? scrolledUnderElevation = const $CopyWithPlaceholder(),
    Object? shadowColor = const $CopyWithPlaceholder(),
    Object? backgroundColor = const $CopyWithPlaceholder(),
    Object? surfaceTintColor = const $CopyWithPlaceholder(),
    Object? bottom = const $CopyWithPlaceholder(),
    Object? windowControlEdgePadding = const $CopyWithPlaceholder(),
  }) {
    return AppBarMaterialStyle(
      centerTitle:
          centerTitle == const $CopyWithPlaceholder() || centerTitle == null
          ? _value.centerTitle
          // ignore: cast_nullable_to_non_nullable
          : centerTitle as bool,
      floating: floating == const $CopyWithPlaceholder() || floating == null
          ? _value.floating
          // ignore: cast_nullable_to_non_nullable
          : floating as bool,
      snap: snap == const $CopyWithPlaceholder() || snap == null
          ? _value.snap
          // ignore: cast_nullable_to_non_nullable
          : snap as bool,
      pinned: pinned == const $CopyWithPlaceholder() || pinned == null
          ? _value.pinned
          // ignore: cast_nullable_to_non_nullable
          : pinned as bool,
      forceElevated:
          forceElevated == const $CopyWithPlaceholder() || forceElevated == null
          ? _value.forceElevated
          // ignore: cast_nullable_to_non_nullable
          : forceElevated as bool,
      scrolledUnderElevation:
          scrolledUnderElevation == const $CopyWithPlaceholder()
          ? _value.scrolledUnderElevation
          // ignore: cast_nullable_to_non_nullable
          : scrolledUnderElevation as double?,
      shadowColor: shadowColor == const $CopyWithPlaceholder()
          ? _value.shadowColor
          // ignore: cast_nullable_to_non_nullable
          : shadowColor as Color?,
      backgroundColor: backgroundColor == const $CopyWithPlaceholder()
          ? _value.backgroundColor
          // ignore: cast_nullable_to_non_nullable
          : backgroundColor as Color?,
      surfaceTintColor: surfaceTintColor == const $CopyWithPlaceholder()
          ? _value.surfaceTintColor
          // ignore: cast_nullable_to_non_nullable
          : surfaceTintColor as Color?,
      bottom: bottom == const $CopyWithPlaceholder()
          ? _value.bottom
          // ignore: cast_nullable_to_non_nullable
          : bottom as PreferredSizeWidget?,
      windowControlEdgePadding:
          windowControlEdgePadding == const $CopyWithPlaceholder() ||
              windowControlEdgePadding == null
          ? _value.windowControlEdgePadding
          // ignore: cast_nullable_to_non_nullable
          : windowControlEdgePadding as EdgeInsetsDirectional,
    );
  }
}

extension $AppBarMaterialStyleCopyWith on AppBarMaterialStyle {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAppBarMaterialStyle.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$AppBarMaterialStyleCWProxy get copyWith =>
      _$AppBarMaterialStyleCWProxyImpl(this);
}

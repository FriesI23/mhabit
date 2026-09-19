// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_bar_apple_style.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AppBarAppleStyleCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// AppBarAppleStyle(...).copyWith(id: 12, name: "My name")
  /// ```
  AppBarAppleStyle call({
    bool collapsible,
    bool enableBackgroundFilterBlur,
    Border? border,
    Color backgroundColor,
    bool automaticBackgroundVisibility,
    EdgeInsetsDirectional? padding,
    bool stretch,
    EdgeInsetsDirectional windowControlEdgePadding,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAppBarAppleStyle.copyWith(...)`.
class _$AppBarAppleStyleCWProxyImpl implements _$AppBarAppleStyleCWProxy {
  const _$AppBarAppleStyleCWProxyImpl(this._value);

  final AppBarAppleStyle _value;

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// AppBarAppleStyle(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  AppBarAppleStyle call({
    Object? collapsible = const $CopyWithPlaceholder(),
    Object? enableBackgroundFilterBlur = const $CopyWithPlaceholder(),
    Object? border = const $CopyWithPlaceholder(),
    Object? backgroundColor = const $CopyWithPlaceholder(),
    Object? automaticBackgroundVisibility = const $CopyWithPlaceholder(),
    Object? padding = const $CopyWithPlaceholder(),
    Object? stretch = const $CopyWithPlaceholder(),
    Object? windowControlEdgePadding = const $CopyWithPlaceholder(),
  }) {
    return AppBarAppleStyle(
      collapsible:
          collapsible == const $CopyWithPlaceholder() || collapsible == null
          ? _value.collapsible
          // ignore: cast_nullable_to_non_nullable
          : collapsible as bool,
      enableBackgroundFilterBlur:
          enableBackgroundFilterBlur == const $CopyWithPlaceholder() ||
              enableBackgroundFilterBlur == null
          ? _value.enableBackgroundFilterBlur
          // ignore: cast_nullable_to_non_nullable
          : enableBackgroundFilterBlur as bool,
      border: border == const $CopyWithPlaceholder()
          ? _value.border
          // ignore: cast_nullable_to_non_nullable
          : border as Border?,
      backgroundColor:
          backgroundColor == const $CopyWithPlaceholder() ||
              backgroundColor == null
          ? _value.backgroundColor
          // ignore: cast_nullable_to_non_nullable
          : backgroundColor as Color,
      automaticBackgroundVisibility:
          automaticBackgroundVisibility == const $CopyWithPlaceholder() ||
              automaticBackgroundVisibility == null
          ? _value.automaticBackgroundVisibility
          // ignore: cast_nullable_to_non_nullable
          : automaticBackgroundVisibility as bool,
      padding: padding == const $CopyWithPlaceholder()
          ? _value.padding
          // ignore: cast_nullable_to_non_nullable
          : padding as EdgeInsetsDirectional?,
      stretch: stretch == const $CopyWithPlaceholder() || stretch == null
          ? _value.stretch
          // ignore: cast_nullable_to_non_nullable
          : stretch as bool,
      windowControlEdgePadding:
          windowControlEdgePadding == const $CopyWithPlaceholder() ||
              windowControlEdgePadding == null
          ? _value.windowControlEdgePadding
          // ignore: cast_nullable_to_non_nullable
          : windowControlEdgePadding as EdgeInsetsDirectional,
    );
  }
}

extension $AppBarAppleStyleCopyWith on AppBarAppleStyle {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAppBarAppleStyle.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$AppBarAppleStyleCWProxy get copyWith => _$AppBarAppleStyleCWProxyImpl(this);
}

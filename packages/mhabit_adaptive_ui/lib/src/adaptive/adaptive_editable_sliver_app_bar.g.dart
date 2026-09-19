// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adaptive_editable_sliver_app_bar.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EditableAppBarStylesCWProxy {
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// EditableAppBarStyles(...).copyWith(id: 12, name: "My name")
  /// ```
  EditableAppBarStyles call({
    MaterialEditableAppBarStyle? material,
    AppleEditableAppBarStyle? apple,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfEditableAppBarStyles.copyWith(...)`.
class _$EditableAppBarStylesCWProxyImpl
    implements _$EditableAppBarStylesCWProxy {
  const _$EditableAppBarStylesCWProxyImpl(this._value);

  final EditableAppBarStyles _value;

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored.
  ///
  /// Example:
  /// ```dart
  /// EditableAppBarStyles(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  EditableAppBarStyles call({
    Object? material = const $CopyWithPlaceholder(),
    Object? apple = const $CopyWithPlaceholder(),
  }) {
    return EditableAppBarStyles(
      material: material == const $CopyWithPlaceholder()
          ? _value.material
          // ignore: cast_nullable_to_non_nullable
          : material as MaterialEditableAppBarStyle?,
      apple: apple == const $CopyWithPlaceholder()
          ? _value.apple
          // ignore: cast_nullable_to_non_nullable
          : apple as AppleEditableAppBarStyle?,
    );
  }
}

extension $EditableAppBarStylesCopyWith on EditableAppBarStyles {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfEditableAppBarStyles.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$EditableAppBarStylesCWProxy get copyWith =>
      _$EditableAppBarStylesCWProxyImpl(this);
}

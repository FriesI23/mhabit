import 'package:flutter/material.dart';

import '../adaptive_style.dart';
import '../cupertino/cupertino_editable_sliver_app_bar.dart';
import '../material/material_editable_sliver_app_bar.dart';

export '../cupertino/cupertino_editable_sliver_app_bar.dart'
    show AppleEditableAppBarStyle;
export '../material/material_editable_sliver_app_bar.dart'
    show MaterialEditableAppBarStyle;

/// Per-platform configuration for [AdaptiveEditableSliverAppBar].
class EditableAppBarStyles {
  const EditableAppBarStyles({this.material, this.apple});

  final MaterialEditableAppBarStyle? material;
  final AppleEditableAppBarStyle? apple;

  EditableAppBarStyles copyWith({
    MaterialEditableAppBarStyle? material,
    AppleEditableAppBarStyle? apple,
  }) => EditableAppBarStyles(
    material: material ?? this.material,
    apple: apple ?? this.apple,
  );

  @override
  bool operator ==(Object other) =>
      other is EditableAppBarStyles &&
      other.material == material &&
      other.apple == apple;

  @override
  int get hashCode => Object.hash(material, apple);
}

/// Adaptive editable title chrome for a scrolling form.
///
/// Material renders the editor inside a pinned large app bar. Apple renders a
/// fixed navigation bar followed by a native inset text field.
class AdaptiveEditableSliverAppBar extends StatelessWidget {
  const AdaptiveEditableSliverAppBar({
    super.key,
    required this.title,
    required this.controller,
    required this.isCollapsed,
    this.onChanged,
    this.hintText,
    this.autofocus = false,
    this.foregroundColor,
    this.leading,
    this.actions = const [],
    this.styles,
  }) : style = null;

  const AdaptiveEditableSliverAppBar.material({
    super.key,
    required this.title,
    required this.controller,
    required this.isCollapsed,
    this.onChanged,
    this.hintText,
    this.autofocus = false,
    this.foregroundColor,
    this.leading,
    this.actions = const [],
    this.styles,
  }) : style = AdaptiveStyle.material;

  const AdaptiveEditableSliverAppBar.apple({
    super.key,
    required this.title,
    required this.controller,
    required this.isCollapsed,
    this.onChanged,
    this.hintText,
    this.autofocus = false,
    this.foregroundColor,
    this.leading,
    this.actions = const [],
    this.styles,
  }) : style = AdaptiveStyle.apple;

  final AdaptiveStyle? style;
  final String title;
  final TextEditingController controller;
  final bool isCollapsed;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final bool autofocus;
  final Color? foregroundColor;
  final Widget? leading;
  final List<Widget> actions;
  final EditableAppBarStyles? styles;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? AdaptiveStyle.of(context);
    return switch (effectiveStyle) {
      AdaptiveStyle.material => MaterialEditableSliverAppBar(
        title: title,
        controller: controller,
        isCollapsed: isCollapsed,
        autofocus: autofocus,
        onChanged: onChanged,
        hintText: hintText,
        foregroundColor: foregroundColor,
        leading: leading,
        actions: actions,
        style: styles?.material ?? const MaterialEditableAppBarStyle(),
      ),
      AdaptiveStyle.apple => CupertinoEditableSliverAppBar(
        title: title,
        controller: controller,
        isCollapsed: isCollapsed,
        autofocus: autofocus,
        onChanged: onChanged,
        hintText: hintText,
        foregroundColor: foregroundColor,
        leading: leading,
        actions: actions,
        style: styles?.apple ?? const AppleEditableAppBarStyle(),
      ),
    };
  }
}

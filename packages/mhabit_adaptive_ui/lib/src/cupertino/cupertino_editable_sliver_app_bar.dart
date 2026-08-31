import 'package:flutter/cupertino.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../adaptive/app_bar_apple_style.dart';
import '../window_control/toolbar_geometry.dart';
import 'cupertino_sliver_app_bar.dart';

/// Apple configuration for a fixed navigation bar and editable title field.
class AppleEditableAppBarStyle {
  const AppleEditableAppBarStyle({
    this.toolbarHeight = 44.0,
    this.sectionPadding = const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
    this.fieldPadding = const EdgeInsetsDirectional.symmetric(
      horizontal: 14,
      vertical: 12,
    ),
    this.fieldBorderRadius = 10.0,
    this.sectionBackgroundColor,
    this.fieldBackgroundColor = CupertinoColors.tertiarySystemFill,
    this.separatorColor = CupertinoColors.separator,
    this.clearButtonMode = OverlayVisibilityMode.editing,
    this.titleTransitionDuration = const Duration(milliseconds: 200),
    this.enableBackgroundFilterBlur = true,
    this.navigationBarBorder,
    this.navigationBarBackgroundColor = CupertinoColors.transparent,
    this.navigationBarPadding,
    this.windowControlEdgePadding = cupertinoWindowControlEdgePadding,
  });

  final double toolbarHeight;
  final EdgeInsetsDirectional sectionPadding;
  final EdgeInsetsDirectional fieldPadding;
  final double fieldBorderRadius;

  /// Background behind the field section.
  ///
  /// Null inherits the host page surface so the editable header stays
  /// visually continuous with the form below it.
  final Color? sectionBackgroundColor;
  final Color fieldBackgroundColor;
  final Color separatorColor;
  final OverlayVisibilityMode clearButtonMode;
  final Duration titleTransitionDuration;
  final bool enableBackgroundFilterBlur;
  final Border? navigationBarBorder;
  final Color navigationBarBackgroundColor;
  final EdgeInsetsDirectional? navigationBarPadding;
  final EdgeInsetsDirectional windowControlEdgePadding;

  AppleEditableAppBarStyle copyWith({
    double? toolbarHeight,
    EdgeInsetsDirectional? sectionPadding,
    EdgeInsetsDirectional? fieldPadding,
    double? fieldBorderRadius,
    Color? sectionBackgroundColor,
    Color? fieldBackgroundColor,
    Color? separatorColor,
    OverlayVisibilityMode? clearButtonMode,
    Duration? titleTransitionDuration,
    bool? enableBackgroundFilterBlur,
    Border? navigationBarBorder,
    Color? navigationBarBackgroundColor,
    EdgeInsetsDirectional? navigationBarPadding,
    EdgeInsetsDirectional? windowControlEdgePadding,
  }) => AppleEditableAppBarStyle(
    toolbarHeight: toolbarHeight ?? this.toolbarHeight,
    sectionPadding: sectionPadding ?? this.sectionPadding,
    fieldPadding: fieldPadding ?? this.fieldPadding,
    fieldBorderRadius: fieldBorderRadius ?? this.fieldBorderRadius,
    sectionBackgroundColor:
        sectionBackgroundColor ?? this.sectionBackgroundColor,
    fieldBackgroundColor: fieldBackgroundColor ?? this.fieldBackgroundColor,
    separatorColor: separatorColor ?? this.separatorColor,
    clearButtonMode: clearButtonMode ?? this.clearButtonMode,
    titleTransitionDuration:
        titleTransitionDuration ?? this.titleTransitionDuration,
    enableBackgroundFilterBlur:
        enableBackgroundFilterBlur ?? this.enableBackgroundFilterBlur,
    navigationBarBorder: navigationBarBorder ?? this.navigationBarBorder,
    navigationBarBackgroundColor:
        navigationBarBackgroundColor ?? this.navigationBarBackgroundColor,
    navigationBarPadding: navigationBarPadding ?? this.navigationBarPadding,
    windowControlEdgePadding:
        windowControlEdgePadding ?? this.windowControlEdgePadding,
  );

  @override
  bool operator ==(Object other) =>
      other is AppleEditableAppBarStyle &&
      other.toolbarHeight == toolbarHeight &&
      other.sectionPadding == sectionPadding &&
      other.fieldPadding == fieldPadding &&
      other.fieldBorderRadius == fieldBorderRadius &&
      other.sectionBackgroundColor == sectionBackgroundColor &&
      other.fieldBackgroundColor == fieldBackgroundColor &&
      other.separatorColor == separatorColor &&
      other.clearButtonMode == clearButtonMode &&
      other.titleTransitionDuration == titleTransitionDuration &&
      other.enableBackgroundFilterBlur == enableBackgroundFilterBlur &&
      other.navigationBarBorder == navigationBarBorder &&
      other.navigationBarBackgroundColor == navigationBarBackgroundColor &&
      other.navigationBarPadding == navigationBarPadding &&
      other.windowControlEdgePadding == windowControlEdgePadding;

  @override
  int get hashCode => Object.hash(
    toolbarHeight,
    sectionPadding,
    fieldPadding,
    fieldBorderRadius,
    sectionBackgroundColor,
    fieldBackgroundColor,
    separatorColor,
    clearButtonMode,
    titleTransitionDuration,
    enableBackgroundFilterBlur,
    navigationBarBorder,
    navigationBarBackgroundColor,
    navigationBarPadding,
    windowControlEdgePadding,
  );
}

/// Cupertino renderer for an editable title field below a fixed toolbar.
class CupertinoEditableSliverAppBar extends StatelessWidget {
  const CupertinoEditableSliverAppBar({
    super.key,
    required this.title,
    required this.controller,
    required this.isCollapsed,
    required this.autofocus,
    required this.onChanged,
    required this.hintText,
    required this.foregroundColor,
    required this.leading,
    required this.actions,
    required this.style,
  });

  final String title;
  final TextEditingController controller;
  final bool isCollapsed;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final Color? foregroundColor;
  final Widget? leading;
  final List<Widget> actions;
  final AppleEditableAppBarStyle style;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = this.foregroundColor;
    final actions = foregroundColor == null
        ? this.actions
        : [
            for (final action in this.actions)
              CupertinoTheme(
                data: CupertinoThemeData(primaryColor: foregroundColor),
                child: action,
              ),
          ];
    final content = MultiSliver(
      children: [
        CupertinoSliverAppBar(
          title: ExcludeSemantics(
            excluding: !isCollapsed,
            child: AnimatedSwitcher(
              duration: style.titleTransitionDuration,
              child: isCollapsed
                  ? Text(
                      title,
                      key: const ValueKey('editable-app-bar-apple-title'),
                      style: TextStyle(color: foregroundColor),
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('editable-app-bar-apple-title-placeholder'),
                    ),
            ),
          ),
          height: style.toolbarHeight,
          leading: leading,
          actions: actions,
          style: AppBarAppleStyle(
            enableBackgroundFilterBlur: style.enableBackgroundFilterBlur,
            border: style.navigationBarBorder,
            backgroundColor: style.navigationBarBackgroundColor,
            padding: style.navigationBarPadding,
            windowControlEdgePadding: style.windowControlEdgePadding,
          ),
        ),
        _buildFieldSection(context),
      ],
    );
    return foregroundColor == null
        ? content
        : CupertinoTheme(
            data: CupertinoThemeData(primaryColor: foregroundColor),
            child: content,
          );
  }

  Widget _buildFieldSection(BuildContext context) {
    final section = SliverSafeArea(
      top: false,
      bottom: false,
      sliver: SliverPadding(
        padding: style.sectionPadding,
        sliver: SliverToBoxAdapter(child: _buildField(context)),
      ),
    );
    final backgroundColor = style.sectionBackgroundColor;
    return backgroundColor == null
        ? section
        : DecoratedSliver(
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(backgroundColor, context),
            ),
            sliver: section,
          );
  }

  Widget _buildField(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final separatorColor = CupertinoDynamicColor.resolve(
      style.separatorColor,
      context,
    ).withValues(alpha: 0.35);
    return CupertinoTextField(
      key: const ValueKey('editable-app-bar-apple-field'),
      controller: controller,
      autofocus: autofocus,
      clearButtonMode: style.clearButtonMode,
      padding: style.fieldPadding,
      placeholder: hintText,
      placeholderStyle: textStyle.copyWith(
        color: foregroundColor?.withValues(alpha: 0.56),
      ),
      style: textStyle.copyWith(
        color: foregroundColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          style.fieldBackgroundColor,
          context,
        ),
        border: Border.all(color: separatorColor, width: 0.5),
        borderRadius: BorderRadius.circular(style.fieldBorderRadius),
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
    );
  }
}

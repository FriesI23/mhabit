import 'package:flutter/material.dart';

import '../window_control/material_app_bar.dart';

/// Material configuration for an editable large sliver app bar.
class MaterialEditableAppBarStyle {
  const MaterialEditableAppBarStyle({
    this.scrolledUnderElevation,
    this.shadowColor = Colors.transparent,
    this.backgroundColor,
    this.surfaceTintColor,
  });

  final double? scrolledUnderElevation;
  final Color? shadowColor;
  final Color? backgroundColor;
  final Color? surfaceTintColor;

  MaterialEditableAppBarStyle copyWith({
    double? scrolledUnderElevation,
    Color? shadowColor,
    Color? backgroundColor,
    Color? surfaceTintColor,
  }) => MaterialEditableAppBarStyle(
    scrolledUnderElevation:
        scrolledUnderElevation ?? this.scrolledUnderElevation,
    shadowColor: shadowColor ?? this.shadowColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
  );

  @override
  bool operator ==(Object other) =>
      other is MaterialEditableAppBarStyle &&
      other.scrolledUnderElevation == scrolledUnderElevation &&
      other.shadowColor == shadowColor &&
      other.backgroundColor == backgroundColor &&
      other.surfaceTintColor == surfaceTintColor;

  @override
  int get hashCode => Object.hash(
    scrolledUnderElevation,
    shadowColor,
    backgroundColor,
    surfaceTintColor,
  );
}

/// Material renderer for an editable large sliver app bar.
class MaterialEditableSliverAppBar extends StatelessWidget {
  const MaterialEditableSliverAppBar({
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
  final MaterialEditableAppBarStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = foregroundColor == null
        ? this.actions
        : [
            for (final action in this.actions)
              Theme(
                data: theme.copyWith(
                  textButtonTheme: TextButtonThemeData(
                    style:
                        theme.textButtonTheme.style?.copyWith(
                          foregroundColor: WidgetStatePropertyAll(
                            foregroundColor,
                          ),
                        ) ??
                        ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll(
                            foregroundColor,
                          ),
                        ),
                  ),
                ),
                child: action,
              ),
          ];
    return WindowControlSliverAppBar.large(
      pinned: true,
      scrolledUnderElevation: style.scrolledUnderElevation,
      shadowColor: style.shadowColor,
      backgroundColor: style.backgroundColor,
      surfaceTintColor: style.surfaceTintColor,
      foregroundColor: foregroundColor,
      flexibleSpace: _MaterialEditableFlexibleSpace(
        collapsedTitle: Text(title),
        expandedTitle: TextField(
          maxLines: 1,
          minLines: 1,
          controller: controller,
          autofocus: autofocus,
          enabled: !isCollapsed,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: hintText,
            hintStyle: TextStyle(
              color: foregroundColor?.withValues(alpha: 0.64),
            ),
            border: InputBorder.none,
          ),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: foregroundColor,
          ),
          keyboardType: TextInputType.text,
          onChanged: onChanged,
        ),
        foregroundColor: foregroundColor,
      ),
      automaticallyImplyLeading: false,
      leading: leading,
      actions: actions.isEmpty ? null : actions,
    );
  }
}

class _MaterialEditableFlexibleSpace extends StatelessWidget {
  const _MaterialEditableFlexibleSpace({
    required this.collapsedTitle,
    required this.expandedTitle,
    required this.foregroundColor,
  });

  final Widget collapsedTitle;
  final Widget expandedTitle;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
    final topPadding = MediaQuery.viewPaddingOf(context).top;
    final collapsedHeight = settings.minExtent - topPadding;
    final scrollUnderHeight = settings.maxExtent - settings.minExtent;
    final isCollapsed = settings.isScrolledUnder ?? false;
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleLarge!.copyWith(color: foregroundColor);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Container(
            height: collapsedHeight,
            padding: const EdgeInsetsDirectional.fromSTEB(56, 0, 64, 0),
            child: AnimatedOpacity(
              opacity: isCollapsed ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              curve: const Cubic(0.2, 0.0, 0.0, 1.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: DefaultTextStyle(
                  style: titleStyle,
                  overflow: TextOverflow.ellipsis,
                  child: collapsedTitle,
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: ClipRect(
            child: OverflowBox(
              minHeight: scrollUnderHeight,
              maxHeight: scrollUnderHeight,
              alignment: AlignmentDirectional.bottomStart,
              child: Container(
                alignment: AlignmentDirectional.bottomStart,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                child: expandedTitle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

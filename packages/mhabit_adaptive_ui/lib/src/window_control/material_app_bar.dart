import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'toolbar_geometry.dart';

/// A Material [AppBar] whose leading and action slots avoid window controls.
///
/// The title, background, flexible space, and bottom keep the full app-bar
/// width. A null [windowControlAvoidance] inherits the adaptive layout scope;
/// an explicit zero disables avoidance.
class WindowControlAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const WindowControlAppBar({
    super.key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.automaticallyImplyActions = true,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.scrolledUnderElevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.shape,
    this.backgroundColor,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary = true,
    this.centerTitle,
    this.titleSpacing,
    this.toolbarHeight,
    this.leadingWidth,
    this.systemOverlayStyle,
    this.forceMaterialTransparency = false,
    this.actionsPadding,
    this.windowControlAvoidance,
    this.windowControlEdgePadding = materialWindowControlEdgePadding,
  });

  /// {@macro flutter.material.appbar.leading}
  final Widget? leading;

  /// {@macro flutter.material.appbar.automaticallyImplyLeading}
  final bool automaticallyImplyLeading;

  /// {@macro flutter.material.appbar.title}
  final Widget? title;

  /// {@macro flutter.material.appbar.actions}
  final List<Widget>? actions;

  /// {@macro flutter.material.appbar.automaticallyImplyActions}
  final bool automaticallyImplyActions;

  /// {@macro flutter.material.appbar.flexibleSpace}
  final Widget? flexibleSpace;

  /// {@macro flutter.material.appbar.bottom}
  final PreferredSizeWidget? bottom;

  /// {@macro flutter.material.appbar.elevation}
  final double? elevation;

  /// {@macro flutter.material.appbar.scrolledUnderElevation}
  final double? scrolledUnderElevation;

  /// {@macro flutter.material.appbar.shadowColor}
  final Color? shadowColor;

  /// {@macro flutter.material.appbar.surfaceTintColor}
  final Color? surfaceTintColor;

  /// {@macro flutter.material.appbar.shape}
  final ShapeBorder? shape;

  /// {@macro flutter.material.appbar.backgroundColor}
  final Color? backgroundColor;

  /// {@macro flutter.material.appbar.foregroundColor}
  final Color? foregroundColor;

  /// {@macro flutter.material.appbar.iconTheme}
  final IconThemeData? iconTheme;

  /// {@macro flutter.material.appbar.actionsIconTheme}
  final IconThemeData? actionsIconTheme;

  /// {@macro flutter.material.appbar.primary}
  final bool primary;

  /// {@macro flutter.material.appbar.centerTitle}
  final bool? centerTitle;

  /// {@macro flutter.material.appbar.titleSpacing}
  final double? titleSpacing;

  /// {@macro flutter.material.appbar.toolbarHeight}
  final double? toolbarHeight;

  /// {@macro flutter.material.appbar.leadingWidth}
  final double? leadingWidth;

  /// {@macro flutter.material.appbar.systemOverlayStyle}
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// {@macro flutter.material.appbar.forceMaterialTransparency}
  final bool forceMaterialTransparency;

  /// {@macro flutter.material.appbar.actionsPadding}
  final EdgeInsetsGeometry? actionsPadding;

  /// {@macro mhabit.windowControlAvoidance}
  final EdgeInsetsDirectional? windowControlAvoidance;

  /// {@macro mhabit.windowControlEdgePadding}
  final EdgeInsetsDirectional windowControlEdgePadding;

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final slots = _resolveMaterialToolbarSlots(
      context,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      automaticallyImplyActions: automaticallyImplyActions,
      leadingWidth: leadingWidth,
      avoidance: windowControlAvoidance,
      edgePadding: windowControlEdgePadding,
    );
    return AppBar(
      leading: slots.leading,
      automaticallyImplyLeading: slots.automaticallyImplyLeading,
      title: title,
      actions: slots.actions,
      automaticallyImplyActions: slots.automaticallyImplyActions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      primary: primary,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      leadingWidth: slots.leadingWidth,
      systemOverlayStyle: systemOverlayStyle,
      forceMaterialTransparency: forceMaterialTransparency,
      actionsPadding: actionsPadding,
    );
  }
}

enum _WindowControlSliverAppBarVariant { small, large }

/// A [SliverAppBar] counterpart to [WindowControlAppBar].
///
/// The default constructor preserves the small app-bar behavior and [large]
/// delegates expanded-title layout to [SliverAppBar.large].
class WindowControlSliverAppBar extends StatelessWidget {
  const WindowControlSliverAppBar({
    super.key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.automaticallyImplyActions = true,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.scrolledUnderElevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.forceElevated = false,
    this.backgroundColor,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary = true,
    this.centerTitle,
    this.titleSpacing,
    this.collapsedHeight,
    this.expandedHeight,
    this.floating = false,
    this.pinned = false,
    this.snap = false,
    this.stretch = false,
    this.stretchTriggerOffset = 100,
    this.onStretchTrigger,
    this.shape,
    this.toolbarHeight = kToolbarHeight,
    this.leadingWidth,
    this.systemOverlayStyle,
    this.forceMaterialTransparency = false,
    this.actionsPadding,
    this.windowControlAvoidance,
    this.windowControlEdgePadding = materialWindowControlEdgePadding,
  }) : _variant = _WindowControlSliverAppBarVariant.small;

  const WindowControlSliverAppBar.large({
    super.key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.automaticallyImplyActions = true,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.scrolledUnderElevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.forceElevated = false,
    this.backgroundColor,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary = true,
    this.centerTitle,
    this.titleSpacing,
    this.collapsedHeight,
    this.expandedHeight,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
    this.stretch = false,
    this.stretchTriggerOffset = 100,
    this.onStretchTrigger,
    this.shape,
    this.toolbarHeight,
    this.leadingWidth,
    this.systemOverlayStyle,
    this.forceMaterialTransparency = false,
    this.actionsPadding,
    this.windowControlAvoidance,
    this.windowControlEdgePadding = materialWindowControlEdgePadding,
  }) : _variant = _WindowControlSliverAppBarVariant.large;

  /// {@macro flutter.material.appbar.leading}
  final Widget? leading;

  /// {@macro flutter.material.appbar.automaticallyImplyLeading}
  final bool automaticallyImplyLeading;

  /// {@macro flutter.material.appbar.title}
  final Widget? title;

  /// {@macro flutter.material.appbar.actions}
  final List<Widget>? actions;

  /// {@macro flutter.material.appbar.automaticallyImplyActions}
  final bool automaticallyImplyActions;

  /// {@macro flutter.material.appbar.flexibleSpace}
  final Widget? flexibleSpace;

  /// {@macro flutter.material.appbar.bottom}
  final PreferredSizeWidget? bottom;

  /// {@macro flutter.material.appbar.elevation}
  final double? elevation;

  /// {@macro flutter.material.appbar.scrolledUnderElevation}
  final double? scrolledUnderElevation;

  /// {@macro flutter.material.appbar.shadowColor}
  final Color? shadowColor;

  /// {@macro flutter.material.appbar.surfaceTintColor}
  final Color? surfaceTintColor;

  /// See [SliverAppBar.forceElevated].
  final bool forceElevated;

  /// {@macro flutter.material.appbar.backgroundColor}
  final Color? backgroundColor;

  /// {@macro flutter.material.appbar.foregroundColor}
  final Color? foregroundColor;

  /// {@macro flutter.material.appbar.iconTheme}
  final IconThemeData? iconTheme;

  /// {@macro flutter.material.appbar.actionsIconTheme}
  final IconThemeData? actionsIconTheme;

  /// {@macro flutter.material.appbar.primary}
  final bool primary;

  /// {@macro flutter.material.appbar.centerTitle}
  final bool? centerTitle;

  /// {@macro flutter.material.appbar.titleSpacing}
  final double? titleSpacing;

  /// See [SliverAppBar.collapsedHeight].
  final double? collapsedHeight;

  /// See [SliverAppBar.expandedHeight].
  final double? expandedHeight;

  /// See [SliverAppBar.floating].
  final bool floating;

  /// See [SliverAppBar.pinned].
  final bool pinned;

  /// See [SliverAppBar.snap].
  final bool snap;

  /// See [SliverAppBar.stretch].
  final bool stretch;

  /// See [SliverAppBar.stretchTriggerOffset].
  final double stretchTriggerOffset;

  /// See [SliverAppBar.onStretchTrigger].
  final AsyncCallback? onStretchTrigger;

  /// {@macro flutter.material.appbar.shape}
  final ShapeBorder? shape;

  /// {@macro flutter.material.appbar.toolbarHeight}
  final double? toolbarHeight;

  /// {@macro flutter.material.appbar.leadingWidth}
  final double? leadingWidth;

  /// {@macro flutter.material.appbar.systemOverlayStyle}
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// {@macro flutter.material.appbar.forceMaterialTransparency}
  final bool forceMaterialTransparency;

  /// {@macro flutter.material.appbar.actionsPadding}
  final EdgeInsetsGeometry? actionsPadding;

  /// {@macro mhabit.windowControlAvoidance}
  final EdgeInsetsDirectional? windowControlAvoidance;

  /// {@macro mhabit.windowControlEdgePadding}
  final EdgeInsetsDirectional windowControlEdgePadding;
  final _WindowControlSliverAppBarVariant _variant;

  @override
  Widget build(BuildContext context) {
    final slots = _resolveMaterialToolbarSlots(
      context,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      automaticallyImplyActions: automaticallyImplyActions,
      leadingWidth: leadingWidth,
      avoidance: windowControlAvoidance,
      edgePadding: windowControlEdgePadding,
    );
    return switch (_variant) {
      _WindowControlSliverAppBarVariant.small => SliverAppBar(
        leading: slots.leading,
        automaticallyImplyLeading: slots.automaticallyImplyLeading,
        title: title,
        actions: slots.actions,
        automaticallyImplyActions: slots.automaticallyImplyActions,
        flexibleSpace: flexibleSpace,
        bottom: bottom,
        elevation: elevation,
        scrolledUnderElevation: scrolledUnderElevation,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        forceElevated: forceElevated,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        iconTheme: iconTheme,
        actionsIconTheme: actionsIconTheme,
        primary: primary,
        centerTitle: centerTitle,
        titleSpacing: titleSpacing,
        collapsedHeight: collapsedHeight,
        expandedHeight: expandedHeight,
        floating: floating,
        pinned: pinned,
        snap: snap,
        stretch: stretch,
        stretchTriggerOffset: stretchTriggerOffset,
        onStretchTrigger: onStretchTrigger,
        shape: shape,
        toolbarHeight: toolbarHeight ?? kToolbarHeight,
        leadingWidth: slots.leadingWidth,
        systemOverlayStyle: systemOverlayStyle,
        forceMaterialTransparency: forceMaterialTransparency,
        actionsPadding: actionsPadding,
      ),
      _WindowControlSliverAppBarVariant.large => _buildLarge(slots),
    };
  }

  Widget _buildLarge(_MaterialToolbarSlots slots) {
    final toolbarHeight = this.toolbarHeight;
    if (toolbarHeight == null) {
      return SliverAppBar.large(
        leading: slots.leading,
        automaticallyImplyLeading: slots.automaticallyImplyLeading,
        title: title,
        actions: slots.actions,
        automaticallyImplyActions: slots.automaticallyImplyActions,
        flexibleSpace: flexibleSpace,
        bottom: bottom,
        elevation: elevation,
        scrolledUnderElevation: scrolledUnderElevation,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        forceElevated: forceElevated,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        iconTheme: iconTheme,
        actionsIconTheme: actionsIconTheme,
        primary: primary,
        centerTitle: centerTitle,
        titleSpacing: titleSpacing,
        collapsedHeight: collapsedHeight,
        expandedHeight: expandedHeight,
        floating: floating,
        pinned: pinned,
        snap: snap,
        stretch: stretch,
        stretchTriggerOffset: stretchTriggerOffset,
        onStretchTrigger: onStretchTrigger,
        shape: shape,
        leadingWidth: slots.leadingWidth,
        systemOverlayStyle: systemOverlayStyle,
        forceMaterialTransparency: forceMaterialTransparency,
        actionsPadding: actionsPadding,
      );
    }
    return SliverAppBar.large(
      leading: slots.leading,
      automaticallyImplyLeading: slots.automaticallyImplyLeading,
      title: title,
      actions: slots.actions,
      automaticallyImplyActions: slots.automaticallyImplyActions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      forceElevated: forceElevated,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      primary: primary,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      collapsedHeight: collapsedHeight,
      expandedHeight: expandedHeight,
      floating: floating,
      pinned: pinned,
      snap: snap,
      stretch: stretch,
      stretchTriggerOffset: stretchTriggerOffset,
      onStretchTrigger: onStretchTrigger,
      shape: shape,
      toolbarHeight: toolbarHeight,
      leadingWidth: slots.leadingWidth,
      systemOverlayStyle: systemOverlayStyle,
      forceMaterialTransparency: forceMaterialTransparency,
      actionsPadding: actionsPadding,
    );
  }
}

final class _MaterialToolbarSlots {
  const _MaterialToolbarSlots({
    required this.leading,
    required this.automaticallyImplyLeading,
    required this.leadingWidth,
    required this.actions,
    required this.automaticallyImplyActions,
  });

  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double? leadingWidth;
  final List<Widget>? actions;
  final bool automaticallyImplyActions;
}

_MaterialToolbarSlots _resolveMaterialToolbarSlots(
  BuildContext context, {
  required Widget? leading,
  required bool automaticallyImplyLeading,
  required List<Widget>? actions,
  required bool automaticallyImplyActions,
  required double? leadingWidth,
  required EdgeInsetsDirectional? avoidance,
  required EdgeInsetsDirectional edgePadding,
}) {
  final geometry = WindowControlToolbarGeometry.resolve(
    context,
    avoidance: avoidance,
    edgePadding: edgePadding,
  );
  final startInset = geometry.materialStartInset;
  final endInset = geometry.materialEndInset;
  final scaffold = startInset > 0 || endInset > 0
      ? Scaffold.maybeOf(context)
      : null;
  var effectiveLeading = leading;
  var effectiveAutomaticallyImplyLeading = automaticallyImplyLeading;
  if (startInset > 0 && effectiveLeading == null && automaticallyImplyLeading) {
    final route = ModalRoute.of(context);
    if (scaffold?.hasDrawer ?? false) {
      effectiveLeading = const DrawerButton();
    } else if (route?.impliesAppBarDismissal ?? false) {
      effectiveLeading = route is PageRoute<dynamic> && route.fullscreenDialog
          ? const CloseButton()
          : const BackButton();
    }
  }
  if (startInset > 0) effectiveAutomaticallyImplyLeading = false;

  List<Widget>? effectiveActions = actions;
  var effectiveAutomaticallyImplyActions = automaticallyImplyActions;
  if (endInset > 0 &&
      (effectiveActions == null || effectiveActions.isEmpty) &&
      automaticallyImplyActions &&
      (scaffold?.hasEndDrawer ?? false)) {
    effectiveActions = const [EndDrawerButton()];
  }
  if (endInset > 0) effectiveAutomaticallyImplyActions = false;

  Widget? paddedLeading;
  double? effectiveLeadingWidth = leadingWidth;
  if (startInset > 0 && effectiveLeading != null) {
    final baseLeadingWidth =
        leadingWidth ?? AppBarTheme.of(context).leadingWidth ?? kToolbarHeight;
    paddedLeading = Padding(
      padding: EdgeInsetsDirectional.only(start: startInset),
      child: effectiveLeading,
    );
    effectiveLeadingWidth = baseLeadingWidth + startInset;
  } else if (startInset > 0) {
    paddedLeading = const SizedBox.shrink();
    effectiveLeadingWidth = startInset;
  }

  if (endInset > 0) {
    effectiveActions = [...?effectiveActions, SizedBox(width: endInset)];
    if (effectiveActions.isEmpty) effectiveActions = null;
  }

  return _MaterialToolbarSlots(
    leading: startInset > 0 ? paddedLeading : leading,
    automaticallyImplyLeading: effectiveAutomaticallyImplyLeading,
    leadingWidth: effectiveLeadingWidth,
    actions: effectiveActions,
    automaticallyImplyActions: effectiveAutomaticallyImplyActions,
  );
}

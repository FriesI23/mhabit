import 'package:flutter/cupertino.dart';

import '../adaptive/app_bar_apple_style.dart';
import '../breakpoints/window_size_class.dart';
import '../shell/navigation_sidebar_app_bar_leading.dart';
import '../window_control/cupertino_navigation_bar.dart';
import '../window_control/toolbar_geometry.dart';
import 'cupertino_toolbar_padding.dart';

const List<Widget> _kDefaultActions = <Widget>[];

/// Cupertino renderer used by the adaptive sliver app bar.
class CupertinoSliverAppBar extends StatelessWidget {
  const CupertinoSliverAppBar({
    super.key,
    required this.title,
    this.actions = _kDefaultActions,
    this.leading,
    this.onLeadingPressed,
    this.height,
    this.bottom,
    this.bottomExtent = 0.0,
    required this.style,
    this.windowControlAvoidance,
  }) : assert(bottomExtent >= 0.0),
       assert(bottom != null || bottomExtent == 0.0),
       assert(bottom == null || height != null);

  final Widget title;
  final List<Widget> actions;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final double? height;
  final Widget? bottom;
  final double bottomExtent;
  final AppBarAppleStyle style;
  final EdgeInsetsDirectional? windowControlAvoidance;

  Widget? _effectiveTrailing(List<Widget> effectiveActions) =>
      effectiveActions.isEmpty
      ? null
      : Row(mainAxisSize: MainAxisSize.min, children: effectiveActions);

  @override
  Widget build(BuildContext context) {
    final sidebarLeading = NavigationSidebarAppBarLeading.maybeOf(context);
    final hasLeading =
        sidebarLeading != null || leading != null || onLeadingPressed != null;
    final effectiveLeading = hasLeading
        ? _CupertinoSliverAppBarLeading(
            sidebarLeading: sidebarLeading,
            leading: leading,
            onLeadingPressed: onLeadingPressed,
          )
        : null;
    final effectiveTrailing = _effectiveTrailing(actions);
    final effectiveWindowControlAvoidance =
        windowControlAvoidance ?? sidebarLeading?.toolbarAvoidance;
    final height = this.height;
    if (height != null) {
      return _FixedCupertinoSliverAppBar(
        title: title,
        leading: effectiveLeading,
        trailing: effectiveTrailing,
        toolbarHeight: height,
        bottom: bottom,
        bottomExtent: bottomExtent,
        enableBackgroundFilterBlur: style.enableBackgroundFilterBlur,
        automaticBackgroundVisibility: style.automaticBackgroundVisibility,
        border: style.border,
        backgroundColor: style.backgroundColor,
        padding: style.padding,
        windowControlAvoidance: effectiveWindowControlAvoidance,
        windowControlEdgePadding: style.windowControlEdgePadding,
      );
    }
    return _CollapsibleCupertinoSliverAppBar(
      title: title,
      leading: effectiveLeading,
      trailing: effectiveTrailing,
      enableBackgroundFilterBlur: style.enableBackgroundFilterBlur,
      border: style.border,
      backgroundColor: style.backgroundColor,
      automaticBackgroundVisibility: style.automaticBackgroundVisibility,
      padding: style.padding,
      stretch: style.stretch,
      windowControlAvoidance: effectiveWindowControlAvoidance,
      windowControlEdgePadding: style.windowControlEdgePadding,
    );
  }
}

class _CupertinoSliverAppBarLeading extends StatelessWidget {
  const _CupertinoSliverAppBarLeading({
    required this.sidebarLeading,
    required this.leading,
    required this.onLeadingPressed,
  });

  final NavigationSidebarAppBarLeading? sidebarLeading;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;

  @override
  Widget build(BuildContext context) {
    final sidebarLeading = this.sidebarLeading;
    final leading =
        this.leading ??
        (onLeadingPressed == null
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onLeadingPressed,
                child: const Icon(CupertinoIcons.back),
              ));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sidebarLeading case final sidebarLeading?)
          SizedBox(
            key: const ValueKey('cupertino-sidebar-leading-anchor'),
            width: sidebarLeading.reservedExtent,
            height: NavigationSidebarAppBarLeading.buttonExtent,
          ),
        ?leading,
      ],
    );
  }
}

class _FixedCupertinoSliverAppBar extends StatelessWidget {
  const _FixedCupertinoSliverAppBar({
    required this.title,
    required this.leading,
    required this.trailing,
    required this.toolbarHeight,
    required this.bottom,
    required this.bottomExtent,
    required this.enableBackgroundFilterBlur,
    required this.automaticBackgroundVisibility,
    required this.border,
    required this.backgroundColor,
    required this.padding,
    required this.windowControlAvoidance,
    required this.windowControlEdgePadding,
  });

  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final double toolbarHeight;
  final Widget? bottom;
  final double bottomExtent;
  final bool enableBackgroundFilterBlur;
  final bool automaticBackgroundVisibility;
  final Border? border;
  final Color? backgroundColor;
  final EdgeInsetsDirectional? padding;
  final EdgeInsetsDirectional? windowControlAvoidance;
  final EdgeInsetsDirectional windowControlEdgePadding;

  @override
  Widget build(BuildContext context) {
    final sidebarLeading = NavigationSidebarAppBarLeading.maybeOf(context);
    final topPadding =
        MediaQuery.paddingOf(context).top +
        (sidebarLeading?.toolbarTopInset ?? 0);
    final extent = topPadding + toolbarHeight + bottomExtent;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _FixedCupertinoToolbarDelegate(
        extent: extent,
        child: SizedBox(
          height: extent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CupertinoNavigationBar(
                automaticallyImplyLeading: false,
                transitionBetweenRoutes: false,
                automaticBackgroundVisibility: automaticBackgroundVisibility,
                enableBackgroundFilterBlur: enableBackgroundFilterBlur,
                border: border,
                backgroundColor: backgroundColor,
              ),
              Positioned(
                top: topPadding,
                left: 0,
                right: 0,
                height: toolbarHeight,
                child: _CupertinoToolbar(
                  title: title,
                  leading: leading,
                  trailing: trailing,
                  padding: padding,
                  windowControlAvoidance: windowControlAvoidance,
                  windowControlEdgePadding: windowControlEdgePadding,
                ),
              ),
              if (bottom case final bottom?)
                Positioned(
                  top: topPadding + toolbarHeight,
                  left: 0,
                  right: 0,
                  height: bottomExtent,
                  child: bottom,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CupertinoToolbar extends StatelessWidget {
  const _CupertinoToolbar({
    required this.title,
    required this.leading,
    required this.trailing,
    required this.padding,
    required this.windowControlAvoidance,
    required this.windowControlEdgePadding,
  });

  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsDirectional? padding;
  final EdgeInsetsDirectional? windowControlAvoidance;
  final EdgeInsetsDirectional windowControlEdgePadding;

  @override
  Widget build(BuildContext context) {
    final contentPadding = CupertinoToolbarPadding.resolveDirectional(
      context,
      contentPadding: padding,
      edgePadding: windowControlEdgePadding,
    );
    final geometry = WindowControlToolbarGeometry.resolve(
      context,
      avoidance: windowControlAvoidance,
      edgePadding: contentPadding,
    );
    final insets = geometry.cupertinoInsets;
    final effectiveLeading = Padding(
      padding: EdgeInsetsDirectional.only(start: insets.start),
      child: leading ?? const SizedBox.shrink(),
    );
    final effectiveTrailing = Padding(
      padding: EdgeInsetsDirectional.only(end: insets.end),
      child: trailing ?? const SizedBox.shrink(),
    );
    return DefaultTextStyle(
      style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
      child: Padding(
        padding: EdgeInsets.only(top: insets.top, bottom: insets.bottom),
        child: NavigationToolbar(
          leading: effectiveLeading,
          middle: title,
          trailing: effectiveTrailing,
          middleSpacing: 6.0,
        ),
      ),
    );
  }
}

class _CollapsibleCupertinoSliverAppBar extends StatelessWidget {
  const _CollapsibleCupertinoSliverAppBar({
    required this.title,
    required this.leading,
    required this.trailing,
    required this.enableBackgroundFilterBlur,
    required this.border,
    required this.backgroundColor,
    required this.automaticBackgroundVisibility,
    required this.padding,
    required this.stretch,
    required this.windowControlAvoidance,
    required this.windowControlEdgePadding,
  });

  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final bool enableBackgroundFilterBlur;
  final Border? border;
  final Color? backgroundColor;
  final bool automaticBackgroundVisibility;
  final EdgeInsetsDirectional? padding;
  final bool stretch;
  final EdgeInsetsDirectional? windowControlAvoidance;
  final EdgeInsetsDirectional windowControlEdgePadding;

  @override
  Widget build(BuildContext context) {
    // Portrait always needs the large-title slot because the SDK chooses the
    // expanded presentation by aspect ratio. Landscape follows WindowSize.
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final useLargeTitle =
        isPortrait || WindowSize.of(context).width == WindowSizeClass.compact;
    final navigationBar = WindowControlCupertinoSliverNavigationBar(
      middle: useLargeTitle ? null : title,
      largeTitle: useLargeTitle ? title : null,
      leading: leading,
      trailing: trailing,
      enableBackgroundFilterBlur: enableBackgroundFilterBlur,
      border: border,
      backgroundColor: backgroundColor,
      automaticBackgroundVisibility: automaticBackgroundVisibility,
      padding: CupertinoToolbarPadding.resolveDirectional(
        context,
        contentPadding: padding,
        edgePadding: windowControlEdgePadding,
      ),
      stretch: stretch,
      windowControlAvoidance: windowControlAvoidance,
      windowControlEdgePadding: EdgeInsetsDirectional.zero,
    );
    final toolbarTopInset =
        NavigationSidebarAppBarLeading.maybeOf(context)?.toolbarTopInset ?? 0;
    return toolbarTopInset == 0
        ? navigationBar
        : SliverPadding(
            padding: EdgeInsets.only(top: toolbarTopInset),
            sliver: navigationBar,
          );
  }
}

class _FixedCupertinoToolbarDelegate extends SliverPersistentHeaderDelegate {
  const _FixedCupertinoToolbarDelegate({
    required this.extent,
    required this.child,
  });

  final double extent;
  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  bool shouldRebuild(_FixedCupertinoToolbarDelegate oldDelegate) =>
      extent != oldDelegate.extent || child != oldDelegate.child;
}

import 'package:flutter/cupertino.dart';

import '../breakpoints/window_size_class.dart';
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
    this.enableBackgroundFilterBlur = true,
    this.border,
    this.backgroundColor,
    this.padding,
    this.stretch = false,
  });

  final Widget title;
  final List<Widget> actions;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final double? height;
  final bool enableBackgroundFilterBlur;
  final Border? border;
  final Color? backgroundColor;
  final EdgeInsetsDirectional? padding;
  final bool stretch;

  Widget? get _effectiveLeading =>
      leading ??
      (onLeadingPressed == null
          ? null
          : CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onLeadingPressed,
              child: const Icon(CupertinoIcons.back),
            ));

  Widget? get _effectiveTrailing => actions.isEmpty
      ? null
      : Row(mainAxisSize: MainAxisSize.min, children: actions);

  @override
  Widget build(BuildContext context) {
    final height = this.height;
    if (height != null) {
      return _FixedCupertinoSliverAppBar(
        title: title,
        leading: _effectiveLeading,
        trailing: _effectiveTrailing,
        toolbarHeight: height,
        enableBackgroundFilterBlur: enableBackgroundFilterBlur,
        border: border,
        backgroundColor: backgroundColor,
        padding: padding,
      );
    }
    return _CollapsibleCupertinoSliverAppBar(
      title: title,
      leading: _effectiveLeading,
      trailing: _effectiveTrailing,
      enableBackgroundFilterBlur: enableBackgroundFilterBlur,
      border: border,
      backgroundColor: backgroundColor,
      padding: padding,
      stretch: stretch,
    );
  }
}

class _FixedCupertinoSliverAppBar extends StatelessWidget {
  const _FixedCupertinoSliverAppBar({
    required this.title,
    required this.leading,
    required this.trailing,
    required this.toolbarHeight,
    required this.enableBackgroundFilterBlur,
    required this.border,
    required this.backgroundColor,
    required this.padding,
  });

  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final double toolbarHeight;
  final bool enableBackgroundFilterBlur;
  final Border? border;
  final Color? backgroundColor;
  final EdgeInsetsDirectional? padding;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final extent = topPadding + toolbarHeight;
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
                ),
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
  });

  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsDirectional? padding;

  @override
  Widget build(BuildContext context) => DefaultTextStyle(
    style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
    child: Padding(
      padding: padding ?? CupertinoToolbarPadding.resolve(context),
      child: NavigationToolbar(
        leading: leading,
        middle: title,
        trailing: trailing,
        middleSpacing: 6.0,
      ),
    ),
  );
}

class _CollapsibleCupertinoSliverAppBar extends StatelessWidget {
  const _CollapsibleCupertinoSliverAppBar({
    required this.title,
    required this.leading,
    required this.trailing,
    required this.enableBackgroundFilterBlur,
    required this.border,
    required this.backgroundColor,
    required this.padding,
    required this.stretch,
  });

  final Widget title;
  final Widget? leading;
  final Widget? trailing;
  final bool enableBackgroundFilterBlur;
  final Border? border;
  final Color? backgroundColor;
  final EdgeInsetsDirectional? padding;
  final bool stretch;

  @override
  Widget build(BuildContext context) {
    // Portrait always needs the large-title slot because the SDK chooses the
    // expanded presentation by aspect ratio. Landscape follows WindowSize.
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final useLargeTitle =
        isPortrait || WindowSize.of(context).width == WindowSizeClass.compact;
    return CupertinoSliverNavigationBar(
      middle: useLargeTitle ? null : title,
      largeTitle: useLargeTitle ? title : null,
      leading: leading,
      trailing: trailing,
      enableBackgroundFilterBlur: enableBackgroundFilterBlur,
      border: border,
      backgroundColor: backgroundColor,
      padding: padding,
      stretch: stretch,
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

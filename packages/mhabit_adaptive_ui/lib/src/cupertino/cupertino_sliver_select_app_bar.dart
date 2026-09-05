import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';

import '../adaptive/adaptive_app_bar_actions.dart';
import '../breakpoints/breakpoints.dart';
import '../breakpoints/window_size_class.dart';
import 'app_bar_apple_style.dart';
import 'cupertino_sliver_app_bar.dart';

/// Cupertino selection-mode sliver command bar.
///
/// Select All and Done stay fixed at the logical edges. Compact layouts place
/// commands in the bottom toolbar; wider layouts place them through
/// adaptive_actions without allowing them to overlap the title.
class CupertinoSliverSelectAppBar<T extends Object> extends StatelessWidget {
  static const double toolbarHeight = 44.0;

  const CupertinoSliverSelectAppBar({
    super.key,
    required this.title,
    required this.selectAllLabel,
    required this.doneLabel,
    required this.onSelectAll,
    required this.onDone,
    required this.collection,
    required this.onInvoke,
    this.actions,
    this.style,
    this.bottom,
    this.bottomExtent = 0.0,
  }) : assert(bottomExtent >= 0.0),
       assert(bottom != null || bottomExtent == 0.0),
       _viewMode = false;

  const CupertinoSliverSelectAppBar.view({
    super.key,
    required this.title,
    required this.collection,
    required this.onInvoke,
    this.actions,
    this.style,
    this.bottom,
    this.bottomExtent = 0.0,
  }) : assert(bottomExtent >= 0.0),
       assert(bottom != null || bottomExtent == 0.0),
       selectAllLabel = '',
       doneLabel = '',
       onSelectAll = null,
       onDone = null,
       _viewMode = true;

  final Widget title;
  final String selectAllLabel;
  final String doneLabel;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDone;
  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final CupertinoAppBarActionsConfig<T>? actions;
  final AppBarAppleStyle? style;
  final Widget? bottom;
  final double bottomExtent;
  final bool _viewMode;

  AppBarAppleStyle get _effectiveStyle => style ?? const AppBarAppleStyle();

  @override
  Widget build(BuildContext context) {
    final compact =
        Breakpoints.of(context).widthClass(MediaQuery.sizeOf(context).width) ==
        WindowSizeClass.compact;
    return CupertinoSliverAppBar(
      key: const ValueKey('cupertino-sliver-select-app-bar'),
      height: toolbarHeight,
      bottom: bottom,
      bottomExtent: bottomExtent,
      style: _effectiveStyle,
      title: _viewMode
          ? _CupertinoSelectEntryToolbar<T>(
              title: title,
              collection: collection,
              onInvoke: onInvoke,
              iconBuilder: actions?.iconBuilder,
              actionButtonBuilder: actions?.actionButtonBuilder,
              menuBuilderForAction: actions?.menuBuilderForAction,
              presentationForAction: actions?.presentationForAction,
            )
          : _CupertinoSelectTopToolbar<T>(
              compact: compact,
              title: title,
              selectAllLabel: selectAllLabel,
              doneLabel: doneLabel,
              onSelectAll: onSelectAll,
              onDone: onDone,
              collection: collection,
              onInvoke: onInvoke,
              iconBuilder: actions?.iconBuilder,
              actionButtonBuilder: actions?.actionButtonBuilder,
              menuBuilderForAction: actions?.menuBuilderForAction,
              presentationForAction: actions?.presentationForAction,
            ),
    );
  }
}

/// Fixed compact selection toolbar, including the bottom safe-area inset.
class CupertinoSelectBottomToolbar<T extends Object> extends StatelessWidget {
  static const double contentHeight = 44.0;

  const CupertinoSelectBottomToolbar({
    super.key,
    required this.collection,
    required this.onInvoke,
    this.actions,
  });

  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final CupertinoAppBarActionsConfig<T>? actions;

  static double totalHeightOf(BuildContext context) =>
      contentHeight + MediaQuery.viewPaddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    final background = CupertinoDynamicColor.resolve(
      CupertinoTheme.of(context).barBackgroundColor,
      context,
    );
    return ClipRect(
      key: const ValueKey('cupertino-select-bottom-toolbar'),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: ColoredBox(
          color: background,
          child: SafeArea(
            top: false,
            minimum: EdgeInsets.zero,
            child: SizedBox(
              height: contentHeight,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                child: _CupertinoSelectActions<T>(
                  collection: collection,
                  onInvoke: onInvoke,
                  iconBuilder: actions?.iconBuilder,
                  actionButtonBuilder: actions?.actionButtonBuilder,
                  menuBuilderForAction: actions?.menuBuilderForAction,
                  presentationForAction: actions?.presentationForAction,
                  layoutDelegate: const _TrailingOverflowLayoutDelegate(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CupertinoSelectTopToolbar<T extends Object> extends StatelessWidget {
  const _CupertinoSelectTopToolbar({
    required this.compact,
    required this.title,
    required this.selectAllLabel,
    required this.doneLabel,
    required this.onSelectAll,
    required this.onDone,
    required this.collection,
    required this.onInvoke,
    required this.iconBuilder,
    required this.actionButtonBuilder,
    required this.menuBuilderForAction,
    required this.presentationForAction,
  });

  final bool compact;
  final Widget title;
  final String selectAllLabel;
  final String doneLabel;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDone;
  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final CupertinoActionIconBuilder<T>? iconBuilder;
  final CupertinoActionButtonBuilder<T>? actionButtonBuilder;
  final CupertinoActionMenuBuilder<T>? menuBuilderForAction;
  final CupertinoActionPresentationCallback<T>? presentationForAction;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: CustomMultiChildLayout(
      delegate: _SelectToolbarLayoutDelegate(
        textDirection: Directionality.of(context),
      ),
      children: [
        LayoutId(
          id: _SelectToolbarSlot.leading,
          child: _FixedTextAction(
            key: const ValueKey('cupertino-select-all-top'),
            label: selectAllLabel,
            onPressed: onSelectAll,
          ),
        ),
        LayoutId(
          id: _SelectToolbarSlot.title,
          child: DefaultTextStyle.merge(
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            child: title,
          ),
        ),
        LayoutId(
          id: _SelectToolbarSlot.actions,
          child: compact
              ? const SizedBox.shrink()
              : _CupertinoSelectActions<T>(
                  collection: collection,
                  onInvoke: onInvoke,
                  iconBuilder: iconBuilder,
                  actionButtonBuilder: actionButtonBuilder,
                  menuBuilderForAction: menuBuilderForAction,
                  presentationForAction: presentationForAction,
                ),
        ),
        LayoutId(
          id: _SelectToolbarSlot.trailing,
          child: Semantics(
            button: true,
            label: doneLabel,
            child: CupertinoButton(
              key: const ValueKey('cupertino-select-done'),
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(44),
              onPressed: onDone,
              child: const Icon(CupertinoIcons.check_mark),
            ),
          ),
        ),
      ],
    ),
  );
}

class _CupertinoSelectEntryToolbar<T extends Object> extends StatelessWidget {
  const _CupertinoSelectEntryToolbar({
    required this.title,
    required this.collection,
    required this.onInvoke,
    required this.iconBuilder,
    required this.actionButtonBuilder,
    required this.menuBuilderForAction,
    required this.presentationForAction,
  });

  final Widget title;
  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final CupertinoActionIconBuilder<T>? iconBuilder;
  final CupertinoActionButtonBuilder<T>? actionButtonBuilder;
  final CupertinoActionMenuBuilder<T>? menuBuilderForAction;
  final CupertinoActionPresentationCallback<T>? presentationForAction;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final visibleCount = collection.roots.length;
        final maxActionWidth = math.max(44.0, constraints.maxWidth - 96.0);
        return Row(
          children: [
            Expanded(
              child: DefaultTextStyle.merge(
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                child: title,
              ),
            ),
            if (visibleCount > 0)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxActionWidth),
                child: _CupertinoSelectActions<T>(
                  collection: collection,
                  onInvoke: onInvoke,
                  iconBuilder: iconBuilder,
                  actionButtonBuilder: actionButtonBuilder,
                  menuBuilderForAction: menuBuilderForAction,
                  presentationForAction: presentationForAction,
                ),
              ),
          ],
        );
      },
    ),
  );
}

enum _SelectToolbarSlot { leading, title, actions, trailing }

class _SelectToolbarLayoutDelegate extends MultiChildLayoutDelegate {
  _SelectToolbarLayoutDelegate({required this.textDirection});

  static const double spacing = 6.0;

  final TextDirection textDirection;

  @override
  void performLayout(Size size) {
    final looseConstraints = BoxConstraints.loose(size);
    final leadingSize = layoutChild(
      _SelectToolbarSlot.leading,
      looseConstraints,
    );
    final trailingSize = layoutChild(
      _SelectToolbarSlot.trailing,
      looseConstraints,
    );
    positionChild(
      _SelectToolbarSlot.leading,
      Offset(
        textDirection == TextDirection.ltr ? 0 : size.width - leadingSize.width,
        (size.height - leadingSize.height) / 2,
      ),
    );
    positionChild(
      _SelectToolbarSlot.trailing,
      Offset(
        textDirection == TextDirection.ltr
            ? size.width - trailingSize.width
            : 0,
        (size.height - trailingSize.height) / 2,
      ),
    );

    final titleSideInset = math.max(leadingSize.width, trailingSize.width);
    final titleSize = layoutChild(
      _SelectToolbarSlot.title,
      BoxConstraints.loose(
        Size(math.max(0, size.width - titleSideInset * 2), size.height),
      ),
    );
    final titleX = (size.width - titleSize.width) / 2;
    positionChild(
      _SelectToolbarSlot.title,
      Offset(titleX, (size.height - titleSize.height) / 2),
    );

    final actionStart = switch (textDirection) {
      TextDirection.ltr => titleX + titleSize.width + spacing,
      TextDirection.rtl => trailingSize.width,
    };
    final actionEnd = switch (textDirection) {
      TextDirection.ltr => size.width - trailingSize.width,
      TextDirection.rtl => titleX - spacing,
    };
    final actionWidth = math.max(0.0, actionEnd - actionStart);
    final actionSize = layoutChild(
      _SelectToolbarSlot.actions,
      BoxConstraints.tightFor(width: actionWidth, height: size.height),
    );
    positionChild(
      _SelectToolbarSlot.actions,
      Offset(actionStart, (size.height - actionSize.height) / 2),
    );
  }

  @override
  bool shouldRelayout(_SelectToolbarLayoutDelegate oldDelegate) =>
      textDirection != oldDelegate.textDirection;
}

class _FixedTextAction extends StatelessWidget {
  const _FixedTextAction({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 44, maxWidth: 132),
    child: Semantics(
      button: true,
      label: label,
      child: CupertinoButton(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
        minimumSize: const Size(44, 44),
        onPressed: onPressed,
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    ),
  );
}

class _CupertinoSelectActions<T extends Object> extends StatelessWidget {
  const _CupertinoSelectActions({
    required this.collection,
    required this.onInvoke,
    required this.iconBuilder,
    required this.actionButtonBuilder,
    required this.menuBuilderForAction,
    required this.presentationForAction,
    this.layoutDelegate,
  });

  final ActionCollection<T> collection;
  final AdaptiveAppBarActionCallback<T> onInvoke;
  final CupertinoActionIconBuilder<T>? iconBuilder;
  final CupertinoActionButtonBuilder<T>? actionButtonBuilder;
  final CupertinoActionMenuBuilder<T>? menuBuilderForAction;
  final CupertinoActionPresentationCallback<T>? presentationForAction;
  final ActionRegionLayoutDelegate? layoutDelegate;

  @override
  Widget build(BuildContext context) {
    if (collection.roots.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final capacity = constraints.maxWidth;
        if (capacity < 44.0) return const SizedBox.shrink();
        return ClipRect(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            widthFactor: 1,
            child: KeyedSubtree(
              key: const ValueKey('cupertino-select-adaptive-actions'),
              child: AdaptiveAppBarActions<T>.apple(
                key: const ValueKey('cupertino-select-action-host'),
                collection: collection,
                primaryCapacity: capacity,
                onInvoke: onInvoke,
                apple: CupertinoAppBarActionsConfig<T>(
                  presentationForAction: presentationForAction,
                  iconBuilder: iconBuilder,
                  actionButtonBuilder: actionButtonBuilder,
                  menuBuilderForAction: menuBuilderForAction,
                ),
                layoutDelegate: layoutDelegate,
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _TrailingOverflowLayoutDelegate
    implements ActionRegionLayoutDelegate {
  const _TrailingOverflowLayoutDelegate();

  @override
  ActionRegionLayoutReservation reserve(
    ActionRegionLayoutReservationInput input,
  ) => ActionRegionLayoutReservation();

  @override
  ActionRegionLayoutPlan layout(ActionRegionLayoutInput input) {
    final entries = <ActionRegionLayoutEntry>[];
    for (final slot in input.slots) {
      if (slot.id.isOverflow && entries.isNotEmpty) {
        entries.add(ActionRegionLayoutEntry.flexGap());
      }
      entries.add(ActionRegionLayoutEntry.slot(slot.id));
    }
    return ActionRegionLayoutPlan(entries: entries);
  }
}

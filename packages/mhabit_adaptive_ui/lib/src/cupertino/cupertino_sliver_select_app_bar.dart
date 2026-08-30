import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';

import '../breakpoints/breakpoints.dart';
import '../breakpoints/window_size_class.dart';
import 'cupertino_sliver_app_bar.dart';

const List<CupertinoSelectAction> _kDefaultActions = <CupertinoSelectAction>[];

typedef CupertinoSelectPrimaryActionBuilder =
    Widget Function(BuildContext context, VoidCallback? onPressed);

enum CupertinoSelectActionPresentation { iconOnly, iconAndLabel }

/// A controlled command used by the Cupertino selection surfaces.
@immutable
final class CupertinoSelectAction {
  const CupertinoSelectAction({
    required this.id,
    required this.label,
    required this.icon,
    this.onPressed,
    this.visible = true,
    this.enabled = true,
    this.destructive = false,
    this.overflowOnly = false,
    this.overflowBelowLarge = false,
    this.retentionPriority = 0,
    this.presentation = CupertinoSelectActionPresentation.iconOnly,
    this.primaryBuilder,
  });

  final String id;
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool visible;
  final bool enabled;
  final bool destructive;
  final bool overflowOnly;
  final bool overflowBelowLarge;
  final int retentionPriority;
  final CupertinoSelectActionPresentation presentation;
  final CupertinoSelectPrimaryActionBuilder? primaryBuilder;
}

/// Cupertino selection-mode sliver command bar.
///
/// Select All and Done stay fixed at the logical edges. Compact layouts place
/// commands in the bottom toolbar; wider layouts place them through
/// adaptive_actions without allowing them to overlap the title.
class CupertinoSliverSelectAppBar extends StatelessWidget {
  static const double toolbarHeight = 44.0;

  const CupertinoSliverSelectAppBar({
    super.key,
    required this.title,
    required this.selectAllLabel,
    required this.doneLabel,
    required this.onSelectAll,
    required this.onDone,
    this.actions = _kDefaultActions,
  }) : _viewMode = false;

  const CupertinoSliverSelectAppBar.view({
    super.key,
    required this.title,
    this.actions = _kDefaultActions,
  }) : selectAllLabel = '',
       doneLabel = '',
       onSelectAll = null,
       onDone = null,
       _viewMode = true;

  final Widget title;
  final String selectAllLabel;
  final String doneLabel;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDone;
  final List<CupertinoSelectAction> actions;
  final bool _viewMode;

  @override
  Widget build(BuildContext context) {
    final compact =
        Breakpoints.of(context).widthClass(MediaQuery.sizeOf(context).width) ==
        WindowSizeClass.compact;
    return CupertinoSliverAppBar(
      key: const ValueKey('cupertino-sliver-select-app-bar'),
      height: toolbarHeight,
      backgroundColor: CupertinoColors.transparent,
      border: null,
      title: _viewMode
          ? _CupertinoSelectEntryToolbar(title: title, actions: actions)
          : _CupertinoSelectTopToolbar(
              compact: compact,
              title: title,
              selectAllLabel: selectAllLabel,
              doneLabel: doneLabel,
              onSelectAll: onSelectAll,
              onDone: onDone,
              actions: actions,
            ),
    );
  }
}

/// Fixed compact selection toolbar, including the bottom safe-area inset.
class CupertinoSelectBottomToolbar extends StatelessWidget {
  static const double contentHeight = 44.0;

  const CupertinoSelectBottomToolbar({
    super.key,
    this.actions = _kDefaultActions,
  });

  final List<CupertinoSelectAction> actions;

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
          color: background.withValues(alpha: 0.82),
          child: SafeArea(
            top: false,
            minimum: EdgeInsets.zero,
            child: SizedBox(
              height: contentHeight,
              child: _CupertinoSelectBottomContent(actions: actions),
            ),
          ),
        ),
      ),
    );
  }
}

class _CupertinoSelectTopToolbar extends StatelessWidget {
  const _CupertinoSelectTopToolbar({
    required this.compact,
    required this.title,
    required this.selectAllLabel,
    required this.doneLabel,
    required this.onSelectAll,
    required this.onDone,
    required this.actions,
  });

  final bool compact;
  final Widget title;
  final String selectAllLabel;
  final String doneLabel;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDone;
  final List<CupertinoSelectAction> actions;

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
          child: _CupertinoSelectActions(
            actions: compact ? _kDefaultActions : actions,
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

class _CupertinoSelectEntryToolbar extends StatelessWidget {
  const _CupertinoSelectEntryToolbar({
    required this.title,
    required this.actions,
  });

  final Widget title;
  final List<CupertinoSelectAction> actions;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final visibleCount = actions.where((action) => action.visible).length;
        final actionWidth = math.min(
          visibleCount * 44.0,
          math.max(44.0, constraints.maxWidth - 96.0),
        );
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
              SizedBox(
                width: actionWidth,
                child: _CupertinoSelectActions(actions: actions),
              ),
          ],
        );
      },
    ),
  );
}

class _CupertinoSelectBottomContent extends StatelessWidget {
  const _CupertinoSelectBottomContent({required this.actions});

  final List<CupertinoSelectAction> actions;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
    child: _CupertinoSelectActions(
      actions: actions,
      layoutDelegate: const _TrailingOverflowLayoutDelegate(),
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

class _CupertinoSelectActions extends StatelessWidget {
  const _CupertinoSelectActions({required this.actions, this.layoutDelegate});

  final List<CupertinoSelectAction> actions;
  final ActionRegionLayoutDelegate? layoutDelegate;

  @override
  Widget build(BuildContext context) {
    final visibleActions = actions.where((action) => action.visible).toList();
    if (visibleActions.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final capacity = constraints.maxWidth;
        if (capacity < 44.0) return const SizedBox.shrink();
        final widthClass = Breakpoints.of(
          context,
        ).widthClass(MediaQuery.sizeOf(context).width);
        final large = widthClass.index >= WindowSizeClass.large.index;
        final actionsById = <String, CupertinoSelectAction>{
          for (final action in visibleActions) action.id: action,
        };
        return SizedBox(
          width: capacity,
          child: ClipRect(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: KeyedSubtree(
                key: const ValueKey('cupertino-select-adaptive-actions'),
                child: CupertinoAdaptiveActions<VoidCallback>.moreAction(
                  key: ValueKey(('cupertino-select-tier', large)),
                  actions: ActionCollection<VoidCallback>(
                    roots: visibleActions.map(
                      (action) => _toAdaptiveAction(action, large: large),
                    ),
                  ),
                  primaryCapacity: capacity,
                  presentationForAction: (context, action) =>
                      switch (actionsById[action.id.value]?.presentation) {
                        CupertinoSelectActionPresentation.iconOnly =>
                          CupertinoActionPresentation.iconOnly,
                        CupertinoSelectActionPresentation.iconAndLabel =>
                          CupertinoActionPresentation.extended,
                        null => null,
                      },
                  onInvoke: (callback) => callback(),
                  invokeAfterMenuClosed: true,
                  iconBuilder: (context, action) {
                    final descriptor = actionsById[action.id.value];
                    return descriptor?.icon;
                  },
                  actionButtonBuilder:
                      (context, action, onPressed, defaultBuilder) {
                        final descriptor = actionsById[action.id.value];
                        final custom = descriptor?.primaryBuilder;
                        if (custom != null) {
                          return custom(context, onPressed);
                        }
                        return defaultBuilder(context, action, onPressed);
                      },
                  layoutDelegate: layoutDelegate,
                  fadeDuration: Duration.zero,
                  resizeDuration: Duration.zero,
                ),
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

AdaptiveAction<VoidCallback> _toAdaptiveAction(
  CupertinoSelectAction action, {
  required bool large,
}) => AdaptiveAction<VoidCallback>.action(
  id: ActionId(action.id),
  metadata: ActionMetadata(
    label: action.label,
    tooltip: action.label,
    iconKey: action.id,
    isDestructive: action.destructive,
  ),
  payload: action.onPressed ?? () {},
  isEnabled: action.enabled && action.onPressed != null,
  placementPolicy: action.overflowOnly || (action.overflowBelowLarge && !large)
      ? ActionPlacementPolicy(placement: ActionPlacement.overflowOnly)
      : ActionPlacementPolicy(
          automaticPreference: AutomaticPlacementPreference(
            retentionPriority: PrimaryRetentionPriority.custom(
              action.retentionPriority,
            ),
          ),
        ),
);

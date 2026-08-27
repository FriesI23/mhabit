import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show
        CircleBorder,
        FloatingActionButton,
        FloatingActionButtonLocation,
        IconTheme,
        MaterialTapTargetSize,
        Theme;

import '../shell/navigation_shell_frame.dart';
import 'cupertino_floating_surface.dart';

const Object _defaultHeroTag = _CupertinoDefaultHeroTag();

final class _CupertinoDefaultHeroTag {
  const _CupertinoDefaultHeroTag();
}

/// A Cupertino navigation shell primary-action description.
@immutable
final class CupertinoNavigationPrimaryAction {
  /// Creates a page-owned primary action.
  ///
  /// The action is interactive only when [enabled] is true and [onPressed] is
  /// non-null.
  const CupertinoNavigationPrimaryAction({
    this.id = _defaultHeroTag,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
    this.prominent = true,
  });

  /// Stable Hero and transition identity for this action.
  ///
  /// The default uses the floating action button's standard Hero identity. A
  /// custom value distinguishes simultaneous actions, while null disables the
  /// Hero transition.
  final Object? id;

  /// Accessible label used by semantics and the button tooltip.
  final String label;

  /// Icon displayed inside the circular action surface.
  final Widget icon;

  /// Callback invoked when the enabled action is pressed.
  ///
  /// A null callback disables interaction regardless of [enabled].
  final VoidCallback? onPressed;

  /// Whether [onPressed] may be invoked.
  final bool enabled;

  /// Whether the action uses the prominent primary-container colors.
  final bool prominent;
}

/// Registers a page-owned action with the nearest Cupertino navigation shell.
///
/// Only an active [TickerMode] subtree reports its action. Switching the shell
/// destination advances the owning generation so the old branch releases its
/// action. Owner checks prevent a delayed release from clearing a newer
/// branch's action.
///
/// ```text
/// page
///  `-- CupertinoNavigationPrimaryActionRegion
///          | reports action
///          v
///      scope/controller --> shell host --> [ + ]
/// ```
class CupertinoNavigationPrimaryActionRegion extends StatefulWidget {
  /// Creates a region that reports [action] while [child] is active.
  const CupertinoNavigationPrimaryActionRegion({
    super.key,
    required this.action,
    required this.child,
  });

  /// Page-owned action reported to the nearest Cupertino navigation shell.
  ///
  /// A null value releases any action previously reported by this region.
  final CupertinoNavigationPrimaryAction? action;

  /// Page subtree associated with [action].
  final Widget child;

  @override
  State<CupertinoNavigationPrimaryActionRegion> createState() =>
      _CupertinoNavigationPrimaryActionRegionState();
}

class _CupertinoNavigationPrimaryActionRegionState
    extends State<CupertinoNavigationPrimaryActionRegion> {
  final Object _owner = Object();
  CupertinoNavigationPrimaryActionScope? _scope;
  CupertinoNavigationPrimaryAction? _reportedAction;
  int? _reportedGeneration;
  bool _reportPending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextScope = CupertinoNavigationPrimaryActionScope.maybeOf(context);
    final nextGeneration = nextScope?.generation;
    if (!identical(_scope, nextScope)) {
      final previousScope = _scope;
      _scope = nextScope;
      _reportedAction = null;
      _reportedGeneration = nextGeneration;
      if (previousScope != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => previousScope.release(_owner),
        );
      }
    } else if (_reportedGeneration != nextGeneration) {
      _reportedAction = null;
      _reportedGeneration = nextGeneration;
    }
    _scheduleReport();
  }

  @override
  void didUpdateWidget(
    covariant CupertinoNavigationPrimaryActionRegion oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.action, widget.action)) _scheduleReport();
  }

  void _scheduleReport() {
    if (_reportPending) return;
    _reportPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportPending = false;
      if (!mounted) return;
      final action = TickerMode.valuesOf(context).enabled
          ? widget.action
          : null;
      final generation = _scope?.generation;
      if (_reportedGeneration == generation &&
          identical(_reportedAction, action)) {
        return;
      }
      _reportedGeneration = generation;
      _reportedAction = action;
      _scope?.report(_owner, action);
    });
  }

  @override
  void dispose() {
    final scope = _scope;
    if (scope != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => scope.release(_owner),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TickerMode.valuesOf(context);
    return widget.child;
  }
}

/// Holds the primary action currently owned by an active page region.
class CupertinoNavigationPrimaryActionController
    extends ValueNotifier<CupertinoNavigationPrimaryAction?> {
  /// Creates a controller with no registered action.
  CupertinoNavigationPrimaryActionController() : super(null);

  Object? _owner;
  bool _disposed = false;

  /// Registers [action] as the value currently owned by [owner].
  void report(Object owner, CupertinoNavigationPrimaryAction? action) {
    if (_disposed) return;
    if (action == null) {
      release(owner);
      return;
    }
    _owner = owner;
    if (identical(value, action)) return;
    value = action;
  }

  /// Clears the current action when it is still owned by [owner].
  void release(Object owner) {
    if (_disposed || !identical(_owner, owner)) return;
    _owner = null;
    if (value == null) return;
    value = null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Exposes primary-action registration to page regions below the shell.
class CupertinoNavigationPrimaryActionScope extends InheritedWidget {
  /// Creates a registration scope for [controller] and [generation].
  const CupertinoNavigationPrimaryActionScope({
    super.key,
    required this.controller,
    required this.generation,
    required super.child,
  });

  /// Controller that owns the action reported by the active region.
  final CupertinoNavigationPrimaryActionController controller;

  /// Destination generation used to invalidate an action from an old branch.
  final int generation;

  /// Registers [action] as the value currently owned by [owner].
  void report(Object owner, CupertinoNavigationPrimaryAction? action) =>
      controller.report(owner, action);

  /// Clears the current action when it is still owned by [owner].
  void release(Object owner) => controller.release(owner);

  /// Returns the nearest scope, or null when no Cupertino shell is present.
  static CupertinoNavigationPrimaryActionScope? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<
            CupertinoNavigationPrimaryActionScope
          >();

  @override
  bool updateShouldNotify(CupertinoNavigationPrimaryActionScope oldWidget) =>
      controller != oldWidget.controller || generation != oldWidget.generation;
}

/// Renders a Cupertino primary action as a floating circular button.
class CupertinoNavigationPrimaryActionButton extends StatelessWidget {
  /// Creates a button with the square [extent].
  const CupertinoNavigationPrimaryActionButton({
    super.key,
    required this.action,
    this.extent = 50,
  }) : assert(extent >= 44 && extent < double.infinity);

  /// Action that supplies identity, semantics, appearance, and interaction.
  final CupertinoNavigationPrimaryAction action;

  /// Width and height of the circular button.
  final double extent;

  /// Returns the Scaffold location aligned to the trailing floating surface.
  static FloatingActionButtonLocation floatingLocationOf(
    BuildContext context,
  ) => CupertinoFloatingSurfaceGeometry.resolveOf(context).endFloatLocation;

  @override
  Widget build(BuildContext context) {
    final onPressed = action.enabled ? action.onPressed : null;
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = action.prominent
        ? colorScheme.primaryContainer.withValues(alpha: 0.82)
        : CupertinoDynamicColor.resolve(
            CupertinoTheme.of(context).barBackgroundColor,
            context,
          );
    final foregroundColor = action.prominent
        ? colorScheme.onPrimaryContainer
        : CupertinoDynamicColor.resolve(
            CupertinoTheme.of(context).primaryColor,
            context,
          );
    final borderRadius = BorderRadius.circular(extent / 2);
    final theme = Theme.of(context);
    final fabChild = CupertinoFloatingGlassSurface(
      key: const ValueKey('cupertino-primary-action-surface'),
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      child: SizedBox.expand(
        child: Center(
          child: IconTheme(
            data: IconThemeData(color: foregroundColor, size: 22),
            child: action.icon,
          ),
        ),
      ),
    );
    final fab = identical(action.id, _defaultHeroTag)
        ? FloatingActionButton(
            tooltip: action.label,
            foregroundColor: foregroundColor,
            backgroundColor: CupertinoColors.transparent,
            focusColor: CupertinoColors.transparent,
            hoverColor: CupertinoColors.transparent,
            splashColor: CupertinoColors.transparent,
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
            disabledElevation: 0,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const CircleBorder(),
            clipBehavior: Clip.none,
            onPressed: onPressed,
            child: fabChild,
          )
        : FloatingActionButton(
            heroTag: action.id,
            tooltip: action.label,
            foregroundColor: foregroundColor,
            backgroundColor: CupertinoColors.transparent,
            focusColor: CupertinoColors.transparent,
            hoverColor: CupertinoColors.transparent,
            splashColor: CupertinoColors.transparent,
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
            disabledElevation: 0,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const CircleBorder(),
            clipBehavior: Clip.none,
            onPressed: onPressed,
            child: fabChild,
          );
    final button = Theme(
      data: theme.copyWith(
        floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
          sizeConstraints: BoxConstraints.tight(Size.square(extent)),
        ),
      ),
      child: fab,
    );
    final actionIdentity =
        identical(action.id, _defaultHeroTag) || action.id == null
        ? action
        : action.id!;
    return SizedBox.square(
      key: ValueKey<Object>(actionIdentity),
      dimension: extent,
      child: Semantics(
        label: action.label,
        button: true,
        enabled: onPressed != null,
        excludeSemantics: true,
        onTap: onPressed,
        child: button,
      ),
    );
  }
}

/// Bridges the shell's action state to its animated floating button.
class CupertinoNavigationPrimaryActionHost extends StatelessWidget {
  /// Creates a host for the shell's current [action].
  const CupertinoNavigationPrimaryActionHost({
    super.key,
    required this.action,
    required this.scrollWish,
    required this.visibility,
    required this.compact,
    required this.routeVisible,
  });

  /// Listenable action reported by the active page region.
  final ValueListenable<CupertinoNavigationPrimaryAction?> action;

  /// Whether compact Apple navigation is expanded rather than minimized.
  final ValueListenable<bool> scrollWish;

  /// Whether compact navigation chrome is visible.
  final ValueListenable<bool> visibility;

  /// Whether the shell currently uses its compact bottom-bar form.
  final bool compact;

  /// Whether route structure allows compact chrome to be displayed.
  final bool routeVisible;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return ValueListenableBuilder<CupertinoNavigationPrimaryAction?>(
      valueListenable: action,
      builder: (context, primaryAction, child) => ValueListenableBuilder<bool>(
        valueListenable: scrollWish,
        builder: (context, expanded, child) => TweenAnimationBuilder<double>(
          duration: disableAnimations
              ? Duration.zero
              : navigationShellAnimationDuration,
          curve: Curves.easeOut,
          tween: Tween(end: compact && !expanded ? 44 : 50),
          builder: (context, extent, child) =>
              CompactNavigationChromeTransition(
                visibility: visibility,
                progressKey: const ValueKey(
                  'apple-primary-action-chrome-opacity',
                ),
                child: _PrimaryActionAnimatedSwitcher(
                  action: !compact && !routeVisible ? null : primaryAction,
                  extent: extent,
                  disableAnimations: disableAnimations,
                ),
              ),
        ),
      ),
    );
  }
}

class _PrimaryActionAnimatedSwitcher extends StatefulWidget {
  const _PrimaryActionAnimatedSwitcher({
    required this.action,
    required this.extent,
    required this.disableAnimations,
  });

  final CupertinoNavigationPrimaryAction? action;
  final double extent;
  final bool disableAnimations;

  @override
  State<_PrimaryActionAnimatedSwitcher> createState() =>
      _PrimaryActionAnimatedSwitcherState();
}

class _PrimaryActionAnimatedSwitcherState
    extends State<_PrimaryActionAnimatedSwitcher> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _started = widget.action != null;
  }

  @override
  void didUpdateWidget(covariant _PrimaryActionAnimatedSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.action != null) _started = true;
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final actionIdentity =
        action == null ||
            identical(action.id, _defaultHeroTag) ||
            action.id == null
        ? action
        : action.id;
    if (!_started) return const SizedBox.shrink();
    return AnimatedSwitcher(
      duration: widget.disableAnimations
          ? Duration.zero
          : navigationShellAnimationDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: action != null
          ? CupertinoNavigationPrimaryActionButton(
              key: ValueKey(('apple-primary-action', actionIdentity)),
              action: action,
              extent: widget.extent,
            )
          : const SizedBox.shrink(key: ValueKey('apple-primary-action-hidden')),
    );
  }
}

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
///
/// This is an app-selected shell command, not a page-owned Material FAB. The
/// renderer currently uses [FloatingActionButton] only as a Flutter layout,
/// interaction, and Hero primitive.
///
/// The shell places the action at the trailing bottom edge (`*`) beside compact
/// navigation or independently of the sidebar in wider layouts:
///
/// ```text
/// compact                 medium / expanded
/// +------------------+    +------+-----------+
/// | content          |    | side | content   |
/// | [ navigation ] * |    | bar  |         * |
/// +------------------+    +------+-----------+
///
/// * = primary action
/// ```
@immutable
final class CupertinoNavigationPrimaryAction {
  /// Creates a primary-action description.
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
    final actionIdentity = identical(action.id, _defaultHeroTag)
        ? _defaultHeroTag
        : action.id ?? action;
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

/// Renders the shell's selected action as an animated floating button.
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

  /// Action selected declaratively by the navigation-shell owner.
  final CupertinoNavigationPrimaryAction? action;

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
    return ValueListenableBuilder<bool>(
      valueListenable: scrollWish,
      builder: (context, expanded, child) => TweenAnimationBuilder<double>(
        duration: disableAnimations
            ? Duration.zero
            : navigationShellAnimationDuration,
        curve: Curves.easeOut,
        tween: Tween(end: compact && !expanded ? 44 : 50),
        builder: (context, extent, child) => CompactNavigationChromeTransition(
          visibility: visibility,
          child: _PrimaryActionAnimatedSwitcher(
            action: !compact && !routeVisible ? null : action,
            extent: extent,
            disableAnimations: disableAnimations,
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
    final actionIdentity = action == null
        ? null
        : identical(action.id, _defaultHeroTag)
        ? _defaultHeroTag
        : action.id ?? action;
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

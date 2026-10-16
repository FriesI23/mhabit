import 'package:flutter/widgets.dart';

/// Optional app-provided registration for native titlebar hit testing. The UI
/// package never imports a window plugin; iPadOS/default callers are unchanged.
typedef AdaptiveWindowInteractionWrapper = Widget Function(Widget child);

/// Binds an optional app-provided interaction wrapper to this subtree.
/// Descendant components use [maybeOf] and [wrapInteractionRegion] to mark their
/// window interaction targets.
class AdaptiveWindowInteractionBinding extends InheritedWidget {
  final AdaptiveWindowInteractionWrapper? wrapper;

  const AdaptiveWindowInteractionBinding({
    super.key,
    required this.wrapper,
    required super.child,
  });

  /// Reads the optional binding and rebuilds the caller when it changes.
  static AdaptiveWindowInteractionBinding? maybeOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<AdaptiveWindowInteractionBinding>();

  /// Applies the app's interaction marker, or retains [child] when disabled.
  Widget wrapInteractionRegion(Widget child) => wrapper?.call(child) ?? child;

  @override
  bool updateShouldNotify(AdaptiveWindowInteractionBinding oldWidget) =>
      wrapper != oldWidget.wrapper;
}

/// Use around business targets, never around empty drag space. Composition
/// slots should keep this wrapper close to their interactive content.
class AdaptiveWindowInteractionRegion extends StatelessWidget {
  final Widget child;

  const AdaptiveWindowInteractionRegion({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      AdaptiveWindowInteractionBinding.maybeOf(
        context,
      )?.wrapInteractionRegion(child) ??
      child;
}

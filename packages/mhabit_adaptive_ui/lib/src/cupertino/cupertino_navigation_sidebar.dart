import 'package:flutter/material.dart';

import '../adaptive/adaptive_navigation_destination.dart';
import '../material/material_navigation_rail.dart';
import '../shell/navigation_shell_frame.dart';

/// Temporary medium+ compatibility renderer.
///
/// TODO(adaptive-ui::apple-sidebar): Replace the delegated Material rail with
/// the Phase 3-4 HIG sidebar. This fallback is intentionally Cupertino-owned;
/// it must not be treated as a common rail or an Apple sidebar implementation.
class CupertinoNavigationSidebarCompatibility extends StatelessWidget {
  /// Creates the temporary rail body for the current shell [form].
  const CupertinoNavigationSidebarCompatibility({
    super.key,
    required this.form,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.railExtent,
    required this.child,
  });

  /// Current compact, constrained-side, or expanded-side shell form.
  final NavigationShellForm form;

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Top-level destinations rendered by the compatibility rail.
  final List<AdaptiveNavigationDestination> destinations;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;

  /// Automatic and manually resizable rail-width policy.
  final NavigationRailExtent railExtent;

  /// Stable branch content composed beside the compatibility rail.
  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surface,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MaterialNavigationRailRegion(
          form: form,
          selectedIndex: selectedIndex,
          destinations: destinations,
          onDestinationSelected: onDestinationSelected,
          railExtent: railExtent,
        ),
        Expanded(
          child: _CupertinoCompatibilityBranch(form: form, child: child),
        ),
      ],
    ),
  );
}

class _CupertinoCompatibilityBranch extends StatelessWidget {
  const _CupertinoCompatibilityBranch({
    required this.form,
    required this.child,
  });

  final NavigationShellForm form;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (form == NavigationShellForm.compact) return child;

    // The compatibility rail consumes logical-start padding until the real
    // Cupertino sidebar replaces this body in Phase 3-4c.
    final removeLeft = Directionality.of(context) == TextDirection.ltr;
    return MediaQuery.removePadding(
      context: context,
      removeLeft: removeLeft,
      removeRight: !removeLeft,
      child: child,
    );
  }
}

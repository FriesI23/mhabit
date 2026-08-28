import 'package:flutter/widgets.dart';

import '../adaptive/adaptive_navigation_destination.dart';
import '../material/material_navigation_rail.dart';
import '../shell/navigation_shell_frame.dart';

/// Temporary medium+ compatibility renderer.
///
/// TODO(adaptive-ui::apple-sidebar): Replace the delegated Material rail with
/// the Phase 3-4 HIG sidebar. This fallback is intentionally Cupertino-owned;
/// it must not be treated as a common rail or an Apple sidebar implementation.
class CupertinoNavigationSidebarCompatibility extends StatelessWidget {
  /// Creates the temporary rail renderer for the current shell [form].
  const CupertinoNavigationSidebarCompatibility({
    super.key,
    required this.form,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    required this.railExtent,
  });

  /// Current compact, collapsed-rail, or extended-rail shell form.
  final NavigationShellForm form;

  /// Zero-based index of the selected destination.
  final int selectedIndex;

  /// Top-level destinations rendered by the compatibility rail.
  final List<AdaptiveNavigationDestination> destinations;

  /// Called with the index of a destination selected by the user.
  final ValueChanged<int> onDestinationSelected;

  /// Automatic and manually resizable rail-width policy.
  final NavigationRailExtent railExtent;

  @override
  Widget build(BuildContext context) => MaterialNavigationRailRegion(
    form: form,
    selectedIndex: selectedIndex,
    destinations: destinations,
    onDestinationSelected: onDestinationSelected,
    railExtent: railExtent,
  );
}

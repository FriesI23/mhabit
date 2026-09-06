import 'package:flutter/widgets.dart';

import 'window_control_layout.dart';

/// Default visual edge padding for Material window-control-aware app bars.
const materialWindowControlEdgePadding = EdgeInsetsDirectional.fromSTEB(
  12,
  0,
  16,
  0,
);

/// Default visual edge padding for Cupertino window-control-aware app bars.
const cupertinoWindowControlEdgePadding = EdgeInsetsDirectional.symmetric(
  horizontal: 16,
);

/// Resolves the shared toolbar avoidance and platform visual baselines.
final class WindowControlToolbarGeometry {
  const WindowControlToolbarGeometry({
    required this.avoidance,
    required this.edgePadding,
  });

  /// {@template mhabit.windowControlAvoidance}
  /// Additional physical space reserved for platform window controls.
  ///
  /// On wrapper widgets, a null value inherits
  /// [AdaptiveWindowControlLayoutScope.appBarAvoidanceOf], while an explicit
  /// [EdgeInsets.zero] disables avoidance.
  /// {@endtemplate}
  final EdgeInsetsDirectional avoidance;

  /// {@template mhabit.windowControlEdgePadding}
  /// Visual spacing between window controls and the app-bar controls.
  ///
  /// This is added to active avoidance and does not replace it.
  /// {@endtemplate}
  final EdgeInsetsDirectional edgePadding;

  /// Resolves [avoidance] from the explicit value or the adaptive scope.
  static WindowControlToolbarGeometry resolve(
    BuildContext context, {
    EdgeInsets? avoidance,
    required EdgeInsetsDirectional edgePadding,
  }) {
    final physicalAvoidance =
        avoidance ??
        AdaptiveWindowControlLayoutScope.appBarAvoidanceOf(context);
    final direction = Directionality.of(context);
    return WindowControlToolbarGeometry(
      avoidance: EdgeInsetsDirectional.fromSTEB(
        direction == TextDirection.ltr
            ? physicalAvoidance.left
            : physicalAvoidance.right,
        physicalAvoidance.top,
        direction == TextDirection.ltr
            ? physicalAvoidance.right
            : physicalAvoidance.left,
        physicalAvoidance.bottom,
      ),
      edgePadding: edgePadding,
    );
  }

  /// Effective Material inset for the leading control slot.
  double get materialStartInset =>
      avoidance.start > 0 ? avoidance.start + edgePadding.start : 0;

  /// Effective Material inset for the trailing actions slot.
  double get materialEndInset =>
      avoidance.end > 0 ? avoidance.end + edgePadding.end : 0;

  /// Effective Cupertino content insets on all directional edges.
  EdgeInsetsDirectional get cupertinoInsets => EdgeInsetsDirectional.fromSTEB(
    edgePadding.start + avoidance.start,
    edgePadding.top,
    edgePadding.end + avoidance.end,
    edgePadding.bottom,
  );
}

import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, immutable, kIsWeb;
import 'package:flutter/material.dart'
    show FloatingActionButtonLocation, ScaffoldPrelayoutGeometry;

import '../window_control/window_control_layout.dart';

/// Resolved edge geometry shared by Apple floating navigation and actions.
@immutable
final class CupertinoFloatingSurfaceGeometry {
  const CupertinoFloatingSurfaceGeometry._({
    required this.horizontalPadding,
    required this.floatingMargin,
  });

  static const double _minimumHorizontalMargin = 12.0;
  static const double _minimumSurfaceMargin = 8.0;
  static const double _fallbackMaximumFloatingMargin = 28.0;
  static const BorderRadius _legacyIosFallbackCornerRadii = BorderRadius.only(
    bottomLeft: Radius.circular(63.0),
    bottomRight: Radius.circular(63.0),
  );

  /// Physical horizontal padding that avoids the lower display corners.
  final EdgeInsets horizontalPadding;

  /// Distance between a floating surface and the physical bottom edge.
  final double floatingMargin;

  /// Resolves the floating geometry for the current window and safe area.
  static CupertinoFloatingSurfaceGeometry resolveOf(
    BuildContext context, {
    double? floatingBottomMargin,
  }) {
    final directionality = Directionality.of(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final safeAreaGeometry =
        AdaptiveWindowControlLayoutScope.safeAreaGeometryOf(context);
    final usesRectangularDisplay =
        AdaptiveWindowControlLayoutScope.usesRectangularDisplayOf(context);
    final verticalSafeAreaAvoidance = safeAreaGeometry?.verticalAvoidance
        .resolve(directionality);
    final floatingMargin = _floatingMarginFor(
      viewPadding: viewPadding,
      verticalSafeAreaAvoidance: verticalSafeAreaAvoidance,
      configuredMargin: floatingBottomMargin,
    );
    final cornerRadii =
        safeAreaGeometry?.effectiveCornerRadii ??
        MediaQuery.displayCornerRadiiOf(context) ??
        ((!kIsWeb &&
                defaultTargetPlatform == TargetPlatform.iOS &&
                !usesRectangularDisplay)
            ? _legacyIosFallbackCornerRadii
            : null);
    final (leftMargin, rightMargin) = cornerRadii == null
        ? _fallbackHorizontalMargins(floatingMargin)
        : _reportedCornerHorizontalMargins(
            radii: cornerRadii,
            floatingMargin: floatingMargin,
          );
    return CupertinoFloatingSurfaceGeometry._(
      horizontalPadding: EdgeInsets.only(left: leftMargin, right: rightMargin),
      floatingMargin: floatingMargin,
    );
  }

  /// A Scaffold placement aligned with the trailing floating surface edge.
  FloatingActionButtonLocation get endFloatLocation =>
      _CupertinoEndFloatLocation(
        leftMargin: horizontalPadding.left,
        rightMargin: horizontalPadding.right,
        bottomMargin: floatingMargin,
      );

  static double _floatingMarginFor({
    required EdgeInsets viewPadding,
    required EdgeInsets? verticalSafeAreaAvoidance,
    required double? configuredMargin,
  }) {
    final baselineMargin = math.max(
      _minimumSurfaceMargin,
      math.min(_fallbackMaximumFloatingMargin, viewPadding.bottom),
    );
    final requestedMargin =
        configuredMargin ??
        math.max(baselineMargin, verticalSafeAreaAvoidance?.bottom ?? 0);
    return math.max(_minimumSurfaceMargin, requestedMargin);
  }

  static (double, double) _fallbackHorizontalMargins(double floatingMargin) {
    final fallbackMargin = math.max(_minimumHorizontalMargin, floatingMargin);
    return (fallbackMargin, fallbackMargin);
  }

  static (double, double) _reportedCornerHorizontalMargins({
    required BorderRadius radii,
    required double floatingMargin,
  }) {
    final visualMargin = math.max(_minimumHorizontalMargin, floatingMargin);
    return (
      math.max(
        visualMargin,
        _horizontalInsetAt(
          radius: radii.bottomLeft,
          distanceFromBottom: floatingMargin,
        ),
      ),
      math.max(
        visualMargin,
        _horizontalInsetAt(
          radius: radii.bottomRight,
          distanceFromBottom: floatingMargin,
        ),
      ),
    );
  }

  static double _horizontalInsetAt({
    required Radius radius,
    required double distanceFromBottom,
  }) {
    if (radius.x <= 0 || radius.y <= 0 || distanceFromBottom >= radius.y) {
      return 0;
    }
    final normalizedY = (radius.y - distanceFromBottom) / radius.y;
    final normalizedX = math.sqrt(math.max(0, 1 - normalizedY * normalizedY));
    return radius.x * (1 - normalizedX);
  }
}

class _CupertinoEndFloatLocation extends FloatingActionButtonLocation {
  const _CupertinoEndFloatLocation({
    required this.leftMargin,
    required this.rightMargin,
    required this.bottomMargin,
  });

  final double leftMargin;
  final double rightMargin;
  final double bottomMargin;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final fabSize = geometry.floatingActionButtonSize;
    final x = switch (geometry.textDirection) {
      TextDirection.ltr =>
        geometry.scaffoldSize.width -
            math.max(rightMargin, geometry.minInsets.right) -
            fabSize.width,
      TextDirection.rtl => math.max(leftMargin, geometry.minInsets.left),
    };
    final safeMargin = math.max(bottomMargin, geometry.minViewPadding.bottom);
    var y = geometry.scaffoldSize.height - fabSize.height - safeMargin;
    if (geometry.snackBarSize.height > 0) {
      y = math.min(
        y,
        geometry.contentBottom -
            geometry.snackBarSize.height -
            fabSize.height -
            bottomMargin,
      );
    }
    if (geometry.bottomSheetSize.height > 0) {
      y = math.min(
        y,
        geometry.contentBottom -
            geometry.bottomSheetSize.height -
            fabSize.height / 2,
      );
    }
    return Offset(x, y);
  }

  @override
  bool operator ==(Object other) =>
      other is _CupertinoEndFloatLocation &&
      other.leftMargin == leftMargin &&
      other.rightMargin == rightMargin &&
      other.bottomMargin == bottomMargin;

  @override
  int get hashCode => Object.hash(leftMargin, rightMargin, bottomMargin);
}

/// A clipped translucent Apple surface with a reusable backdrop treatment.
class CupertinoFloatingGlassSurface extends StatelessWidget {
  /// Creates a floating glass surface around [child].
  const CupertinoFloatingGlassSurface({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(25)),
    this.blurSigma = 10,
  });

  /// Conservative paint allowance for the shared floating-surface shadow.
  ///
  /// Parents that animate by clipping can extend their clip by this amount so
  /// the shadow remains intact without exposing hidden layout content.
  static const double shadowClipOverflow = 32.0;

  static const BoxShadow _shadow = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  /// Content painted above the translucent surface.
  final Widget child;

  /// Surface color; defaults to the current Cupertino bar background.
  final Color? backgroundColor;

  /// Rounded clipping and shadow shape.
  final BorderRadius borderRadius;

  /// Gaussian backdrop blur strength.
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final resolvedBackground =
        backgroundColor ??
        CupertinoDynamicColor.resolve(
          CupertinoTheme.of(context).barBackgroundColor,
          context,
        );
    Widget surface = ColoredBox(color: resolvedBackground, child: child);
    if (resolvedBackground.a != 1.0 && blurSigma > 0) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: surface,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [_shadow],
      ),
      child: ClipRRect(borderRadius: borderRadius, child: surface),
    );
  }
}

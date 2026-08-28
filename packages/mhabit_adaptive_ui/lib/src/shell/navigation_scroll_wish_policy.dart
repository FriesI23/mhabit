import 'package:flutter/foundation.dart';

/// Converts vertical scrolling into navigation visibility wishes.
sealed class NavigationScrollWishPolicy {
  const NavigationScrollWishPolicy();

  /// Reacts immediately to every non-zero scroll update.
  const factory NavigationScrollWishPolicy.directional() =
      DirectionalNavigationScrollWishPolicy;

  /// Reacts only after a drag reaches scaled platform fling thresholds.
  const factory NavigationScrollWishPolicy.flingThreshold({
    double distanceFactor,
    double velocityFactor,
  }) = FlingThresholdNavigationScrollWishPolicy;

  /// Creates isolated gesture state for one navigation shell.
  NavigationScrollWishTracker createTracker();
}

/// Immediate direction-driven navigation wishes.
@immutable
final class DirectionalNavigationScrollWishPolicy
    extends NavigationScrollWishPolicy {
  const DirectionalNavigationScrollWishPolicy();

  @override
  NavigationScrollWishTracker createTracker() =>
      _DirectionalNavigationScrollWishTracker();
}

/// Platform-fling navigation wishes with configurable tolerance factors.
@immutable
final class FlingThresholdNavigationScrollWishPolicy
    extends NavigationScrollWishPolicy {
  const FlingThresholdNavigationScrollWishPolicy({
    this.distanceFactor = 1,
    this.velocityFactor = 1,
  }) : assert(distanceFactor > 0),
       assert(velocityFactor > 0);

  /// Multiplier applied to [ScrollPhysics.minFlingDistance].
  final double distanceFactor;

  /// Multiplier applied to [ScrollPhysics.minFlingVelocity].
  final double velocityFactor;

  @override
  NavigationScrollWishTracker createTracker() =>
      _FlingThresholdNavigationScrollWishTracker(
        distanceFactor: distanceFactor,
        velocityFactor: velocityFactor,
      );

  @override
  bool operator ==(Object other) =>
      other is FlingThresholdNavigationScrollWishPolicy &&
      distanceFactor == other.distanceFactor &&
      velocityFactor == other.velocityFactor;

  @override
  int get hashCode => Object.hash(distanceFactor, velocityFactor);
}

/// Gesture-local state created by a [NavigationScrollWishPolicy].
abstract interface class NavigationScrollWishTracker {
  /// Starts a new scroll gesture or activity.
  void start(Duration? timestamp);

  /// Returns `true` to show/expand navigation, `false` to hide/minimize it,
  /// or `null` to retain the current presentation.
  bool? update({
    required double extentBefore,
    required double delta,
    required bool directDrag,
    required Duration? timestamp,
    required double minFlingDistance,
    required double minFlingVelocity,
  });

  /// Clears gesture-local state when scrolling ends.
  void end();
}

final class _DirectionalNavigationScrollWishTracker
    implements NavigationScrollWishTracker {
  @override
  void start(Duration? timestamp) {}

  @override
  bool? update({
    required double extentBefore,
    required double delta,
    required bool directDrag,
    required Duration? timestamp,
    required double minFlingDistance,
    required double minFlingVelocity,
  }) => extentBefore <= 0 ? true : delta < 0;

  @override
  void end() {}
}

final class _FlingThresholdNavigationScrollWishTracker
    implements NavigationScrollWishTracker {
  _FlingThresholdNavigationScrollWishTracker({
    required this.distanceFactor,
    required this.velocityFactor,
  });

  final double distanceFactor;
  final double velocityFactor;

  Duration? _startedAt;
  double _distance = 0;
  double _direction = 0;

  void _reset({Duration? startedAt}) {
    _startedAt = startedAt;
    _distance = 0;
    _direction = 0;
  }

  @override
  void start(Duration? timestamp) => _reset(startedAt: timestamp);

  @override
  bool? update({
    required double extentBefore,
    required double delta,
    required bool directDrag,
    required Duration? timestamp,
    required double minFlingDistance,
    required double minFlingVelocity,
  }) {
    if (extentBefore <= 0) {
      _reset(startedAt: timestamp);
      return true;
    }
    if (!directDrag) return delta < 0;

    final direction = delta.sign;
    if (_direction != 0 && _direction != direction) {
      _reset(startedAt: timestamp);
    }
    _direction = direction;
    final startedAt = _startedAt ?? timestamp;
    _startedAt = startedAt;
    _distance += delta.abs();
    if (timestamp == null || startedAt == null) return null;

    final elapsed = timestamp - startedAt;
    if (elapsed <= Duration.zero) return null;
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final velocity = _distance / seconds;
    final reachedThreshold =
        _distance >= minFlingDistance * distanceFactor &&
        velocity >= minFlingVelocity * velocityFactor;
    return reachedThreshold ? delta < 0 : null;
  }

  @override
  void end() => _reset();
}

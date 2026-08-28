import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/src/shell/navigation_scroll_wish_policy.dart';

void main() {
  const minDistance = 18.0;
  const minVelocity = 100.0;

  bool? update(
    NavigationScrollWishTracker tracker, {
    required double delta,
    required Duration timestamp,
    double extentBefore = 100,
    bool directDrag = true,
  }) => tracker.update(
    extentBefore: extentBefore,
    delta: delta,
    directDrag: directDrag,
    timestamp: timestamp,
    minFlingDistance: minDistance,
    minFlingVelocity: minVelocity,
  );

  test('directional policy reacts immediately in both directions', () {
    final tracker = const NavigationScrollWishPolicy.directional()
        .createTracker();

    expect(update(tracker, delta: 1, timestamp: Duration.zero), isFalse);
    expect(update(tracker, delta: -1, timestamp: Duration.zero), isTrue);
  });

  test('fling policy tolerates slow drags in both directions', () {
    final tracker = const NavigationScrollWishPolicy.flingThreshold(
      distanceFactor: 1.5,
      velocityFactor: 1.5,
    ).createTracker();
    tracker.start(Duration.zero);

    expect(
      update(tracker, delta: 80, timestamp: const Duration(seconds: 2)),
      isNull,
    );
    expect(
      update(tracker, delta: -80, timestamp: const Duration(seconds: 4)),
      isNull,
    );
  });

  test('fling policy switches after scaled thresholds in both directions', () {
    final tracker = const NavigationScrollWishPolicy.flingThreshold(
      distanceFactor: 1.5,
      velocityFactor: 1.5,
    ).createTracker();
    tracker.start(Duration.zero);

    expect(
      update(tracker, delta: 20, timestamp: const Duration(milliseconds: 10)),
      isNull,
    );
    expect(
      update(tracker, delta: 10, timestamp: const Duration(milliseconds: 20)),
      isFalse,
    );
    expect(
      update(tracker, delta: -20, timestamp: const Duration(milliseconds: 30)),
      isNull,
    );
    expect(
      update(tracker, delta: -10, timestamp: const Duration(milliseconds: 40)),
      isTrue,
    );
  });

  test('fling policy expands immediately at the leading edge', () {
    final tracker = const NavigationScrollWishPolicy.flingThreshold(
      distanceFactor: 1.5,
      velocityFactor: 1.5,
    ).createTracker();

    expect(
      update(tracker, delta: 1, timestamp: Duration.zero, extentBefore: 0),
      isTrue,
    );
  });
}

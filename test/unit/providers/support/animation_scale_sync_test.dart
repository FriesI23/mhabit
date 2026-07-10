// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/providers/support/_animation_scale_sync/android_animation_scale_sync.dart';
import 'package:mhabit/providers/support/_animation_scale_sync/stub_animation_scale_sync.dart';
import 'package:mhabit/providers/support/animation_scale_sync.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StubAnimationScaleSync', () {
    test('returns default values', () {
      final sync = StubAnimationScaleSync();
      expect(sync.scale, 1.0);
      expect(sync.disableAnimations, isFalse);
      expect(sync.isOverridden, isFalse);
    });
  });

  group('AnimationScaleSync.create', () {
    test('returns a valid AnimationScaleSync', () {
      final sync = AnimationScaleSync.create();
      expect(sync, isA<AnimationScaleSync>());
      expect(sync.scale, 1.0);
      expect(sync.disableAnimations, isFalse);
      expect(sync.isOverridden, isFalse);
    });
  });

  group('AndroidAnimationScaleSync', () {
    late AndroidAnimationScaleSync sync;
    late double savedTimeDilation;

    setUp(() {
      savedTimeDilation = timeDilation;
      timeDilation = 1.0;
      sync = AndroidAnimationScaleSync();
    });

    tearDown(() {
      sync.dispose();
      timeDilation = savedTimeDilation;
    });

    test('initial state is default', () {
      expect(sync.scale, 1.0);
      expect(sync.disableAnimations, isFalse);
      expect(sync.isOverridden, isFalse);
    });

    test('applies normal scale to timeDilation', () {
      sync.testReceiveScale(2.0);

      expect(sync.scale, 2.0);
      expect(timeDilation, 2.0);
      expect(sync.disableAnimations, isFalse);
      expect(sync.isOverridden, isFalse);
    });

    test('applies fractional scale to timeDilation', () {
      sync.testReceiveScale(0.5);

      expect(sync.scale, 0.5);
      expect(timeDilation, 0.5);
      expect(sync.disableAnimations, isFalse);
    });

    test('scale=0 sets disableAnimations but does not write timeDilation', () {
      sync.testReceiveScale(0.0);

      expect(sync.scale, 0.0);
      expect(sync.disableAnimations, isTrue);
      expect(timeDilation, 1.0);
    });

    test(
      'resets timeDilation to 1.0 when scale drops to 0 after bridge-set',
      () {
        sync.testReceiveScale(2.0);
        expect(timeDilation, 2.0);

        sync.testReceiveScale(0.0);
        expect(timeDilation, 1.0);
        expect(sync.disableAnimations, isTrue);
      },
    );

    test('transition 2.0 → 0 → 1.5 applies new scale correctly', () {
      sync.testReceiveScale(2.0);
      expect(timeDilation, 2.0);

      sync.testReceiveScale(0.0);
      expect(timeDilation, 1.0);
      expect(sync.disableAnimations, isTrue);

      sync.testReceiveScale(1.5);
      expect(timeDilation, 1.5);
      expect(sync.disableAnimations, isFalse);
      expect(sync.isOverridden, isFalse);
    });

    test('transition 0 → scale re-enables animations', () {
      sync.testReceiveScale(0.0);
      expect(sync.disableAnimations, isTrue);

      sync.testReceiveScale(1.0);
      expect(sync.disableAnimations, isFalse);
      expect(sync.scale, 1.0);
    });

    test('detects external override via frame callback', () {
      sync.testReceiveScale(2.0);
      expect(timeDilation, 2.0);

      timeDilation = 3.0;
      sync.testTickFrame();
      expect(sync.isOverridden, isTrue);
    });

    test('releases override when timeDilation returns to 1.0', () {
      sync.testReceiveScale(2.0);
      timeDilation = 3.0;
      sync.testTickFrame();
      expect(sync.isOverridden, isTrue);

      timeDilation = 1.0;
      sync.testTickFrame();
      expect(sync.isOverridden, isFalse);
      expect(timeDilation, 2.0);
    });

    test('override prevents new scale from being applied', () {
      sync.testReceiveScale(2.0);
      timeDilation = 3.0;
      sync.testTickFrame();
      expect(sync.isOverridden, isTrue);

      sync.testReceiveScale(1.5);
      expect(timeDilation, 3.0);
      expect(sync.scale, 1.5);
    });

    test('does not stomp external override when scale goes to 0', () {
      sync.testReceiveScale(2.0);
      timeDilation = 3.0;
      sync.testTickFrame();
      expect(sync.isOverridden, isTrue);

      sync.testReceiveScale(0.0);
      expect(timeDilation, 3.0);
      expect(sync.disableAnimations, isTrue);
    });

    test('notifies listeners on scale change', () {
      var notified = false;
      sync.addListener(() => notified = true);

      sync.testReceiveScale(2.0);
      expect(notified, isTrue);
    });

    test('notifies listeners on override detected', () {
      sync.testReceiveScale(2.0);
      var notified = false;
      sync.addListener(() => notified = true);

      timeDilation = 3.0;
      sync.testTickFrame();
      expect(notified, isTrue);
    });

    test('notifies listeners on override released', () {
      sync.testReceiveScale(2.0);
      timeDilation = 3.0;
      sync.testTickFrame();

      var notified = false;
      sync.addListener(() => notified = true);

      timeDilation = 1.0;
      sync.testTickFrame();
      expect(notified, isTrue);
    });

    test('dispose stops frame callback from detecting overrides', () {
      sync.testReceiveScale(2.0);
      sync.dispose();

      timeDilation = 3.0;
      sync.testTickFrame();
      expect(sync.isOverridden, isFalse);
    });
  });
}

// Copyright 2025 Fries_I23
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

import 'package:flutter/foundation.dart';

import '_animation_scale_sync/android_animation_scale_sync.dart';
import '_animation_scale_sync/stub_animation_scale_sync.dart';

/// Bridge that syncs the Android system animation scale to Flutter's
/// [timeDilation].
///
/// When the Android scale is 0 (animations disabled) [disableAnimations]
/// is set to true instead of writing to [timeDilation], which Flutter
/// requires to be > 0.
///
/// Flutter debug tools take priority: when they modify [timeDilation]
/// the Android scale is tracked but not applied until the override is
/// released.
abstract class AnimationScaleSync extends ChangeNotifier {
  /// Generative constructor for subclass use.
  AnimationScaleSync();

  /// The Android-reported animation scale (1.0 = normal speed).
  double get scale;

  /// Whether the Android system has animations disabled (scale = 0).
  ///
  /// Consumer should apply this to [MediaQueryData.disableAnimations]
  /// so Flutter widgets skip animations entirely.
  bool get disableAnimations => false;

  /// Whether an external source (e.g. Flutter debug tools) currently
  /// controls [timeDilation] instead of this bridge.
  bool get isOverridden => false;

  /// Creates the platform-appropriate implementation.
  ///
  /// On Android returns [AndroidAnimationScaleSync]; on all other platforms
  /// returns [StubAnimationScaleSync].
  factory AnimationScaleSync.create() => switch (defaultTargetPlatform) {
    TargetPlatform.android => AndroidAnimationScaleSync(),
    _ => StubAnimationScaleSync(),
  };
}

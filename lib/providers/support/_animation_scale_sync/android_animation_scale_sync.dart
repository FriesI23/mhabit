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

import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/scheduler.dart' show SchedulerBinding, timeDilation;
import 'package:flutter/services.dart' show EventChannel;

import '../../../logging/helper.dart';
import '../animation_scale_sync.dart';

const _channelName = 'global.app.animation/scale_stream';

class AndroidAnimationScaleSync extends AnimationScaleSync {
  StreamSubscription<dynamic>? _subscription;

  /// Raw Android animation scale (may be 0 when animations are disabled).
  double _scale = 1.0;

  /// The last [timeDilation] value we wrote, or null when we are not
  /// controlling timeDilation (scale=0 or not yet written).
  double? _lastWrittenDilation;
  bool _isOverridden = false;
  bool _disposed = false;

  AndroidAnimationScaleSync() {
    const channel = EventChannel(_channelName);
    _subscription = channel.receiveBroadcastStream().listen(
      _onScaleChanged,
      onError: (Object error) {
        appLog.debugger.error(
          '$runtimeType.receiveBroadcastStream',
          ex: [error],
        );
      },
    );
    // Persistent callback is the idiomatic Flutter pattern for per-frame
    // monitoring.  The _disposed guard is sufficient because this object
    // is a single app-lifetime instance.
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
  }

  @override
  double get scale => _scale;

  @override
  bool get disableAnimations => _scale <= 0.0;

  @override
  bool get isOverridden => _isOverridden;

  void _onScaleChanged(dynamic value) {
    if (value is! num) return;
    final prevScale = _scale;
    _scale = value.toDouble();
    appLog.debugger.debug(
      'AndroidAnimationScaleSync._onScaleChanged',
      ex: [_scale],
    );
    if (_scale <= 0.0) {
      // Animations off — yield timeDilation, use disableAnimations.
      if (_lastWrittenDilation != null && !_isOverridden) {
        timeDilation = 1.0;
      }
      _lastWrittenDilation = null;
      _isOverridden = false;
    } else {
      if (prevScale <= 0.0 && _scale > 0.0) {
        // Transitioning from off → on: check for active debug override.
        _isOverridden = timeDilation != 1.0;
      }
      if (!_isOverridden) {
        _lastWrittenDilation = _scale;
        timeDilation = _scale;
      }
    }
    notifyListeners();
  }

  void _onFrame(Duration _) {
    if (_disposed) return;
    final lastWritten = _lastWrittenDilation;
    if (lastWritten == null) return;

    if (timeDilation == 1.0) {
      if (_isOverridden) {
        _isOverridden = false;
        _lastWrittenDilation = _scale;
        timeDilation = _scale;
        notifyListeners();
      }
    } else if (timeDilation != lastWritten) {
      if (!_isOverridden) {
        _isOverridden = true;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }

  @visibleForTesting
  void testReceiveScale(double value) => _onScaleChanged(value);

  @visibleForTesting
  void testTickFrame() => _onFrame(Duration.zero);
}

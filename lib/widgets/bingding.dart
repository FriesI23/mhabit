// Copyright 2025 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../utils/app_clock.dart';

/// Clicking the top edge of the screen is recognized twice on iPadOS 26
/// see: https://github.com/flutter/flutter/issues/175606
class FixedIos26FlutterBinding extends WidgetsFlutterBinding {
  static FixedIos26FlutterBinding? _instance;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  DateTime? _lastRealPointerUpTime;
  static const int _fakeTapThreshold = 400;

  bool _shouldBlockFakeTap(PointerEvent event) {
    if (event.position != Offset.zero) return false;
    if (!(event is PointerDownEvent || event is PointerUpEvent)) return false;
    final last = _lastRealPointerUpTime;
    if (last == null) return false;
    return DateTime.now().difference(last).inMilliseconds < _fakeTapThreshold;
  }

  void _updateLastRealPointerUp(PointerEvent event) {
    if (event is PointerUpEvent && event.position != Offset.zero) {
      _lastRealPointerUpTime = AppClock().now();
    }
  }

  @override
  void handlePointerEvent(PointerEvent event) {
    _updateLastRealPointerUp(event);
    if (_shouldBlockFakeTap(event)) return;
    super.handlePointerEvent(event);
  }

  static FixedIos26FlutterBinding get instance =>
      BindingBase.checkInstance(_instance);

  static FixedIos26FlutterBinding ensureInitialized() {
    if (_instance == null) FixedIos26FlutterBinding();
    return instance;
  }
}

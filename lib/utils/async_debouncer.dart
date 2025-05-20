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

import 'dart:async';

class CascadingAsyncDebouncer {
  final Future<void> Function() action;

  Timer? _timer;
  Duration? _pendingDelay;
  bool _isExecuting = false;

  CascadingAsyncDebouncer({required this.action});

  void exec({Duration delay = Duration.zero}) {
    assert(!delay.isNegative);

    if (_isExecuting) {
      final pendingDelay = _pendingDelay;
      _pendingDelay = (pendingDelay == null)
          ? delay
          : (pendingDelay.compareTo(delay) > 0 ? pendingDelay : delay);
      return;
    }

    _timer?.cancel();
    _timer = Timer(delay, () {
      _isExecuting = true;
      action().whenComplete(() {
        _isExecuting = false;
        final nextDelay = _pendingDelay;
        _pendingDelay = null;
        if (nextDelay != null) {
          exec(delay: nextDelay);
        }
      });
    });
  }

  bool get isRunning => _isExecuting || (_timer?.isActive ?? false);

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pendingDelay = null;
  }
}

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

import 'app_sync_options.dart';

class AppSyncPeriodicTimer implements Timer {
  final AppSyncFetchInterval interval;

  final Timer _timer;

  AppSyncPeriodicTimer._(Timer timer, {required this.interval})
      : _timer = timer;

  factory AppSyncPeriodicTimer(
      AppSyncFetchInterval interval, void Function(Timer timer) callback) {
    assert(interval != AppSyncFetchInterval.manual);
    assert(interval.t != null);
    return AppSyncPeriodicTimer._(Timer.periodic(interval.t!, callback),
        interval: interval);
  }

  @override
  void cancel() => _timer.cancel();

  @override
  bool get isActive => _timer.isActive;

  @override
  int get tick => _timer.tick;
}

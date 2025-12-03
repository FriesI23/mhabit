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
import 'package:quiver/time.dart';

class AppClock {
  static AppClock? _instance;

  Clock _clock;
  final StreamController<(Clock, Clock)> _clockChanges =
      StreamController.broadcast();

  factory AppClock() => _instance ??= AppClock._();

  AppClock._() : _clock = const Clock(systemTime);

  Clock get clock => _clock;

  DateTime now() => _clock.now();

  void setClock(Clock newClock) {
    final oldClock = _clock;
    _clock = newClock;
    _clockChanges.add((oldClock, newClock));
  }

  Stream<(Clock, Clock)> get onClockChanged => _clockChanges.stream;
}

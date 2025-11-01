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

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../models/app_event.dart';

class AppEventViewModel extends ChangeNotifier {
  final _controller = StreamController<AppEvent>.broadcast();

  Stream<T> on<T extends AppEvent>() => _controller.stream.whereType<T>();

  void push(AppEvent event) {
    _controller.add(event);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

abstract interface class AppEventLoaded {
  void updateAppEvent(AppEventViewModel newAppEvent);
}

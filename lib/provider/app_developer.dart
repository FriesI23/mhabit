// Copyright 2023 Fries_I23
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

import 'package:flutter/material.dart';

import '../common/global.dart';
import '../logging/level.dart';
import '../model/global.dart';

class AppDeveloperViewModel extends ChangeNotifier
    implements GlobalProxyProviderInterface {
  Global _g;

  AppDeveloperViewModel({required Global global}) : _g = global;

  @override
  Global get g => _g;

  @override
  void updateGlobal(Global newGloal) => _g = newGloal;

  bool get isInDevelopMode => _g.isInDevelopMode;

  void switchDevelopMode(bool value) {
    if (g.isInDevelopMode != value) {
      g.switchDevelopMode(value);
      notifyListeners();
    }
  }

  bool get displayDebugMenu => _g.displayDebugMenu;

  void switchDisplayDebugMenu(bool value) {
    if (g.displayDebugMenu != value) {
      g.switchDisplayDebugMenu(value);
      notifyListeners();
    }
  }

  LogLevel get loggingLevel => kLogLevel.level;

  set loggingLevel(LogLevel newLevel) {
    if (kLogLevel.level != newLevel) {
      kLogLevel.level = newLevel;
      notifyListeners();
    }
  }

  bool get showDebugMenuOnDisplayView => isInDevelopMode && displayDebugMenu;
}

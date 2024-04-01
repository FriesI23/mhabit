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

import 'package:flutter/foundation.dart';

import '../logging/helper.dart';

class Global {
  Global();

  bool _isInDevelopMode = kDebugMode ? true : false;
  bool? _displayDebugMenu;

  bool get isInDevelopMode => _isInDevelopMode;
  void switchDevelopMode(bool value) => _isInDevelopMode = value;

  bool get displayDebugMenu => _displayDebugMenu ?? kDebugMode ? true : false;
  void switchDisplayDebugMenu(bool value) => _displayDebugMenu = value;
}

abstract mixin class GlobalLoadedMixin {
  late Global _g;

  Global get g => _g;

  @mustCallSuper
  void updateGlobal(Global newGloal) {
    appLog.load.info("$runtimeType.updateGlobal", ex: [newGloal]);
    _g = newGloal;
  }
}

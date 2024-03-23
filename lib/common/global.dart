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
import 'package:flutter/material.dart';

import '../logging/level.dart';

//#region debug options
bool debugClearDBWhenStart = false;
bool debugClearSharedPrefWhenStart = false;
//#endregion

//#region log level
final kLogLevel = _LoggingLevel();
//#endregion

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

class _LoggingLevel {
  late LogLevel level;

  _LoggingLevel() {
    if (kDebugMode) {
      level = LogLevel.debug;
    } else if (kProfileMode) {
      level = LogLevel.info;
    } else if (kReleaseMode) {
      level = LogLevel.warn;
    } else {
      level = LogLevel.debug;
    }
  }
}

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

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'enums.dart';
import 'global.dart';
import 'utils.dart';

class _Log {
  static _getLogName(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return "DEBUG";
      case LogLevel.info:
        return "INFO";
      case LogLevel.warn:
      case LogLevel.warning:
        return "WARN";
      case LogLevel.error:
        return "ERROR";
    }
  }

  static log(String name, String message, LogLevel level,
      {Object? error, StackTrace? track}) {
    developer.log("[${_getLogName(level)}] $message",
        name: name, level: level.level, error: error, stackTrace: track);
  }

  static withException({VoidCallback? log, String? label}) {
    try {
      log?.call();
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) rethrow;
      debugPrint("Trace on log: $e");
      debugPrintStack(stackTrace: stackTrace, label: label);
    }
  }
}

class DebugLog {
  static LogLevel get level => LogLevel.debug;

  static _log(String name, String message) {
    if (kLogLevel.level > LogLevel.debug) return;
    return _Log.withException(
      log: () => _Log.log(name, message, level),
      label: name,
    );
  }

  static rebuild(String message) => _log("app:rebuild", message);

  static setValue(String message) => _log("app:setValue", message);

  static naviResult(String message) => _log("app:naviResult", message);

  static db(String message) => _log("app:db", message);

  static profile(String message) => _log("app:profile", message);

  static load(String message) => _log("app:load", message);

  static notify(String message) => _log("app:notify", message);
}

class InfoLog {
  static LogLevel get level => LogLevel.info;

  static _log(String name, String message) {
    if (kLogLevel.level > LogLevel.info) return;
    return _Log.withException(
      log: () => _Log.log(name, message, level),
      label: name,
    );
  }

  static _export(String fileName, String jsonData) {
    const name = "app:export";
    return _Log.withException(
      log: () {
        final fd = truncateString(jsonData, 2000, 80, 20,
            midStr: " <<<...IGNORE ${jsonData.length - 120} CHARS...>>> ");
        _Log.log(name, "fileName: $fileName, data: $fd", level);
      },
      label: name,
    );
  }

  static export(String fileName, String jsonData) =>
      _export(fileName, jsonData);

  static import(String message) => _log("app:import", message);

  static setValue(String message) => _log("app:setValue", message);
}

class WarnLog {
  static LogLevel get level => LogLevel.warn;

  static _log(String name, String message) {
    if (kLogLevel.level > LogLevel.warn) return;
    return _Log.withException(
      log: () => _Log.log(name, message, level),
      label: name,
    );
  }

  static rebuild(String message) => _log("app:rebuild", message);

  static load(String message) => _log("app:load", message);

  static setValue(String message) => _log("app:setValue", message);

  static notify(String message) => _log("app:notify", message);

  static saveHabit(String message) => _log("app:saveHabit", message);
}

class ErrorLog {
  static LogLevel get level => LogLevel.error;

  static _log(String name, String message, {Object? error, StackTrace? track}) {
    if (kLogLevel.level > LogLevel.debug) return;
    return _Log.withException(
      log: () => _Log.log(name, message, level, error: error, track: track),
      label: name,
    );
  }

  static loadFile(String message) => _log("app:loadFile", message);

  static notify(String meesage, {Object? error, StackTrace? track}) =>
      _log("app:notify", meesage, error: error, track: track);

  static openUrl(String message) => _log("app:openUrl", message);
}

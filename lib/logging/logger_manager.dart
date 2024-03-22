// Copyright 2024 Fries_I23
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

import 'package:logger/logger.dart' as l;

import '../common/abc.dart';
import 'handler/console_handler.dart';
import 'logger/value_change_logger.dart';
import 'logger/widget_logger.dart';
import 'logger_type.dart';

abstract interface class AppLoggerMananger with FutureInitializationABC {
  static AppLoggerMananger? _instance;

  l.Logger get logger;

  AppWidgetLogger get rebuild;

  AppValueChangeLogger get setValue;

  Future<bool> changeLogger(l.Logger newLogger);

  factory AppLoggerMananger({l.Logger? logger}) =>
      _instance ?? AppLoggerMananger._new();

  factory AppLoggerMananger._new({l.Logger? logger}) {
    if (logger != null) assert(logger.isClosed(), false);
    final mgr = _instance = _AppLoggerManager(logger ?? _defaultLogger());
    return mgr;
  }

  static l.Logger _defaultLogger() => l.Logger(
        printer: AppLoggerPrinter(),
        output: AppLoggerConsoleOutput(),
      );
}

class _AppLoggerManager implements AppLoggerMananger {
  @override
  l.Logger logger;
  final Map<LoggerType, dynamic> appLoggerInstances = {};

  _AppLoggerManager(this.logger);

  @override
  Future init() => logger.init;

  T _tryGetAppLogger<T>(LoggerType t,
      {required T Function(LoggerType t) buildNewLogger}) {
    if (appLoggerInstances.containsKey(t)) {
      return appLoggerInstances[t];
    }
    final newAppLogger = buildNewLogger(t);
    appLoggerInstances[t] = newAppLogger;
    return newAppLogger;
  }

  @override
  AppWidgetLogger get rebuild => _tryGetAppLogger(
        LoggerType.rebuild,
        buildNewLogger: (t) => AppWidgetLogger(this, t),
      );

  @override
  AppValueChangeLogger get setValue => _tryGetAppLogger(
        LoggerType.setValue,
        buildNewLogger: (t) => AppValueChangeLogger(this, t),
      );

  @override
  Future<bool> changeLogger(l.Logger newLogger) async {
    if (newLogger.isClosed()) return false;
    await newLogger.init;
    final oldLogger = logger;
    logger = newLogger;
    oldLogger.close();
    return true;
  }
}

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

import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as l;
import 'package:provider/provider.dart';

import 'console_handler.dart';
import 'logger_type.dart';
import 'widget_logger.dart';

abstract interface class AppLoggerMananger {
  l.Logger get logger;

  AppWidgetLogger get rebuild;

  Future<bool> changeLogger(l.Logger newLogger);

  factory AppLoggerMananger({l.Logger? logger}) {
    if (logger != null) assert(logger.isClosed(), false);
    return _AppLoggerManager(logger ?? _defaultLogger());
  }

  static l.Logger _defaultLogger() => l.Logger(
        printer: AppLoggerPrinter(),
        output: AppLoggerConsoleOutput(),
      );

  static AppLoggerMananger of(BuildContext context) =>
      context.read<AppLoggerMananger>();
}

class _AppLoggerManager implements AppLoggerMananger {
  @override
  l.Logger logger;
  final Map<LoggerType, dynamic> appLoggerInstances = {};

  _AppLoggerManager(this.logger);

  AppWidgetLogger _tryGetAppWidgetLogger(LoggerType t) {
    if (appLoggerInstances.containsKey(t)) {
      return appLoggerInstances[t];
    }
    final newAppLogger = AppWidgetLogger(this, t);
    appLoggerInstances[t] = newAppLogger;
    return newAppLogger;
  }

  @override
  AppWidgetLogger get rebuild => _tryGetAppWidgetLogger(LoggerType.rebuild);

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

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

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as l;

import '../common/async.dart';
import '../utils/debug_info.dart';
import 'handler/console_output.dart';
import 'handler/console_printer.dart';
import 'handler/filter.dart';
import 'logger/text_logger.dart';
import 'logger/value_change_logger.dart';
import 'logger/widget_logger.dart';
import 'logger_type.dart';

enum AppLoggerHandlerType {
  custom,
  normal,
  debugging,
}

abstract interface class AppLoggerMananger implements AsyncInitialization {
  static AppLoggerMananger? _instance;
  static late final l.Logger normalLogger;
  static late final l.Logger debuggingLogger;

  l.Logger get logger;

  AppTextLogger get debugger;
  AppWidgetLogger get build;
  AppValueChangeLogger get value;
  AppTextLogger get navi;
  AppTextLogger get db;
  AppTextLogger get profile;
  AppTextLogger get load;
  AppTextLogger get notify;
  AppTextLogger get import;
  AppTextLogger get export;
  AppTextLogger get habit;
  AppTextLogger get network;
  AppTextLogger get json;
  AppWidgetLogger get l10n;
  AppTextLogger get cache;

  Future<bool> changeLogger(l.Logger newLogger);
  bool changeLoggerByType(AppLoggerHandlerType t);

  factory AppLoggerMananger(
          {AppLoggerHandlerType t = AppLoggerHandlerType.normal}) =>
      _instance ?? AppLoggerMananger._new(t: t);

  factory AppLoggerMananger._new(
      {AppLoggerHandlerType t = AppLoggerHandlerType.normal}) {
    final mgr = _instance = _AppLoggerManager(t);
    return mgr;
  }

  static l.Logger buildNormalLogger() => kReleaseMode
      ? l.Logger(
          filter: const AppLogFilter(),
          printer: const AppLoggerConsoleReleasePrinter(),
          output: const AppLoggerConsoleReleaseOutput(),
        )
      : l.Logger(
          filter: const AppLogFilter(),
          printer: const AppLoggerConsolePrinter(),
          output: const AppLoggerConsoleOutput(),
        );

  static l.Logger buildDebuggingLogger({required String filePath}) =>
      kReleaseMode
          ? l.Logger(
              filter: const AppLogFilter(),
              printer: const AppLoggerConsoleReleasePrinter(),
              output: l.MultiOutput([
                l.AdvancedFileOutput(
                  path: filePath,
                  overrideExisting: false,
                  writeImmediately: l.Level.values
                      .where((e) => e.value >= l.Level.warning.value)
                      .toList(),
                  maxFileSizeKB: 0,
                ),
                const AppLoggerConsoleReleaseOutput(),
              ]),
            )
          : l.Logger(
              filter: const AppLogFilter(),
              printer: const AppLoggerConsolePrinter(),
              output: l.MultiOutput([
                l.AdvancedFileOutput(
                  path: filePath,
                  overrideExisting: false,
                  writeImmediately: l.Level.values
                      .where((e) => e.value >= l.Level.warning.value)
                      .toList(),
                  maxFileSizeKB: 0,
                ),
                const AppLoggerConsoleOutput(),
              ]),
            );

  static l.Logger getLoggerByType(AppLoggerHandlerType t) {
    switch (t) {
      case AppLoggerHandlerType.normal:
        return normalLogger;
      case AppLoggerHandlerType.debugging:
        return debuggingLogger;
      default:
        throw UnsupportedError("Un-supported named AppLoggerType, $t");
    }
  }
}

class _AppLoggerManager implements AppLoggerMananger {
  @override
  late l.Logger logger;
  AppLoggerHandlerType loggerType;
  final Map<LoggerType, dynamic> appLoggerInstances = {};

  _AppLoggerManager(AppLoggerHandlerType t) : loggerType = t {
    logger = l.Logger(level: l.Level.warning);
  }

  @override
  Future init() async {
    AppLoggerMananger.normalLogger = AppLoggerMananger.buildNormalLogger();
    AppLoggerMananger.debuggingLogger = AppLoggerMananger.buildDebuggingLogger(
        filePath: await debugLogFilePath);
    logger = AppLoggerMananger.getLoggerByType(loggerType);
    await Future.wait([
      AppLoggerMananger.normalLogger.init,
      AppLoggerMananger.debuggingLogger.init,
    ]);

    FlutterError.onError = _onFlutterErrorCatched;
    PlatformDispatcher.instance.onError = _onPlatformErrorCatched;
  }

  void _onFlutterErrorCatched(FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugger.fatal(
      "------- Catched UN-HANDLED Exception -------",
      ex: [details.context, details.library, details.summary],
      error: details.exception,
      stackTrace: details.stack,
    );
  }

  bool _onPlatformErrorCatched(Object exception, StackTrace stackTrace) {
    debugger.fatal(
      "------- Catched UN-HANDLED Exception -------",
      error: exception,
      stackTrace: stackTrace,
    );
    return true;
  }

  T _tryGetAppLogger<T>(LoggerType t,
      {required T Function(LoggerType t) buildNewLogger}) {
    if (appLoggerInstances.containsKey(t)) {
      return appLoggerInstances[t];
    }
    final newAppLogger = buildNewLogger(t);
    appLoggerInstances[t] = newAppLogger;
    return newAppLogger;
  }

  AppTextLogger _tryGetAppTextLogger(LoggerType t) =>
      _tryGetAppLogger(t, buildNewLogger: (t) => AppTextLogger(this, t));

  @override
  AppWidgetLogger get build => _tryGetAppLogger(
        LoggerType.build,
        buildNewLogger: (t) => AppWidgetLogger(this, t),
      );

  @override
  AppValueChangeLogger get value => _tryGetAppLogger(
        LoggerType.value,
        buildNewLogger: (t) => AppValueChangeLogger(this, t),
      );

  @override
  AppTextLogger get navi => _tryGetAppTextLogger(LoggerType.navi);

  @override
  AppTextLogger get db => _tryGetAppTextLogger(LoggerType.db);

  @override
  AppTextLogger get profile => _tryGetAppTextLogger(LoggerType.profile);

  @override
  AppTextLogger get load => _tryGetAppTextLogger(LoggerType.load);

  @override
  AppTextLogger get notify => _tryGetAppTextLogger(LoggerType.notify);

  @override
  AppTextLogger get import => _tryGetAppTextLogger(LoggerType.import);

  @override
  AppTextLogger get export => _tryGetAppTextLogger(LoggerType.export);

  @override
  AppTextLogger get habit => _tryGetAppTextLogger(LoggerType.habit);

  @override
  AppTextLogger get network => _tryGetAppTextLogger(LoggerType.network);

  @override
  AppTextLogger get json => _tryGetAppTextLogger(LoggerType.json);

  @override
  AppWidgetLogger get l10n => _tryGetAppLogger(
        LoggerType.l10n,
        buildNewLogger: (t) => AppWidgetLogger(this, t),
      );

  @override
  AppTextLogger get cache => _tryGetAppTextLogger(LoggerType.cache);

  @override
  Future<bool> changeLogger(l.Logger newLogger) async {
    if (newLogger.isClosed()) return false;
    await newLogger.init;
    final oldLoggerType = loggerType;
    final oldLogger = logger;
    value.warn("AppLoggerMananger.changeLogger",
        beforeVal: (oldLogger.hashCode, oldLoggerType),
        afterVal: newLogger.hashCode,
        ex: ["before", oldLogger.isClosed(), newLogger.isClosed()]);
    logger = newLogger;
    loggerType = AppLoggerHandlerType.custom;
    if (oldLoggerType == AppLoggerHandlerType.custom) oldLogger.close();
    value.warn("AppLoggerMananger.changeLogger",
        beforeVal: (oldLogger.hashCode, oldLoggerType),
        afterVal: logger.hashCode,
        ex: ["after", oldLogger.isClosed(), logger.isClosed()]);
    return true;
  }

  @override
  bool changeLoggerByType(AppLoggerHandlerType t) {
    if (t == loggerType) return false;
    final oldLoggerType = loggerType;
    final oldLogger = logger;
    value.warn("AppLoggerMananger.changeLoggerByType",
        beforeVal: oldLoggerType,
        afterVal: t,
        ex: ["before", oldLogger.isClosed()]);
    logger = AppLoggerMananger.getLoggerByType(t);
    loggerType = t;
    value.warn("AppLoggerMananger.changeLoggerByType",
        beforeVal: oldLoggerType,
        afterVal: loggerType,
        ex: ["after", t, oldLogger.isClosed(), logger.isClosed()]);
    return true;
  }

  @override
  AppTextLogger get debugger => _tryGetAppTextLogger(LoggerType.debugger);
}

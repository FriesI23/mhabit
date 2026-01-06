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

import '../logger_manager.dart';
import '../logger_type.dart';
import 'text_logger.dart';

abstract interface class AppValueChangeLogger {
  LoggerType get type;
  AppTextLogger get parentLogger;

  void debug(
    String name, {
    required dynamic beforeVal,
    required dynamic afterVal,
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  });
  void info(
    String name, {
    required dynamic beforeVal,
    required dynamic afterVal,
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  });
  void warn(
    String name, {
    required dynamic beforeVal,
    required dynamic afterVal,
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  });
  void error(
    String name, {
    required dynamic beforeVal,
    required dynamic afterVal,
    Iterable ex,
    Object? error,
    StackTrace? stackTrace,
  });
  void fatal(
    String name, {
    required dynamic beforeVal,
    required dynamic afterVal,
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  });

  factory AppValueChangeLogger(
    AppLoggerMananger m,
    LoggerType t, {
    AppTextLogger? parentLogger,
  }) => _AppValueChangeLogger(m, t, parentLogger ?? AppTextLogger(m, t));
}

class _AppValueChangeLogger implements AppValueChangeLogger {
  final AppLoggerMananger mananger;
  @override
  final LoggerType type;
  @override
  final AppTextLogger parentLogger;

  const _AppValueChangeLogger(this.mananger, this.type, this.parentLogger);

  String buildMsg(String name, beforeVal, afterVal) {
    return "$name{$beforeVal -> $afterVal}";
  }

  @override
  void debug(
    String name, {
    required beforeVal,
    required afterVal,
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => parentLogger.debug(
    buildMsg(name, beforeVal, afterVal),
    ex: ex,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void info(
    String name, {
    required beforeVal,
    required afterVal,
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => parentLogger.info(
    buildMsg(name, beforeVal, afterVal),
    ex: ex,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void warn(
    String name, {
    required beforeVal,
    required afterVal,
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => parentLogger.warn(
    buildMsg(name, beforeVal, afterVal),
    ex: ex,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void error(
    String name, {
    required beforeVal,
    required afterVal,
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => parentLogger.error(
    buildMsg(name, beforeVal, afterVal),
    ex: ex,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void fatal(
    String name, {
    required beforeVal,
    required afterVal,
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => parentLogger.fatal(
    buildMsg(name, beforeVal, afterVal),
    ex: ex,
    error: error,
    stackTrace: stackTrace,
  );
}

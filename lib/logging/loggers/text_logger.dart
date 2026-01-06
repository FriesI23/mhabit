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

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as l;

import '../logger_manager.dart';
import '../logger_message.dart';
import '../logger_type.dart';

class AppTextLoggerMessage implements AppLoggerMessage {
  @override
  final LoggerType type;
  final String? message;
  final Iterable? extraInfo;
  @override
  final bool forceLogging;

  const AppTextLoggerMessage(
    this.type, {
    this.message,
    this.extraInfo,
    this.forceLogging = false,
  });

  @override
  Iterable<String?> toLogPrinterMessage() => [
    if (message != null) message,
    if (extraInfo != null)
      ...extraInfo!
          .where((e) => e != null)
          .map((e) => (e is Function ? e.call() : e).toString()),
  ];
}

abstract interface class AppTextLogger {
  LoggerType get type;

  void debug(String msg, {Iterable? ex, Object? error, StackTrace? stackTrace});
  void info(String msg, {Iterable? ex, Object? error, StackTrace? stackTrace});
  void warn(String msg, {Iterable? ex, Object? error, StackTrace? stackTrace});
  void error(String msg, {Iterable? ex, Object? error, StackTrace? stackTrace});
  void fatal(String msg, {Iterable? ex, Object? error, StackTrace? stackTrace});

  factory AppTextLogger(AppLoggerMananger m, LoggerType t) {
    if (t == LoggerType.debugger) return _DebuggerAppTextLogger(m, t);
    return _AppTextLogger(m, t);
  }
}

class _AppTextLogger implements AppTextLogger {
  final AppLoggerMananger manager;
  @override
  final LoggerType type;

  const _AppTextLogger(this.manager, this.type);

  void _log(
    l.Level level,
    String msg, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) {
    try {
      manager.logger.log(
        level,
        AppTextLoggerMessage(type, message: msg, extraInfo: ex),
        error: error,
        stackTrace: stackTrace,
      );
    } on Exception catch (e) {
      if (kDebugMode) rethrow;
      log(
        "catch exception while logging",
        level: l.Level.fatal.value,
        error: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  @override
  void debug(
    String msg, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => _log(l.Level.debug, msg, ex: ex, error: error, stackTrace: stackTrace);

  @override
  void info(
    String msg, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => _log(l.Level.info, msg, ex: ex, error: error, stackTrace: stackTrace);

  @override
  void warn(
    String msg, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log(l.Level.warning, msg, ex: ex, error: error, stackTrace: stackTrace);

  @override
  void error(
    String msg, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => _log(l.Level.error, msg, ex: ex, error: error, stackTrace: stackTrace);

  @override
  void fatal(
    String msg, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => _log(l.Level.fatal, msg, ex: ex, error: error, stackTrace: stackTrace);
}

final class _DebuggerAppTextLogger extends _AppTextLogger {
  const _DebuggerAppTextLogger(super.manager, super.type);

  @override
  void _log(
    l.Level level,
    String msg, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) {
    try {
      manager.logger.log(
        level,
        AppTextLoggerMessage(
          type,
          message: msg,
          extraInfo: ex,
          forceLogging: true,
        ),
        error: error,
        stackTrace: stackTrace,
      );
    } on Exception catch (e) {
      if (kDebugMode) rethrow;
      log(
        "catch exception while logging",
        level: l.Level.fatal.value,
        error: e,
        stackTrace: StackTrace.current,
      );
    }
  }
}

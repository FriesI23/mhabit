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
import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as l;

import 'logger_manager.dart';
import 'logger_type.dart';
import 'logger_message.dart';

class AppWidgetLoggerMessage implements AppLoggerMessage {
  @override
  final LoggerType type;
  final Widget? widget;
  final Iterable? extraInfo;
  final String? name;

  const AppWidgetLoggerMessage(this.type,
      {this.widget, this.extraInfo, this.name});

  @override
  Iterable<String?> toLogPrinterMessage() sync* {
    if (widget != null) {
      yield "${name ?? widget!.runtimeType}"
          "[${widget!.key},${widget!.hashCode}]";
    } else if (name != null) {
      yield name;
    }
    if (extraInfo != null) {
      yield* extraInfo!.where((e) => e != null).map((e) => e.toString());
    }
  }
}

abstract interface class AppWidgetLogger {
  LoggerType get type;

  void debug(BuildContext context,
      {Iterable? ex, String? name, Object? error, StackTrace? stackTrace});
  void info(BuildContext context,
      {Iterable? ex, String? name, Object? error, StackTrace? stackTrace});
  void warn(BuildContext context,
      {Iterable? ex, String? name, Object? error, StackTrace? stackTrace});
  void error(BuildContext context,
      {Iterable? ex, String? name, Object? error, StackTrace? stackTrace});
  void fatal(BuildContext context,
      {Iterable? ex, String? name, Object? error, StackTrace? stackTrace});

  factory AppWidgetLogger(AppLoggerMananger m, LoggerType t) =>
      _AppWidgetLogger(m, t);
}

class _AppWidgetLogger implements AppWidgetLogger {
  final AppLoggerMananger manager;
  @override
  final LoggerType type;

  const _AppWidgetLogger(this.manager, this.type);

  void _log(l.Level level, Widget widget,
      {Iterable? ex, String? name, Object? error, StackTrace? stackTrace}) {
    try {
      manager.logger.log(
        level,
        AppWidgetLoggerMessage(type, widget: widget, extraInfo: ex, name: name),
      );
    } on Exception catch (e) {
      if (kDebugMode) rethrow;
      log("catch exception while logging",
          level: l.Level.fatal.value, error: e, stackTrace: StackTrace.current);
    }
  }

  @override
  void debug(BuildContext context,
          {Iterable? ex,
          String? name,
          Object? error,
          StackTrace? stackTrace}) =>
      _log(l.Level.debug, context.widget,
          ex: ex, name: name, error: error, stackTrace: stackTrace);

  @override
  void info(BuildContext context,
          {Iterable? ex,
          String? name,
          Object? error,
          StackTrace? stackTrace}) =>
      _log(l.Level.info, context.widget,
          ex: ex, name: name, error: error, stackTrace: stackTrace);

  @override
  void warn(BuildContext context,
          {Iterable? ex,
          String? name,
          Object? error,
          StackTrace? stackTrace}) =>
      _log(l.Level.warning, context.widget,
          ex: ex, name: name, error: error, stackTrace: stackTrace);

  @override
  void error(BuildContext context,
          {Iterable? ex,
          String? name,
          Object? error,
          StackTrace? stackTrace}) =>
      _log(l.Level.error, context.widget,
          ex: ex, name: name, error: error, stackTrace: stackTrace);

  @override
  void fatal(BuildContext context,
          {Iterable? ex,
          String? name,
          Object? error,
          StackTrace? stackTrace}) =>
      _log(l.Level.fatal, context.widget,
          ex: ex, name: name, error: error, stackTrace: stackTrace);
}

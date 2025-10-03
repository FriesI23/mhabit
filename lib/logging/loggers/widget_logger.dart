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

import '../logger_manager.dart';
import '../logger_message.dart';
import '../logger_type.dart';

class AppWidgetLoggerMessage implements AppLoggerMessage {
  @override
  final LoggerType type;
  final Widget? widget;
  final Iterable? extraInfo;
  final String? name;

  const AppWidgetLoggerMessage(this.type,
      {this.widget, this.extraInfo, this.name});

  @override
  Iterable<String?> toLogPrinterMessage() {
    final result = <String>[];
    if (widget != null) {
      result.add("${name ?? widget!.runtimeType}"
          "[${widget!.key},${widget!.hashCode.toString().padLeft(10, ' ')}]");
    } else if (name != null) {
      result.add(name!);
    }
    if (extraInfo != null) {
      result.addAll(extraInfo!
          .where((e) => e != null)
          .map((e) => (e is Function ? e.call() : e).toString()));
    }
    return result;
  }

  @override
  bool get forceLogging => false;
}

abstract interface class AppWidgetLogger {
  LoggerType get type;

  void debug(BuildContext context,
      {Iterable? ex,
      Widget? widget,
      String? name,
      Object? error,
      StackTrace? stackTrace});
  void info(BuildContext context,
      {Iterable? ex,
      Widget? widget,
      String? name,
      Object? error,
      StackTrace? stackTrace});
  void warn(BuildContext context,
      {Iterable? ex,
      Widget? widget,
      String? name,
      Object? error,
      StackTrace? stackTrace});
  void error(BuildContext context,
      {Iterable? ex,
      Widget? widget,
      String? name,
      Object? error,
      StackTrace? stackTrace});
  void fatal(BuildContext context,
      {Iterable? ex,
      Widget? widget,
      String? name,
      Object? error,
      StackTrace? stackTrace});

  factory AppWidgetLogger(AppLoggerMananger m, LoggerType t) =>
      _AppWidgetLogger(m, t);
}

class _AppWidgetLogger implements AppWidgetLogger {
  final AppLoggerMananger manager;
  @override
  final LoggerType type;

  const _AppWidgetLogger(this.manager, this.type);

  void _log(l.Level level, BuildContext context,
      {Iterable? ex,
      Widget? widget,
      String? name,
      Object? error,
      StackTrace? stackTrace}) {
    try {
      manager.logger.log(
        level,
        AppWidgetLoggerMessage(type,
            widget: context.mounted ? context.widget : widget,
            extraInfo: ex,
            name: name),
        error: error,
        stackTrace: stackTrace,
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
          Widget? widget,
          String? name,
          Object? error,
          StackTrace? stackTrace}) =>
      _log(l.Level.debug, context,
          ex: ex,
          widget: widget,
          name: name,
          error: error,
          stackTrace: stackTrace);

  @override
  void info(BuildContext context,
          {Iterable? ex,
          Widget? widget,
          String? name,
          Object? error,
          StackTrace? stackTrace}) =>
      _log(l.Level.info, context,
          ex: ex,
          widget: widget,
          name: name,
          error: error,
          stackTrace: stackTrace);

  @override
  void warn(BuildContext context,
          {Iterable? ex,
          Widget? widget,
          String? name,
          Object? error,
          StackTrace? stackTrace}) =>
      _log(l.Level.warning, context,
          ex: ex,
          widget: widget,
          name: name,
          error: error,
          stackTrace: stackTrace);

  @override
  void error(BuildContext context,
          {Iterable? ex,
          Widget? widget,
          String? name,
          Object? error,
          StackTrace? stackTrace}) =>
      _log(l.Level.error, context,
          ex: ex,
          widget: widget,
          name: name,
          error: error,
          stackTrace: stackTrace);

  @override
  void fatal(BuildContext context,
          {Iterable? ex,
          Widget? widget,
          String? name,
          Object? error,
          StackTrace? stackTrace}) =>
      _log(l.Level.fatal, context,
          ex: ex,
          widget: widget,
          name: name,
          error: error,
          stackTrace: stackTrace);
}

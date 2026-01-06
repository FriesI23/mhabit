// Copyright 2025 Fries_I23
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

import '../../models/app_sync_tasks.dart' show AppSyncContext;
import '../logger_manager.dart';
import '../logger_type.dart';
import 'text_logger.dart';

abstract interface class AppSyncTaskLogger {
  LoggerType get type;
  AppTextLogger get parentLogger;

  void debug(
    AppSyncContext task, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  });
  void info(
    AppSyncContext task, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  });
  void warn(
    AppSyncContext task, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  });
  void error(
    AppSyncContext task, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  });
  void fatal(
    AppSyncContext task, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  });

  factory AppSyncTaskLogger(
    AppLoggerMananger m,
    LoggerType t, {
    AppTextLogger? parentLogger,
  }) => _AppSyncTaskLogger(m, t, parentLogger ?? AppTextLogger(m, t));
}

class _AppSyncTaskLogger implements AppSyncTaskLogger {
  final AppLoggerMananger mananger;
  @override
  final LoggerType type;
  @override
  final AppTextLogger parentLogger;

  const _AppSyncTaskLogger(this.mananger, this.type, this.parentLogger);

  String buildMsg(AppSyncContext task) =>
      "[${task.sessionId}][${task.runtimeType}][${task.status.name}]";

  @override
  void debug(
    AppSyncContext task, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => parentLogger.debug(
    buildMsg(task),
    ex: ex,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void info(
    AppSyncContext task, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => parentLogger.info(
    buildMsg(task),
    ex: ex,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void warn(
    AppSyncContext task, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => parentLogger.warn(
    buildMsg(task),
    ex: ex,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void error(
    AppSyncContext task, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => parentLogger.error(
    buildMsg(task),
    ex: ex,
    error: error,
    stackTrace: stackTrace,
  );

  @override
  void fatal(
    AppSyncContext task, {
    Iterable? ex,
    Object? error,
    StackTrace? stackTrace,
  }) => parentLogger.fatal(
    buildMsg(task),
    ex: ex,
    error: error,
    stackTrace: stackTrace,
  );
}

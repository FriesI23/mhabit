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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as l;
import 'package:rxdart/rxdart.dart';

import 'handler/console_printer.dart';
import 'logger/text_logger.dart';
import 'logger_message.dart';
import 'logger_type.dart';

class ReplayAppLoggerStreamer<T extends AppLoggerMessage> {
  final l.LogPrinter printer;
  final l.LogOutput outputer;
  final T? startMessage;
  final T? errorMessage;
  final T? completeMessage;

  final ReplaySubject<l.LogEvent> _replaySubject;
  final Completer<void> _completer;

  StreamSubscription<l.LogEvent>? _subscription;
  Completer<void>? _init;
  int _count = 0;

  ReplayAppLoggerStreamer({
    required ReplaySubject<l.LogEvent> replaySubject,
    required this.printer,
    required this.outputer,
    this.startMessage,
    this.errorMessage,
    this.completeMessage,
  })  : _replaySubject = replaySubject,
        _completer = Completer();

  static ReplayAppLoggerStreamer<AppLoggerMessage> buildAppSyncFailed(
      {required ReplaySubject<l.LogEvent> replaySubject,
      required String filePath,
      String? sessionId}) {
    return ReplayAppLoggerStreamer(
        replaySubject: replaySubject,
        printer: const AppLoggerConsoleReleasePrinter(addTime: true),
        outputer: l.AdvancedFileOutput(path: filePath, maxFileSizeKB: -1),
        startMessage: AppTextLoggerMessage(LoggerType.appsync,
            message: "----- START TASK [${sessionId ?? 'unknown'}] -----",
            forceLogging: true),
        completeMessage: AppTextLoggerMessage(LoggerType.appsync,
            message: "----- COMPLETE TASK [${sessionId ?? 'unknown'}] -----",
            forceLogging: true),
        errorMessage: AppTextLoggerMessage(LoggerType.appsync,
            message: "----- FOUND ERROR [${sessionId ?? 'unknown'}] -----",
            forceLogging: true));
  }

  bool get isComplete => _completer.isCompleted;

  Future<void> init() {
    if (_init != null) _init!.future;

    final init = _init = Completer();
    Future.wait([printer.init(), outputer.init()]).catchError((e, s) {
      if (!init.isCompleted) init.completeError(e, s);
      if (init == _init) _init = null;
      return const [];
    }).whenComplete(() {
      if (!init.isCompleted) init.complete();
    });
    return init.future;
  }

  Future<void> run() async {
    if (_subscription != null) return _completer.future;

    _subscription = _replaySubject
        .startWith(l.LogEvent(l.Level.info, startMessage))
        .listen(onData, onDone: onDone, onError: (e, s) {
      if (kDebugMode) Error.throwWithStackTrace(e, s);
    }, cancelOnError: kDebugMode);

    return _completer.future;
  }

  void onComplete() {
    if (_completer.isCompleted) return;
    try {
      handleData(l.LogEvent(l.Level.info, completeMessage));
      outputer.destroy();
      printer.destroy();
    } catch (e, s) {
      if (!_completer.isCompleted) _completer.completeError(e, s);
    } finally {
      if (!_completer.isCompleted) _completer.complete();
    }
  }

  void onDone() {
    try {
      if (_count >= _replaySubject.values.length) {
        for (var es in _replaySubject.errorAndStackTraces) {
          handleData(l.LogEvent(l.Level.info, errorMessage,
              error: es.error, stackTrace: es.stackTrace));
        }
        onComplete();
      }
    } catch (e, s) {
      _completer.completeError(e, s);
    }
  }

  void onData(l.LogEvent event) async {
    if (_completer.isCompleted) return;

    _count += 1;
    if (_replaySubject.isClosed) onDone();
    if (_completer.isCompleted) return;

    handleData(event);
  }

  void handleData(l.LogEvent event) {
    assert(event.message is T?);
    final output = printer.log(event);
    if (output.isNotEmpty) outputer.output(l.OutputEvent(event, output));
  }
}

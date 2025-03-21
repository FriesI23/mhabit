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
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as l;
import 'package:rxdart/rxdart.dart';

import 'handler/console_printer.dart';
import 'logger/text_logger.dart';
import 'logger_message.dart';
import 'logger_type.dart';

class ReplayAppLoggerStreamer<T extends AppLoggerMessage> {
  final ReplaySubject<l.LogEvent> replaySubject;
  final l.LogPrinter printer;
  final l.LogOutput outputer;
  final T? startMessage;
  final T? errorMessage;
  final T? completeMessage;

  StreamSubscription<l.LogEvent>? _subscription;
  bool _isComplete = false;

  ReplayAppLoggerStreamer({
    required this.replaySubject,
    required this.printer,
    required this.outputer,
    this.startMessage,
    this.errorMessage,
    this.completeMessage,
  });

  Future<void> init() async {
    await Future.wait([printer.init(), outputer.init()]);
  }

  static ReplayAppLoggerStreamer<AppLoggerMessage> buildAppSyncFailed(
      {required ReplaySubject<l.LogEvent> replaySubject,
      required String filePath,
      String? sessionId}) {
    return ReplayAppLoggerStreamer(
        replaySubject: replaySubject,
        printer: const AppLoggerConsoleReleasePrinter(),
        outputer: l.FileOutput(file: File(filePath)),
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

  bool get isComplete => _isComplete;

  void handleEvent(l.LogEvent event) {
    assert(event.message is T?);
    final output = printer.log(event);
    if (output.isNotEmpty) outputer.output(l.OutputEvent(event, output));
  }

  Future<void> run() async {
    if (_subscription != null) return _subscription!.asFuture();

    void onDone() {
      try {
        handleEvent(l.LogEvent(l.Level.info, completeMessage));
      } catch (e, s) {
        debugPrint("error: $e, trace: $s");
        if (kDebugMode) rethrow;
      } finally {
        _isComplete = true;
        outputer.destroy();
        printer.destroy();
      }
    }

    Future<l.LogEvent>? last;
    _subscription =
        replaySubject.startWith(l.LogEvent(l.Level.info, startMessage)).listen(
              (event) async {
                handleEvent(event);
                if (replaySubject.isClosed) {
                  last = replaySubject.last;
                }
                if (await last == event && !_isComplete) onDone();
              },
              onDone: onDone,
              onError: (e, s) {
                try {
                  handleEvent(l.LogEvent(l.Level.info, errorMessage,
                      error: e, stackTrace: s));
                } catch (e, s) {
                  debugPrint("error: $e, trace: $s");
                  if (kDebugMode) rethrow;
                } finally {
                  _isComplete = true;
                  outputer.destroy();
                  printer.destroy();
                }
              },
            );

    return _subscription!.asFuture();
  }
}

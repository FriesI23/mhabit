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
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:logger/logger.dart' as l;

import '../logger_message.dart';

class AppLoggerPrinter implements l.LogPrinter {
  static const prefixMap = {
    l.Level.debug: "D",
    l.Level.info: "I",
    l.Level.warning: "W",
    l.Level.error: "E",
    l.Level.fatal: "F",
  };

  @override
  Future<void> destroy() async {}

  @override
  Future<void> init() async {}

  @override
  List<String> log(l.LogEvent event) {
    final AppLoggerMessage? message = event.message;

    Iterable<String?> iterPrefix() sync* {
      yield "[${prefixMap[event.level]}]";
    }

    return [
      [
        iterPrefix().whereNotNull().join(" "),
        " - ",
        if (message != null)
          message.toLogPrinterMessage().whereNotNull().join(" | "),
      ].join(),
    ];
  }
}

class AppLoggerConsoleOutput implements l.LogOutput {
  @override
  Future<void> destroy() async {}

  @override
  Future<void> init() async {}

  @override
  void output(l.OutputEvent event) {
    final AppLoggerMessage? message = event.origin.message;
    for (var msg in event.lines) {
      log(msg,
          level: event.level.value,
          time: event.origin.time,
          name: "app:${message?.type.name ?? ''}:${Isolate.current.debugName}",
          error: event.origin.error,
          stackTrace: event.origin.stackTrace);
    }
  }
}

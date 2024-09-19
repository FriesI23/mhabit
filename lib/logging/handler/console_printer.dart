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

import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as l;

import '../extension.dart';
import '../logger_message.dart';

class AppLoggerConsolePrinter<T extends AppLoggerMessage>
    implements l.LogPrinter {
  static const prefixMap = {
    l.Level.debug: "D",
    l.Level.info: "I",
    l.Level.warning: "W",
    l.Level.error: "E",
    l.Level.fatal: "F",
  };

  const AppLoggerConsolePrinter();

  @override
  Future<void> destroy() async {}

  @override
  Future<void> init() async {}

  @override
  List<String> log(l.LogEvent event) {
    final T? message = event.message;

    return [
      [
        "[${prefixMap[event.level]}]",
        " - ",
        if (message != null)
          message.toLogPrinterMessage().whereNotNull().join(" | "),
      ].join(),
    ];
  }
}

class AppLoggerConsoleReleasePrinter<T extends AppLoggerMessage>
    implements l.LogPrinter {
  static const prefixMap = {
    l.Level.debug: "DEBUG",
    l.Level.info: "INFO",
    l.Level.warning: "WARN",
    l.Level.error: "ERROR",
    l.Level.fatal: "FATAL",
  };

  static final _errorPrinter = l.PrettyPrinter(
    methodCount: 10,
    errorMethodCount: null,
    printEmojis: false,
    dateTimeFormat: l.DateTimeFormat.dateAndTime,
    colors: false,
  );

  const AppLoggerConsoleReleasePrinter();

  @override
  Future<void> destroy() async {}

  @override
  Future<void> init() async {}

  @override
  List<String> log(l.LogEvent event) {
    final T? message = event.message;

    String getMsg({bool addTime = kReleaseMode}) => [
          "[app:${message?.type.name ?? ''}:${Isolate.current.debugName}]"
              " [${prefixMap[event.level]}]",
          if (addTime) _errorPrinter.getTime(event.time),
          if (message != null)
            message.toLogPrinterMessage().whereNotNull().join(" | "),
        ].join(" - ");

    if (event.level.value >= l.Level.error.value) {
      return _errorPrinter.log(event.copyWith(message: getMsg(addTime: true)));
    }

    return [getMsg()];
  }
}

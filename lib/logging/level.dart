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

import 'package:logger/logger.dart' as l;

import '../common/enums.dart';

enum LogLevel implements Comparable<LogLevel>, EnumWithDBCode {
  debug(2000),
  info(3000),
  warn(4000),
  error(5000),
  fatal(6000);

  final int value;

  const LogLevel(this.value);

  @override
  int get dbCode => value;

  static LogLevel? getFromDBCode(int dbCode, {LogLevel? withDefault}) {
    for (var value in LogLevel.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }

  bool operator >(LogLevel other) => value > other.value;

  bool operator <(LogLevel other) => value < other.value;

  bool operator >=(LogLevel other) => value >= other.value;

  bool operator <=(LogLevel other) => value <= other.value;

  @override
  int compareTo(LogLevel other) {
    return value.compareTo(other.value);
  }

  l.Level toLoggerLevel() {
    switch (this) {
      case LogLevel.debug:
        return l.Level.debug;
      case LogLevel.info:
        return l.Level.info;
      case LogLevel.warn:
        return l.Level.warning;
      case LogLevel.error:
        return l.Level.error;
      case LogLevel.fatal:
        return l.Level.fatal;
    }
  }
}

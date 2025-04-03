// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

class DuplicatedDateError implements Exception {
  final dynamic message;

  DuplicatedDateError([this.message = '']);

  @override
  String toString() {
    return "Duplicated Date: ${message.toString()}";
  }
}

class DuplicatedHabitRecordUUIDError implements Exception {
  final dynamic message;

  DuplicatedHabitRecordUUIDError([this.message = '']);

  @override
  String toString() {
    return "Duplicated HabitRecordUUID: ${message.toString()}";
  }
}

class UnknownHabitFrequencyError implements Exception {}

class UnknownWeekdayNumber implements Exception {
  final dynamic message;

  UnknownWeekdayNumber([this.message = '']);

  @override
  String toString() {
    return "Error week day, range [1, 7]: ${message.toString()}";
  }
}

class NotificationIdOutOfDefinedRange implements Exception {
  final num crt;
  final dynamic type;

  const NotificationIdOutOfDefinedRange(this.crt, {this.type});

  @override
  String toString() {
    return "Notification<$type> id out of range, got $crt";
  }
}

class HttpStatusException implements HttpException {
  @override
  final String message;
  @override
  final Uri? uri;
  final int status;

  const HttpStatusException(this.message, this.status, {this.uri});

  @override
  String toString() {
    final b = StringBuffer()
      ..write('HttpStatusException: ')
      ..write(message)
      ..write(', status = $status');
    final uri = this.uri;
    if (uri != null) {
      b.write(', uri = $uri');
    }
    return b.toString();
  }
}

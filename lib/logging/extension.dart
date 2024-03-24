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

import 'package:logger/logger.dart';

extension LogPrinterCopyWithExtension on LogEvent {
  LogEvent copyWith({
    Level? level,
    dynamic message,
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    return LogEvent(
      level ?? this.level,
      message ?? this.message,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      time: time ?? this.time,
    );
  }
}

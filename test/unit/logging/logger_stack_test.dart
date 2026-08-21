// Copyright 2026 Fries_I23
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/logging/logger_stack.dart';

void main() {
  test('parses a stack frame with line and column numbers', () {
    final trace = StackTrace.fromString(
      '#0 LoggerStackTrace.from '
      '(package:mhabit/logging/logger_stack.dart:36:12)\n'
      '#1 HabitDetailViewModel.loadData '
      '(package:mhabit/pages/habit_detail.dart:290:8)',
    );

    final result = LoggerStackTrace.from(trace);

    expect(result.functionName, 'LoggerStackTrace.from');
    expect(result.callerFunctionName, 'HabitDetailViewModel.loadData');
    expect(result.fileName, 'logger_stack.dart');
    expect(result.lineNumber, 36);
    expect(result.columnNumber, 12);
  });

  test('parses a Windows release stack frame without a column number', () {
    final trace = StackTrace.fromString(
      '#0 LoggerStackTrace.from '
      '(package:mhabit/logging/logger_stack.dart:36)\n'
      '#1 HabitDetailViewModel.loadData.loadingFailed '
      '(package:mhabit/pages/habit_detail.dart:290)',
    );

    final result = LoggerStackTrace.from(trace);

    expect(result.fileName, 'logger_stack.dart');
    expect(result.lineNumber, 36);
    expect(result.columnNumber, 0);
  });

  test('does not throw for an unrecognized stack trace', () {
    final result = LoggerStackTrace.from(StackTrace.fromString('unrecognized'));

    expect(result.functionName, 'unknown');
    expect(result.callerFunctionName, 'unknown');
    expect(result.fileName, 'unknown.dart');
    expect(result.lineNumber, 0);
    expect(result.columnNumber, 0);
  });
}

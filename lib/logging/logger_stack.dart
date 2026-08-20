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

// copyright: @Holofox and @LuisDev99 on stackoverflow,
// source code see here: https://stackoverflow.com/a/65924300
class LoggerStackTrace implements StackTrace {
  const LoggerStackTrace._({
    required this.functionName,
    required this.callerFunctionName,
    required this.fileName,
    required this.lineNumber,
    required this.columnNumber,
  });

  factory LoggerStackTrace.from(StackTrace trace) {
    final frames = trace
        .toString()
        .split('\n')
        .where((frame) => frame.isNotEmpty)
        .toList();
    final firstFrame = frames.firstOrNull ?? '';
    final callerFrame = frames.elementAtOrNull(1) ?? '';
    final fileInfo = _getFileInfoFromFrame(firstFrame);

    return LoggerStackTrace._(
      functionName: _getFunctionNameFromFrame(firstFrame),
      callerFunctionName: _getFunctionNameFromFrame(callerFrame),
      fileName: fileInfo.$1,
      lineNumber: fileInfo.$2,
      columnNumber: fileInfo.$3,
    );
  }

  final String functionName;
  final String callerFunctionName;
  final String fileName;
  final int lineNumber;
  final int columnNumber;

  static (String, int, int) _getFileInfoFromFrame(String trace) {
    final match = RegExp(
      r'([A-Za-z0-9_]+\.dart):(\d+)(?::(\d+))?\)?',
    ).firstMatch(trace);
    return (
      match?.group(1) ?? 'unknown.dart',
      int.tryParse(match?.group(2) ?? '') ?? 0,
      int.tryParse(match?.group(3) ?? '') ?? 0,
    );
  }

  static String _getFunctionNameFromFrame(String trace) {
    final match = RegExp(r'^#\d+\s+([^\s(]+)').firstMatch(trace.trim());
    return match?.group(1) ?? 'unknown';
  }

  @override
  String toString() {
    return 'LoggerStackTrace('
        'functionName: $functionName, '
        'callerFunctionName: $callerFunctionName, '
        'fileName: $fileName, '
        'lineNumber: $lineNumber, '
        'columnNumber: $columnNumber)';
  }
}

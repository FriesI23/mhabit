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
    final frames = trace.toString().split('\n');
    final functionName = _getFunctionNameFromFrame(frames[0]);
    final callerFunctionName = _getFunctionNameFromFrame(frames[1]);
    final fileInfo = _getFileInfoFromFrame(frames[0]);

    return LoggerStackTrace._(
      functionName: functionName,
      callerFunctionName: callerFunctionName,
      fileName: fileInfo[0],
      lineNumber: int.parse(fileInfo[1]),
      columnNumber: int.parse(fileInfo[2].replaceFirst(')', '')),
    );
  }

  final String functionName;
  final String callerFunctionName;
  final String fileName;
  final int lineNumber;
  final int columnNumber;

  static List<String> _getFileInfoFromFrame(String trace) {
    final indexOfFileName = trace.indexOf(RegExp('[A-Za-z]+.dart'));
    final fileInfo = trace.substring(indexOfFileName);

    return fileInfo.split(':');
  }

  static String _getFunctionNameFromFrame(String trace) {
    final indexOfWhiteSpace = trace.indexOf(' ');
    final subStr = trace.substring(indexOfWhiteSpace);
    final indexOfFunction = subStr.indexOf(RegExp('[A-Za-z0-9]'));

    return subStr
        .substring(indexOfFunction)
        .substring(0, subStr.substring(indexOfFunction).indexOf(' '));
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

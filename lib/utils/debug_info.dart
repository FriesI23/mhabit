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

import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../common/app_info.dart';
import '../common/consts.dart';

Future<String> get debugLogFilePath async =>
    buildDebugLogFilePath((await getApplicationDocumentsDirectory()).path);

String buildDebugLogFilePath(String dirPath) =>
    path.join(dirPath, debuggerLogFileName);

Future<String> get debugInfoFilePath async =>
    buildDebugInfoFilePath((await getTemporaryDirectory()).path);

String buildDebugInfoFilePath(String dirPath) =>
    path.join(dirPath, debuggerInfoFileName);

Future<String> generateZippedDebugInfo() async {
  final debugLogFile = File(await debugLogFilePath);
  final debugInfoFile = await File(await debugInfoFilePath).writeAsString(
      await AppInfo().generateAppDebugInfo(),
      mode: FileMode.writeOnly);
  final encoder = ZipFileEncoder()
    ..create(path.join(path.dirname(debugInfoFile.path), debuggerZipFile));
  if (await debugLogFile.exists()) encoder.addFile(debugLogFile);
  encoder.addFile(debugInfoFile);
  await encoder.close();
  return encoder.zipPath;
}

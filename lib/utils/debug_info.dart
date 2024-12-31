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

import '../common/app_info.dart';
import '../common/consts.dart';
import 'app_path_provider.dart';

String buildDebugLogFilePath(String dirPath) =>
    path.join(dirPath, debuggerLogFileName);

String buildDebugInfoFilePath(String dirPath) =>
    path.join(dirPath, debuggerInfoFileName);

Future<String> generateZippedDebugInfo() async {
  final pathProvider = AppPathProvider();
  final debugLogFile = File(await pathProvider.getAppDebugLogFilePath());
  final debugInfoFile = await File(await pathProvider.getAppDebugInfoFilePath())
      .writeAsString(await AppInfo().generateAppDebugInfo(),
          mode: FileMode.writeOnly);
  final zipPath = path.join(path.dirname(debugInfoFile.path), debuggerZipFile);
  final encoder = ZipFileEncoder()..create(zipPath);
  await Future.wait([
    debugLogFile
        .exists()
        .then((value) => value ? encoder.addFile(debugLogFile) : null),
    encoder.addFile(debugInfoFile),
  ]).then((_) => encoder.close());
  return zipPath;
}

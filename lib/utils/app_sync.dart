// Copyright 2025 Fries_I23
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

import '../common/consts.dart';
import '../common/utils.dart';
import 'app_path_provider.dart';

String buildSyncFailedLogFilePath(String dirPath, [String? sessionId]) =>
    path.join(
      dirPath,
      sanitizeFileName(
        "$appSyncFailedLogFilePrefix${sessionId != null ? '-$sessionId' : ''}"
        "$appSyncFailedLogFileSuffix",
      ),
    );

Future<String> generateZippedSyncFailedLogs() async {
  final pathProvider = AppPathProvider();
  final syncFailedDir = await pathProvider.getSyncFailLogDir();
  final tempDir = await pathProvider.getTempDir();
  final zipPath = path.join(tempDir.path, appSyncFailedZipFile);
  final encoder = ZipFileEncoder()..create(zipPath);
  await encoder
      .addDirectory(
        syncFailedDir,
        filter: (entity, progress) =>
            entity is File ? ZipFileOperation.include : ZipFileOperation.skip,
      )
      .then((_) => encoder.close());
  return zipPath;
}

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

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'debug_info.dart';

abstract interface class AppPathProvider {
  Future<String> getAppDebugLogFilePath();

  Future<String> getAppDebugInfoFilePath();

  Future<String> getExportHabitsDirPath();

  Future<String> getDatabaseDirPath();

  factory AppPathProvider.v1() => const _AppPathProviderImpl();

  factory AppPathProvider.v2() => const _AppPathProviderV2Impl();

  factory AppPathProvider() => AppPathProvider.v2();

  static Iterable<AppPathProvider> olderProviders() => [
        AppPathProvider.v1(),
      ];
}

final class _AppPathProviderImpl implements AppPathProvider {
  const _AppPathProviderImpl();

  @override
  Future<String> getAppDebugInfoFilePath() => getTemporaryDirectory()
      .then((value) => buildDebugInfoFilePath(value.path));

  @override
  Future<String> getAppDebugLogFilePath() => getApplicationDocumentsDirectory()
      .then((value) => buildDebugLogFilePath(value.path));

  @override
  Future<String> getDatabaseDirPath() => getDatabasesPath();

  @override
  Future<String> getExportHabitsDirPath() =>
      getTemporaryDirectory().then((value) => value.path);
}

final class _AppPathProviderV2Impl implements AppPathProvider {
  const _AppPathProviderV2Impl();

  @override
  Future<String> getAppDebugInfoFilePath() => getApplicationCacheDirectory()
      .then((value) => buildDebugInfoFilePath(value.path));

  @override
  Future<String> getAppDebugLogFilePath() => getApplicationSupportDirectory()
      .then((value) => buildDebugLogFilePath(value.path));

  @override
  Future<String> getDatabaseDirPath() => switch (defaultTargetPlatform) {
        TargetPlatform.android => getDatabasesPath(),
        _ => getApplicationSupportDirectory().then((value) => value.path),
      };

  @override
  Future<String> getExportHabitsDirPath() =>
      getApplicationCacheDirectory().then((value) => value.path);
}

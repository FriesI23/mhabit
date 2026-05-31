// Copyright 2026 Fries_I23
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

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/logging/logger_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Directory? dbDir;
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  setUp(() async {
    dbDir = await Directory.systemTemp.createTemp('mhabit_flutter_test_');
    await databaseFactory.setDatabasesPath(dbDir!.path);
  });
  tearDown(() async {
    final crtDbDir = dbDir;
    dbDir = null;
    if (crtDbDir == null) return;
    try {
      await crtDbDir.delete(recursive: true);
    } on FileSystemException {
      // Some tests dispose DB helpers asynchronously; ignore best-effort cleanup failures.
    }
  });
  AppLoggerMananger(t: AppLoggerHandlerType.custom);
  await testMain();
}

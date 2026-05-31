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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/storage/db_helper_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> _deleteTempDir(Directory dir) async {
  try {
    if (await dir.exists()) await dir.delete(recursive: true);
  } on FileSystemException {
    // DB disposal is asynchronous in current implementation; cleanup is best effort.
  }
}

void main() {
  group('DBHelper database path', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('DBHelperViewModel uses the current databaseFactory path', () async {
      final helper = DBHelperViewModel();
      final expectedPath = path.join(
        await databaseFactory.getDatabasesPath(),
        appDBName,
      );

      addTearDown(helper.dispose);

      await helper.init();

      expect(helper.local.db.path, expectedPath);
      expect(await File(expectedPath).exists(), isTrue);
    });

    test(
      'DBHelperViewModel keeps the current databaseFactory path on reload',
      () async {
        final helper = DBHelperViewModel();
        final expectedPath = path.join(
          await databaseFactory.getDatabasesPath(),
          appDBName,
        );

        addTearDown(helper.dispose);

        await helper.init();
        final initialPath = helper.local.db.path;

        await helper.reload();

        expect(initialPath, expectedPath);
        expect(helper.local.db.path, initialPath);
      },
    );

    test(
      'DBHelperViewModel picks up a changed databaseFactory path for new helpers',
      () async {
        final overrideDir = await Directory.systemTemp.createTemp(
          'mhabit_db_helper_override_',
        );
        final firstHelper = DBHelperViewModel();
        final firstExpectedPath = path.join(
          await databaseFactory.getDatabasesPath(),
          appDBName,
        );

        addTearDown(() async {
          firstHelper.dispose();
          await _deleteTempDir(overrideDir);
        });

        await firstHelper.init();
        await databaseFactory.setDatabasesPath(overrideDir.path);

        final secondHelper = DBHelperViewModel();
        final secondExpectedPath = path.join(overrideDir.path, appDBName);

        addTearDown(secondHelper.dispose);

        await secondHelper.init();

        expect(firstHelper.local.db.path, firstExpectedPath);
        expect(secondHelper.local.db.path, secondExpectedPath);
        expect(firstHelper.local.db.path, isNot(secondHelper.local.db.path));
      },
    );
  });
}

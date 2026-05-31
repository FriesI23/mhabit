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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/storage/db/db_helper.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DBHelper config', () {
    test('DBHelperViewModel uses the configured scoped db path', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'mhabit_db_helper_default_',
      );
      final expectedPath = path.join(tempDir.path, 'default.db');
      await DBHelper.runWithConfig(
        DBHelperConfig.dbPathBuilder(() => expectedPath),
        () async {
          final helper = DBHelperViewModel();

          addTearDown(() async {
            helper.dispose();
            await _deleteTempDir(tempDir);
          });

          await helper.init();

          expect(helper.local.db.path, expectedPath);
          expect(await File(expectedPath).exists(), isTrue);
        },
      );
    });

    test(
      'DBHelperViewModel keeps a scoped config path stable on reload',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'mhabit_db_helper_reload_',
        );
        var builderCallCount = 0;
        await DBHelper.runWithConfig(
          DBHelperConfig.dbPathBuilder(() {
            builderCallCount += 1;
            return path.join(tempDir.path, 'reload.db');
          }),
          () async {
            final helper = DBHelperViewModel();

            addTearDown(() async {
              helper.dispose();
              await _deleteTempDir(tempDir);
            });

            await helper.init();
            final initialPath = helper.local.db.path;

            await helper.reload();

            expect(helper.local.db.path, initialPath);
            expect(builderCallCount, 1);
          },
        );
      },
    );
  });
}

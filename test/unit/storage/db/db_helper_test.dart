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
import 'package:mhabit/storage/db/table.dart';
import 'package:mhabit/storage/db_helper_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _v4CreateHabitsTable =
    '''
CREATE TABLE IF NOT EXISTS ${TableName.habits} (
    id_ INTEGER PRIMARY KEY AUTOINCREMENT,
    type_ INTEGER NOT NULL,
    create_t INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
    modify_t INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
    uuid TEXT NOT NULL UNIQUE,
    status INTEGER NOT NULL,
    name TEXT,
    desc TEXT,
    color INTEGER,
    daily_goal REAL NOT NULL,
    daily_goal_unit TEXT NOT NULL,
    daily_goal_extra REAL,
    freq_type INTEGER,
    freq_custom TEXT,
    start_date INTEGER NOT NULL,
    target_days INTEGER,
    remind_cutsom TEXT,
    remind_question TEXT,
    sort_position REAL NOT NULL DEFAULT 9e999
)
''';

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

  group('DB v4→v5 migration — custom_color + custom_color_tinted columns', () {
    test('ALTER TABLE adds both columns', () async {
      final db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 4,
          onCreate: (db, version) async {
            await db.execute(_v4CreateHabitsTable);
          },
        ),
      );
      addTearDown(db.close);

      // Verify v4 schema has neither column
      var tableInfo = await db.rawQuery(
        'PRAGMA table_info(${TableName.habits})',
      );
      expect(
        tableInfo.any((col) => col['name'] == 'custom_color'),
        isFalse,
        reason: 'v4 schema should not have custom_color column',
      );
      expect(
        tableInfo.any((col) => col['name'] == 'custom_color_tinted'),
        isFalse,
        reason: 'v4 schema should not have custom_color_tinted column',
      );

      // Apply v5 migration (same logic as _onUpgrade)
      tableInfo = await db.rawQuery('PRAGMA table_info(${TableName.habits})');
      if (!tableInfo.any((col) => col['name'] == 'custom_color')) {
        await db.execute(
          "ALTER TABLE ${TableName.habits} "
          "ADD COLUMN custom_color INTEGER",
        );
      }
      if (!tableInfo.any((col) => col['name'] == 'custom_color_tinted')) {
        await db.execute(
          "ALTER TABLE ${TableName.habits} "
          "ADD COLUMN custom_color_tinted INTEGER",
        );
      }

      // Verify both columns now exist
      tableInfo = await db.rawQuery('PRAGMA table_info(${TableName.habits})');
      for (final name in ['custom_color', 'custom_color_tinted']) {
        expect(
          tableInfo.any((col) => col['name'] == name),
          isTrue,
          reason: 'after v5 migration, $name column should exist',
        );
        final col = tableInfo.firstWhere((col) => col['name'] == name);
        expect(col['type'], 'INTEGER');
        expect(col['notnull'], 0, reason: 'column should be nullable');
      }
    });

    test('reapplying migration is safe (PRAGMA guard)', () async {
      final db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 4,
          onCreate: (db, version) async {
            await db.execute(_v4CreateHabitsTable);
          },
        ),
      );
      addTearDown(db.close);

      Future<void> applyMigration() async {
        final tableInfo = await db.rawQuery(
          'PRAGMA table_info(${TableName.habits})',
        );
        if (!tableInfo.any((col) => col['name'] == 'custom_color')) {
          await db.execute(
            "ALTER TABLE ${TableName.habits} "
            "ADD COLUMN custom_color INTEGER",
          );
        }
        if (!tableInfo.any((col) => col['name'] == 'custom_color_tinted')) {
          await db.execute(
            "ALTER TABLE ${TableName.habits} "
            "ADD COLUMN custom_color_tinted INTEGER",
          );
        }
      }

      // Apply once, then again — the PRAGMA check should skip the ALTERs.
      await applyMigration();
      await expectLater(
        applyMigration,
        returnsNormally,
        reason:
            'second migration pass should be a no-op, not throw duplicate column',
      );
    });

    test('existing data survives migration', () async {
      final db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 4,
          onCreate: (db, version) async {
            await db.execute(_v4CreateHabitsTable);
          },
        ),
      );
      addTearDown(db.close);

      // Insert a habit in v4 schema
      await db.insert(TableName.habits, {
        'type_': 1,
        'uuid': 'test-uuid-001',
        'status': 1,
        'name': 'Legacy Habit',
        'desc': '',
        'color': 1,
        'daily_goal': 1,
        'daily_goal_unit': 'times',
        'freq_type': 1,
        'freq_custom': '{}',
        'start_date': 20000,
        'target_days': 30,
        'sort_position': 1,
      });

      // Apply v5 migration
      final tableInfo = await db.rawQuery(
        'PRAGMA table_info(${TableName.habits})',
      );
      if (!tableInfo.any((col) => col['name'] == 'custom_color')) {
        await db.execute(
          "ALTER TABLE ${TableName.habits} "
          "ADD COLUMN custom_color INTEGER",
        );
      }
      if (!tableInfo.any((col) => col['name'] == 'custom_color_tinted')) {
        await db.execute(
          "ALTER TABLE ${TableName.habits} "
          "ADD COLUMN custom_color_tinted INTEGER",
        );
      }

      // Insert a new habit with custom_color + custom_color_tinted
      await db.insert(TableName.habits, {
        'type_': 1,
        'uuid': 'test-uuid-002',
        'status': 1,
        'name': 'Custom Color Habit',
        'desc': '',
        'color': 1,
        'custom_color': 0xFF123456,
        'custom_color_tinted': 0,
        'daily_goal': 1,
        'daily_goal_unit': 'times',
        'freq_type': 1,
        'freq_custom': '{}',
        'start_date': 20000,
        'target_days': 30,
        'sort_position': 2,
      });

      // Query both habits back
      final rows = await db.query(
        TableName.habits,
        orderBy: 'sort_position ASC',
      );
      expect(rows.length, 2);

      // Legacy habit: both new columns are null
      expect(rows[0]['name'], 'Legacy Habit');
      expect(rows[0]['custom_color'], isNull);
      expect(rows[0]['custom_color_tinted'], isNull);

      // New habit: both columns are preserved
      expect(rows[1]['name'], 'Custom Color Habit');
      expect(rows[1]['custom_color'], 0xFF123456);
      expect(rows[1]['custom_color_tinted'], 0);
    });
  });
}

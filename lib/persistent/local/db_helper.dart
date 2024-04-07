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

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../assets/assets.dart';
import '../../common/async.dart';
import '../../common/consts.dart';
import '../../common/global.dart';
import '../../logging/helper.dart';
import '../../logging/logger_stack.dart';
import '../utils.dart';
import 'handler/habit.dart';
import 'handler/record.dart';
import 'sql.dart';
import 'table.dart';

abstract interface class DBHelper implements AsyncInitialization {
  Database get db;

  factory DBHelper() => _DBHelper();

  @override
  Future init({bool reinit = false});

  void dispose();
}

class _DBHelper implements DBHelper {
  late Database _db;

  @override
  Database get db => _db;

  _DBHelper();

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(await getSqlFromFile(Assets.sql.mhHabits));
    await db.execute(await getSqlFromFile(Assets.sql.mhRecords));
    final indexesBatch = db.batch();
    const LineSplitter()
        .convert(await getSqlFromFile(Assets.sql.indexes))
        .forEach((sql) {
      indexesBatch.execute(sql);
    });
    await indexesBatch.commit();
    await db.execute(CustomSql.autoUpdateHabitssModifyTimeTrigger);
    await db.execute(CustomSql.autoUpdateRecordsModifyTimeTrigger);
    await db.execute(CustomSql.autoAddSortPostionWhenAddNewHabit);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final tableInfo =
          await db.rawQuery('PRAGMA table_info(${TableName.records})');
      if (!tableInfo
          .any((column) => column['name'] == RecordDBCellKey.reason)) {
        await db.execute("ALTER TABLE ${TableName.records} "
            "ADD COLUMN ${RecordDBCellKey.reason} TEXT NOT NULL DEFAULT ''");
      }
    }
    if (oldVersion < 3) {
      final tableInfo =
          await db.rawQuery('PRAGMA table_info(${TableName.habits})');
      if (!tableInfo
          .any((column) => column['name'] == HabitDBCellKey.dailyGoalExtra)) {
        await db.execute("ALTER TABLE ${TableName.habits} "
            "ADD COLUMN ${HabitDBCellKey.dailyGoalExtra} REAL");
      }
    }
  }

  Future<Database> _openDB(String dbPath) async {
    return openDatabase(
      dbPath,
      version: appDBVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        db.execute("PRAGMA foreign_keys = ON");
      },
    );
  }

  Future<void> _deleteBD(String dbPath) async {
    try {
      await deleteDatabase(dbPath);
      appLog.db.info("Delete db");
    } catch (e) {
      appLog.db.error("error during delete db",
          error: e, stackTrace: LoggerStackTrace.from(StackTrace.current));
    }
  }

  @override
  Future init({bool reinit = false}) async {
    String dbPath = join(await getDatabasesPath(), appDBName);

    Future initNew() async {
      appLog.db.info("local.$runtimeType.init", ex: ["processing"]);
      if (kDebugMode && debugClearDBWhenStart) await _deleteBD(dbPath);
      _db = await _openDB(dbPath);
      appLog.db.info("local.$runtimeType.init", ex: ["done", _db]);
    }

    Future initOld() async {
      appLog.db.info("local.$runtimeType.init", ex: ["re-init processing"]);
      await db.close();
      await _deleteBD(dbPath);
      _db = await _openDB(dbPath);
      appLog.db.info("local.$runtimeType.init", ex: ["re-init done"]);
    }

    await (reinit ? initOld() : initNew());
  }

  @override
  void dispose() {
    db.close();
  }

  @override
  String toString() {
    return "local.$runtimeType(db=$_db)";
  }
}

abstract class DBHelperHandler {
  final DBHelper helper;

  const DBHelperHandler(this.helper);

  Database get db => helper.db;
  String get table;
}

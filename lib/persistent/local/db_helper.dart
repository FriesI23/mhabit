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
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../assets/assets.dart';
import '../../common/async.dart';
import '../../common/consts.dart';
import '../../common/global.dart';
import '../../logging/helper.dart';
import '../../logging/logger_stack.dart';
import '../../utils/app_path_provider.dart';
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
  static const Set<TargetPlatform> useffiPlafroms = {
    TargetPlatform.linux,
    TargetPlatform.windows
  };

  Database? _db;

  @override
  Database get db => _db!;

  _DBHelper();

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(await getSqlFromFile(Assets.sql.mhHabits));
    await db.execute(await getSqlFromFile(Assets.sql.mhRecords));
    final indexesBatch = db.batch();
    const LineSplitter()
        .convert(await getSqlFromFile(Assets.sql.indexes))
        .forEach(indexesBatch.execute);
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
      singleInstance: false,
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

  Future<void> migrateDatabaseToNewPath() async {
    final dbDirPath = await AppPathProvider().getDatabaseDirPath();
    final dbPath = path.join(dbDirPath, appDBName);
    final rand = Random();
    if (await File(dbPath).exists()) return;
    for (var oldPd in AppPathProvider.olderProviders()) {
      final oldDirPath = await oldPd.getDatabaseDirPath();
      final oldDbFile = File(path.join(oldDirPath, appDBName));
      final magicNum = rand.nextInt(2 << 15 - 1);
      appLog.db.info("migrate db to new path",
          ex: [magicNum, oldDbFile.path, dbPath]);
      if (await oldDbFile.exists()) {
        final oldJoFile = File('${oldDbFile.path}-journal');
        await Future.wait<File?>([
          oldDbFile.copy(dbPath),
          oldJoFile.exists().then(
              (value) => value ? oldJoFile.copy('$dbPath-journal') : null),
        ])
            .then((value) =>
                appLog.db.info("migrate db to new path done", ex: [magicNum]))
            .onError((error, stackTrace) => appLog.db.fatal(
                "migrate db failed with error",
                ex: [magicNum],
                error: error,
                stackTrace: stackTrace));
        break;
      }
    }
  }

  @override
  Future init({bool reinit = false}) async {
    if (!reinit && useffiPlafroms.contains(defaultTargetPlatform)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    await migrateDatabaseToNewPath();
    final String dbPath =
        path.join(await AppPathProvider().getDatabaseDirPath(), appDBName);

    Future initNew() async {
      appLog.db.info("local.$runtimeType.init", ex: ["processing"]);
      if (kDebugMode && debugClearDBWhenStart) await _deleteBD(dbPath);
      _db = await _openDB(dbPath);
      appLog.db.info("local.$runtimeType.init", ex: ["done", _db]);
    }

    Future initOld() async {
      appLog.db.info("local.$runtimeType.init", ex: ["re-init processing"]);
      await _db?.close();
      await _deleteBD(dbPath);
      _db = await _openDB(dbPath);
      appLog.db.info("local.$runtimeType.init", ex: ["re-init done"]);
    }

    await (reinit ? initOld() : initNew());
  }

  @override
  void dispose() {
    appLog.db.info("local.$runtimeType.dispose", ex: [_db]);
    final orginDB = _db;
    if (orginDB != null) {
      Future.delayed(const Duration(seconds: 1)).then((_) {
        appLog.db.info("local.$runtimeType.dispose", ex: ["close db", orginDB]);
        if (orginDB.isOpen) orginDB.close();
      });
    }
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

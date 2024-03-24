// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../common/abc.dart';
import '../common/consts.dart';
import '../common/global.dart';
import '../logging/helper.dart';
import '../logging/logger_stack.dart';
import 'db_helper/habits.dart';
import 'db_helper/records.dart';

const String _autoUpdateRecordsModifyTimeTrigger = """
CREATE TRIGGER auto_update_mh_records_modify_t
AFTER UPDATE ON mh_records
BEGIN
  UPDATE mh_records
  SET modify_t = (cast(strftime('%s','now') as int))
  WHERE uuid = NEW.uuid;
END""";

const String _autoUpdateHabitssModifyTimeTrigger = """
CREATE TRIGGER auto_update_mh_habits_modify_t
AFTER UPDATE ON mh_habits
BEGIN
  UPDATE mh_habits
  SET modify_t = (cast(strftime('%s','now') as int))
  WHERE uuid = NEW.uuid;
END
""";

const String _autoAddSortPostionWhenAddNewHabit = """
CREATE TRIGGER auto_insert_mh_habits_sort_position
AFTER INSERT ON mh_habits
BEGIN
  UPDATE mh_habits
  SET sort_position = NEW.id_
  WHERE uuid = NEW.uuid;
END
""";

Future<String> getSQLText(String dbfile) async {
  ByteData rawText = await rootBundle.load(join('assets/sql', dbfile));
  var u8List =
      rawText.buffer.asUint8List(rawText.offsetInBytes, rawText.lengthInBytes);
  return utf8.decode(u8List);
}

abstract class DBInterface {}

class DB implements DBInterface, FutureInitializationABC {
  static DB? _instance;
  late Database db;

  DB._internal() {
    _instance = this;
  }

  factory DB() => _instance ?? DB._internal();

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(await getSQLText('mh_habits.sql'));
    await db.execute(await getSQLText('mh_records.sql'));
    var indexesBatch = db.batch();
    const LineSplitter()
        .convert(await getSQLText('indexes.sql'))
        .forEach((sql) {
      indexesBatch.execute(sql);
    });
    await indexesBatch.commit();
    // await db.execute(await getSQLText('indexes.sql'));
    await db.execute(_autoUpdateHabitssModifyTimeTrigger);
    await db.execute(_autoUpdateRecordsModifyTimeTrigger);
    await db.execute(_autoAddSortPostionWhenAddNewHabit);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final tableInfo =
          await db.rawQuery('PRAGMA table_info($dbRecordsTableName)');
      if (!tableInfo
          .any((column) => column['name'] == RecordDBCellKey.reason)) {
        await db.execute("ALTER TABLE $dbRecordsTableName "
            "ADD COLUMN ${RecordDBCellKey.reason} TEXT NOT NULL DEFAULT ''");
      }
    }
    if (oldVersion < 3) {
      final tableInfo =
          await db.rawQuery('PRAGMA table_info($dbHabitsTableName)');
      if (!tableInfo
          .any((column) => column['name'] == HabitDBCellKey.dailyGoalExtra)) {
        await db.execute("ALTER TABLE $dbHabitsTableName "
            "ADD COLUMN ${HabitDBCellKey.dailyGoalExtra} REAL");
      }
    }
  }

  Future<Database> _initDatabase(String dbPath) async {
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
  Future init() async {
    appLog.db.info("Initializing db ...");
    String dbPath = join(await getDatabasesPath(), appDBName);
    if (kDebugMode && debugClearDBWhenStart) _deleteBD(dbPath);
    db = await _initDatabase(dbPath);
    appLog.db.info('Initialized db', ex: [db]);
  }

  Future reInit() async {
    appLog.db.info('Re-Initializing db ...');
    String dbPath = join(await getDatabasesPath(), appDBName);
    final orgDB = db;
    await orgDB.close();
    await _deleteBD(dbPath);
    db = await _initDatabase(dbPath);
    appLog.db.info('Re-Initialized db', ex: [orgDB, db]);
  }
}

class DBCellBase {
  const DBCellBase();

  Map<String, dynamic> toMap() => throw UnimplementedError();

  @override
  String toString() {
    return 'DBCell${toMap().toString()}';
  }
}

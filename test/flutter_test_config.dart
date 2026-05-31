import 'dart:async';
import 'dart:io';

import 'package:mhabit/logging/logger_manager.dart';
import 'package:mhabit/storage/db/db_helper.dart';
import 'package:path/path.dart' as path;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final dbDir = await Directory.systemTemp.createTemp('mhabit_flutter_test_');
  var nextDbId = 0;
  AppLoggerMananger(t: AppLoggerHandlerType.custom);
  try {
    await DBHelper.runWithConfig(
      DBHelperConfig.dbPathBuilder(
        () => path.join(dbDir.path, 'db_${nextDbId++}.db'),
      ),
      () async => testMain(),
    );
  } finally {
    try {
      await dbDir.delete(recursive: true);
    } on FileSystemException {
      // Some tests dispose DB helpers asynchronously; ignore best-effort cleanup failures.
    }
  }
}

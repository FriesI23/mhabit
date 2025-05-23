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
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../common/types.dart';
import '../logging/helper.dart';
import '../model/habit_export.dart';
import '../persistent/db_helper_provider.dart';
import '../utils/app_path_provider.dart';

class HabitFileExporterViewModel extends ChangeNotifier
    with DBHelperLoadedMixin {
  static const defaultExportFileNamePrefix = "export-habits";

  String _getExportDataFileName(
      {DateTime? dateTime,
      String? prefix = defaultExportFileNamePrefix,
      String? suffix}) {
    dateTime = dateTime ?? DateTime.now();
    final dateString = DateFormat('y_MM_dd_H_m_s').format(dateTime);
    final fileStringList = [
      if (prefix != null) prefix,
      dateString,
      if (suffix != null) suffix,
    ];
    return "${fileStringList.join("-")}.json";
  }

  Future<String> _writeDataToTmpDir(String fileName, String data) =>
      AppPathProvider()
          .getExportHabitsDirPath()
          .then((value) => File(path.join(value, fileName)).writeAsString(data))
          .then((value) => value.path);

  Map<String, Object?> formatExportJsonData(
      {Iterable<HabitExportData>? habits}) {
    final result = <String, Object?>{};
    if (habits != null) {
      final habitsData = <Map<String, Object?>>[];
      for (var habit in habits) {
        habitsData.add(habit.toJson());
      }
      result["habits"] = habitsData;
    }
    return result;
  }

  Future<String?> exportHabitData(HabitUUID habitUUID,
      {withRecords = true, bool listen = true}) async {
    final exporter =
        HabitExporter(habitDBHelper, recordDBHelper, uuidList: [habitUUID]);
    final result = await exporter.exportData(withRecords: withRecords);
    if (result.isEmpty) return null;

    final data = formatExportJsonData(habits: result);
    final jsonData = jsonEncode(data);
    final fileName = _getExportDataFileName();
    final filePath = await _writeDataToTmpDir(fileName, jsonData);

    appLog.export
        .info("$runtimeType.exportHabitData", ex: [fileName, jsonData]);

    if (listen) notifyListeners();
    return filePath;
  }

  Future<String?> exportMultiHabitsData(List<HabitUUID> uuidList,
      {withRecords = true, bool listen = true}) async {
    final exporter =
        HabitExporter(habitDBHelper, recordDBHelper, uuidList: uuidList);
    final result = await exporter.exportData(withRecords: withRecords);
    if (result.isEmpty) return null;

    final data = formatExportJsonData(habits: result);
    final jsonData = jsonEncode(data);
    final fileName = _getExportDataFileName();
    final filePath = await _writeDataToTmpDir(fileName, jsonData);

    appLog.export
        .info("$runtimeType.exportMultiHabitsData", ex: [fileName, jsonData]);

    if (listen) notifyListeners();
    return filePath;
  }

  Future<String?> exportAllHabitsData(
      {withRecords = true, bool listen = true}) async {
    Iterable<HabitExportData> habitExportData;

    habitExportData = await HabitExportAll(habitDBHelper, recordDBHelper)
        .exportData(withRecords: withRecords);

    final data = formatExportJsonData(habits: habitExportData);
    final jsonData = jsonEncode(data);
    final fileName = _getExportDataFileName(prefix: "export-all");
    final filePath = await _writeDataToTmpDir(fileName, jsonData);

    appLog.export
        .info("$runtimeType.exportAllHabitsData", ex: [fileName, jsonData]);

    if (listen) notifyListeners();
    return filePath;
  }
}

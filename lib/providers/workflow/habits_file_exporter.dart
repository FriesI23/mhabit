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

import '../../common/types.dart';
import '../../logging/helper.dart';
import '../../models/group_export.dart';
import '../../models/habit_export.dart';
import '../../utils/app_clock.dart';
import '../../utils/app_path_provider.dart';
import 'group_manager.dart';
import 'habits_manager.dart';

class HabitFileExportRunner extends ChangeNotifier {
  static const defaultExportFileNamePrefix = "export-habits";
  final AppPathProvider _pathProvider;
  late HabitExportAccess _access;
  GroupExportAccess? _groupAccess;

  HabitFileExportRunner({AppPathProvider? pathProvider})
    : _pathProvider = pathProvider ?? AppPathProvider();

  void attachAccess(HabitExportAccess newAccess) {
    _access = newAccess;
  }

  void attachGroupAccess(GroupExportAccess newAccess) {
    _groupAccess = newAccess;
  }

  String _getExportDataFileName({
    DateTime? dateTime,
    String? prefix = defaultExportFileNamePrefix,
    String? suffix,
  }) {
    dateTime = dateTime ?? AppClock().now();
    final dateString = DateFormat('y_MM_dd_H_m_s').format(dateTime);
    final fileStringList = [?prefix, dateString, ?suffix];
    return "${fileStringList.join("-")}.json";
  }

  Future<String> _writeDataToTmpDir(String fileName, String data) =>
      _pathProvider
          .getExportHabitsDirPath()
          .then((value) => File(path.join(value, fileName)).writeAsString(data))
          .then((value) => value.path);

  Map<String, Object?> formatExportJsonData({
    Iterable<HabitExportData>? habits,
    Iterable<GroupExportData>? groups,
  }) {
    final result = <String, Object?>{};
    if (habits != null) {
      final habitsData = <Map<String, Object?>>[];
      for (var habit in habits) {
        habitsData.add(habit.toJson());
      }
      result["habits"] = habitsData;
    }
    if (groups != null) {
      final groupsData = <Map<String, Object?>>[];
      for (var group in groups) {
        groupsData.add(group.toJson());
      }
      result["groups"] = groupsData;
    }
    return result;
  }

  Future<String?> exportHabitData(
    HabitUUID habitUUID, {
    bool withRecords = true,
    bool withGroups = true,
    bool listen = true,
  }) async {
    final result = await _access.loadHabitExportData(
      uuidList: [habitUUID],
      withRecords: withRecords,
    );
    if (result.isEmpty) return null;

    final groupExportData = withGroups
        ? await _groupAccess?.loadGroupExportData()
        : null;

    final data = formatExportJsonData(habits: result, groups: groupExportData);
    final jsonData = jsonEncode(data);
    final fileName = _getExportDataFileName();
    final filePath = await _writeDataToTmpDir(fileName, jsonData);

    appLog.export.info(
      "$runtimeType.exportHabitData",
      ex: [fileName, jsonData],
    );

    if (listen) notifyListeners();
    return filePath;
  }

  Future<String?> exportMultiHabitsData(
    List<HabitUUID> uuidList, {
    bool withRecords = true,
    bool withGroups = true,
    bool listen = true,
  }) async {
    final result = await _access.loadHabitExportData(
      uuidList: uuidList,
      withRecords: withRecords,
    );
    if (result.isEmpty) return null;

    final groupExportData = withGroups
        ? await _groupAccess?.loadGroupExportData()
        : null;

    final data = formatExportJsonData(habits: result, groups: groupExportData);
    final jsonData = jsonEncode(data);
    final fileName = _getExportDataFileName();
    final filePath = await _writeDataToTmpDir(fileName, jsonData);

    appLog.export.info(
      "$runtimeType.exportMultiHabitsData",
      ex: [fileName, jsonData],
    );

    if (listen) notifyListeners();
    return filePath;
  }

  Future<String?> exportAllHabitsData({
    bool withRecords = true,
    bool withGroups = true,
    bool listen = true,
  }) async {
    final habitExportData = await _access.loadHabitExportData(
      withRecords: withRecords,
    );
    final groupExportData = withGroups
        ? await _groupAccess?.loadGroupExportData()
        : null;

    final data = formatExportJsonData(
      habits: habitExportData,
      groups: groupExportData,
    );
    final jsonData = jsonEncode(data);
    final fileName = _getExportDataFileName(prefix: "export-all");
    final filePath = await _writeDataToTmpDir(fileName, jsonData);

    appLog.export.info(
      "$runtimeType.exportAllHabitsData",
      ex: [fileName, jsonData],
    );

    if (listen) notifyListeners();
    return filePath;
  }
}

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

import 'package:flutter/material.dart';

import '../model/habit_import.dart';
import '../storage/db_helper_provider.dart';
import 'commons.dart';

class HabitFileImporterViewModel extends ChangeNotifier
    with DBHelperLoadedMixin
    implements ProviderMounted {
  // status
  bool _needReloadDisplayUI = false;
  // inside status
  bool _mounted = true;

  @override
  void dispose() {
    if (!_mounted) return;
    super.dispose();
    _mounted = false;
  }

  void markReloadDisplayFlag() {
    _needReloadDisplayUI = true;
  }

  bool consumeReloadDisplayFlag() {
    final tmp = _needReloadDisplayUI;
    _needReloadDisplayUI = false;
    return tmp;
  }

  bool importHabitsData(
    Iterable<Object?> jsonData, {
    void Function(int count, int total)? whenloadHabit,
    void Function(int total)? whenloadAllHabits,
    bool listen = true,
  }) {
    void onAllFutureComplated(int total) {
      whenloadAllHabits?.call(total);
      markReloadDisplayFlag();
      if (listen) notifyListeners();
    }

    final importer = HabitImport(habitDBHelper, recordDBHelper, data: jsonData);
    final futures = importer.importData();
    if (futures.isEmpty) return false;

    var completeCount = 0;
    final allCount = futures.length;
    for (var future in futures) {
      future.whenComplete(() {
        completeCount += 1;
        whenloadHabit?.call(completeCount, allCount);
        if (completeCount >= allCount) onAllFutureComplated(allCount);
      });
    }
    return true;
  }

  HabitImport importHabitsDataDryRun(Iterable<Object?> jsonData) {
    final importer = HabitImport(habitDBHelper, recordDBHelper, data: jsonData);
    return importer;
  }

  @override
  bool get mounted => _mounted;
}

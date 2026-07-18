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

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../common/types.dart';
import '../support/commons.dart';
import 'group_manager.dart';
import 'habits_manager.dart';

class HabitFileImportRunner extends ChangeNotifier implements ProviderMounted {
  // inside status
  bool _mounted = true;
  late HabitImportAccess _access;
  GroupImportAccess? _groupAccess;

  void attachAccess(HabitImportAccess newAccess) {
    _access = newAccess;
  }

  void attachGroupAccess(GroupImportAccess newAccess) {
    _groupAccess = newAccess;
  }

  @override
  void dispose() {
    if (!_mounted) return;
    super.dispose();
    _mounted = false;
  }

  Future<int>? importHabitsData(
    Iterable<Object?> jsonData, {
    void Function(int count, int failed, int total)? whenloadHabit,
    void Function(int count, int failed, int total)? whenloadAllHabits,
    bool listen = true,
    Map<String, GroupUUID>? groupUuidMapping,
  }) {
    void onAllFutureComplated(int count, int failed, int total) {
      whenloadAllHabits?.call(count, failed, total);
      if (listen) notifyListeners();
    }

    final futures = _access.importHabitsData(
      jsonData,
      groupUuidMapping: groupUuidMapping,
    );
    if (futures.isEmpty) return null;

    final completer = Completer<int>();
    var completeCount = 0, failedCount = 0;
    final allCount = futures.length;
    for (var future in futures) {
      future
          .then((_) {
            completeCount += 1;
          })
          .catchError((e, s) {
            failedCount += 1;
          })
          .whenComplete(() {
            whenloadHabit?.call(completeCount, failedCount, allCount);
            final totalCount = completeCount + failedCount;
            if (totalCount >= allCount) {
              completer.complete(totalCount);
              onAllFutureComplated(completeCount, failedCount, allCount);
            }
          });
    }
    return completer.future;
  }

  int importHabitsDataDryRun(Iterable<Object?> jsonData) {
    return _access.getImportHabitsCount(jsonData);
  }

  int importGroupsDataDryRun(Iterable<Object?> jsonData) {
    return _groupAccess?.getImportGroupsCount(jsonData) ?? 0;
  }

  Future<Map<String, GroupUUID>> importGroupsData(
    Iterable<Object?> jsonData, {
    bool listen = true,
  }) async {
    final mapping = await _groupAccess?.importGroupsData(jsonData) ?? {};
    if (listen) notifyListeners();
    return mapping;
  }

  @override
  bool get mounted => _mounted;
}

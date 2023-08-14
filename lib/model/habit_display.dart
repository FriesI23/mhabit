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

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:quiver/core.dart';

import '../common/consts.dart';
import '../common/enums.dart';
import '../common/types.dart';
import '../db/db_helper/habits.dart';
import 'habit_form.dart';
import 'habit_summary.dart';

part 'habit_display.g.dart';

enum HabitDisplaySortType implements EnumWithDBCodeABC {
  manual(code: 1),
  name(code: 2),
  colorType(code: 3),
  progress(code: 4),
  startT(code: 5),
  status(code: 6);

  final int _code;

  const HabitDisplaySortType({required int code}) : _code = code;

  @override
  int get dbCode => _code;

  static HabitDisplaySortType? getFromDBCode(int dbCode,
      {HabitDisplaySortType? withDefault = HabitDisplaySortType.manual}) {
    for (var value in HabitDisplaySortType.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }

  static Iterable<HabitDisplaySortType> get menuOrderedList => const [
        HabitDisplaySortType.name,
        HabitDisplaySortType.colorType,
        HabitDisplaySortType.status,
        HabitDisplaySortType.progress,
        HabitDisplaySortType.startT,
        HabitDisplaySortType.manual,
      ];
}

enum HabitDisplaySortDirection implements EnumWithDBCodeABC {
  asc(code: 1),
  desc(code: 2);

  final int _code;

  const HabitDisplaySortDirection({required int code}) : _code = code;

  @override
  int get dbCode => _code;

  static HabitDisplaySortDirection? getFromDBCode(int dbCode,
      {HabitDisplaySortDirection? withDefault =
          HabitDisplaySortDirection.asc}) {
    for (var value in HabitDisplaySortDirection.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }
}

enum HabitDisplayEditMode { create, edit }

enum HabitsDisplayFilterKey {
  allowActivedHabits,
  allowArchivedHabits,
  allowCompleteHabits
}

class HabitDisplayEditParams {
  final HabitUUID uuid;
  final DateTime createT;
  final DateTime modifyT;

  const HabitDisplayEditParams({
    required this.uuid,
    required this.createT,
    required this.modifyT,
  });

  HabitDisplayEditParams.fromDBCell(HabitDBCell dbCell)
      : uuid = dbCell.uuid!,
        createT =
            DateTime.fromMillisecondsSinceEpoch(dbCell.createT! * onSecondMS),
        modifyT =
            DateTime.fromMillisecondsSinceEpoch(dbCell.modifyT! * onSecondMS);

  @override
  String toString() {
    return "HabitEditParams($uuid, $createT, $modifyT)";
  }
}

@CopyWith()
class HabitsDisplayFilter {
  static const _defaultAllowActivedHabits = true;
  static const _defualtAllowArchivedHabits = false;
  static const _defaultAllowCompleteHabits = true;

  final bool allowActivedHabits;
  final bool allowArchivedHabits;
  final bool allowCompleteHabits;

  static const allFalse = HabitsDisplayFilter._(
    allowActivedHabits: false,
    allowArchivedHabits: false,
    allowCompleteHabits: false,
  );

  const HabitsDisplayFilter({
    required this.allowActivedHabits,
    required this.allowArchivedHabits,
    required this.allowCompleteHabits,
  });

  const HabitsDisplayFilter._({
    required this.allowActivedHabits,
    required this.allowArchivedHabits,
    required this.allowCompleteHabits,
  });

  const HabitsDisplayFilter.withDefault()
      : allowActivedHabits = _defaultAllowActivedHabits,
        allowArchivedHabits = _defualtAllowArchivedHabits,
        allowCompleteHabits = _defaultAllowCompleteHabits;

  HabitsDisplayFilter.fromMap(Map<String, Object?> data)
      : allowActivedHabits =
            (data[HabitsDisplayFilterKey.allowActivedHabits.name] ??
                _defaultAllowActivedHabits) as bool,
        allowArchivedHabits =
            (data[HabitsDisplayFilterKey.allowArchivedHabits.name] ??
                _defualtAllowArchivedHabits) as bool,
        allowCompleteHabits =
            (data[HabitsDisplayFilterKey.allowCompleteHabits.name] ??
                _defaultAllowCompleteHabits) as bool;

  Map<String, Object?> toMap() {
    return {
      HabitsDisplayFilterKey.allowActivedHabits.name: allowActivedHabits,
      HabitsDisplayFilterKey.allowArchivedHabits.name: allowArchivedHabits,
      HabitsDisplayFilterKey.allowCompleteHabits.name: allowCompleteHabits,
    };
  }

  bool Function(HabitSummaryData) getDisplayFilterFunction() {
    bool func(HabitSummaryData data) {
      var show = false;
      show = show || (data.isActived && allowActivedHabits);
      show = show || (data.isArchived && allowArchivedHabits);
      show = show || (data.isComplated && allowCompleteHabits);
      return show;
    }

    return func;
  }

  @override
  bool operator ==(Object other) {
    if (other is! HabitsDisplayFilter) return false;
    return allowActivedHabits == other.allowActivedHabits &&
        allowArchivedHabits == other.allowArchivedHabits &&
        allowCompleteHabits == other.allowCompleteHabits;
  }

  @override
  int get hashCode =>
      hash3(allowActivedHabits, allowArchivedHabits, allowCompleteHabits);
}

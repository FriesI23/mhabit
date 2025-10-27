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

import 'dart:collection';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';

import '../annotations/json_annotations.dart';
import '../common/consts.dart';
import '../common/enums.dart';
import '../common/types.dart';
import '../storage/db/handlers/habit.dart';
import 'common.dart';
import 'habit_form.dart';
import 'habit_summary.dart';

part 'habit_display.g.dart';

enum HabitDisplaySortType implements EnumWithDBCode {
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

enum HabitDisplaySortDirection implements EnumWithDBCode {
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
    return "HabitEditParams($uuid,$createT,$modifyT)";
  }
}

@CopyWith()
@JsonSerializable()
class HabitsDisplayFilter {
  static const _defaultAllowInProgressHabits = true;
  static const _defualtAllowArchivedHabits = false;
  static const _defaultAllowCompleteHabits = true;

  @JsonKey(name: "allowActivedHabits")
  final bool allowInProgressHabits;
  final bool allowArchivedHabits;
  final bool allowCompleteHabits;

  static const allFalse = HabitsDisplayFilter(
    allowInProgressHabits: false,
    allowArchivedHabits: false,
    allowCompleteHabits: false,
  );

  static const allTrue = HabitsDisplayFilter(
    allowInProgressHabits: true,
    allowArchivedHabits: true,
    allowCompleteHabits: true,
  );

  const HabitsDisplayFilter({
    required this.allowInProgressHabits,
    required this.allowArchivedHabits,
    required this.allowCompleteHabits,
  });

  const HabitsDisplayFilter.withDefault()
      : allowInProgressHabits = _defaultAllowInProgressHabits,
        allowArchivedHabits = _defualtAllowArchivedHabits,
        allowCompleteHabits = _defaultAllowCompleteHabits;

  factory HabitsDisplayFilter.fromJson(JsonMap data) =>
      _$HabitsDisplayFilterFromJson(data);

  JsonMap toJson() => _$HabitsDisplayFilterToJson(this);

  bool Function(HabitSummaryData) getDisplayFilterFunction() {
    bool func(HabitSummaryData data) {
      if (data.isArchived) {
        return allowArchivedHabits;
      }
      if (data.isComplated) {
        return allowCompleteHabits;
      }
      if (data.isInProgress) {
        return allowInProgressHabits;
      }
      return true;
    }

    return func;
  }

  @override
  bool operator ==(Object other) {
    if (other is! HabitsDisplayFilter) return false;
    return allowInProgressHabits == other.allowInProgressHabits &&
        allowArchivedHabits == other.allowArchivedHabits &&
        allowCompleteHabits == other.allowCompleteHabits;
  }

  @override
  int get hashCode =>
      hash3(allowInProgressHabits, allowArchivedHabits, allowCompleteHabits);

  @override
  String toString() => "$runtimeType(${toJson()})";
}

@JsonSerializable(
  fieldRename: FieldRename.snake,
  includeIfNull: false,
  converters: [HabitDisplayOpConfigConverter()],
)
@CopyWith(skipFields: true)
class HabitDisplayOpConfig implements JsonAdaptor {
  final UserAction changeRecordStatus;
  final UserAction openRecordStatusDialog;

  const HabitDisplayOpConfig({
    required this.changeRecordStatus,
    required this.openRecordStatusDialog,
  });

  const HabitDisplayOpConfig.withDefault()
      : changeRecordStatus = UserAction.tap,
        openRecordStatusDialog = UserAction.longTap;

  factory HabitDisplayOpConfig.fromJson(Map<String, dynamic> json) =>
      _$HabitDisplayOpConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HabitDisplayOpConfigToJson(this);

  @override
  String toString() => "$runtimeType(${toJson()})";
}

@CopyWith(skipFields: true)
class HabitDisplaySearchOptions {
  final String keyword;
  final bool activated;
  final bool completed;
  final Set<HabitType> _types;

  Set<HabitType> get types => UnmodifiableSetView(_types);

  const HabitDisplaySearchOptions({
    this.keyword = "",
    this.activated = false,
    this.completed = false,
    Set<HabitType> types = const {},
  }) : _types = types;

  const HabitDisplaySearchOptions.empty() : this();

  bool get isEmpty => keyword.isEmpty && isFilterEmpty;

  bool get isFilterEmpty => !activated && !completed && types.isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool filter(HabitSummaryData data,
      {Iterable<String>? keywords, bool caps = false}) {
    final kws = keywords ?? [keyword];
    final name = caps ? data.name.toUpperCase() : data.name;
    if (kws.isNotEmpty && kws.any((kw) => !name.contains(kw))) return false;
    if (activated && !data.isActived) return false;
    if (completed && !data.isComplated) return false;
    if (types.isNotEmpty && !types.contains(data.type)) return false;
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HabitDisplaySearchOptions) return false;
    return keyword == other.keyword &&
        activated == other.activated &&
        completed == other.completed &&
        setEquals(types, other.types);
  }

  @override
  int get hashCode => hashObjects([keyword, activated, completed, ...types]);

  @override
  String toString() {
    return 'HabitDisplaySearchOptions(keyword=$keyword,activated=$activated, '
        'completed=$completed,types=$types)';
  }
}

// Copyright 2026 Fries_I23
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

import 'package:mhabit/common/types.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_detail.dart';
import 'package:mhabit/models/habit_repo_actions.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';

/// Base stub for [HabitsDisplayAccess] with all methods defaulting to
/// `throw UnimplementedError()`.  Concrete test fakes extend this and
/// override only the methods their scenario exercises.
abstract class StubHabitsDisplayAccess implements HabitsDisplayAccess {
  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) => throw UnimplementedError();

  @override
  Future<String?> loadHabitRecordReason(
    HabitSummaryData data,
    HabitRecordDate date,
  ) => throw UnimplementedError();

  @override
  Future<HabitDBCell?> loadHabitDetail(HabitUUID uuid) =>
      throw UnimplementedError();

  @override
  Future<Iterable<ChangeHabitStatusResult>> changeHabitStatus({
    required ChangeHabitStatusAction action,
    FutureOr Function(ChangeHabitStatusResult result)? extraResolver,
  }) => throw UnimplementedError();

  @override
  Future<Iterable<ChangeRecordStatusResult>> changeHabitRecordStatus({
    required ChangeRecordStatusAction<HabitDate> preAction,
    ChangeRecordStatusAction<ChangeRecordStatusResult> Function(
      List<ChangeRecordStatusResult> results,
    )?
    postActionBuilder,
    BeforeHabitRecordReminderUpdateCb? beforeReminderUpdate,
    FutureOr<void> Function(ChangeRecordStatusResult result)? extraResolver,
  }) => throw UnimplementedError();

  @override
  Future<List<HabitUUID>> fixAndSaveSortPositions(
    List<HabitSummaryData> habits, {
    required num increaseStep,
    required int decimalPlaces,
  }) => throw UnimplementedError();

  @override
  Future<void> updateHabitGroupIds(
    List<HabitUUID> uuids,
    List<String?> groupIds,
  ) async {}

  @override
  Future<void> repairHabitReminders({
    required HabitReminderRepairParams params,
  }) => Future.value();

  @override
  Future<void> refreshHabitReminders({
    required HabitReminderRefreshParams params,
  }) => Future.value();
}

/// Base stub for [HabitDetailAccess] with all inherited methods defaulting to
/// `throw UnimplementedError()`.
abstract class StubHabitDetailAccess extends StubHabitsDisplayAccess
    implements HabitDetailAccess {
  @override
  Future<HabitDetailData?> loadHabitDetailData(HabitUUID uuid) =>
      throw UnimplementedError();
}

/// Base stub for [HabitStatusChangerAccess] with all inherited methods
/// defaulting to `throw UnimplementedError()`.
abstract class StubHabitStatusChangerAccess extends StubHabitsDisplayAccess
    implements HabitStatusChangerAccess {
  @override
  Future<void> saveChangedHabitRecords({
    required Iterable<ChangeRecordStatusResult> records,
    BeforeHabitRecordReminderUpdateCb? beforeReminderUpdate,
  }) => throw UnimplementedError();
}

// Copyright 2025 Fries_I23
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

import 'dart:collection';

import '../habit_form.dart';
import '../habit_repo_actions.dart';
import '../habit_summary.dart';

class ChangeHabitStatusResult {
  final HabitSummaryData data;
  final HabitStatus orgStatus;

  const ChangeHabitStatusResult({required this.data, required this.orgStatus});
}

abstract interface class ChangeHabitStatusAction
    implements HabitRepoAction<List<ChangeHabitStatusResult>> {
  HabitStatus get status;
  UnmodifiableListView<HabitSummaryData> get data;

  ChangeHabitStatusResult resolveSingle(HabitSummaryData data);
}

final class ChangeMultiHabitStatusAction implements ChangeHabitStatusAction {
  @override
  final HabitStatus status;
  final List<HabitSummaryData> _data;

  const ChangeMultiHabitStatusAction(
    List<HabitSummaryData> data, {
    required this.status,
  }) : _data = data;

  @override
  UnmodifiableListView<HabitSummaryData> get data =>
      UnmodifiableListView(_data);

  @override
  List<ChangeHabitStatusResult> resolve() => _data.map(resolveSingle).toList();

  @override
  ChangeHabitStatusResult resolveSingle(HabitSummaryData data) {
    final orgStatus = data.status;
    data.status = status;
    data.bumpVersion();
    return ChangeHabitStatusResult(data: data, orgStatus: orgStatus);
  }
}

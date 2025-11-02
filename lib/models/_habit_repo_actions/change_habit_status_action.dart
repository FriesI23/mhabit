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

import 'dart:async';
import 'dart:collection';

import '../../common/consts.dart';
import '../habit_form.dart';
import '../habit_repo_actions.dart';
import '../habit_summary.dart';

class ChangeHabitStatusResult {
  final HabitSummaryData data;
  final HabitStatus orgStatus;

  const ChangeHabitStatusResult({
    required this.data,
    required this.orgStatus,
  });
}

abstract interface class ChangeHabitsStatusAction
    implements HabitRepoAction<FutureOr<List<ChangeHabitStatusResult>>> {
  HabitStatus get status;
  UnmodifiableListView<HabitSummaryData> get data;

  FutureOr<ChangeHabitStatusResult> resolveSingle(HabitSummaryData data);
}

final class BasicChangeHabitsStatusAction implements ChangeHabitsStatusAction {
  final HabitStatus status;
  final int firstDay;
  final List<HabitSummaryData> _data;
  final FutureOr<void> Function(HabitSummaryData data)? extraResolver;

  const BasicChangeHabitsStatusAction(
    List<HabitSummaryData> data, {
    required this.status,
    this.firstDay = defaultFirstDay,
    this.extraResolver,
  }) : _data = data;

  @override
  UnmodifiableListView<HabitSummaryData> get data =>
      UnmodifiableListView(_data);

  @override
  FutureOr<List<ChangeHabitStatusResult>> resolve() {
    bool hasFuture = false;
    final results = <FutureOr<ChangeHabitStatusResult>>[];
    for (final d in _data) {
      final r = resolveSingle(d);
      results.add(r);
      if (r is Future<ChangeHabitStatusResult>) {
        hasFuture = true;
      }
    }
    if (!hasFuture) {
      return results.cast<ChangeHabitStatusResult>();
    }
    return Future.wait(results.map(Future.value));
  }

  @override
  FutureOr<ChangeHabitStatusResult> resolveSingle(HabitSummaryData data) {
    final orgStatus = data.status;
    data.status = status;
    data.bumpVersion();
    final result = ChangeHabitStatusResult(data: data, orgStatus: orgStatus);
    final extraResolver = this.extraResolver;
    if (extraResolver != null) {
      final maybeFuture = extraResolver(data);
      if (maybeFuture is Future<void>) {
        return maybeFuture.then((_) => result);
      }
    }
    return result;
  }
}

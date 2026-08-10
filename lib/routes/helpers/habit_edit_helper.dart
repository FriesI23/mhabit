// Copyright 2026 Fries_I23
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/types.dart';
import '../../models/habit_form.dart';
import '../../storage/db/handlers/habit.dart';
import '../app_router.dart';

const _kRouteQueryHabitId = 'habitId';

/// Strongly-typed container for [AppRoute.habitEdit] extra data.
///
/// Wraps the underlying go_router record with an [extension type] so the
/// extra payload carries a nominal (non-structural) type.  Callers construct
/// via [HabitEditExtra.new] and consumers unwrap via the [habitId]/[initForm]
/// accessors — the raw record is never exposed.
///
/// Both [habitId] and [initForm] are required. The [habitId] is also carried
/// as a query parameter in the URL for observability and future deep-link
/// support.
extension type const HabitEditExtra._(
  ({HabitUUID habitId, HabitForm initForm}) _value
) {
  const HabitEditExtra({
    required HabitUUID habitId,
    required HabitForm initForm,
  }) : this._((habitId: habitId, initForm: initForm));

  HabitUUID get habitId => _value.habitId;
  HabitForm get initForm => _value.initForm;
}

/// Unpacked parameters for the habit edit route builder.
typedef HabitEditParams = ({HabitUUID habitId, HabitForm initForm});

/// Unpacks [GoRouterState] into [HabitEditParams] for the
/// [AppRoute.habitEdit] route builder.
///
/// Asserts that the query parameter [habitId] matches the [extra.habitId]
/// for bidirectional integrity.
extension HabitEditRoute on GoRouterState {
  HabitEditParams unpackHabitEdit() {
    final extra = this.extra! as HabitEditExtra;
    assert(
      uri.queryParameters[_kRouteQueryHabitId] == extra.habitId,
      'Query habitId (${uri.queryParameters[_kRouteQueryHabitId]}) '
      '!= extra habitId (${extra.habitId})',
    );
    return (habitId: extra.habitId, initForm: extra.initForm);
  }
}

/// Pushes the [AppRoute.habitEdit] route onto the navigator.
///
/// Asserts that [initForm.editParams.uuid] matches [habitId] for
/// caller-side integrity.
extension HabitEditPush on BuildContext {
  Future<HabitDBCell?> pushHabitEdit({
    required HabitUUID habitId,
    required HabitForm initForm,
  }) {
    assert(
      initForm.editParams?.uuid == habitId,
      'initForm.editParams.uuid (${initForm.editParams?.uuid}) '
      '!= habitId ($habitId)',
    );
    return pushNamed<HabitDBCell>(
      AppRoute.habitEdit.name,
      queryParameters: {_kRouteQueryHabitId: habitId},
      extra: HabitEditExtra(habitId: habitId, initForm: initForm),
    );
  }
}

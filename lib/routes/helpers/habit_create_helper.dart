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

import '../../models/habit_form.dart';
import '../../storage/db/handlers/habit.dart';
import '../app_router.dart';

/// Strongly-typed container for [AppRoute.habitCreate] extra data.
///
/// Wraps the underlying go_router record with an [extension type] so the
/// extra payload carries a nominal (non-structural) type.  Callers construct
/// via [HabitCreateExtra.new] and consumers unwrap via the [initForm]
/// accessor — the raw record is never exposed.
///
/// [initForm] is optional: when provided it acts as a template
/// (e.g. pre-filling fields from a selected habit).
extension type const HabitCreateExtra._(({HabitForm? initForm}) _value) {
  const HabitCreateExtra({HabitForm? initForm}) : this._((initForm: initForm));

  HabitForm? get initForm => _value.initForm;
}

/// Unpacked parameters for the habit create route builder.
typedef HabitCreateParams = ({HabitForm? initForm});

/// Unpacks [GoRouterState] into [HabitCreateParams] for the
/// [AppRoute.habitCreate] route builder.
extension HabitCreateRoute on GoRouterState {
  HabitCreateParams unpackHabitCreate() {
    final extra = this.extra! as HabitCreateExtra;
    return (initForm: extra.initForm);
  }
}

/// Pushes the [AppRoute.habitCreate] route onto the navigator.
extension HabitCreatePush on BuildContext {
  Future<HabitDBCell?> pushHabitCreate({HabitForm? initForm}) =>
      pushNamed<HabitDBCell>(
        AppRoute.habitCreate.name,
        extra: HabitCreateExtra(initForm: initForm),
      );
}

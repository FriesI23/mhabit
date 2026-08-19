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
import '../app_router.dart';

const _kRouteQueryHabitId = 'habitId';

/// Strongly-typed container for [AppRoute.habitsStatus] extra data.
///
/// Wraps the [uuidList] with an [extension type] so the extra payload
/// carries a nominal (non-structural) type.
///
/// [uuidList] is nullable: when set, it is the primary source of habit
/// IDs (programmatic navigation). When null, the unpacker falls back to
/// the [_kRouteQueryHabitId] query parameters (deeplink navigation).
extension type const HabitsStatusChangerExtra._(
  ({List<HabitUUID>? uuidList}) _value
) {
  const HabitsStatusChangerExtra({List<HabitUUID>? uuidList})
    : this._((uuidList: uuidList));

  List<HabitUUID>? get uuidList => _value.uuidList;
}

/// Unpacked parameters for the habits status changer route builder.
typedef HabitsStatusChangerParams = ({List<HabitUUID> uuidList});

/// Unpacks [GoRouterState] into [HabitsStatusChangerParams] for the
/// [AppRoute.habitsStatus] route builder.
///
/// Priority: [HabitsStatusChangerExtra.uuidList] (programmatic) →
/// [_kRouteQueryHabitId] query parameters (deeplink).
extension HabitsStatusChangerRoute on GoRouterState {
  HabitsStatusChangerParams unpackHabitsStatusChanger() {
    final extra = this.extra as HabitsStatusChangerExtra?;
    final uuidList =
        extra?.uuidList ??
        uri.queryParametersAll[_kRouteQueryHabitId] ??
        const <String>[];
    return (uuidList: uuidList);
  }
}

/// Pushes the [AppRoute.habitsStatus] route onto the navigator.
///
/// Passes [uuidList] via [extra] (in-memory, primary source).
/// The unpacker also supports deeplink via [_kRouteQueryHabitId] query
/// parameters as a future extension.
extension HabitsStatusChangerPush on BuildContext {
  Future<void> pushHabitsStatusChanger({required List<HabitUUID> uuidList}) =>
      pushNamed(
        AppRoute.habitsStatus.name,
        extra: HabitsStatusChangerExtra(uuidList: uuidList),
      );
}

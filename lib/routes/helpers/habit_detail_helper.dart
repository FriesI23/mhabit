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
import '../../models/habit_color.dart';
import '../../pages/habit_detail/page.dart' as habit_detail;
import '../../pages/habits_display/providers.dart' show HabitDetailAdapter;
import '../app_router.dart';

/// Strongly-typed container for [AppRoute.habitDetail] extra data.
///
/// Wraps the underlying go_router record with an [extension type] so the
/// extra payload carries a nominal (non-structural) type.  Callers construct
/// via [HabitDetailExtra.new] and consumers unwrap via the [color]/[adapter]
/// accessors — the raw record is never exposed.
extension type const HabitDetailExtra._(
  ({HabitColor? color, HabitDetailAdapter? adapter}) _value
) {
  const HabitDetailExtra({HabitColor? color, HabitDetailAdapter? adapter})
    : this._((color: color, adapter: adapter));

  HabitColor? get color => _value.color;
  HabitDetailAdapter? get adapter => _value.adapter;
}

/// Unpacked parameters for the habit detail route builder.
typedef HabitDetailParams = ({
  HabitUUID habitUUID,
  HabitColor? color,
  HabitDetailAdapter? adapter,
});

/// Unpacks [GoRouterState] into [HabitDetailParams] for the
/// [AppRoute.habitDetail] route builder.
///
/// When [extra] is null or not a [HabitDetailExtra] (e.g. deep-link
/// navigation where [HabitDetailAdapter] cannot be passed via extra),
/// [color] and [adapter] default to null.
extension HabitDetailRoute on GoRouterState {
  HabitDetailParams unpackHabitDetail() {
    final extra = this.extra;
    final detailExtra = extra is HabitDetailExtra ? extra : null;
    return (
      habitUUID: pathParameters['habitId']!,
      color: detailExtra?.color,
      adapter: detailExtra?.adapter,
    );
  }
}

/// Pushes the [AppRoute.habitDetail] route onto the navigator.
extension HabitDetailPush on BuildContext {
  Future<habit_detail.DetailPageReturn?> pushHabitDetail({
    required HabitUUID habitUUID,
    HabitColor? color,
    HabitDetailAdapter? adapter,
  }) => pushNamed<habit_detail.DetailPageReturn>(
    AppRoute.habitDetail.name,
    pathParameters: {'habitId': habitUUID},
    extra: HabitDetailExtra(color: color, adapter: adapter),
  );
}

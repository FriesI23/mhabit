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

import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart' show IconData;

import '../models/habit_group.dart';

/// Resolves a raw DB icon code point to a [GroupIcon].
///
/// Maps [IconData.codePoint] values back to their corresponding
/// [GroupIcon] using the structural [Icons] constants so the mapping
/// remains readable and the domain model never references raw hex.
extension GroupIconCodePoint on int {
  static final _toGroupIcon = <int, GroupIcon>{
    Icons.folder_outlined.codePoint: GroupIcon.folder,
    Icons.work_outline.codePoint: GroupIcon.work,
    Icons.fitness_center.codePoint: GroupIcon.fitness,
    Icons.school.codePoint: GroupIcon.study,
    Icons.home.codePoint: GroupIcon.home,
    Icons.star_outline.codePoint: GroupIcon.star,
    Icons.music_note.codePoint: GroupIcon.music,
    Icons.account_balance_wallet.codePoint: GroupIcon.finance,
    Icons.self_improvement.codePoint: GroupIcon.meditation,
    Icons.volunteer_activism.codePoint: GroupIcon.health,
  };

  GroupIcon? get toGroupIcon => _toGroupIcon[this];
}

/// UI-side helper to convert a [GroupIcon] to an [IconData].
extension GroupIconUI on GroupIcon {
  IconData get iconData => switch (this) {
    GroupIcon.folder => Icons.folder_outlined,
    GroupIcon.work => Icons.work_outline,
    GroupIcon.fitness => Icons.fitness_center,
    GroupIcon.study => Icons.school,
    GroupIcon.home => Icons.home,
    GroupIcon.star => Icons.star_outline,
    GroupIcon.music => Icons.music_note,
    GroupIcon.finance => Icons.account_balance_wallet,
    GroupIcon.meditation => Icons.self_improvement,
    GroupIcon.health => Icons.volunteer_activism,
  };
}

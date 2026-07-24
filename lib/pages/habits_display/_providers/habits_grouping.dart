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

import 'package:flutter/foundation.dart';

import '../../../common/consts.dart';
import '../../../logging/helper.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_group_display.dart';
import '../../../providers/support/commons.dart';
import '../../../storage/profile/handlers.dart';
import '../../../storage/profile_provider.dart';

class HabitsGroupingViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin
    implements ProviderMounted {
  DisplayGroupModeProfileHandler? _groupMode;
  bool _experimentalEnabled = true;
  bool _mounted = true;

  HabitsGroupingViewModel();

  @override
  bool get mounted => _mounted;

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    super.dispose();
  }

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _groupMode = newProfile.getHandler<DisplayGroupModeProfileHandler>();
  }

  void updateExperimentalGrouping(bool enabled) =>
      _experimentalEnabled = enabled;

  void requestReload() {
    if (mounted) notifyListeners();
  }

  HabitDisplayGroupType? get groupType =>
      _experimentalEnabled ? _groupMode?.groupType : null;

  HabitDisplaySortDirection get groupDirection =>
      _groupMode?.groupDirection ?? defaultGroupSortDirection;

  bool get isGroupingEnabled => groupType != null;

  Future<void> setGroupMode({
    required HabitDisplayGroupType groupType,
    HabitDisplaySortDirection? groupDirection,
  }) async {
    final resolvedDirection = groupDirection ?? this.groupDirection;
    final newMode = (groupType, resolvedDirection);
    appLog.value.info(
      "$runtimeType.setGroupMode",
      beforeVal: [this.groupType, this.groupDirection],
      afterVal: newMode,
    );
    await _groupMode?.set(newMode);
    notifyListeners();
  }

  Future<void> disableGrouping() async {
    appLog.value.info(
      "$runtimeType.disableGrouping",
      beforeVal: [groupType, groupDirection],
      afterVal: null,
    );
    await _groupMode?.set((null, null));
    notifyListeners();
  }
}

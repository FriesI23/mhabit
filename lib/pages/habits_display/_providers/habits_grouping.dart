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
import 'package:flutter/widgets.dart' show IconData;

import '../../../common/consts.dart';
import '../../../l10n/localizations.dart';
import '../../../logging/helper.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_group_display.dart';
import '../../../providers/support/commons.dart';
import '../../../storage/profile/handlers.dart';
import '../../../storage/profile_provider.dart';
import '../../../theme/icon.dart';

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

  IconData getCurrentIcon() => getIcon(groupType, groupDirection);
  String getCurrentTitle({L10n? l10n}) =>
      getTitle(groupType, groupDirection, l10n: l10n);

  static IconData getIcon(
    HabitDisplayGroupType? groupType,
    HabitDisplaySortDirection direction,
  ) {
    // When grouping is off, return the "hide" icon.
    if (groupType == null) return hideGroupingIcon;

    switch (groupType) {
      case HabitDisplayGroupType.name:
        switch (direction) {
          case HabitDisplaySortDirection.asc:
            return HabitSortIcons.sortalphabeticalascending;
          case HabitDisplaySortDirection.desc:
            return HabitSortIcons.sortalphabeticaldescending;
        }
      case HabitDisplayGroupType.colorType:
        switch (direction) {
          case HabitDisplaySortDirection.asc:
            return HabitSortIcons.sortboolascending;
          case HabitDisplaySortDirection.desc:
            return HabitSortIcons.sortbooldescending;
        }
      case HabitDisplayGroupType.createDate:
        switch (direction) {
          case HabitDisplaySortDirection.asc:
            return HabitSortIcons.sortcalendarascending;
          case HabitDisplaySortDirection.desc:
            return HabitSortIcons.sortcalendardescending;
        }
    }
  }

  static String getTitle(
    HabitDisplayGroupType? groupType,
    HabitDisplaySortDirection? groupDirection, {
    L10n? l10n,
  }) {
    if (groupType == null) {
      return l10n?.habitDisplay_groupTypeDialog_none ?? "Flat";
    }

    final String directionName;
    if (groupDirection == null) {
      directionName = '';
    } else if (groupDirection == HabitDisplaySortDirection.asc) {
      directionName = l10n?.habitDisplay_sortDirection_asc ?? "(Asc)";
    } else {
      directionName = l10n?.habitDisplay_sortDirection_Desc ?? "(Desc)";
    }

    String getAutoGroupTitle(String title) {
      if (directionName.isEmpty) return title;
      return "$title $directionName";
    }

    switch (groupType) {
      case HabitDisplayGroupType.name:
        return getAutoGroupTitle(
          l10n?.habitDisplay_groupType_name ?? "By Name",
        );
      case HabitDisplayGroupType.colorType:
        return getAutoGroupTitle(
          l10n?.habitDisplay_groupType_colorType ?? "By Color",
        );
      case HabitDisplayGroupType.createDate:
        return getAutoGroupTitle(
          l10n?.habitDisplay_groupType_createDate ?? "By Creation Date",
        );
    }
  }
}

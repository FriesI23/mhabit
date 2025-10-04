// Copyright 2023 Fries_I23
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

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../models/habit_display.dart';
import '../storage/profile/handlers.dart';
import '../storage/profile_provider.dart';
import '../theme/icon.dart';

class HabitsSortViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin {
  DisplaySortModeProfileHandler? _sortMode;

  HabitsSortViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _sortMode = newProfile.getHandler<DisplaySortModeProfileHandler>();
  }

  HabitDisplaySortType get sortType =>
      _sortMode?.sortType ?? HabitDisplaySortType.manual;
  HabitDisplaySortDirection get sortDirection =>
      _sortMode?.sortDirection ?? HabitDisplaySortDirection.asc;

  Future<void> setNewSortMode(
      {HabitDisplaySortType? sortType,
      HabitDisplaySortDirection? sortDirection}) async {
    final Tuple2<HabitDisplaySortType, HabitDisplaySortDirection> newSortMode =
        Tuple2((sortType != null) ? sortType : this.sortType,
            (sortDirection != null) ? sortDirection : this.sortDirection);
    appLog.value.info("$runtimeType.setNewSortMode",
        beforeVal: [this.sortType, this.sortDirection], afterVal: newSortMode);
    await _sortMode?.set(newSortMode);
    notifyListeners();
  }

  String getCurrentSortTitle({L10n? l10n}) {
    return getSortTitle(sortType, sortDirection, l10n: l10n);
  }

  static String getSortTitle(
      HabitDisplaySortType sortType, HabitDisplaySortDirection? sortDirection,
      {L10n? l10n}) {
    final String sortTitle, sortDirectionName;
    if (sortDirection == null) {
      sortDirectionName = '';
    } else if (sortDirection == HabitDisplaySortDirection.asc) {
      sortDirectionName = l10n?.habitDisplay_sortDirection_asc ?? "(Asc)";
    } else {
      sortDirectionName = l10n?.habitDisplay_sortDirection_Desc ?? "(Desc)";
    }

    String getAutoSortTitle(String title) {
      if (sortDirectionName.isEmpty) {
        return title;
      } else {
        return "$title $sortDirectionName";
      }
    }

    switch (sortType) {
      case HabitDisplaySortType.manual:
        sortTitle = l10n?.habitDisplay_sortType_manual ?? "My order";
        break;
      case HabitDisplaySortType.name:
        sortTitle = getAutoSortTitle(
          l10n?.habitDisplay_sortType_name ?? "By Name",
        );
        break;
      case HabitDisplaySortType.colorType:
        sortTitle = getAutoSortTitle(
          l10n?.habitDisplay_sortType_colorType ?? "By Color",
        );
        break;
      case HabitDisplaySortType.progress:
        sortTitle = getAutoSortTitle(
          l10n?.habitDisplay_sortType_progress ?? "By Rate",
        );
        break;
      case HabitDisplaySortType.startT:
        sortTitle = getAutoSortTitle(
          l10n?.habitDisplay_sortType_startT ?? "By Start Date",
        );
        break;
      case HabitDisplaySortType.status:
        sortTitle = getAutoSortTitle(
          l10n?.habitDisplay_sortType_status ?? "By Status",
        );
        break;
    }
    return sortTitle;
  }

  IconData getCurrentSortIcon() {
    return getSortIcon(sortType, sortDirection);
  }

  static IconData getSortIcon(
      HabitDisplaySortType sortType, HabitDisplaySortDirection sortDirection) {
    switch (sortType) {
      case HabitDisplaySortType.manual:
        return HabitSortIcons.sort;
      case HabitDisplaySortType.name:
        switch (sortDirection) {
          case HabitDisplaySortDirection.asc:
            return HabitSortIcons.sort_alphabetical_ascending;
          case HabitDisplaySortDirection.desc:
            return HabitSortIcons.sort_alphabetical_descending;
        }
      case HabitDisplaySortType.colorType:
        switch (sortDirection) {
          case HabitDisplaySortDirection.asc:
            return HabitSortIcons.sort_bool_ascending;
          case HabitDisplaySortDirection.desc:
            return HabitSortIcons.sort_bool_descending;
        }
      case HabitDisplaySortType.progress:
        switch (sortDirection) {
          case HabitDisplaySortDirection.asc:
            return HabitSortIcons.sort_ascending;
          case HabitDisplaySortDirection.desc:
            return HabitSortIcons.sort_descending;
        }
      case HabitDisplaySortType.startT:
        switch (sortDirection) {
          case HabitDisplaySortDirection.asc:
            return HabitSortIcons.sort_calendar_ascending;
          case HabitDisplaySortDirection.desc:
            return HabitSortIcons.sort_calendar_descending;
        }
      case HabitDisplaySortType.status:
        switch (sortDirection) {
          case HabitDisplaySortDirection.asc:
            return HabitSortIcons.sort_bool_ascending_variant;
          case HabitDisplaySortDirection.desc:
            return HabitSortIcons.sort_bool_descending_variant;
        }
    }
  }
}

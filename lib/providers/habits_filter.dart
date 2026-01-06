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

import 'package:flutter/foundation.dart';

import '../logging/helper.dart';
import '../models/habit_display.dart';
import '../storage/profile/handlers.dart';
import '../storage/profile_provider.dart';

class HabitsFilterViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin {
  DisplayHabitsFilterProfileHandler? _filter;

  HabitsFilterViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _filter = newProfile.getHandler<DisplayHabitsFilterProfileHandler>();
  }

  HabitsDisplayFilter get habitsDisplayFilter =>
      _filter?.get() ?? const HabitsDisplayFilter.withDefault();

  Future<void> setNewHabitsDisplayFilter(
    HabitsDisplayFilter? newFilter, {
    bool listen = true,
  }) async {
    if (_filter?.get() != newFilter) {
      appLog.value.info(
        "$runtimeType.setNewHabitsDisplayFilter",
        beforeVal: habitsDisplayFilter,
        afterVal: newFilter,
      );
      await _filter?.set(newFilter ?? const HabitsDisplayFilter.withDefault());
      if (listen) notifyListeners();
    }
  }

  int getHabitDisplayFilterAllowedNumber() {
    int result = 0;
    if (habitsDisplayFilter.allowInProgressHabits) result++;
    if (habitsDisplayFilter.allowArchivedHabits) result++;
    if (habitsDisplayFilter.allowCompleteHabits) result++;
    return result;
  }
}

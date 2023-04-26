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

import '../model/global.dart';
import '../model/habit_display.dart';

class HabitsFilterViewModel extends ChangeNotifier
    implements GlobalProxyProviderInterface {
  Global _g;

  HabitsFilterViewModel({required Global global}) : _g = global;

  @override
  Global get g => _g;

  @override
  void updateGlobal(Global newGloal) => _g = newGloal;

  HabitsDisplayFilter get habitsDisplayFilter => _g.habitsDisplayFilter;

  Future<void> setNewHabitsDisplayFilter(HabitsDisplayFilter? newFilter,
      {bool listen = true}) async {
    var filter = newFilter ?? const HabitsDisplayFilter.withDefault();
    await _g.profile.setHabitDisplayFilter(filter.toMap());
    if (listen) notifyListeners();
  }

  int getHabitDisplayFilterAllowedNumber() {
    int result = 0;
    if (habitsDisplayFilter.allowActivedHabits) result++;
    if (habitsDisplayFilter.allowArchivedHabits) result++;
    if (habitsDisplayFilter.allowCompleteHabits) result++;
    return result;
  }
}

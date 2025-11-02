// Copyright 2025 Fries_I23
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

import '../logging/helper.dart';
import '../models/habit_form.dart';
import '../models/habit_repo_actions.dart';
import '../models/habit_summary.dart';
import '../reminders/notification_service.dart';
import '../storage/db_helper_provider.dart';
import 'commons.dart';

class HabitsManager with DBHelperLoadedMixin, NotificationChannelDataMixin {
  HabitsManager();

  Future<Iterable<ChangeHabitStatusResult>> changeHabitsStatus(
      {required ChangeHabitsStatusAction action}) {
    return habitDBHelper
        .updateSelectedHabitStatus(
            action.data.map((e) => e.uuid).toList(), action.status)
        .then((_) => action.resolve());
  }

  Future<void> updateHabitReminder(HabitSummaryData data) async {
    try {
      switch (data.status) {
        case HabitStatus.activated:
          if (data.reminder != null) {
            await NotificationService().regrHabitReminder(
              id: data.id,
              uuid: data.uuid,
              name: data.name,
              quest: data.reminderQuest,
              reminder: data.reminder!,
              lastUntrackDate: data.getFirstUnTrackedDate(),
              details: channelData.habitReminder,
            );
          }
          break;
        case HabitStatus.unknown:
        case HabitStatus.deleted:
        case HabitStatus.archived:
          await NotificationService().cancelHabitReminder(id: data.id);
          break;
      }
    } on Exception catch (e) {
      appLog.notify.error("HabitsManager._regrHabitReminder",
          ex: ["catch err when try regr reminder"], error: e);
    }
  }
}

mixin HabitsManagerLoadedMixin {
  bool _loaded = false;
  late HabitsManager _habitsManager;

  HabitsManager get habitsManager => _habitsManager;

  void updateHabitManager(HabitsManager newManager) {
    if (!_loaded || _habitsManager != newManager) {
      _habitsManager = newManager;
      _loaded = true;
    }
  }
}

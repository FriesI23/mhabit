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

import 'localizations.dart';

export 'localizations.g.dart' show L10n, lookupL10n;

extension L10nExtra on L10n {
  String getHabitEditReminderWeekDayText(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return habitEdit_reminder_weekdayText_monday;
      case 2:
        return habitEdit_reminder_weekdayText_tuesday;
      case 3:
        return habitEdit_reminder_weekdayText_wednesday;
      case 4:
        return habitEdit_reminder_weekdayText_thursday;
      case 5:
        return habitEdit_reminder_weekdayText_friday;
      case 6:
        return habitEdit_reminder_weekdayText_saturday;
      case 7:
        return habitEdit_reminder_weekdayText_sunday;
      default:
        return '';
    }
  }
}

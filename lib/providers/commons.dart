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

import '../models/habit_summary.dart';
import '../reminders/notification_channel.dart';

abstract interface class ProviderMounted {
  bool get mounted;
}

abstract interface class HabitSummaryDirtyMarker {
  void bumpHatbitVersion(HabitSummaryData data);
}

mixin NotificationChannelDataMixin {
  late NotificationChannelData channelData;

  void setNotificationChannelData(NotificationChannelData newData) {
    channelData = newData;
  }
}

mixin PinnedAppbarMixin on ChangeNotifier {
  bool _isAppbarPinned = false;

  bool get isAppbarPinned => _isAppbarPinned;

  void pinAppbar() {
    if (isAppbarPinned) return;
    _isAppbarPinned = true;
    notifyListeners();
  }

  void unpinAppbar() {
    if (!isAppbarPinned) return;
    _isAppbarPinned = false;
    notifyListeners();
  }
}

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

import '../model/habit_summary.dart';
import '../reminders/notification_channel.dart';

mixin ScrollControllerChangeNotifierMixin {
  late final ScrollController _verticalScrollController;
  bool _isAppbarPinned = false;

  void initVerticalScrollController(
      Function notifyListeners, ScrollController scrollController) {
    _verticalScrollController = scrollController;
    _verticalScrollController.addListener(() {
      if (!_isAppbarPinned &&
          _verticalScrollController.hasClients &&
          _verticalScrollController.offset > kToolbarHeight) {
        _isAppbarPinned = true;
        notifyListeners();
      } else if (_isAppbarPinned &&
          _verticalScrollController.hasClients &&
          _verticalScrollController.offset < kToolbarHeight) {
        _isAppbarPinned = false;
        notifyListeners();
      }
    });
  }

  void disposeVerticalScrollController() {
    _verticalScrollController.dispose();
  }

  ScrollController get verticalScrollController => _verticalScrollController;

  bool get isAppbarPinned => _isAppbarPinned;
}

abstract mixin class ProviderMounted {
  bool get mounted;
}

abstract class HabitSummaryDirtyMarkABC {
  void bumpHatbitVersion(HabitSummaryData data);
}

mixin NotificationChannelDataMixin {
  late NotificationChannelData channelData;

  void setNotificationChannelData(NotificationChannelData newData) {
    channelData = newData;
  }
}

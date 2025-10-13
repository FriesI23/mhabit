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
import 'package:flutter/widgets.dart'
    show PageScrollPhysics, ScrollMetrics, ScrollPhysics;

import '../common/consts.dart';
import '../common/enums.dart';
import '../logging/helper.dart';
import '../storage/profile/handlers.dart';
import '../storage/profile_provider.dart';
import '../widgets/widgets.dart';

class HabitsRecordScrollBehaviorViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin {
  DisplayCalendarScrollModeProfileHandler? _scroll;

  HabitsRecordScrollBehaviorViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _scroll = newProfile.getHandler<DisplayCalendarScrollModeProfileHandler>();
  }

  HabitsRecordScrollBehavior get scrollBehavior =>
      _scroll?.get() ?? defaultHabitsRecordScrollBehavior;

  Future<void> setScrollBehavior(HabitsRecordScrollBehavior newBehavior) async {
    if (_scroll?.get() != newBehavior) {
      appLog.value.info("$runtimeType.setScrollBehavior",
          beforeVal: scrollBehavior, afterVal: newBehavior);
      await _scroll?.set(newBehavior);
      notifyListeners();
    }
  }

  ScrollPhysics? getPhysics(double itemSize, ScrollMetrics metrics) {
    switch (scrollBehavior) {
      case HabitsRecordScrollBehavior.page:
        return const PageScrollPhysics();
      case HabitsRecordScrollBehavior.scrollable:
        return MagnetScrollPhysics(itemSize: itemSize, metrics: metrics);
      default:
        return null;
    }
  }
}

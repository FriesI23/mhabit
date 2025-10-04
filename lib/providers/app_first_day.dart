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

import '../common/consts.dart';
import '../common/utils.dart';
import '../logging/helper.dart';
import '../storage/profile/handlers.dart';
import '../storage/profile_provider.dart';

class AppFirstDayViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin {
  FirstDayProfileHandler? _firstDay;

  AppFirstDayViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _firstDay = newProfile.getHandler<FirstDayProfileHandler>();
  }

  int get firstDay => _firstDay?.get() ?? defaultFirstDay;

  Future<void> setNewFirstDay(int newFirstDay) async {
    if (_firstDay?.get() != newFirstDay) {
      final stdNewFirstDay = standardizeFirstDay(newFirstDay);
      appLog.value.info("$runtimeType.setNewFirstDay",
          beforeVal: firstDay, afterVal: newFirstDay, ex: [stdNewFirstDay]);
      await _firstDay?.set(stdNewFirstDay);
      notifyListeners();
    }
  }
}

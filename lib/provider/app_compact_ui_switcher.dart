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

import '../logging/helper.dart';
import '../persistent/profile/handlers.dart';
import '../persistent/profile_provider.dart';

class AppCompactUISwitcherViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin {
  CompactUISwitcherProfileHandler? _compactUI;

  AppCompactUISwitcherViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _compactUI = newProfile.getHandler<CompactUISwitcherProfileHandler>();
  }

  bool get flag => _compactUI?.get() ?? false;

  Future<void> setFlag(bool newFlag) async {
    if (_compactUI?.get() != newFlag) {
      appLog.value
          .info("$runtimeType.flag", beforeVal: flag, afterVal: newFlag);
      await _compactUI?.set(newFlag);
      notifyListeners();
    }
  }

  double get appCalendarBarHeight => flag ? 48.0 : 64.0;
  EdgeInsets get appCalendarBarItemPadding => flag
      ? const EdgeInsets.symmetric(horizontal: 4.0)
      : const EdgeInsets.all(8.0);
  double get appHabitDisplayListTileHeight => flag ? 48.0 : 64.0;
}

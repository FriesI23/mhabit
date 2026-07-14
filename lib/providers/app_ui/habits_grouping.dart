// Copyright 2026 Fries_I23
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

import 'package:flutter/foundation.dart';

import '../../logging/helper.dart';
import '../../storage/profile/handlers.dart';
import '../../storage/profile_provider.dart';

class HabitsGroupingViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin {
  DisplayGroupingProfileHandler? _handler;

  HabitsGroupingViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _handler = newProfile.getHandler<DisplayGroupingProfileHandler>();
  }

  bool get isGroupingEnabled => _handler?.get() ?? false;

  Future<void> setGroupingEnabled(bool value) async {
    appLog.value.info(
      "$runtimeType.setGroupingEnabled",
      beforeVal: isGroupingEnabled,
      afterVal: value,
    );
    await _handler?.set(value);
    notifyListeners();
  }
}

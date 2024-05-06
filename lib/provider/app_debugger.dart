// Copyright 2024 Fries_I23
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

import 'package:flutter/material.dart';

import '../persistent/profile/handlers.dart';
import '../persistent/profile_provider.dart';

class AppDebuggerViewModel with ChangeNotifier, ProfileHandlerLoadedMixin {
  CollectLogswitcherProfileHandler? _collectLogsSwitcher;

  AppDebuggerViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _collectLogsSwitcher =
        newProfile.getHandler<CollectLogswitcherProfileHandler>();
  }

  bool get isCollectLogs => _collectLogsSwitcher?.get() ?? false;

  Future<void> setCollectLogsSatus(bool newStatus) async {
    if (newStatus != isCollectLogs) {
      await _collectLogsSwitcher?.set(newStatus);
      notifyListeners();
    }
  }
}

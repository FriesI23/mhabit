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

import 'package:flutter/material.dart';

import '../model/app_sync_server.dart';
import '../persistent/profile/handler/app_sync.dart';
import '../persistent/profile_provider.dart';

class AppSyncViewModel with ChangeNotifier, ProfileHandlerLoadedMixin {
  AppSyncSwitchHandler? _switch;
  AppSyncServerConfigHandler? _serverConfig;

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _switch = newProfile.getHandler<AppSyncSwitchHandler>();
    _serverConfig = newProfile.getHandler<AppSyncServerConfigHandler>();
  }

  bool get enabled => _switch?.get() ?? false;

  Future<void> setSyncSwitch(bool value, {bool listen = true}) async {
    if (_switch?.get() != value) {
      await _switch?.set(value);
      notifyListeners();
    }
  }

  AppSyncServer? get serverConfig => _serverConfig?.get();
}

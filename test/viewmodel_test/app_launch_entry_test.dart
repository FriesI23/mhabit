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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/app_entry.dart';
import 'package:mhabit/providers/app_launch_entry.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProfileViewModel> _loadProfile() async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel([AppLaunchEntryProfileHandler.new]);
  await profile.init();
  return profile;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLaunchEntryViewModel', () {
    test('reads default launch entry from profile', () async {
      final profile = await _loadProfile();
      final viewModel = AppLaunchEntryViewModel()..updateProfile(profile);

      expect(viewModel.launchEntry, AppEntrys.undefined);

      viewModel.dispose();
      profile.dispose();
    });

    test('persists launch entry updates through profile handler', () async {
      final profile = await _loadProfile();
      final viewModel = AppLaunchEntryViewModel()..updateProfile(profile);

      await viewModel.setNewLaunchEntry(AppEntrys.habitToday);

      expect(viewModel.launchEntry, AppEntrys.habitToday);
      expect(
        profile.getHandler<AppLaunchEntryProfileHandler>()?.get(),
        AppEntrys.habitToday,
      );

      viewModel.dispose();
      profile.dispose();
    });
  });
}

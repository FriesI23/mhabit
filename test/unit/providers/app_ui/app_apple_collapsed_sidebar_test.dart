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
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/providers/app_ui/app_apple_collapsed_sidebar.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProfileViewModel> _loadProfile({
  Map<String, Object> values = const {},
  bool resetValues = true,
}) async {
  if (resetValues) SharedPreferences.setMockInitialValues(values);
  final profile = ProfileViewModel([AppleCollapsedSidebarProfileHandler.new]);
  await profile.init();
  return profile;
}

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  for (final testCase in <({TargetPlatform platform, bool enabled})>[
    (platform: TargetPlatform.android, enabled: true),
    (platform: TargetPlatform.iOS, enabled: true),
    (platform: TargetPlatform.linux, enabled: false),
    (platform: TargetPlatform.macOS, enabled: false),
    (platform: TargetPlatform.windows, enabled: false),
  ]) {
    test('missing value uses the ${testCase.platform.name} default', () async {
      debugDefaultTargetPlatformOverride = testCase.platform;
      final profile = await _loadProfile();
      final viewModel = AppAppleCollapsedSidebarViewModel()
        ..updateProfile(profile);

      expect(viewModel.enabled, testCase.enabled);

      viewModel.dispose();
      profile.dispose();
    });
  }

  test('persists an explicit value across profile rebuilds', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final firstProfile = await _loadProfile();
    final firstViewModel = AppAppleCollapsedSidebarViewModel()
      ..updateProfile(firstProfile);
    final preferences = await SharedPreferences.getInstance();

    expect(firstViewModel.enabled, isFalse);
    await firstViewModel.setEnabled(true);
    expect(firstViewModel.enabled, isTrue);
    expect(preferences.getBool('appleCollapsedSidebarEnabled'), isTrue);
    firstViewModel.dispose();
    firstProfile.dispose();

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final secondProfile = await _loadProfile(resetValues: false);
    final secondViewModel = AppAppleCollapsedSidebarViewModel()
      ..updateProfile(secondProfile);

    expect(secondViewModel.enabled, isTrue);

    secondViewModel.dispose();
    secondProfile.dispose();
  });

  test('profile reset restores the current platform default', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final profile = await _loadProfile();
    final viewModel = AppAppleCollapsedSidebarViewModel()
      ..updateProfile(profile);

    await viewModel.setEnabled(false);
    expect(viewModel.enabled, isFalse);

    await profile.clear();
    await profile.reload();
    viewModel.updateProfile(profile);

    expect(viewModel.enabled, isTrue);

    viewModel.dispose();
    profile.dispose();
  });
}

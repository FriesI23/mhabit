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
import 'package:mhabit/models/app_adaptive_style_mode.dart';
import 'package:mhabit/models/app_apple_sidebar_style_mode.dart';
import 'package:mhabit/providers/app_ui/app_theme.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProfileViewModel> _loadProfile({
  Map<String, Object> values = const {},
  bool resetValues = true,
}) async {
  if (resetValues) SharedPreferences.setMockInitialValues(values);
  final profile = ProfileViewModel([
    AdaptiveStyleOverrideProfileHandler.new,
    AppleSidebarStyleModeProfileHandler.new,
  ]);
  await profile.init();
  return profile;
}

void main() {
  test('Apple Sidebar modes resolve automatic and forced generations', () {
    expect(
      AppAppleSidebarStyleMode.automatic.resolve(const AppleSystemVersion(26)),
      AppleSidebarStyle.inset,
    );
    expect(
      AppAppleSidebarStyleMode.automatic.resolve(const AppleSystemVersion(27)),
      AppleSidebarStyle.edge,
    );
    expect(
      AppAppleSidebarStyleMode.os26.resolve(const AppleSystemVersion(99)),
      AppleSidebarStyle.inset,
    );
    expect(AppAppleSidebarStyleMode.os27.resolve(null), AppleSidebarStyle.edge);
  });

  group('AppThemeViewModel adaptive style', () {
    test('defaults missing and unknown values to automatic', () async {
      for (final values in [
        <String, Object>{},
        <String, Object>{
          'adaptiveStyleOverride': -1,
          'appleSidebarStyleMode': -1,
        },
        <String, Object>{
          'adaptiveStyleOverride': 99,
          'appleSidebarStyleMode': 99,
        },
      ]) {
        final profile = await _loadProfile(values: values);
        final viewModel = (AppThemeViewModel()..updateProfile(profile));

        expect(viewModel.adaptiveStyleMode, AppAdaptiveStyleMode.automatic);
        expect(viewModel.adaptiveStyleOverride, isNull);
        expect(
          viewModel.appleSidebarStyleMode,
          AppAppleSidebarStyleMode.automatic,
        );

        viewModel.dispose();
        profile.dispose();
      }
    });

    test('persists all modes and maps them to adaptive styles', () async {
      final profile = await _loadProfile();
      final viewModel = (AppThemeViewModel()..updateProfile(profile));
      final preferences = await SharedPreferences.getInstance();

      await viewModel.setAdaptiveStyleMode(AppAdaptiveStyleMode.material);
      expect(viewModel.adaptiveStyleOverride, AdaptiveStyle.material);
      expect(preferences.getInt('adaptiveStyleOverride'), 1);

      await viewModel.setAdaptiveStyleMode(AppAdaptiveStyleMode.apple);
      expect(viewModel.adaptiveStyleOverride, AdaptiveStyle.apple);
      expect(preferences.getInt('adaptiveStyleOverride'), 2);

      await viewModel.setAdaptiveStyleMode(AppAdaptiveStyleMode.automatic);
      expect(viewModel.adaptiveStyleOverride, isNull);
      expect(preferences.getInt('adaptiveStyleOverride'), 0);

      viewModel.dispose();
      profile.dispose();
    });

    test(
      'restores the stored mode after rebuilding profile and view model',
      () async {
        final firstProfile = await _loadProfile();
        final firstViewModel = (AppThemeViewModel()
          ..updateProfile(firstProfile));
        await firstViewModel.setAdaptiveStyleMode(AppAdaptiveStyleMode.apple);
        firstViewModel.dispose();
        firstProfile.dispose();

        final secondProfile = await _loadProfile(resetValues: false);
        final secondViewModel = (AppThemeViewModel()
          ..updateProfile(secondProfile));

        expect(secondViewModel.adaptiveStyleMode, AppAdaptiveStyleMode.apple);
        expect(secondViewModel.adaptiveStyleOverride, AdaptiveStyle.apple);

        secondViewModel.dispose();
        secondProfile.dispose();
      },
    );

    test('profile reset restores automatic', () async {
      final profile = await _loadProfile();
      final viewModel = (AppThemeViewModel()..updateProfile(profile));
      await viewModel.setAdaptiveStyleMode(AppAdaptiveStyleMode.material);

      await profile.clear();
      await profile.reload();
      viewModel.updateProfile(profile);

      expect(viewModel.adaptiveStyleMode, AppAdaptiveStyleMode.automatic);
      expect(viewModel.adaptiveStyleOverride, isNull);

      viewModel.dispose();
      profile.dispose();
    });
  });

  test(
    'Sidebar appearance survives rebuilding and switching UI styles',
    () async {
      final profile = await _loadProfile();
      final first = AppThemeViewModel()..updateProfile(profile);
      await first.setAppleSidebarStyleMode(AppAppleSidebarStyleMode.os27);
      await first.setAdaptiveStyleMode(AppAdaptiveStyleMode.material);
      expect(first.appleSidebarStyleMode, AppAppleSidebarStyleMode.os27);
      first.dispose();
      profile.dispose();

      final restoredProfile = await _loadProfile(resetValues: false);
      final restored = AppThemeViewModel()..updateProfile(restoredProfile);
      addTearDown(restored.dispose);
      addTearDown(restoredProfile.dispose);
      expect(restored.appleSidebarStyleMode, AppAppleSidebarStyleMode.os27);
      expect(restored.adaptiveStyleOverride, AdaptiveStyle.material);
      await restored.setAdaptiveStyleMode(AppAdaptiveStyleMode.apple);
      expect(restored.appleSidebarStyleMode, AppAppleSidebarStyleMode.os27);

      await restoredProfile.clear();
      await restoredProfile.reload();
      restored.updateProfile(restoredProfile);
      expect(restored.adaptiveStyleMode, AppAdaptiveStyleMode.automatic);
      expect(
        restored.appleSidebarStyleMode,
        AppAppleSidebarStyleMode.automatic,
      );
    },
  );

  test('profile replacement publishes the new style preferences', () async {
    final firstProfile = await _loadProfile();
    final viewModel = AppThemeViewModel()..updateProfile(firstProfile);
    final secondProfile = await _loadProfile(
      values: {'adaptiveStyleOverride': 2, 'appleSidebarStyleMode': 2},
    );
    addTearDown(viewModel.dispose);
    addTearDown(firstProfile.dispose);
    addTearDown(secondProfile.dispose);
    var notifications = 0;
    viewModel.addListener(() => notifications++);
    viewModel.updateProfile(secondProfile);
    expect(notifications, 1);
    expect(viewModel.adaptiveStyleOverride, AdaptiveStyle.apple);
    expect(viewModel.appleSidebarStyleMode, AppAppleSidebarStyleMode.os27);
    viewModel.updateProfile(secondProfile);
    expect(notifications, 1);
    await viewModel.setAdaptiveStyleMode(AppAdaptiveStyleMode.apple);
    await viewModel.setAppleSidebarStyleMode(AppAppleSidebarStyleMode.os27);
    expect(notifications, 1);
  });
}

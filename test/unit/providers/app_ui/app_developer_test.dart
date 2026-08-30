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

import 'package:flutter/widgets.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/app_adaptive_style_mode.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProfileViewModel> _loadProfile({
  Map<String, Object> values = const {},
  bool resetValues = true,
}) async {
  if (resetValues) SharedPreferences.setMockInitialValues(values);
  final profile = ProfileViewModel([AdaptiveStyleOverrideProfileHandler.new]);
  await profile.init();
  return profile;
}

void main() {
  group('AppDeveloperViewModel adaptive style', () {
    test('defaults missing and unknown values to automatic', () async {
      for (final values in [
        <String, Object>{},
        <String, Object>{'adaptiveStyleOverride': -1},
        <String, Object>{'adaptiveStyleOverride': 99},
      ]) {
        final profile = await _loadProfile(values: values);
        final viewModel = AppDeveloperViewModel(
          global: Global(),
          profile: profile,
        );

        expect(viewModel.adaptiveStyleMode, AppAdaptiveStyleMode.automatic);
        expect(viewModel.adaptiveStyleOverride, isNull);

        viewModel.dispose();
        profile.dispose();
      }
    });

    test('persists all modes and maps them to adaptive styles', () async {
      final profile = await _loadProfile();
      final viewModel = AppDeveloperViewModel(
        global: Global(),
        profile: profile,
      );
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
        final firstViewModel = AppDeveloperViewModel(
          global: Global(),
          profile: firstProfile,
        );
        await firstViewModel.setAdaptiveStyleMode(AppAdaptiveStyleMode.apple);
        firstViewModel.dispose();
        firstProfile.dispose();

        final secondProfile = await _loadProfile(resetValues: false);
        final secondViewModel = AppDeveloperViewModel(
          global: Global(),
          profile: secondProfile,
        );

        expect(secondViewModel.adaptiveStyleMode, AppAdaptiveStyleMode.apple);
        expect(secondViewModel.adaptiveStyleOverride, AdaptiveStyle.apple);

        secondViewModel.dispose();
        secondProfile.dispose();
      },
    );

    test('profile reset restores automatic', () async {
      final profile = await _loadProfile();
      final viewModel = AppDeveloperViewModel(
        global: Global(),
        profile: profile,
      );
      await viewModel.setAdaptiveStyleMode(AppAdaptiveStyleMode.material);

      await profile.clear();
      await profile.reload();
      viewModel.updateProfile(profile);

      expect(viewModel.adaptiveStyleMode, AppAdaptiveStyleMode.automatic);
      expect(viewModel.adaptiveStyleOverride, isNull);

      viewModel.dispose();
      profile.dispose();
    });

    test(
      'develop mode only controls visibility, not the saved override',
      () async {
        final profile = await _loadProfile();
        final global = Global();
        final viewModel = AppDeveloperViewModel(
          global: global,
          profile: profile,
        );
        await viewModel.setAdaptiveStyleMode(AppAdaptiveStyleMode.apple);

        viewModel.switchDevelopMode(false);

        expect(viewModel.isInDevelopMode, isFalse);
        expect(viewModel.adaptiveStyleOverride, AdaptiveStyle.apple);

        viewModel.dispose();
        profile.dispose();
      },
    );
  });

  test('text direction override is in-memory only', () async {
    final profile = await _loadProfile();
    final firstViewModel = AppDeveloperViewModel(
      global: Global(),
      profile: profile,
    );

    firstViewModel.setTextDirectionOverride(TextDirection.rtl);
    expect(firstViewModel.textDirectionOverride, TextDirection.rtl);
    firstViewModel.dispose();

    final secondViewModel = AppDeveloperViewModel(
      global: Global(),
      profile: profile,
    );
    expect(secondViewModel.textDirectionOverride, isNull);

    secondViewModel.dispose();
    profile.dispose();
  });
}

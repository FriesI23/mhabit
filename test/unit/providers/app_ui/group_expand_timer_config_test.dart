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
import 'package:mhabit/providers/app_ui/group_expand_timer_config.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProfileViewModel> _loadProfile() async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel([GroupExpandTimerDelayProfileHandler.new]);
  await profile.init();
  return profile;
}

void main() {
  group('GroupExpandTimerConfigViewModel', () {
    test('default speed is defaultSpeed when no value stored', () async {
      final profile = await _loadProfile();
      final viewModel = GroupExpandTimerConfigViewModel()
        ..updateProfile(profile);

      expect(viewModel.speed, GroupExpandTimerSpeed.defaultSpeed);

      viewModel.dispose();
      profile.dispose();
    });

    test(
      'expandDelayMs returns platform-aware default when defaultSpeed',
      () async {
        final profile = await _loadProfile();
        final viewModel = GroupExpandTimerConfigViewModel()
          ..updateProfile(profile);

        final expected = switch (defaultTargetPlatform) {
          TargetPlatform.android || TargetPlatform.iOS => 400,
          _ => 600,
        };
        expect(viewModel.expandDelayMs, expected);

        viewModel.dispose();
        profile.dispose();
      },
    );

    test('setSpeed persists and notifies', () async {
      final profile = await _loadProfile();
      var notified = false;
      final viewModel = GroupExpandTimerConfigViewModel()
        ..updateProfile(profile)
        ..addListener(() => notified = true);

      await viewModel.setSpeed(GroupExpandTimerSpeed.fast);

      expect(viewModel.speed, GroupExpandTimerSpeed.fast);
      expect(viewModel.expandDelayMs, 200);
      expect(notified, isTrue);

      viewModel.dispose();
      profile.dispose();
    });

    test('setSpeed to defaultSpeed stores ordinal 0', () async {
      final profile = await _loadProfile();
      final viewModel = GroupExpandTimerConfigViewModel()
        ..updateProfile(profile);

      await viewModel.setSpeed(GroupExpandTimerSpeed.defaultSpeed);
      expect(viewModel.speed, GroupExpandTimerSpeed.defaultSpeed);
      expect(
        profile.getHandler<GroupExpandTimerDelayProfileHandler>()?.get(),
        0,
      );

      viewModel.dispose();
      profile.dispose();
    });

    test('setSpeed to fast stores ordinal 1', () async {
      final profile = await _loadProfile();
      final viewModel = GroupExpandTimerConfigViewModel()
        ..updateProfile(profile);

      await viewModel.setSpeed(GroupExpandTimerSpeed.fast);
      expect(
        profile.getHandler<GroupExpandTimerDelayProfileHandler>()?.get(),
        1,
      );

      viewModel.dispose();
      profile.dispose();
    });

    test('setSpeed to slow stores ordinal 2', () async {
      final profile = await _loadProfile();
      final viewModel = GroupExpandTimerConfigViewModel()
        ..updateProfile(profile);

      await viewModel.setSpeed(GroupExpandTimerSpeed.slow);
      expect(
        profile.getHandler<GroupExpandTimerDelayProfileHandler>()?.get(),
        2,
      );

      viewModel.dispose();
      profile.dispose();
    });

    test('setSpeed fast gives 200 ms', () async {
      final profile = await _loadProfile();
      final viewModel = GroupExpandTimerConfigViewModel()
        ..updateProfile(profile);

      await viewModel.setSpeed(GroupExpandTimerSpeed.fast);
      expect(viewModel.expandDelayMs, 200);

      viewModel.dispose();
      profile.dispose();
    });

    test('setSpeed slow gives 800 ms', () async {
      final profile = await _loadProfile();
      final viewModel = GroupExpandTimerConfigViewModel()
        ..updateProfile(profile);

      await viewModel.setSpeed(GroupExpandTimerSpeed.slow);
      expect(viewModel.expandDelayMs, 800);

      viewModel.dispose();
      profile.dispose();
    });

    test('setSpeed overwrites previous speed', () async {
      final profile = await _loadProfile();
      final viewModel = GroupExpandTimerConfigViewModel()
        ..updateProfile(profile);

      await viewModel.setSpeed(GroupExpandTimerSpeed.fast);
      await viewModel.setSpeed(GroupExpandTimerSpeed.slow);

      expect(viewModel.speed, GroupExpandTimerSpeed.slow);
      expect(viewModel.expandDelayMs, 800);

      viewModel.dispose();
      profile.dispose();
    });

    test('handles unknown ordinal stored in profile as defaultSpeed', () async {
      SharedPreferences.setMockInitialValues({'groupExpandTimerDelay': 99});
      final profile = ProfileViewModel([
        GroupExpandTimerDelayProfileHandler.new,
      ]);
      await profile.init();
      final viewModel = GroupExpandTimerConfigViewModel()
        ..updateProfile(profile);

      expect(viewModel.speed, GroupExpandTimerSpeed.defaultSpeed);

      viewModel.dispose();
      profile.dispose();
    });

    test(
      'handles negative ordinal stored in profile as defaultSpeed',
      () async {
        SharedPreferences.setMockInitialValues({'groupExpandTimerDelay': -1});
        final profile = ProfileViewModel([
          GroupExpandTimerDelayProfileHandler.new,
        ]);
        await profile.init();
        final viewModel = GroupExpandTimerConfigViewModel()
          ..updateProfile(profile);

        expect(viewModel.speed, GroupExpandTimerSpeed.defaultSpeed);

        viewModel.dispose();
        profile.dispose();
      },
    );
  });
}

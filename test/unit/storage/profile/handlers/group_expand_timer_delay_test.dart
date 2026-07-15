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
  group('GroupExpandTimerDelayProfileHandler', () {
    test('key is "groupExpandTimerDelay"', () async {
      final profile = await _loadProfile();
      final handler = profile.getHandler<GroupExpandTimerDelayProfileHandler>();

      expect(handler?.key, 'groupExpandTimerDelay');

      profile.dispose();
    });

    test('get() returns null when no value stored', () async {
      final profile = await _loadProfile();
      final handler = profile.getHandler<GroupExpandTimerDelayProfileHandler>();

      expect(handler?.get(), isNull);

      profile.dispose();
    });

    test('set() + get() round-trip', () async {
      final profile = await _loadProfile();
      final handler = profile.getHandler<GroupExpandTimerDelayProfileHandler>();

      await handler?.set(200);
      expect(handler?.get(), 200);

      profile.dispose();
    });

    test('set() overwrites previous value', () async {
      final profile = await _loadProfile();
      final handler = profile.getHandler<GroupExpandTimerDelayProfileHandler>();

      await handler?.set(200);
      await handler?.set(800);
      expect(handler?.get(), 800);

      profile.dispose();
    });

    test('remove() clears stored value', () async {
      final profile = await _loadProfile();
      final handler = profile.getHandler<GroupExpandTimerDelayProfileHandler>();

      await handler?.set(200);
      await handler?.remove();
      expect(handler?.get(), isNull);

      profile.dispose();
    });

    test('handles all valid ordinal values', () async {
      final profile = await _loadProfile();
      final handler = profile.getHandler<GroupExpandTimerDelayProfileHandler>();

      for (final ordinal in [0, 1, 2]) {
        await handler?.set(ordinal);
        expect(handler?.get(), ordinal);
      }

      profile.dispose();
    });
  });
}

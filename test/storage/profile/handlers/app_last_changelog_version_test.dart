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
  final profile = ProfileViewModel([AppLastChangelogVersionProfileHandler.new]);
  await profile.init();
  return profile;
}

void main() {
  group('AppLastChangelogVersionProfileHandler', () {
    test('get() returns null when no value stored', () async {
      final profile = await _loadProfile();
      final handler = profile
          .getHandler<AppLastChangelogVersionProfileHandler>();

      expect(handler?.get(), isNull);

      profile.dispose();
    });

    test('set() + get() round-trip', () async {
      final profile = await _loadProfile();
      final handler = profile
          .getHandler<AppLastChangelogVersionProfileHandler>();

      await handler?.set('1.25.3+168');
      expect(handler?.get(), '1.25.3+168');

      profile.dispose();
    });

    test('set() overwrites previous value', () async {
      final profile = await _loadProfile();
      final handler = profile
          .getHandler<AppLastChangelogVersionProfileHandler>();

      await handler?.set('1.0.0+1');
      await handler?.set('2.0.0+200');
      expect(handler?.get(), '2.0.0+200');

      profile.dispose();
    });

    test('remove() clears stored value', () async {
      final profile = await _loadProfile();
      final handler = profile
          .getHandler<AppLastChangelogVersionProfileHandler>();

      await handler?.set('1.25.3+168');
      await handler?.remove();
      expect(handler?.get(), isNull);

      profile.dispose();
    });

    test("key is 'lastChangelogVersion'", () async {
      final profile = await _loadProfile();
      final handler = profile
          .getHandler<AppLastChangelogVersionProfileHandler>();

      expect(handler?.key, 'lastChangelogVersion');

      profile.dispose();
    });

    test('set() returns true on success', () async {
      final profile = await _loadProfile();
      final handler = profile
          .getHandler<AppLastChangelogVersionProfileHandler>();

      final result = await handler?.set('1.25.3+168');
      expect(result, isTrue);

      profile.dispose();
    });

    test('remove() returns true', () async {
      final profile = await _loadProfile();
      final handler = profile
          .getHandler<AppLastChangelogVersionProfileHandler>();

      await handler?.set('1.25.3+168');
      final result = await handler?.remove();
      expect(result, isTrue);

      profile.dispose();
    });

    test('handler accessible via getHandler<T>()', () async {
      final profile = await _loadProfile();
      final handler = profile
          .getHandler<AppLastChangelogVersionProfileHandler>();

      expect(handler, isNotNull);
      expect(handler, isA<AppLastChangelogVersionProfileHandler>());

      profile.dispose();
    });
  });
}

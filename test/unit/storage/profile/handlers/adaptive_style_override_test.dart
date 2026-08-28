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
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProfileViewModel> _loadProfile(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final profile = ProfileViewModel([AdaptiveStyleOverrideProfileHandler.new]);
  await profile.init();
  return profile;
}

void main() {
  group('AdaptiveStyleOverrideProfileHandler', () {
    test('uses a stable key and returns null when missing', () async {
      final profile = await _loadProfile({});
      final handler = profile.getHandler<AdaptiveStyleOverrideProfileHandler>();

      expect(handler?.key, 'adaptiveStyleOverride');
      expect(handler?.get(), isNull);

      profile.dispose();
    });

    test('round-trips all stable codes', () async {
      final profile = await _loadProfile({});
      final handler = profile.getHandler<AdaptiveStyleOverrideProfileHandler>();
      final preferences = await SharedPreferences.getInstance();

      for (final mode in AppAdaptiveStyleMode.values) {
        await handler?.set(mode);
        expect(handler?.get(), mode);
        expect(preferences.getInt(handler!.key), mode.code);
      }

      profile.dispose();
    });

    test('unknown and negative codes fall back to automatic', () async {
      for (final code in [-1, 3, 99]) {
        final profile = await _loadProfile({'adaptiveStyleOverride': code});
        final handler = profile
            .getHandler<AdaptiveStyleOverrideProfileHandler>();
        expect(handler?.get(), AppAdaptiveStyleMode.automatic);
        profile.dispose();
      }
    });
  });
}

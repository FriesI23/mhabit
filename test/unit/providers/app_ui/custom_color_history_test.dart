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
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/providers/app_ui/custom_color_history.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProfileViewModel> _loadProfile() async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel([CustomColorHistoryProfileHandler.new]);
  await profile.init();
  return profile;
}

void main() {
  group('CustomColorHistoryProfileHandler', () {
    test('decodes the {argb, tinted} map format', () async {
      SharedPreferences.setMockInitialValues({
        'customColorHistory':
            '[{"argb":4292714768,"tinted":false},{"argb":4289510092,"tinted":true}]',
      });
      final pref = await SharedPreferences.getInstance();
      final handler = CustomColorHistoryProfileHandler(pref);

      expect(handler.get(), [
        const CustomHabitColor(4292714768, tinted: false),
        const CustomHabitColor(4289510092, tinted: true),
      ]);
    });

    test('round-trips set/get through the {argb, tinted} map format', () async {
      SharedPreferences.setMockInitialValues({});
      final pref = await SharedPreferences.getInstance();
      final handler = CustomColorHistoryProfileHandler(pref);

      await handler.set(const [
        CustomHabitColor(0xFFAABBCC, tinted: false),
        CustomHabitColor(0xFF112233),
      ]);

      expect(handler.get(), [
        const CustomHabitColor(0xFFAABBCC, tinted: false),
        const CustomHabitColor(0xFF112233),
      ]);
    });
  });

  group('CustomColorHistoryViewModel', () {
    test('reads empty history by default', () async {
      final profile = await _loadProfile();
      final viewModel = CustomColorHistoryViewModel()..updateProfile(profile);

      expect(viewModel.history, isEmpty);

      viewModel.dispose();
      profile.dispose();
    });

    test('recordUsage inserts a new color at the front', () async {
      final profile = await _loadProfile();
      final viewModel = CustomColorHistoryViewModel()..updateProfile(profile);

      await viewModel.recordUsage(const CustomHabitColor(0xFFAAAAAA));
      await viewModel.recordUsage(const CustomHabitColor(0xFFBBBBBB));

      expect(viewModel.history, [
        const CustomHabitColor(0xFFBBBBBB),
        const CustomHabitColor(0xFFAAAAAA),
      ]);
      expect(profile.getHandler<CustomColorHistoryProfileHandler>()?.get(), [
        const CustomHabitColor(0xFFBBBBBB),
        const CustomHabitColor(0xFFAAAAAA),
      ]);

      viewModel.dispose();
      profile.dispose();
    });

    test('recordUsage moves an existing color to the front instead of '
        'duplicating it', () async {
      final profile = await _loadProfile();
      final viewModel = CustomColorHistoryViewModel()..updateProfile(profile);

      await viewModel.recordUsage(const CustomHabitColor(0xFFAAAAAA));
      await viewModel.recordUsage(const CustomHabitColor(0xFFBBBBBB));
      await viewModel.recordUsage(const CustomHabitColor(0xFFCCCCCC));
      await viewModel.recordUsage(const CustomHabitColor(0xFFAAAAAA));

      expect(viewModel.history, [
        const CustomHabitColor(0xFFAAAAAA),
        const CustomHabitColor(0xFFCCCCCC),
        const CustomHabitColor(0xFFBBBBBB),
      ]);

      viewModel.dispose();
      profile.dispose();
    });

    test('recordUsage treats the same argb with a different tinted state as a '
        'separate entry rather than overwriting it', () async {
      final profile = await _loadProfile();
      final viewModel = CustomColorHistoryViewModel()..updateProfile(profile);

      await viewModel.recordUsage(
        const CustomHabitColor(0xFFAAAAAA, tinted: true),
      );
      await viewModel.recordUsage(
        const CustomHabitColor(0xFFAAAAAA, tinted: false),
      );

      expect(viewModel.history, [
        const CustomHabitColor(0xFFAAAAAA, tinted: false),
        const CustomHabitColor(0xFFAAAAAA, tinted: true),
      ]);

      viewModel.dispose();
      profile.dispose();
    });

    test('recordUsage truncates history to maxLength, dropping the oldest '
        'entry', () async {
      final profile = await _loadProfile();
      final viewModel = CustomColorHistoryViewModel()..updateProfile(profile);

      for (var i = 0; i < CustomColorHistoryViewModel.maxLength + 1; i++) {
        await viewModel.recordUsage(CustomHabitColor(0xFF000000 + i));
      }

      expect(
        viewModel.history,
        hasLength(CustomColorHistoryViewModel.maxLength),
      );
      // The first inserted color (index 0) should have been evicted as the
      // oldest entry once the 21st distinct color was recorded.
      expect(
        viewModel.history,
        isNot(contains(const CustomHabitColor(0xFF000000))),
      );
      // The most recently recorded color stays at the front.
      expect(
        viewModel.history.first,
        const CustomHabitColor(
          0xFF000000 + CustomColorHistoryViewModel.maxLength,
        ),
      );

      viewModel.dispose();
      profile.dispose();
    });
  });
}

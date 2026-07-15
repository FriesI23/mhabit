// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/pages/common/_widgets/not_found_image.dart';
import 'package:mhabit/pages/habits_status_changer/page.dart';
import 'package:mhabit/providers/app_ui/app_compact_ui_switcher.dart';
import 'package:mhabit/providers/app_ui/app_custom_date_format.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/app_ui/app_first_day.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/stub/habits_display_access.dart';

final class _FailingHabitStatusChangerAccess
    extends StubHabitStatusChangerAccess {
  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async => throw StateError('load failed');
}

Future<ProfileViewModel> _loadProfile() async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel(const []);
  await profile.init();
  return profile;
}

void main() {
  testWidgets('HabitsStatusChangerPage shows error placeholder on load error', (
    tester,
  ) async {
    final profile = await _loadProfile();
    final access = _FailingHabitStatusChangerAccess();

    final customDate = AppCustomDateYmdHmsConfigViewModel()
      ..updateProfile(profile);
    final firstDay = AppFirstDayViewModel()..updateProfile(profile);
    final compactUi = AppCompactUISwitcherViewModel()..updateProfile(profile);
    final developer = AppDeveloperViewModel(global: Global());

    addTearDown(() {
      developer.dispose();
      compactUi.dispose();
      firstDay.dispose();
      customDate.dispose();
      profile.dispose();
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileViewModel>.value(value: profile),
          Provider<HabitStatusChangerAccess>.value(value: access),
          ChangeNotifierProvider<AppCustomDateYmdHmsConfigViewModel>.value(
            value: customDate,
          ),
          ChangeNotifierProvider<AppFirstDayViewModel>.value(value: firstDay),
          ChangeNotifierProvider<AppCompactUISwitcherViewModel>.value(
            value: compactUi,
          ),
          ChangeNotifierProvider<AppDeveloperViewModel>.value(value: developer),
        ],
        child: const MaterialApp(
          home: HabitsStatusChangerPage(
            uuidList: ['11111111-1111-4111-8111-111111111111'],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(NotFoundImage), findsOneWidget);
  });
}

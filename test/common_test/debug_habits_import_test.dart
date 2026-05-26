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
import 'package:mhabit/pages/common/debug.dart';
import 'package:mhabit/providers/habits_manager.dart';
import 'package:provider/provider.dart';

final class _FakeHabitImportAccess implements HabitImportAccess {
  List<Object?>? lastJsonData;
  bool? lastWithRecords;

  @override
  int getImportHabitsCount(Iterable<Object?> jsonData) => jsonData.length;

  @override
  List<Future<void>> importHabitsData(
    Iterable<Object?> jsonData, {
    bool withRecords = true,
  }) {
    lastJsonData = jsonData.toList(growable: false);
    lastWithRecords = withRecords;
    return List.generate(lastJsonData!.length, (_) => Future.value());
  }
}

final class _DebugActions with HabitsDisplayViewDebug {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'debugAddMultiTempHabit routes through HabitImportAccess without records',
    (tester) async {
      final access = _FakeHabitImportAccess();
      final actions = _DebugActions();
      late BuildContext buildContext;

      await tester.pumpWidget(
        Provider<HabitImportAccess>.value(
          value: access,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                buildContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      await actions.debugAddMultiTempHabit(buildContext, count: 2);

      expect(access.lastWithRecords, isFalse);
      expect(access.lastJsonData, hasLength(2));
      expect(access.lastJsonData, everyElement(isA<Map<String, dynamic>>()));
    },
  );
}

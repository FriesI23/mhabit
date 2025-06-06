// Copyright 2025 Fries_I23
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

import 'package:mhabit/reminders/notification_id_range.dart';
import 'package:test/test.dart';

void main() {
  bool isValidSyncId(int id) => id >= minSyncNotifyId && id <= maxSyncNotifyId;

  bool isEven(int value) => value % 2 == 0;

  test('getRandomSyncId should return values within valid range and even', () {
    const iterations = 10000;
    for (int i = 0; i < iterations; i++) {
      final id = getRandomSyncId();
      expect(isValidSyncId(id), isTrue, reason: 'ID $id is out of range');
      expect(isEven(id), isTrue, reason: 'ID $id is not even');
    }
  });

  test('getRandomSyncId covers edge values', () {
    final seen = <int>{};
    const iterations = 100000;
    for (int i = 0; i < iterations; i++) {
      seen.add(getRandomSyncId());
    }

    final evenStart =
        minSyncNotifyId.isEven ? minSyncNotifyId : minSyncNotifyId + 1;
    final evenEnd =
        maxSyncNotifyId.isEven ? maxSyncNotifyId : maxSyncNotifyId - 1;

    expect(seen.contains(evenStart), isTrue,
        reason: 'Did not generate evenStart');
    expect(seen.contains(evenEnd), isTrue, reason: 'Did not generate evenEnd');
  });
}

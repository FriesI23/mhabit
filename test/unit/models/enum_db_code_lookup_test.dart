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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/enums.dart';
import 'package:mhabit/models/app_entry.dart';
import 'package:mhabit/models/app_sync_options.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/models/app_theme_color.dart';

void main() {
  group('Common enum DB code lookups', () {
    test('return matching values for known codes', () {
      expect(
        HabitsRecordScrollBehavior.getFromDBCode(2),
        HabitsRecordScrollBehavior.page,
      );
      expect(UserAction.getFromDBCode(3), UserAction.longTap);
    });

    test('return provided defaults for unknown codes', () {
      expect(
        HabitsRecordScrollBehavior.getFromDBCode(
          99,
          withDefault: HabitsRecordScrollBehavior.scrollable,
        ),
        HabitsRecordScrollBehavior.scrollable,
      );
      expect(
        UserAction.getFromDBCode(99, withDefault: UserAction.doubleTap),
        UserAction.doubleTap,
      );
    });
  });

  group('Additional model enum DB code lookups', () {
    test('return matching values for known codes', () {
      expect(AppEntrys.getFromDBCode(2), AppEntrys.habitToday);
      expect(
        AppSyncFetchInterval.getFromDBCode(1800),
        AppSyncFetchInterval.minute30,
      );
      expect(AppSyncServerType.getFromDBCode(99), AppSyncServerType.fake);
      expect(AppThemeColorType.getFromDBCode(3), AppThemeColorType.dynamic);
    });

    test('return provided defaults or null for unknown codes', () {
      expect(
        AppEntrys.getFromDBCode(99, withDefault: AppEntrys.habitDisplay),
        AppEntrys.habitDisplay,
      );
      expect(
        AppSyncFetchInterval.getFromDBCode(
          99,
          withDefault: AppSyncFetchInterval.hour1,
        ),
        AppSyncFetchInterval.hour1,
      );
      expect(
        AppSyncServerType.getFromDBCode(
          -99,
          withDefault: AppSyncServerType.webdav,
        ),
        AppSyncServerType.webdav,
      );
      expect(AppThemeColorType.getFromDBCode(99), isNull);
    });
  });
}

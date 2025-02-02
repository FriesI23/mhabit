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

import '../common/enums.dart';

enum AppSyncFetchInterval implements EnumWithDBCode {
  manual(null),
  minute5(Duration(minutes: 5)),
  minute15(Duration(minutes: 15)),
  minute30(Duration(minutes: 30)),
  hour1(Duration(hours: 1));

  final Duration? t;

  const AppSyncFetchInterval(this.t);

  @override
  int get dbCode => t?.inSeconds ?? -1;

  static AppSyncFetchInterval? getFromDBCode(int dbCode,
      {AppSyncFetchInterval? withDefault = AppSyncFetchInterval.manual}) {
    for (var value in AppSyncFetchInterval.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }
}

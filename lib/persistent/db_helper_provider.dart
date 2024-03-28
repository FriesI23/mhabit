// Copyright 2024 Fries_I23
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

import '../common/abc.dart';
import '../provider/commons.dart';
import 'local/db_helper.dart';
import 'local/handler/habit.dart';
import 'local/handler/record.dart';

class DBHelperViewModel extends ChangeNotifier
    with FutureInitializationABC, ProviderMounted {
  DBHelper local;
  Future? inited;
  bool _mounted = true;

  DBHelperViewModel() : local = DBHelper();

  @override
  Future init() async {
    Future initAll() async {
      await local.init();
    }

    inited = initAll();
    await inited;
  }

  @override
  void dispose() {
    _mounted = false;
    local.dispose();
    super.dispose();
  }

  @override
  bool get mounted => _mounted;
}

abstract mixin class DBHelperLoadedMixin {
  late HabitDBHelper habitDBHelper;
  late RecordDBHelper recordDBHelper;

  void updateDBHelper(DBHelperViewModel newHelper) {
    habitDBHelper = HabitDBHelper(newHelper.local);
    recordDBHelper = RecordDBHelper(newHelper.local);
  }
}

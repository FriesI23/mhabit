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

import '../models/cache.dart';
import '../storage/profile/handlers.dart';
import '../storage/profile_provider.dart';

enum _InputFillCacheKey {
  habitEditTargetDays,
}

class AppCachesViewModel with ProfileHandlerLoadedMixin {
  AppCacheDelegate? _inputFill;

  void _updateInputFile(ProfileViewModel newProfile) {
    final handler = newProfile.getHandler<InputFillCacheProfileHandler>();
    _inputFill = handler != null ? AppCacheDelegate(handler: handler) : null;
  }

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _updateInputFile(newProfile);
  }

  int? get habitEditTargetDaysInputFill =>
      _inputFill?.getCache<int>(_InputFillCacheKey.habitEditTargetDays.name);

  Future<bool> updateHabitEditTargetDaysInputFill(int? newTargetDays) async {
    bool rst = false;
    await _inputFill?.updateCache<int>(
        _InputFillCacheKey.habitEditTargetDays.name, newTargetDays,
        onUpdated: (result, oldValue) => rst = result);
    return rst;
  }

  Future<List<bool>> clearAllCache() async {
    final List<bool> clearResultList = [];
    final List<Future> futures = [
      if (_inputFill != null) _inputFill!.clear(onClear: clearResultList.add),
    ];
    await Future.wait(futures);
    return clearResultList;
  }
}

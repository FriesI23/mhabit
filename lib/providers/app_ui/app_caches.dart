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

import '../../models/cache.dart';
import '../../storage/profile/handlers.dart';
import '../../storage/profile_provider.dart';

enum _InputFillCacheKey { habitEditTargetDays }

enum _AppFlagKey { skipGroupChangeConfirm }

class AppCachesViewModel with ProfileHandlerLoadedMixin {
  AppCacheDelegate? _inputFill;
  AppCacheDelegate? _appFlags;

  void _updateInputFile(ProfileViewModel newProfile) {
    final handler = newProfile.getHandler<InputFillCacheProfileHandler>();
    if (handler != null) {
      final delegate = AppCacheDelegate(handler: handler);
      delegate.reload();
      _inputFill = delegate;
    } else {
      _inputFill = null;
    }
  }

  void _updateAppFlags(ProfileViewModel newProfile) {
    final handler = newProfile.getHandler<AppFlagsProfileHandler>();
    if (handler != null) {
      final delegate = AppCacheDelegate(handler: handler);
      delegate.reload();
      _appFlags = delegate;
    } else {
      _appFlags = null;
    }
  }

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _updateInputFile(newProfile);
    _updateAppFlags(newProfile);
  }

  int? get habitEditTargetDaysInputFill =>
      _inputFill?.getCache<int>(_InputFillCacheKey.habitEditTargetDays.name);

  Future<bool> updateHabitEditTargetDaysInputFill(int? newTargetDays) async {
    bool rst = false;
    await _inputFill?.updateCache<int>(
      _InputFillCacheKey.habitEditTargetDays.name,
      newTargetDays,
      onUpdated: (result, oldValue) => rst = result,
    );
    return rst;
  }

  bool get appFlagSkipGroupChangeConfirm =>
      _appFlags?.getCache<bool>(_AppFlagKey.skipGroupChangeConfirm.name) ??
      false;

  Future<bool> updateAppFlagSkipGroupChangeConfirm(bool value) async {
    bool rst = false;
    await _appFlags?.updateCache<bool>(
      _AppFlagKey.skipGroupChangeConfirm.name,
      value,
      onUpdated: (result, oldValue) => rst = result,
    );
    return rst;
  }

  Future<List<bool>> clearAllCache() async {
    final List<bool> clearResultList = [];
    final List<Future> futures = [
      if (_inputFill != null) _inputFill!.clear(onClear: clearResultList.add),
      if (_appFlags != null) _appFlags!.clear(onClear: clearResultList.add),
    ];
    await Future.wait(futures);
    return clearResultList;
  }
}

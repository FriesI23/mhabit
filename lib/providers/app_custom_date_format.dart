// Copyright 2023 Fries_I23
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

import 'package:flutter/foundation.dart';

import '../logging/helper.dart';
import '../models/custom_date_format.dart';
import '../storage/profile/handlers.dart';
import '../storage/profile_provider.dart';

class AppCustomDateYmdHmsConfigViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin {
  ShowDateFormatProfileHandler? _dataFmt;

  AppCustomDateYmdHmsConfigViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _dataFmt = newProfile.getHandler<ShowDateFormatProfileHandler>();
  }

  CustomDateYmdHmsConfig get config =>
      _dataFmt?.get() ?? const CustomDateYmdHmsConfig.withDefault();

  Future<void> setNewConfig(CustomDateYmdHmsConfig newConfig) async {
    appLog.value.info(
      "$runtimeType.setNewConfig",
      beforeVal: config,
      afterVal: newConfig,
    );
    await _dataFmt?.set(newConfig);
    notifyListeners();
  }
}

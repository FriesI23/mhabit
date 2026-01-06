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

import '../common/enums.dart';
import '../logging/helper.dart';
import '../models/habit_display.dart';
import '../storage/profile/handlers.dart';
import '../storage/profile_provider.dart';

class HabitRecordOpConfigViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin {
  HabitCellGestureModeProfileHandler? _op;

  HabitRecordOpConfigViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _op = newProfile.getHandler<HabitCellGestureModeProfileHandler>();
  }

  HabitDisplayOpConfig get _opData =>
      _op?.get() ?? const HabitDisplayOpConfig.withDefault();

  UserAction get changeRecordStatus => _opData.changeRecordStatus;
  UserAction get openRecordStatusDialog => _opData.openRecordStatusDialog;

  HabitDisplayOpConfig _generateExchangeActionsConfig() => _opData.copyWith(
    changeRecordStatus: openRecordStatusDialog,
    openRecordStatusDialog: changeRecordStatus,
  );

  void setChangeRecordStatusAction(UserAction newAction) async {
    final newOpConfig = newAction == openRecordStatusDialog
        ? _generateExchangeActionsConfig()
        : _opData.copyWith(changeRecordStatus: newAction);
    appLog.value.info(
      "$runtimeType.setChangeRecordStatusAction",
      beforeVal: _opData,
      afterVal: newOpConfig,
    );
    await _op?.set(newOpConfig);
    notifyListeners();
  }

  void setOpenRecordStatusDialogAction(UserAction newAction) async {
    final newOpConfig = newAction == changeRecordStatus
        ? _generateExchangeActionsConfig()
        : _opData.copyWith(openRecordStatusDialog: newAction);
    appLog.value.info(
      "$runtimeType.setOpenRecordStatusDialogAction",
      beforeVal: _opData,
      afterVal: newOpConfig,
    );
    await _op?.set(newOpConfig);
    notifyListeners();
  }
}

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

import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

import '../common/consts.dart';
import '../storage/profile/handlers.dart';
import '../storage/profile_provider.dart';
import '../theme/color.dart';

class AppThemeViewModel extends ChangeNotifier with ProfileHandlerLoadedMixin {
  AppThemeTypeProfileHandler? _theme;
  AppThemeMainColorProfileHandler? _mainColor;
  DisplayCalendartBarOccupyPrtProfileHandler? _calOccupy;

  AppThemeViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _theme = newProfile.getHandler<AppThemeTypeProfileHandler>();
    _mainColor = newProfile.getHandler<AppThemeMainColorProfileHandler>();
    _calOccupy =
        newProfile.getHandler<DisplayCalendartBarOccupyPrtProfileHandler>();
  }

  //#region app theme
  AppThemeType get themeType => _theme?.get() ?? appDefaultThemeType;

  Future<void> setNewthemeType(AppThemeType newThemeType) async {
    if (_theme?.get() != newThemeType) {
      await _theme?.set(newThemeType);
      notifyListeners();
    }
  }

  Future<void> onTapChangeThemeType(Brightness brightness) async {
    final AppThemeType nextThemeType;
    // in lightmode: followSystem -> light -> dark -> followSystem -> ...
    // in darkmode: followSystem -> dart -> light -> followSystem -> ...
    switch (themeType) {
      case AppThemeType.light:
        nextThemeType = brightness == Brightness.light
            ? AppThemeType.dark
            : AppThemeType.followSystem;
        break;
      case AppThemeType.dark:
        nextThemeType = brightness == Brightness.light
            ? AppThemeType.followSystem
            : AppThemeType.light;
        break;
      case AppThemeType.unknown:
      case AppThemeType.followSystem:
        nextThemeType = brightness == Brightness.light
            ? AppThemeType.light
            : AppThemeType.dark;
        break;
    }
    await setNewthemeType(nextThemeType);
  }
  //#endregion

  //#region app theme main color
  Color get mainColor => _mainColor?.get() ?? appDefaultThemeMainColor;
  //#endregion

  //#region display page occupy percentage
  int get displayPageOccupyPrt =>
      _calOccupy?.get() ?? appCalendarBarDefualtOccupyPrt;

  Future<void> setNewDisplayPageOccupyPrt(int newPrt) async {
    if (_calOccupy?.get() != newPrt) {
      await _calOccupy?.set(newPrt);
      notifyListeners();
    }
  }
  //#endregion
}

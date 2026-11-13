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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../common/consts.dart';
import '../../models/app_adaptive_style_mode.dart';
import '../../models/app_apple_sidebar_style_mode.dart';
import '../../models/app_theme_color.dart';
import '../../storage/profile/handlers.dart';
import '../../storage/profile_provider.dart';
import '../../theme/color.dart';

class AppThemeViewModel extends ChangeNotifier with ProfileHandlerLoadedMixin {
  AdaptiveStyleOverrideProfileHandler? _adaptiveStyleOverride;
  AppleSidebarStyleModeProfileHandler? _appleSidebarStyleMode;
  AppThemeTypeProfileHandler? _theme;
  AppThemeColorProfileHandler? _themeColor;
  AppThemeMainColorProfileHandler? _mainColor;
  DisplayCalendartBarOccupyPrtProfileHandler? _calOccupy;

  AppThemeViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    final previousStyle = (adaptiveStyleMode, appleSidebarStyleMode);
    super.updateProfile(newProfile);
    _adaptiveStyleOverride = newProfile
        .getHandler<AdaptiveStyleOverrideProfileHandler>();
    _appleSidebarStyleMode = newProfile
        .getHandler<AppleSidebarStyleModeProfileHandler>();
    _theme = newProfile.getHandler<AppThemeTypeProfileHandler>();
    _themeColor = newProfile.getHandler<AppThemeColorProfileHandler>();
    _mainColor = newProfile.getHandler<AppThemeMainColorProfileHandler>();
    _calOccupy = newProfile
        .getHandler<DisplayCalendartBarOccupyPrtProfileHandler>();
    if (previousStyle != (adaptiveStyleMode, appleSidebarStyleMode)) {
      notifyListeners();
    }
  }

  AppAdaptiveStyleMode get adaptiveStyleMode =>
      _adaptiveStyleOverride?.get() ?? AppAdaptiveStyleMode.automatic;

  AdaptiveStyle? get adaptiveStyleOverride => switch (adaptiveStyleMode) {
    AppAdaptiveStyleMode.automatic => null,
    AppAdaptiveStyleMode.material => AdaptiveStyle.material,
    AppAdaptiveStyleMode.apple => AdaptiveStyle.apple,
  };

  Future<void> setAdaptiveStyleMode(AppAdaptiveStyleMode mode) async {
    if (adaptiveStyleMode == mode) return;
    await _adaptiveStyleOverride?.set(mode);
    notifyListeners();
  }

  AppAppleSidebarStyleMode get appleSidebarStyleMode =>
      _appleSidebarStyleMode?.get() ?? AppAppleSidebarStyleMode.automatic;

  Future<void> setAppleSidebarStyleMode(AppAppleSidebarStyleMode mode) async {
    if (appleSidebarStyleMode == mode) return;
    await _appleSidebarStyleMode?.set(mode);
    notifyListeners();
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

  //#region app theme color
  AppThemeColor get themeColor =>
      _themeColor?.get() ??
      switch (defaultTargetPlatform) {
        TargetPlatform.iOS => const SystemAppThemeColor(),
        _ => const DynamicAppThemeColor(),
      };

  Future<void> setNewAppThemeColor(AppThemeColor newThemeColor) async {
    if (_themeColor?.get() != newThemeColor) {
      await _themeColor?.set(newThemeColor);
      notifyListeners();
    }
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

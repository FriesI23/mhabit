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

import 'package:flutter/material.dart';

import '../common/utils.dart';
import '../model/global.dart';
import '../theme/color.dart';

class AppThemeViewModel extends ChangeNotifier
    implements GlobalProxyProviderInterface {
  Global _g;

  AppThemeViewModel({required Global global}) : _g = global;

  @override
  Global get g => _g;

  @override
  void updateGlobal(Global newGloal) => _g = newGloal;

  AppThemeType get themeType => _g.themeType;
  ThemeMode get matertialThemeType => transToMaterialThemeType(themeType);

  Future<void> setNewthemeType(AppThemeType newThemeType) async {
    if (_g.themeType != newThemeType) {
      await _g.profile.setThemeType(newThemeType);
      notifyListeners();
    }
  }

  Future<void> onTapChangeThemeType(Brightness brightness) async {
    var crtThemeType = _g.themeType;
    AppThemeType nextThemeType;
    // in lightmode: followSystem -> light -> dark -> followSystem -> ...
    // in darkmode: followSystem -> dart -> light -> followSystem -> ...
    switch (crtThemeType) {
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
}

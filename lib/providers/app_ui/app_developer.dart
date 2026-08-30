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
import 'package:flutter/widgets.dart' show TextDirection;
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../models/app_adaptive_style_mode.dart';
import '../../storage/profile/handlers.dart';
import '../../storage/profile_provider.dart';
import '../support/global.dart';

class AppDeveloperViewModel extends ChangeNotifier
    with GlobalLoadedMixin, ProfileHandlerLoadedMixin {
  AdaptiveStyleOverrideProfileHandler? _adaptiveStyleOverride;
  TextDirection? _textDirectionOverride;

  AppDeveloperViewModel({required Global global, ProfileViewModel? profile}) {
    updateGlobal(global);
    if (profile != null) updateProfile(profile);
  }

  @override
  void updateProfile(ProfileViewModel newProfile) {
    final previousMode = adaptiveStyleMode;
    super.updateProfile(newProfile);
    _adaptiveStyleOverride = newProfile
        .getHandler<AdaptiveStyleOverrideProfileHandler>();
    if (adaptiveStyleMode != previousMode) notifyListeners();
  }

  bool get isInDevelopMode => g.isInDevelopMode;

  void switchDevelopMode(bool value) {
    if (g.isInDevelopMode != value) {
      g.switchDevelopMode(value);
      notifyListeners();
    }
  }

  bool get displayDebugMenu => g.displayDebugMenu;

  void switchDisplayDebugMenu(bool value) {
    if (g.displayDebugMenu != value) {
      g.switchDisplayDebugMenu(value);
      notifyListeners();
    }
  }

  bool get showDebugMenuOnDisplayView => isInDevelopMode && displayDebugMenu;

  AppAdaptiveStyleMode get adaptiveStyleMode =>
      _adaptiveStyleOverride?.get() ?? AppAdaptiveStyleMode.automatic;

  AdaptiveStyle? get adaptiveStyleOverride => switch (adaptiveStyleMode) {
    AppAdaptiveStyleMode.automatic => null,
    AppAdaptiveStyleMode.material => AdaptiveStyle.material,
    AppAdaptiveStyleMode.apple => AdaptiveStyle.apple,
  };

  TextDirection? get textDirectionOverride => _textDirectionOverride;

  Future<void> setAdaptiveStyleMode(AppAdaptiveStyleMode mode) async {
    if (adaptiveStyleMode == mode) return;
    await _adaptiveStyleOverride?.set(mode);
    notifyListeners();
  }

  void setTextDirectionOverride(TextDirection? textDirection) {
    if (_textDirectionOverride == textDirection) return;
    _textDirectionOverride = textDirection;
    notifyListeners();
  }
}

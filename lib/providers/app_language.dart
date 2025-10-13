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

import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../storage/profile/handlers/app_language.dart';
import '../storage/profile_provider.dart';

class AppLanguageViewModel with ChangeNotifier, ProfileHandlerLoadedMixin {
  AppLanguageProfileHanlder? _language;

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _language = newProfile.getHandler<AppLanguageProfileHanlder>();
  }

  Locale? get languange => _language?.get();

  Future<void> switchLanguage(Locale? locale, {bool listen = true}) async {
    if (_language?.get() != locale) {
      await (locale != null ? _language?.set(locale) : _language?.remove());
      notifyListeners();
    }
  }

  String getAppLanguageText([L10n? l10n, String fallbackText = ""]) {
    final languange = this.languange;
    if (languange == null) {
      return l10n?.appSetting_changeLanguage_followSystem_text(
              l10n.localeScriptName) ??
          "Follow System";
    }
    try {
      return lookupL10n(languange).localeScriptName;
    } on FlutterError catch (e) {
      appLog.debugger.warn("$runtimeType.getAppLanguageText",
          ex: [l10n, fallbackText, languange], error: e);
      return l10n?.localeScriptName ?? fallbackText;
    }
  }
}

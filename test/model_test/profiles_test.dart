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
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/db/profile.dart';
import 'package:mhabit/theme/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  SharedPreferences.setMockInitialValues({});
  final setting = Profile();
  await setting.init();
  group("AppSettingSharedPrefModel:themeType", () {
    test('getThemeType', () async {
      await setting.clearAll();
      final int thisAppThemeType = setting.getThemeType();
      expect(thisAppThemeType, AppThemeType.followSystem.dbCode);
    });
    test('setThemeType To Dark', () async {
      await setting.clearAll();
      final result = await setting.setThemeType(AppThemeType.dark);
      expect(result, true);
      expect(setting.getThemeType(), AppThemeType.dark.dbCode);
    });
    test('setThemeType To Light', () async {
      await setting.clearAll();
      final result = await setting.setThemeType(AppThemeType.light);
      expect(result, true);
      expect(setting.getThemeType(), AppThemeType.light.dbCode);
    });
    test('setThemeType Error', () async {
      await setting.clearAll();
      try {
        await setting.setThemeType(AppThemeType.unknown);
      } catch (err) {
        expect(err, isInstanceOf<TypeError>());
      }
    });
  });
  group("AppSettingSharedPrefModel:sysThemeMainColor", () {
    test('getSysThemeMainColor', () async {
      await setting.clearAll();
      expect(setting.getSysThemeMainColor(), appDefaultThemeMainColor);
    });
    test('setSysThemeMainColor', () async {
      await setting.clearAll();
      const newColor = 0xFF8BC34A;
      final result = await setting.setSysThemeMainColor(const Color(newColor));
      expect(result, true);
      expect(setting.getSysThemeMainColor(), newColor);
    });
  });
}

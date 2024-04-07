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

import '../common/enums.dart';

export '_colors/colors.dart';
export '_colors/crypto_colors.dart';
export '_colors/custom_color.g.dart';
export '_colors/userdefined_color.dart';

enum AppThemeType implements EnumWithDBCode {
  unknown(code: 0),
  light(code: 1),
  dark(code: 2),
  followSystem(code: 3);

  final int _code;

  const AppThemeType({required int code}) : _code = code;

  @override
  int get dbCode => _code;

  static AppThemeType? getFromDBCode(int dbCode,
      {AppThemeType? withDefault = AppThemeType.unknown}) {
    for (var value in AppThemeType.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }
}

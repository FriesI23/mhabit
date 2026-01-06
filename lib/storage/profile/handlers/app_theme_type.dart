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

import 'dart:convert';

import '../../../theme/color.dart';
import '../profile_helper.dart';

final class AppThemeTypeProfileHandler
    extends ProfileHelperCovertToIntHandler<AppThemeType> {
  @override
  String get key => "themeType";

  const AppThemeTypeProfileHandler(
    super.pref, {
    super.codec = const AppThemeTypeProfileCodec(),
  });
}

final class AppThemeTypeProfileCodec extends Codec<AppThemeType, int> {
  const AppThemeTypeProfileCodec();

  @override
  Converter<int, AppThemeType> get decoder => const _Decoder();

  @override
  Converter<AppThemeType, int> get encoder => const _Encoder();
}

final class _Decoder extends Converter<int, AppThemeType> {
  const _Decoder();

  @override
  AppThemeType convert(int input) =>
      AppThemeType.getFromDBCode(input, withDefault: AppThemeType.unknown)!;
}

final class _Encoder extends Converter<AppThemeType, int> {
  const _Encoder();

  @override
  int convert(AppThemeType input) => input.dbCode;
}

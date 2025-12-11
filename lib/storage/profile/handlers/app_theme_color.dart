// Copyright 2025 Fries_I23
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

import '../../../common/types.dart';
import '../../../models/app_theme_color.dart';
import '../profile_helper.dart';

class AppThemeColorProfileHandler
    extends ProfileHelperCovertToJsonHandler<AppThemeColor?> {
  const AppThemeColorProfileHandler(super.pref,
      {super.codec = const AppThemeColorProfileCodec()});

  @override
  String get key => 'appThemeColor';
}

final class AppThemeColorProfileCodec extends Codec<AppThemeColor?, JsonMap> {
  const AppThemeColorProfileCodec();

  @override
  Converter<JsonMap, AppThemeColor?> get decoder =>
      const _AppThemeColorProfileDecoder();

  @override
  Converter<AppThemeColor?, JsonMap> get encoder =>
      const _AppThemeColorProfileEncoder();
}

final class _AppThemeColorProfileDecoder
    extends Converter<JsonMap, AppThemeColor?> {
  const _AppThemeColorProfileDecoder();

  @override
  AppThemeColor? convert(JsonMap input) => AppThemeColor.fromJson(input);
}

final class _AppThemeColorProfileEncoder
    extends Converter<AppThemeColor?, JsonMap> {
  const _AppThemeColorProfileEncoder();

  @override
  JsonMap convert(AppThemeColor? input) => input?.toJson() ?? {};
}

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
import '../../../models/app_notify_config.dart';
import '../profile_helper.dart';

class AppNotifyConfigProfileHandler
    extends ProfileHelperCovertToJsonHandler<AppNotifyConfig> {
  AppNotifyConfigProfileHandler(super.pref,
      {super.codec = const AppNotifyConfigProfileCodec()});

  @override
  String get key => "appNotifyConfig";
}

final class AppNotifyConfigProfileCodec
    extends Codec<AppNotifyConfig, JsonMap> {
  const AppNotifyConfigProfileCodec();

  @override
  Converter<JsonMap, AppNotifyConfig> get decoder => const _Decoder();

  @override
  Converter<AppNotifyConfig, JsonMap> get encoder => const _Encoder();
}

final class _Decoder extends Converter<JsonMap, AppNotifyConfig> {
  const _Decoder();

  @override
  AppNotifyConfig convert(JsonMap input) => AppNotifyConfig.fromJson(input);
}

final class _Encoder extends Converter<AppNotifyConfig, JsonMap> {
  const _Encoder();

  @override
  JsonMap convert(AppNotifyConfig input) => input.toJson();
}

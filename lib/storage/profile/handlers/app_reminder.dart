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

import '../../../common/types.dart';
import '../../../model/app_reminder_config.dart';
import '../profile_helper.dart';

final class AppReminderProfileHandler
    extends ProfileHelperCovertToJsonHandler<AppReminderConfig> {
  const AppReminderProfileHandler(super.pref)
      : super(codec: const AppReminderCodec());

  @override
  String get key => "appReminder";
}

final class AppReminderCodec extends Codec<AppReminderConfig, JsonMap> {
  const AppReminderCodec();

  @override
  Converter<JsonMap, AppReminderConfig> get decoder => const _Decoder();

  @override
  Converter<AppReminderConfig, JsonMap> get encoder => const _Encoder();
}

final class _Decoder extends Converter<JsonMap, AppReminderConfig> {
  const _Decoder();

  @override
  AppReminderConfig convert(JsonMap input) => AppReminderConfig.fromJson(input);
}

final class _Encoder extends Converter<AppReminderConfig, JsonMap> {
  const _Encoder();

  @override
  JsonMap convert(AppReminderConfig input) => input.toJson();
}

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
import '../../../logging/helper.dart';
import '../../../models/custom_date_format.dart';
import '../profile_helper.dart';

final class ShowDateFormatProfileHandler
    extends ProfileHelperCovertToJsonHandler<CustomDateYmdHmsConfig> {
  const ShowDateFormatProfileHandler(super.pref)
      : super(codec: const ShowDateFormatCodec());

  @override
  String get key => "customDateYmdHmsConfig";
}

final class ShowDateFormatCodec extends Codec<CustomDateYmdHmsConfig, JsonMap> {
  const ShowDateFormatCodec();

  @override
  Converter<JsonMap, CustomDateYmdHmsConfig> get decoder => const _Decoder();

  @override
  Converter<CustomDateYmdHmsConfig, JsonMap> get encoder => const _Encoder();
}

final class _Decoder extends Converter<JsonMap, CustomDateYmdHmsConfig> {
  const _Decoder();

  @override
  CustomDateYmdHmsConfig convert(JsonMap input) {
    try {
      return CustomDateYmdHmsConfig.fromJson(input);
    } catch (e) {
      appLog.load.warn("ShowDateFormatCodec.$runtimeType",
          ex: ["format err"], error: e);
      return const CustomDateYmdHmsConfig.withDefault();
    }
  }
}

final class _Encoder extends Converter<CustomDateYmdHmsConfig, JsonMap> {
  const _Encoder();

  @override
  JsonMap convert(CustomDateYmdHmsConfig input) => input.toJson();
}

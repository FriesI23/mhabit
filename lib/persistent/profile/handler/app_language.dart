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

import 'package:flutter/material.dart';

import '../../../common/types.dart';
import '../profile_helper.dart';

class AppLanguageProfileHanlder
    extends ProfileHelperCovertToJsonHandler<Locale> {
  AppLanguageProfileHanlder(super.pref,
      {super.codec = const AppLanguageProfileCodec()});

  @override
  String get key => "appLocale";
}

final class AppLanguageProfileCodec extends Codec<Locale, JsonMap> {
  const AppLanguageProfileCodec();

  @override
  Converter<JsonMap, Locale> get decoder => const _Decoder();

  @override
  Converter<Locale, JsonMap> get encoder => const _Encoder();
}

final class _Decoder extends Converter<JsonMap, Locale> {
  const _Decoder();

  @override
  Locale convert(JsonMap input) => Locale.fromSubtags(
        languageCode: input["lc"],
        countryCode: input["cc"],
        scriptCode: input["sc"],
      );
}

final class _Encoder extends Converter<Locale, JsonMap> {
  const _Encoder();

  @override
  JsonMap convert(Locale input) => {
        "lc": input.languageCode,
        "cc": input.countryCode,
        "sc": input.scriptCode,
      };
}

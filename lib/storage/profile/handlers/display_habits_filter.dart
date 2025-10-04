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
import '../../../models/habit_display.dart';
import '../profile_helper.dart';

final class DisplayHabitsFilterProfileHandler
    extends ProfileHelperCovertToJsonHandler<HabitsDisplayFilter> {
  const DisplayHabitsFilterProfileHandler(super.pref)
      : super(codec: const DisplayHabitsFilterCodec());

  @override
  String get key => "habitDisplayFilter";
}

final class DisplayHabitsFilterCodec
    extends Codec<HabitsDisplayFilter, JsonMap> {
  const DisplayHabitsFilterCodec();

  @override
  Converter<JsonMap, HabitsDisplayFilter> get decoder => const _Decoder();

  @override
  Converter<HabitsDisplayFilter, JsonMap> get encoder => const _Encoder();
}

final class _Decoder extends Converter<JsonMap, HabitsDisplayFilter> {
  const _Decoder();

  @override
  HabitsDisplayFilter convert(JsonMap input) =>
      HabitsDisplayFilter.fromJson(input);
}

final class _Encoder extends Converter<HabitsDisplayFilter, JsonMap> {
  const _Encoder();

  @override
  JsonMap convert(HabitsDisplayFilter input) => input.toJson();
}

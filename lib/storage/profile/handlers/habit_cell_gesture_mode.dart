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
import '../../../model/habit_display.dart';
import '../profile_helper.dart';

final class HabitCellGestureModeProfileHandler
    extends ProfileHelperCovertToJsonHandler<HabitDisplayOpConfig> {
  HabitCellGestureModeProfileHandler(super.pref)
      : super(codec: const HabitCellGestureModeCodec());

  @override
  String get key => "displayOpConfig";
}

final class HabitCellGestureModeCodec
    extends Codec<HabitDisplayOpConfig, JsonMap> {
  const HabitCellGestureModeCodec();

  @override
  Converter<JsonMap, HabitDisplayOpConfig> get decoder => const _Decoder();

  @override
  Converter<HabitDisplayOpConfig, JsonMap> get encoder => const _Encoder();
}

final class _Decoder extends Converter<JsonMap, HabitDisplayOpConfig> {
  const _Decoder();

  @override
  HabitDisplayOpConfig convert(JsonMap input) =>
      HabitDisplayOpConfig.fromJson(input);
}

final class _Encoder extends Converter<HabitDisplayOpConfig, JsonMap> {
  const _Encoder();

  @override
  JsonMap convert(HabitDisplayOpConfig input) => input.toJson();
}

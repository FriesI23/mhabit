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

import '../../../common/enums.dart';
import '../profile_helper.dart';

final class DisplayCalendarScrollModeProfileHandler
    extends ProfileHelperCovertToIntHandler<HabitsRecordScrollBehavior> {
  const DisplayCalendarScrollModeProfileHandler(super.pref)
    : super(codec: const DisplayCalendarScrollModeCodec());

  @override
  String get key => "habitsRecordScrollBehavior";
}

final class DisplayCalendarScrollModeCodec
    extends Codec<HabitsRecordScrollBehavior, int> {
  const DisplayCalendarScrollModeCodec();

  @override
  Converter<int, HabitsRecordScrollBehavior> get decoder => const _Decoder();

  @override
  Converter<HabitsRecordScrollBehavior, int> get encoder => const _Encoder();
}

final class _Decoder extends Converter<int, HabitsRecordScrollBehavior> {
  const _Decoder();

  @override
  HabitsRecordScrollBehavior convert(int input) =>
      HabitsRecordScrollBehavior.getFromDBCode(
        input,
        withDefault: HabitsRecordScrollBehavior.unknown,
      )!;
}

final class _Encoder extends Converter<HabitsRecordScrollBehavior, int> {
  const _Encoder();

  @override
  int convert(HabitsRecordScrollBehavior input) => input.dbCode;
}

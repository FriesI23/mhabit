// Copyright 2026 Fries_I23
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

import '../../../models/app_adaptive_style_mode.dart';
import '../profile_helper.dart';

final class AdaptiveStyleOverrideProfileHandler
    extends ProfileHelperCovertToIntHandler<AppAdaptiveStyleMode> {
  @override
  String get key => 'adaptiveStyleOverride';

  const AdaptiveStyleOverrideProfileHandler(
    super.pref, {
    super.codec = const AppAdaptiveStyleModeCodec(),
  });
}

final class AppAdaptiveStyleModeCodec extends Codec<AppAdaptiveStyleMode, int> {
  const AppAdaptiveStyleModeCodec();

  @override
  Converter<int, AppAdaptiveStyleMode> get decoder => const _Decoder();

  @override
  Converter<AppAdaptiveStyleMode, int> get encoder => const _Encoder();
}

final class _Decoder extends Converter<int, AppAdaptiveStyleMode> {
  const _Decoder();

  @override
  AppAdaptiveStyleMode convert(int input) =>
      AppAdaptiveStyleMode.fromCode(input);
}

final class _Encoder extends Converter<AppAdaptiveStyleMode, int> {
  const _Encoder();

  @override
  int convert(AppAdaptiveStyleMode input) => input.code;
}

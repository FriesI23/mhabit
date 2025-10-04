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

import '../profile_helper.dart';

final class AppThemeMainColorProfileHandler
    extends ProfileHelperCovertToIntHandler<Color> {
  const AppThemeMainColorProfileHandler(super.pref)
      : super(codec: const AppThemeMainColorProfileCodes());

  @override
  String get key => "sysThemeMainColor";
}

final class AppThemeMainColorProfileCodes extends Codec<Color, int> {
  const AppThemeMainColorProfileCodes();

  @override
  Converter<int, Color> get decoder => const _Decoder();

  @override
  Converter<Color, int> get encoder => const _Encoder();
}

final class _Decoder extends Converter<int, Color> {
  const _Decoder();

  @override
  Color convert(int input) => Color(input);
}

final class _Encoder extends Converter<Color, int> {
  const _Encoder();

  @override
  int convert(Color input) => input.toARGB32();
}

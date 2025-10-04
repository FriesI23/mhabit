// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import '../../models/habit_form.dart';
import '../color.dart';
import 'custom_color.g.dart';

final cc1Palette = CorePalette.of(cc1.toARGB32());
final cc2Palette = CorePalette.of(cc2.toARGB32());
final cc3Palette = CorePalette.of(cc3.toARGB32());
final cc4Palette = CorePalette.of(cc4.toARGB32());
final cc5Palette = CorePalette.of(cc5.toARGB32());
final cc6Palette = CorePalette.of(cc6.toARGB32());
final cc7Palette = CorePalette.of(cc7.toARGB32());
final cc8Palette = CorePalette.of(cc8.toARGB32());
final cc9Palette = CorePalette.of(cc9.toARGB32());
final cc10Palette = CorePalette.of(cc10.toARGB32());

final modifedLightCustomColors = lightCustomColors.copyWith(
  cc1: genHabitColorPrimaryLight(HabitColorType.cc1),
  cc2: genHabitColorPrimaryLight(HabitColorType.cc2),
  cc3: genHabitColorPrimaryLight(HabitColorType.cc3),
  cc4: genHabitColorPrimaryLight(HabitColorType.cc4),
  cc5: genHabitColorPrimaryLight(HabitColorType.cc5),
  cc6: genHabitColorPrimaryLight(HabitColorType.cc6),
  cc7: genHabitColorPrimaryLight(HabitColorType.cc7),
  cc8: genHabitColorPrimaryLight(HabitColorType.cc8),
  cc9: genHabitColorPrimaryLight(HabitColorType.cc9),
  cc10: genHabitColorPrimaryLight(HabitColorType.cc10),
);

CorePalette getHabitPalette(HabitColorType colorType) {
  switch (colorType) {
    case HabitColorType.cc1:
      return cc1Palette;
    case HabitColorType.cc2:
      return cc2Palette;
    case HabitColorType.cc3:
      return cc3Palette;
    case HabitColorType.cc4:
      return cc4Palette;
    case HabitColorType.cc5:
      return cc5Palette;
    case HabitColorType.cc6:
      return cc6Palette;
    case HabitColorType.cc7:
      return cc7Palette;
    case HabitColorType.cc8:
      return cc8Palette;
    case HabitColorType.cc9:
      return cc9Palette;
    case HabitColorType.cc10:
      return cc10Palette;
  }
}

Color genHabitColorPrimaryLight(HabitColorType colorType) =>
    Color(getHabitPalette(colorType).primary.get(60));

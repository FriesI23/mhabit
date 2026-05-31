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

import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_color_utilities/palettes/core_palettes.dart';

import '../../models/habit_form.dart';
import '../color.dart';
import 'custom_color.g.dart';

const _lightHabitPrimaryMinChroma = 48.0;
const _lightHabitPrimaryTone = 56;

CorePalettes buildCorePalettes(Color color) {
  final sourceColor = Hct.fromInt(color.toARGB32());
  final scheme = SchemeTonalSpot(
    sourceColorHct: sourceColor,
    isDark: false,
    contrastLevel: 0,
  );
  return CorePalettes(
    TonalPalette.of(
      sourceColor.hue,
      math.max(_lightHabitPrimaryMinChroma, sourceColor.chroma),
    ),
    scheme.secondaryPalette,
    scheme.tertiaryPalette,
    scheme.neutralPalette,
    scheme.neutralVariantPalette,
  );
}

final cc1Palette = buildCorePalettes(cc1);
final cc2Palette = buildCorePalettes(cc2);
final cc3Palette = buildCorePalettes(cc3);
final cc4Palette = buildCorePalettes(cc4);
final cc5Palette = buildCorePalettes(cc5);
final cc6Palette = buildCorePalettes(cc6);
final cc7Palette = buildCorePalettes(cc7);
final cc8Palette = buildCorePalettes(cc8);
final cc9Palette = buildCorePalettes(cc9);
final cc10Palette = buildCorePalettes(cc10);

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

CorePalettes getHabitPalette(HabitColorType colorType) {
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
    Color(getHabitPalette(colorType).primary.get(_lightHabitPrimaryTone));

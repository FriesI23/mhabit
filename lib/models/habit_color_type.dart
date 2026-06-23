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

import 'package:json_annotation/json_annotation.dart';

import '../common/enums.dart';
import '../l10n/localizations.dart';

/// Split into its own file (re-exported by `habit_form.dart`) so
/// `habit_color.dart` can depend on the built-in color enum without also
/// depending on `habit_form.dart`, which itself depends on `HabitColor` for
/// `HabitForm.color`. Keeping both in `habit_form.dart` made that a circular
/// import between the two model files.
@JsonEnum(valueField: 'code')
enum HabitColorType implements EnumWithDBCode<HabitColorType> {
  cc1(code: 1),
  cc2(code: 2),
  cc3(code: 3),
  cc4(code: 4),
  cc5(code: 5),
  cc6(code: 6),
  cc7(code: 7),
  cc8(code: 8),
  cc9(code: 9),
  cc10(code: 10);

  final int code;

  const HabitColorType({required this.code});

  @override
  int get dbCode => code;

  static HabitColorType? getFromDBCode(
    int dbCode, {
    HabitColorType? withDefault = HabitColorType.cc1,
  }) => HabitColorType.values.byDBCode(dbCode, withDefault: withDefault);

  static String getColorName(HabitColorType colorType, L10n? l10n) {
    final fallbackColorName = 'Color ${colorType.code}';
    return switch (colorType) {
      HabitColorType.cc1 =>
        l10n?.common_habitColorType_cc1 ?? fallbackColorName,
      HabitColorType.cc2 =>
        l10n?.common_habitColorType_cc2 ?? fallbackColorName,
      HabitColorType.cc3 =>
        l10n?.common_habitColorType_cc3 ?? fallbackColorName,
      HabitColorType.cc4 =>
        l10n?.common_habitColorType_cc4 ?? fallbackColorName,
      HabitColorType.cc5 =>
        l10n?.common_habitColorType_cc5 ?? fallbackColorName,
      HabitColorType.cc6 =>
        l10n?.common_habitColorType_cc6 ?? fallbackColorName,
      HabitColorType.cc7 =>
        l10n?.common_habitColorType_cc7 ?? fallbackColorName,
      HabitColorType.cc8 =>
        l10n?.common_habitColorType_cc8 ?? fallbackColorName,
      HabitColorType.cc9 =>
        l10n?.common_habitColorType_cc9 ?? fallbackColorName,
      HabitColorType.cc10 =>
        l10n?.common_habitColorType_cc10 ?? fallbackColorName,
    };
  }
}

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

import 'consts.dart';
import 'types.dart';

HabitDailyGoal onDailyGoalTextInputChanged(
  num newDailyGoal, {
  required TextEditingController controller,
  num defaultValue = defaultHabitDailyGoal,
  num maxValue = maxHabitdailyGoal,
  bool allowInputZero = false,
}) {
  if (newDailyGoal >= maxValue) {
    controller.text = maxValue.toString();
    controller.selection = TextSelection(
        baseOffset: controller.text.length,
        extentOffset: controller.text.length);
    newDailyGoal = maxValue;
  } else if (newDailyGoal < minHabitDailyGoal) {
    controller.text = '';
    newDailyGoal = defaultHabitDailyGoal;
  } else if (newDailyGoal == minHabitDailyGoal) {
    newDailyGoal = allowInputZero ? newDailyGoal : defaultHabitDailyGoal;
  }
  return newDailyGoal;
}

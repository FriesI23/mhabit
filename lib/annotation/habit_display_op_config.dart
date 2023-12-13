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
import '../model/habit_display.dart';

class HabitDisplayOpConfigConverter
    implements JsonConverter<HabitDisplayOpConfig, List<int>> {
  const HabitDisplayOpConfigConverter();

  @override
  HabitDisplayOpConfig fromJson(List<int> json) {
    return HabitDisplayOpConfig(
      changeRecordStatus: UserAction.getFromDBCode(json[0])!,
      openRecordStatusDialog: UserAction.getFromDBCode(json[1])!,
    );
  }

  @override
  List<int> toJson(HabitDisplayOpConfig object) {
    return [
      object.changeRecordStatus.dbCode,
      object.openRecordStatusDialog.dbCode,
    ];
  }
}

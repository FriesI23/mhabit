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

import '../common/types.dart';
import 'habit_form.dart';

class HabitStatusChangedRecord {
  final HabitUUID habitUUID;
  final HabitStatus newStatus;
  final HabitStatus orgStatus;

  const HabitStatusChangedRecord(
      {required this.habitUUID,
      required this.newStatus,
      required this.orgStatus});

  @override
  String toString() =>
      "$runtimeType(habitUUID=$habitUUID,os=$orgStatus,ns=$newStatus)";
}

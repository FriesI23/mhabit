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

import '../common/consts.dart';
import '../common/types.dart';
import 'habit_form.dart';

abstract interface class HabitDailyGoalContainer {
  HabitType get type;
  HabitDailyGoal get dailyGoal;
  String get dailyGoalUnit;
  HabitDailyGoal? get dailyGoalExtra;

  num get normalizedGoal;
  HabitDailyGoal get defaultDailyGoal;

  bool isGoalValid();

  HabitDailyGoalData transform({required HabitType type});

  factory HabitDailyGoalContainer({
    required HabitType type,
    HabitDailyGoal? dailyGoal,
    String? dailyGoalUnit,
    HabitDailyGoal? dailyGoalExtra,
  }) => HabitDailyGoalData(
    type: type,
    dailyGoal: dailyGoal,
    dailyGoalUnit: dailyGoalUnit,
    dailyGoalExtra: dailyGoalExtra,
  );
}

abstract interface class HabitDailyGoalData implements HabitDailyGoalContainer {
  set dailyGoal(HabitDailyGoal value);
  set dailyGoalUnit(String value);
  set dailyGoalExtra(HabitDailyGoal? value);

  factory HabitDailyGoalData({
    required HabitType type,
    HabitDailyGoal? dailyGoal,
    String? dailyGoalUnit,
    HabitDailyGoal? dailyGoalExtra,
  }) => switch (type) {
    HabitType.normal => PositiveHabitDailyGoalData(
      dailyGoal: dailyGoal,
      dailyGoalUnit: dailyGoalUnit,
      dailyGoalExtra: dailyGoalExtra,
    ),
    HabitType.negative => NegativeHabitDailyGoalData(
      dailyGoal: dailyGoal,
      dailyGoalUnit: dailyGoalUnit,
      dailyGoalExtra: dailyGoalExtra,
    ),
    _ => throw UnsupportedError("Unsupport habit type: $type"),
  };
}

abstract class _BaseHabitDailyGoalData implements HabitDailyGoalData {
  @override
  HabitDailyGoal dailyGoal;
  @override
  String dailyGoalUnit;
  @override
  HabitDailyGoal? dailyGoalExtra;

  _BaseHabitDailyGoalData({
    required this.dailyGoal,
    required this.dailyGoalUnit,
    this.dailyGoalExtra,
  });

  @override
  HabitDailyGoalData transform({required HabitType type}) => switch (type) {
    HabitType.normal => PositiveHabitDailyGoalData(
      dailyGoal: dailyGoal != defaultDailyGoal ? dailyGoal : null,
      dailyGoalUnit: dailyGoalUnit,
      dailyGoalExtra: dailyGoalExtra,
    ),
    HabitType.negative => NegativeHabitDailyGoalData(
      dailyGoal: dailyGoal != defaultDailyGoal ? dailyGoal : null,
      dailyGoalUnit: dailyGoalUnit,
      dailyGoalExtra: dailyGoalExtra,
    ),
    _ => throw UnsupportedError("Unsupport habit type: $type"),
  };
}

final class PositiveHabitDailyGoalData extends _BaseHabitDailyGoalData
    implements HabitDailyGoalData {
  static const _defaultGoal = defaultHabitDailyGoal;

  @override
  final HabitType type = HabitType.normal;
  @override
  HabitDailyGoal defaultDailyGoal = _defaultGoal;

  PositiveHabitDailyGoalData._({
    required super.dailyGoal,
    required super.dailyGoalUnit,
    super.dailyGoalExtra,
  });

  PositiveHabitDailyGoalData({
    HabitDailyGoal? dailyGoal,
    String? dailyGoalUnit,
    HabitDailyGoal? dailyGoalExtra,
  }) : this._(
         dailyGoal: dailyGoal ?? _defaultGoal,
         dailyGoalUnit: dailyGoalUnit ?? defaultHabitDailyGoalUnit,
         dailyGoalExtra: dailyGoalExtra,
       );

  @override
  bool isGoalValid() {
    if (dailyGoal <= minHabitDailyGoal) {
      return false;
    } else if (dailyGoal > maxHabitdailyGoal) {
      return false;
    } else {
      return true;
    }
  }

  @override
  num get normalizedGoal {
    if (dailyGoal <= minHabitDailyGoal) {
      return defaultDailyGoal;
    } else if (dailyGoal > maxHabitdailyGoal) {
      return maxHabitdailyGoal;
    } else {
      return dailyGoal;
    }
  }

  @override
  HabitDailyGoalData transform({required HabitType type}) => switch (type) {
    final newType when newType == this.type => this,
    _ => super.transform(type: type),
  };

  @override
  String toString() =>
      "PositiveHabitDailyGoalData(dailyGoal=$dailyGoal,"
      "dailyGoalUnit=$dailyGoalUnit,dailyGoalExtra=$dailyGoalExtra"
      ")";
}

final class NegativeHabitDailyGoalData extends _BaseHabitDailyGoalData
    implements HabitDailyGoalData {
  static const _defaultGoal = defaultNegativeHabitDailyGoal;

  @override
  final HabitType type = HabitType.negative;
  @override
  HabitDailyGoal defaultDailyGoal = _defaultGoal;

  NegativeHabitDailyGoalData._({
    required super.dailyGoal,
    required super.dailyGoalUnit,
    super.dailyGoalExtra,
  });

  NegativeHabitDailyGoalData({
    HabitDailyGoal? dailyGoal,
    String? dailyGoalUnit,
    HabitDailyGoal? dailyGoalExtra,
  }) : this._(
         dailyGoal: dailyGoal ?? _defaultGoal,
         dailyGoalUnit: dailyGoalUnit ?? defaultHabitDailyGoalUnit,
         dailyGoalExtra: dailyGoalExtra,
       );

  @override
  bool isGoalValid() {
    if (dailyGoal < minHabitDailyGoal) {
      return false;
    } else if (dailyGoal > maxHabitdailyGoal) {
      return false;
    } else {
      return true;
    }
  }

  @override
  num get normalizedGoal {
    if (dailyGoal < minHabitDailyGoal) {
      return defaultDailyGoal;
    } else if (dailyGoal > maxHabitdailyGoal) {
      return maxHabitdailyGoal;
    } else {
      return dailyGoal;
    }
  }

  @override
  HabitDailyGoalData transform({required HabitType type}) => switch (type) {
    final newType when newType == this.type => this,
    _ => super.transform(type: type),
  };

  @override
  String toString() =>
      "NegativeHabitDailyGoalData(dailyGoal=$dailyGoal,"
      "dailyGoalUnit=$dailyGoalUnit,dailyGoalExtra=$dailyGoalExtra"
      ")";
}

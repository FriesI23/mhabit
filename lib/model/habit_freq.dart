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

import 'package:quiver/core.dart';

import '../common/exceptions.dart';
import '../l10n/localizations.dart';
import 'habit_form.dart';

class HabitFrequency {
  static const daily =
      HabitFrequency(type: HabitFrequencyType.custom, freq: 1, days: 1);

  final HabitFrequencyType type;
  final int freq;
  final int days;

  const HabitFrequency({required this.type, required this.freq, this.days = 0});

  const HabitFrequency.weekly({this.freq = 1})
      : type = HabitFrequencyType.weekly,
        days = 0;

  const HabitFrequency.monthly({this.freq = 1})
      : type = HabitFrequencyType.monthly,
        days = 0;

  factory HabitFrequency.custom({int days = 1, int freq = 1}) => days == freq
      ? daily
      : HabitFrequency(
          type: HabitFrequencyType.custom,
          freq: math.min(freq, days),
          days: math.max(freq, days));

  bool get isDaily {
    switch (type) {
      case HabitFrequencyType.unknown:
        return false;
      case HabitFrequencyType.weekly:
        return freq >= 7;
      case HabitFrequencyType.monthly:
        return freq >= 31;
      case HabitFrequencyType.custom:
        return freq == days;
    }
  }

  static HabitFrequency fromMap(Map<String, dynamic> data) {
    final type = HabitFrequencyType.getFromDBCode(data["type"])!;
    switch (type) {
      case HabitFrequencyType.weekly:
        return HabitFrequency.weekly(freq: data["args"][0]);
      case HabitFrequencyType.monthly:
        return HabitFrequency.monthly(freq: data["args"][0]);
      case HabitFrequencyType.custom:
        return HabitFrequency(
            type: type, freq: data["args"][0], days: data["args"][1]);
      default:
        throw UnknownHabitFrequencyError();
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {"type": type.dbCode};
    switch (type) {
      case HabitFrequencyType.weekly:
        result["args"] = [freq];
        break;
      case HabitFrequencyType.monthly:
        result["args"] = [freq];
        break;
      case HabitFrequencyType.custom:
        result["args"] = [freq, days];
        break;
      default:
        throw UnknownHabitFrequencyError();
    }
    return result;
  }

  String toLocalString(L10n l10n) {
    switch (type) {
      case HabitFrequencyType.unknown:
        return '';
      case HabitFrequencyType.weekly:
        return l10n.habitEdit_habitFreq_show_perweek(freq);
      case HabitFrequencyType.monthly:
        return l10n.habitEdit_habitFreq_show_permonth(freq);
      case HabitFrequencyType.custom:
        if (freq == days) {
          return l10n.habitEdit_habitFreq_show_daily;
        } else {
          return l10n.habitEdit_habitFreq_show_perdayfreq(freq, days);
        }
    }
  }

  @override
  String toString() {
    switch (type) {
      case HabitFrequencyType.weekly:
        if (freq == 1) {
          return "Per week";
        } else {
          return "At least $freq times per week";
        }
      case HabitFrequencyType.monthly:
        if (freq == 1) {
          return "Per month";
        } else {
          return "At least $freq times per month";
        }
      case HabitFrequencyType.custom:
        if (freq == 1 && days == 1) {
          return "Daily";
        } else if (freq == 1) {
          return "In every $days days";
        } else {
          return "At least $freq times in every $days days";
        }
      default:
        return "";
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! HabitFrequency) {
      return false;
    }
    if (type != other.type) {
      return false;
    }
    if (type == HabitFrequencyType.custom) {
      return freq == other.freq && days == other.days;
    } else {
      return freq == other.freq;
    }
  }

  @override
  int get hashCode {
    if (type == HabitFrequencyType.custom) {
      return hash3(type, freq, days);
    } else {
      return hash2(type, freq);
    }
  }
}

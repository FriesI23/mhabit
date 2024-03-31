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

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';

import '../annotation/_json_annotation.dart';
import '../common/enums.dart';
import 'common.dart';

part 'app_reminder_config.g.dart';

@JsonEnum(valueField: "code")
enum AppReminderConfigType implements EnumWithDBCodeABC<AppReminderConfigType> {
  daily(code: 1);

  final int code;

  const AppReminderConfigType({required this.code});

  @override
  int get dbCode => code;
}

@JsonSerializable()
@CopyWith(skipFields: true, copyWithNull: false)
class AppReminderConfig implements JsonAdaptor {
  static const off = AppReminderConfig(
    enabled: false,
    type: AppReminderConfigType.daily,
    timeOfDay: TimeOfDay(hour: 21, minute: 30),
  );
  static const dailyNight =
      AppReminderConfig.daily(timeOfDay: TimeOfDay(hour: 21, minute: 30));

  final bool enabled;
  final AppReminderConfigType type;
  @TimeOfDayConverter()
  final TimeOfDay? timeOfDay;

  const AppReminderConfig({
    required this.enabled,
    required this.type,
    required this.timeOfDay,
  });

  const AppReminderConfig.daily({required this.timeOfDay})
      : enabled = true,
        type = AppReminderConfigType.daily;

  factory AppReminderConfig.fromJson(Map<String, dynamic> json) =>
      _$AppReminderConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AppReminderConfigToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppReminderConfig) return false;
    if (other.enabled != enabled) return false;
    if (other.type != type) return false;
    switch (type) {
      case AppReminderConfigType.daily:
        return other.timeOfDay == timeOfDay;
    }
  }

  @override
  int get hashCode =>
      hash3(enabled.hashCode, type.hashCode, timeOfDay.hashCode);

  @override
  String toString() {
    return "$runtimeType(${toJson()})";
  }
}

// Copyright 2025 Fries_I23
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

import 'package:json_annotation/json_annotation.dart';

import '../common/enums.dart';
import '../common/types.dart';
import 'common.dart';
import 'habit_form.dart';

part 'app_theme_color.g.dart';

@JsonEnum(valueField: "code")
enum AppThemeColorType implements EnumWithDBCode {
  system(code: 1),
  primary(code: 2),
  dynamic(code: 3),
  internal(code: 4);

  final int code;

  const AppThemeColorType({required this.code});

  @override
  int get dbCode => code;

  static AppThemeColorType? getFromDBCode(int dbCode) {
    for (var value in AppThemeColorType.values) {
      if (value.dbCode == dbCode) return value;
    }
    return null;
  }
}

abstract interface class AppThemeColor implements JsonAdaptor {
  factory AppThemeColor.fromJson(JsonMap json) {
    final type = AppThemeColorType.getFromDBCode(json['type']);

    switch (type) {
      case AppThemeColorType.system:
        return SystemAppThemeColor.fromJson(json);
      case AppThemeColorType.primary:
        return PrimaryAppThemeColor.fromJson(json);
      case AppThemeColorType.dynamic:
        return DynamicAppThemeColor.fromJson(json);
      case AppThemeColorType.internal:
        return InternalAppThemeColor.fromJson(json);
      case null:
        throw UnsupportedError("Unsupport app theme color $json");
    }
  }
}

abstract class _BaseAppThemeColor implements AppThemeColor {
  @JsonKey(includeToJson: true)
  final AppThemeColorType type;

  const _BaseAppThemeColor({required this.type});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _BaseAppThemeColor &&
            runtimeType == other.runtimeType &&
            type == other.type;
  }

  @override
  int get hashCode => type.hashCode;
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class SystemAppThemeColor extends _BaseAppThemeColor {
  const SystemAppThemeColor() : super(type: AppThemeColorType.system);

  factory SystemAppThemeColor.fromJson(JsonMap json) =>
      _$SystemAppThemeColorFromJson(json);

  @override
  JsonMap toJson() => _$SystemAppThemeColorToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class PrimaryAppThemeColor extends _BaseAppThemeColor {
  const PrimaryAppThemeColor() : super(type: AppThemeColorType.primary);

  factory PrimaryAppThemeColor.fromJson(JsonMap json) =>
      _$PrimaryAppThemeColorFromJson(json);

  @override
  JsonMap toJson() => _$PrimaryAppThemeColorToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class DynamicAppThemeColor extends _BaseAppThemeColor {
  const DynamicAppThemeColor() : super(type: AppThemeColorType.dynamic);

  factory DynamicAppThemeColor.fromJson(JsonMap json) =>
      _$DynamicAppThemeColorFromJson(json);

  @override
  JsonMap toJson() => _$DynamicAppThemeColorToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class InternalAppThemeColor extends _BaseAppThemeColor {
  final HabitColorType colorType;

  const InternalAppThemeColor({required this.colorType})
      : super(type: AppThemeColorType.internal);

  factory InternalAppThemeColor.fromJson(JsonMap json) =>
      _$InternalAppThemeColorFromJson(json);

  @override
  JsonMap toJson() => _$InternalAppThemeColorToJson(this);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is InternalAppThemeColor &&
            runtimeType == other.runtimeType &&
            type == other.type &&
            colorType == other.colorType;
  }

  @override
  int get hashCode => Object.hash(type, colorType);
}

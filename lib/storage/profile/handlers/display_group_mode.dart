// Copyright 2026 Fries_I23
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

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/habit_display.dart';
import '../../../models/habit_group_display.dart';
import '../profile_helper.dart';

typedef DisplayGroupModeOption = (
  HabitDisplayGroupType?,
  HabitDisplaySortDirection?,
);

final class DisplayGroupModeProfileHandler
    extends ProfileHelperConvertHandler<DisplayGroupModeOption, List> {
  final SharedPreferences _pref;

  const DisplayGroupModeProfileHandler(SharedPreferences pref)
    : _pref = pref,
      super(codec: const DisplayGroupModeCodec());

  @override
  String get key => "habitDisplayGroupMode";

  HabitDisplayGroupType? get groupType => get()?.$1;
  HabitDisplaySortDirection? get groupDirection => get()?.$2;

  List? _getMethod(String key) {
    final source = _pref.getString(key);
    return source != null ? jsonDecode(source) : null;
  }

  @override
  List? Function(String key) get getMethod => _getMethod;

  Future<bool> _setMethod(String key, List value) =>
      _pref.setString(key, jsonEncode(value));

  @override
  Future<bool> Function(String key, List value) get setMethod => _setMethod;

  @override
  Future<bool> remove() => _pref.remove(key);
}

final class DisplayGroupModeCodec extends Codec<DisplayGroupModeOption, List> {
  const DisplayGroupModeCodec();

  @override
  Converter<List, DisplayGroupModeOption> get decoder => const _Decoder();

  @override
  Converter<DisplayGroupModeOption, List> get encoder => const _Encoder();
}

final class _Decoder extends Converter<List, DisplayGroupModeOption> {
  const _Decoder();

  @override
  DisplayGroupModeOption convert(List input) => (
    ((input[0] as int?) != null)
        ? HabitDisplayGroupType.getFromDBCode(input[0])
        : null,
    ((input[1] as int?) != null)
        ? HabitDisplaySortDirection.getFromDBCode(input[1])
        : null,
  );
}

final class _Encoder extends Converter<DisplayGroupModeOption, List> {
  const _Encoder();

  @override
  List convert(DisplayGroupModeOption input) => [
    input.$1?.dbCode,
    input.$2?.dbCode,
  ];
}

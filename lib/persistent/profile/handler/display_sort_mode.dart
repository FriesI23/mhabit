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

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import '../../../model/habit_display.dart';
import '../profile_helper.dart';

final class DisplaySortModeProfileHandler extends ProfileHelperConvertHandler<
    Tuple2<HabitDisplaySortType?, HabitDisplaySortDirection?>, List> {
  final SharedPreferences _pref;

  const DisplaySortModeProfileHandler(SharedPreferences pref)
      : _pref = pref,
        super(codec: const DisplaySortModeCodec());

  @override
  String get key => "habitSortMode";

  HabitDisplaySortType? get sortType => get()?.item1;
  HabitDisplaySortDirection? get sortDirection => get()?.item2;

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
}

final class DisplaySortModeCodec extends Codec<
    Tuple2<HabitDisplaySortType?, HabitDisplaySortDirection?>, List> {
  const DisplaySortModeCodec();

  @override
  Converter<List, Tuple2<HabitDisplaySortType?, HabitDisplaySortDirection?>>
      get decoder => const _Decoder();

  @override
  Converter<Tuple2<HabitDisplaySortType?, HabitDisplaySortDirection?>, List>
      get encoder => const _Encoder();
}

final class _Decoder extends Converter<List,
    Tuple2<HabitDisplaySortType?, HabitDisplaySortDirection?>> {
  const _Decoder();

  @override
  Tuple2<HabitDisplaySortType?, HabitDisplaySortDirection?> convert(
          List input) =>
      Tuple2(
        ((input[0] as int?) != null)
            ? HabitDisplaySortType.getFromDBCode(input[0])
            : null,
        ((input[1] as int?) != null)
            ? HabitDisplaySortDirection.getFromDBCode(input[1])
            : null,
      );
}

final class _Encoder extends Converter<
    Tuple2<HabitDisplaySortType?, HabitDisplaySortDirection?>, List> {
  const _Encoder();

  @override
  List convert(
          Tuple2<HabitDisplaySortType?, HabitDisplaySortDirection?> input) =>
      [input.item1?.dbCode, input.item2?.dbCode];
}

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

import '../../../models/habit_color.dart';
import '../profile_helper.dart';

/// Persists the locally most-recently-used custom (non-built-in) colors,
/// including each one's [CustomHabitColor.tinted] state. MRU ordering and
/// the 20-entry cap are enforced by [CustomColorHistoryViewModel], not here —
/// this handler only stores and retrieves whatever list it is given, same
/// division of responsibility as every other [ProfileHelperHandler].
final class CustomColorHistoryProfileHandler
    implements ProfileHelperHandler<List<CustomHabitColor>> {
  final SharedPreferences _pref;

  const CustomColorHistoryProfileHandler(SharedPreferences pref) : _pref = pref;

  @override
  String get key => "customColorHistory";

  @override
  List<CustomHabitColor>? get() {
    final source = _pref.getString(key);
    if (source == null) return null;
    return (jsonDecode(source) as List)
        .map(
          (e) => CustomHabitColor(
            (e as Map)['argb'] as int,
            tinted: e['tinted'] as bool? ?? true,
          ),
        )
        .toList();
  }

  @override
  Future<bool> set(List<CustomHabitColor> value) => _pref.setString(
    key,
    jsonEncode([
      for (final c in value) {'argb': c.argb, 'tinted': c.tinted},
    ]),
  );

  @override
  Future<bool> remove() => _pref.remove(key);
}

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

import '../common/logging.dart';
import '../model/habit_date.dart';
import 'commons.dart';

class HabitDateChangeNotifier extends ChangeNotifier
    implements ProviderMounted {
  late HabitDate _dateTime;
  late String _tzName;
  bool _mounted = true;

  HabitDateChangeNotifier({HabitDate? dateTime, String? timezoneName}) {
    final now = DateTime.now();
    _dateTime = dateTime ?? HabitDate.dateTime(now);
    _tzName = timezoneName ?? now.timeZoneName;
  }

  HabitDate get dateTime => _dateTime;

  set dateTime(HabitDate dateTime) {
    if (dateTime != _dateTime) {
      InfoLog.setValue("date change: $_dateTime -> $dateTime");
      _dateTime = dateTime;
      notifyListeners();
    }
  }

  String get tzName => _tzName;

  set tzName(String tzName) {
    if (tzName != _tzName) {
      InfoLog.setValue("timezone change: $_tzName -> $tzName");
      _tzName = tzName;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (!_mounted) return;
    _mounted = false;
    super.dispose();
  }

  @override
  bool get mounted => _mounted;
}

class HabitDateChangeProvider
    extends InheritedNotifier<HabitDateChangeNotifier> {
  static final _fallback = HabitDateChangeNotifier();

  final HabitDateChangeNotifier dateTimeNotifier;

  const HabitDateChangeProvider({
    super.key,
    required this.dateTimeNotifier,
    required super.child,
  }) : super(notifier: dateTimeNotifier);

  static HabitDateChangeNotifier? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<HabitDateChangeProvider>()
        ?.dateTimeNotifier;
  }

  static HabitDateChangeNotifier of(BuildContext context) {
    return maybeOf(context) ?? _fallback;
  }
}

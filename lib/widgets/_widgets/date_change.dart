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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logging/helper.dart';
import '../../models/habit_date.dart';
import '../../providers/commons.dart';
import '../../utils/app_clock.dart';
import '../../utils/local_timezone.dart';

class DateChangeNotifier extends ChangeNotifier implements ProviderMounted {
  late HabitDate _dateTime;
  late String _tzName;
  bool _mounted = true;

  DateChangeNotifier({HabitDate? dateTime, String? timezoneName}) {
    final now = AppClock().now();
    _dateTime = dateTime ?? HabitDate.dateTime(now);
    _tzName = timezoneName ?? now.timeZoneName;
  }

  HabitDate get dateTime => _dateTime;

  set dateTime(HabitDate dateTime) {
    if (dateTime != _dateTime) {
      appLog.value.info("$runtimeType.dateTime",
          beforeVal: _dateTime, afterVal: dateTime);
      _dateTime = dateTime;
      notifyListeners();
    }
  }

  String get tzName => _tzName;

  set tzName(String tzName) {
    if (tzName != _tzName) {
      appLog.value
          .info("$runtimeType.tzName", beforeVal: _tzName, afterVal: tzName);
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

class DateChangeProvider extends InheritedNotifier<DateChangeNotifier> {
  static final _fallback = DateChangeNotifier();

  final DateChangeNotifier dateTimeNotifier;

  const DateChangeProvider({
    super.key,
    required this.dateTimeNotifier,
    required super.child,
  }) : super(notifier: dateTimeNotifier);

  static DateChangeNotifier? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DateChangeProvider>()
        ?.dateTimeNotifier;
  }

  static DateChangeNotifier of(BuildContext context) {
    return maybeOf(context) ?? _fallback;
  }
}

class DateChangeBuilder extends StatefulWidget {
  final Duration interval;
  final WidgetBuilder builder;

  const DateChangeBuilder({
    super.key,
    required this.interval,
    required this.builder,
  });

  @override
  State<StatefulWidget> createState() => _DateChangeBuilder();
}

class _DateChangeBuilder extends State<DateChangeBuilder> {
  late final Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(widget.interval, (timer) async {
      if (!changeNotifer.mounted) return;
      final now = AppClock().now();
      // datetime
      final crtDate = HabitDate.dateTime(now);
      if (changeNotifer.dateTime != crtDate) changeNotifer.dateTime = crtDate;
      // timezone
      final tzName = now.timeZoneName;
      if (changeNotifer.tzName != tzName) {
        changeNotifer.tzName = tzName;
        await LocalTimeZoneManager().updateTimeZone();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  DateChangeNotifier get changeNotifer => context.read<DateChangeNotifier>();

  @override
  Widget build(BuildContext context) {
    return DateChangeProvider(
      dateTimeNotifier: changeNotifer,
      child: Builder(builder: widget.builder),
    );
  }
}

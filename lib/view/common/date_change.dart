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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/utils.dart';
import '../../model/habit_date.dart';
import '../../provider/habit_date_change.dart';

class HabitDateChangeBuilder extends StatefulWidget {
  final Duration interval;
  final WidgetBuilder builder;

  const HabitDateChangeBuilder({
    super.key,
    this.interval = const Duration(seconds: 1),
    required this.builder,
  });

  @override
  State<StatefulWidget> createState() => _HabitDateChangeBuilder();
}

class _HabitDateChangeBuilder extends State<HabitDateChangeBuilder> {
  late final Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(widget.interval, (timer) async {
      if (!changeNotifer.mounted) return;
      final now = DateTime.now();
      // datetime
      final crtDate = HabitDate.dateTime(now);
      if (changeNotifer.dateTime != crtDate) changeNotifer.dateTime = crtDate;
      // timezone
      final tzName = now.timeZoneName;
      if (changeNotifer.tzName != tzName) {
        changeNotifer.tzName = tzName;
        await configureLocalTimeZone();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  HabitDateChangeNotifier get changeNotifer =>
      context.read<HabitDateChangeNotifier>();

  @override
  Widget build(BuildContext context) {
    return HabitDateChangeProvider(
      dateTimeNotifier: changeNotifer,
      child: Builder(builder: widget.builder),
    );
  }
}

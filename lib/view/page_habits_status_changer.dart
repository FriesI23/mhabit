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

import 'package:flutter/material.dart';

import '../model/habit_summary.dart';
import '../provider/habit_status_changer.dart';
import 'for_habits_status_changer/page_providers.dart';

class PageHabitsStatusChanger extends StatelessWidget {
  final List<HabitSummaryData> dataList;

  const PageHabitsStatusChanger({super.key, required this.dataList});

  @override
  Widget build(BuildContext context) => PageProviders(
        dataList: dataList,
        child: const HabitsStatusChangerView(),
      );
}

class HabitsStatusChangerView extends StatefulWidget {
  const HabitsStatusChangerView({super.key});

  @override
  State<StatefulWidget> createState() => _HabitsStatusChangerView();
}

class _HabitsStatusChangerView extends State<HabitsStatusChangerView> {
  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: IconButton(
        icon: Icon(Icons.abc_outlined),
        onPressed: () => Navigator.of(context)
            .pop(PageHabitsStatusChangerResult.fromNum(10)),
      ),
    );
  }
}

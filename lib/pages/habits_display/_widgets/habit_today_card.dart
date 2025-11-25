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

import 'package:flutter/material.dart';

import '../../../models/habit_summary.dart';

class HabitTodayCard extends StatelessWidget {
  final HabitSummaryData? testData;

  const HabitTodayCard({super.key, this.testData});

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: ListTile(
        isThreeLine: true,
        title: Text(testData?.name ?? "<NOT FOUND>"),
        subtitle: Text(testData.toString()),
      ),
    );
  }
}

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
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '../../common/types.dart';
import '../../providers/app_first_day.dart';
import '../../providers/habit_status_changer.dart';
import '../../providers/habits_manager.dart';
import '../../widgets/provider.dart';

class PageProviders extends SingleChildStatelessWidget {
  final List<HabitUUID> uuidList;

  const PageProviders({super.key, super.child, required this.uuidList});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
    providers: [
      ChangeNotifierProvider<HabitStatusChangerViewModel>(
        create: (context) => HabitStatusChangerViewModel(uuidList: uuidList),
      ),
      ViewModelProxyProvider<HabitsManager, HabitStatusChangerViewModel>(
        update: (context, value, previous) =>
            previous..updateHabitManager(value),
      ),
      ViewModelProxyProvider<AppFirstDayViewModel, HabitStatusChangerViewModel>(
        update: (context, value, previous) =>
            previous..updateFirstday(value.firstDay),
        post: (t, value, vm) =>
            value.firstDay != vm.firstday ? vm.requestReloadData() : null,
      ),
    ],
    child: child,
  );
}

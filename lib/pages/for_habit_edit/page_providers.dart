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

import '../../model/habit_form.dart';
import '../../persistent/db_helper_provider.dart';
import '../../provider/habit_form.dart';

class PageProviders extends SingleChildStatelessWidget {
  final HabitForm? initForm;

  const PageProviders({super.key, super.child, this.initForm});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => HabitFormViewModel(
              initForm: initForm,
              appbarScrollController: ScrollController(),
              nameFieldInputController: TextEditingController(),
              dailyGoalFieldInputController: TextEditingController(),
              dailyGoalUnitFieldInputController: TextEditingController(),
              dailyGoalExtraFieldInpuController: TextEditingController(),
              descFieldInputController: TextEditingController(),
            ),
          ),
          ChangeNotifierProxyProvider<DBHelperViewModel, HabitFormViewModel>(
            create: (context) => context.read<HabitFormViewModel>(),
            update: (context, value, previous) =>
                previous!..updateDBHelper(value),
          ),
        ],
        child: child,
      );
}

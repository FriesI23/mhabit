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

import '../../models/habit_form.dart';
import '../../providers/workflow/app_event.dart';
import '../../providers/workflow/app_sync.dart';
import '../../providers/workflow/group_manager.dart';
import '../../providers/workflow/habits_manager.dart';
import '../../widgets/provider.dart';
import '_providers/habit_form.dart';

class PageProviders extends SingleChildStatelessWidget {
  final HabitForm? initForm;

  const PageProviders({super.key, super.child, this.initForm});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => HabitFormViewModel(initForm: initForm),
      ),
      ViewModelProxyProvider<HabitFormAccess, HabitFormViewModel>(
        update: (context, value, previous) => previous..attachAccess(value),
      ),
      ViewModelProxyProvider<AppEventBus, HabitFormViewModel>(
        update: (context, value, previous) => previous..updateAppEvent(value),
      ),
      ViewModelProxyProvider<GroupManager, HabitFormViewModel>(
        update: (context, value, previous) =>
            previous..attachGroupManager(value),
        post: (t, _, vm) {
          vm.ensureGroupsLoaded();
        },
      ),
      ViewModelProxyProvider<AppSyncWorkflowAccess, HabitFormViewModel>(
        update: (context, value, previous) =>
            previous..attachSyncWorkflow(value),
      ),
    ],
    child: child,
  );
}

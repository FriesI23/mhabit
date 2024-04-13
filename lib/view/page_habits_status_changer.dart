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
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../model/habit_date.dart';
import '../model/habit_summary.dart';
import '../provider/habit_status_changer.dart';
import '../utils/safe_sliver_tools.dart';
import 'for_habits_status_changer/_widget.dart';

/// Depend Providers
/// - Required for builder:
/// - Required for callback:
/// - Optional:
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

Widget _buildDebugInfo(BuildContext context) =>
    Consumer<HabitStatusChangerViewModel>(
      builder: (context, value, child) => ListTile(
        leading: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
        isThreeLine: true,
        title: const Text('DEBUG'),
        subtitle: Column(
          children: [
            Text(context.read<HabitStatusChangerViewModel>().toString()),
            Text(context
                .read<HabitStatusChangerViewModel>()
                .selectDateAllowedStatus
                .toString()),
          ],
        ),
      ),
    );

class _HabitsStatusChangerView extends State<HabitsStatusChangerView> {
  void _onSelectedDateChanged(HabitDate od, HabitDate nd) {
    if (!mounted) return;
    final vm = context.read<HabitStatusChangerViewModel>();
    if (!vm.mounted) return;
    vm.updateSelectDate(nd);
  }

  void _onSelectedStatusChanged(
      RecordStatusChangerStatus? od, RecordStatusChangerStatus? nd) {
    if (!mounted) return;
    final vm = context.read<HabitStatusChangerViewModel>();
    if (!vm.mounted) return;
    vm.updateSelectStatus(nd);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildDatePickerTile(BuildContext context) {
      final vm = context.read<HabitStatusChangerViewModel>();
      return DatePickerTile(
        initDate: vm.selectDate,
        firstDate: vm.earlistStartDate,
        onSelectDateChanged: _onSelectedDateChanged,
      );
    }

    Widget buildStatusChangeTile(BuildContext context) =>
        Selector<HabitStatusChangerViewModel, HabitDate>(
          selector: (context, vm) => vm.selectDate,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, _, child) {
            final vm = context.read<HabitStatusChangerViewModel>();
            return RecordStatusChangeTile(
              initStatus: vm.selectStatus,
              allowedStatus: vm.selectDateAllowedStatus,
              onSelectedNewStatus: _onSelectedStatusChanged,
            );
          },
        );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("text"),
            pinned: true,
          ),
          SafedMultiSliver(
            pushPinnedChildren: false,
            children: [
              SliverPinnedHeader(child: buildDatePickerTile(context)),
              SliverPinnedHeader(child: buildStatusChangeTile(context)),
            ],
          ),
          SafedSliverList(
            children: [
              Placeholder(fallbackHeight: 1000),
              _buildDebugInfo(context),
            ],
          ),
        ],
      ),
    );
  }
}

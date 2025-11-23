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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logging/helper.dart';
import '../../models/habit_date.dart';
import '../../providers/app_developer.dart';
import '../../providers/app_sync.dart';
import '../../providers/habits_today.dart';
import '../../widgets/widgets.dart';

class TodayTabPage extends StatefulWidget {
  const TodayTabPage({super.key});

  @override
  State<TodayTabPage> createState() => TodayTabPageState();
}

class TodayTabPageState extends State<TodayTabPage>
    with AutomaticKeepAliveClientMixin {
  late HabitsTodayViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = context.read<HabitsTodayViewModel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<HabitsTodayViewModel>();
    if (vm != _vm) {
      _vm = vm;
    }
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _onRefreshIndicatorTriggered() async {
    if (!mounted) return;
    DateChangeProvider.of(context).dateTime = HabitDate.now();
    final syncvm = context.read<AppSyncViewModel>();
    if (syncvm.mounted) {
      try {
        await syncvm.startSync(initWait: kAppSyncDelayDuration2);
        await syncvm.appSyncTask.processing;
        if (_vm.mounted && !_vm.isDataLoading) await _vm.loadData();
      } catch (e, s) {
        appLog.appsync.fatal("start sync failed",
            ex: [syncvm.appSyncTask.task], error: e, stackTrace: s);
        if (kDebugMode) Error.throwWithStackTrace(e, s);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final body = CustomScrollView(
      slivers: [
        _Appbar(),
        _DevelopTile(),
      ],
    );
    final page = RefreshIndicator.adaptive(
      onRefresh: _onRefreshIndicatorTriggered,
      edgeOffset: kToolbarHeight + MediaQuery.paddingOf(context).top,
      child: body,
    );
    return page;
  }
}

class _Appbar extends StatelessWidget {
  const _Appbar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: true,
      title: Text("Today"),
    );
  }
}

class _DevelopTile extends StatelessWidget {
  const _DevelopTile();

  @override
  Widget build(BuildContext context) {
    final displayDebugMenu = context
        .select<AppDeveloperViewModel, bool>((vm) => vm.displayDebugMenu);
    final vm = context.watch<HabitsTodayViewModel>();
    final body = SliverToBoxAdapter(
      child: ListTile(
        title: const Text("Debug Info"),
        subtitle: Text(vm.toDebugString()),
        leading: const Icon(Icons.warning),
        iconColor: Colors.red,
        isThreeLine: true,
      ),
    );
    return SliverVisibility(
      visible: displayDebugMenu,
      sliver: EnhancedSafeArea.edgeToEdgeSafe(
        withSliver: true,
        child: body,
      ),
    );
  }
}

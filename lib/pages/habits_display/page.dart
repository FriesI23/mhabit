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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../extensions/context_extensions.dart';
import '../../extensions/navigator_extensions.dart';
import '../../models/habit_summary.dart';
import '../../routes/navigator_helpers.dart';
import '../../storage/db/handlers/habit.dart';
import '../../widgets/widgets.dart';
import '../common/widgets.dart';
import '_providers/habit_summary.dart';
import '_widgets/habit_display_contextual_chrome.dart';
import '_widgets/material/habit_display_fab.dart';
import 'navigation_chrome.dart';
import 'page_habits.dart';
import 'page_today.dart';
import 'providers.dart';
import 'shortcuts.dart';

/// Branch root page for the habits tab.
///
/// Owns the tab's FAB, back-gesture interception, and dismiss intent. The
/// enclosing [AdaptiveNavigationShell] owns navigation scroll behavior.
class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const HabitsPageProviders(child: _HabitsPageBody());
}

class _HabitsPageBody extends StatefulWidget {
  const _HabitsPageBody();

  @override
  State<_HabitsPageBody> createState() => _HabitsPageBodyState();
}

class _HabitsPageBodyState extends State<_HabitsPageBody> {
  final GlobalKey<HabitsTabPageState> _habitsTabKey = GlobalKey();
  HabitSummaryViewModel? _summary;
  HabitDisplayNavigationChrome? _navigationChrome;
  bool _navigationPending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final summary = context.read<HabitSummaryViewModel>();
    if (!identical(_summary, summary)) {
      _summary?.removeListener(_syncNavigationChrome);
      _summary = summary..addListener(_syncNavigationChrome);
    }
    final navigationChrome = context.maybeRead<HabitDisplayNavigationChrome>();
    if (!identical(_navigationChrome, navigationChrome)) {
      _navigationChrome?.unregisterPrimaryAction(_handleCreateHabitPressed);
      _navigationChrome = navigationChrome
        ?..registerPrimaryAction(_handleCreateHabitPressed);
    }
    _syncNavigationChrome();
  }

  @override
  void dispose() {
    _summary?.removeListener(_syncNavigationChrome);
    _navigationChrome?.unregisterPrimaryAction(_handleCreateHabitPressed);
    _navigationChrome?.setContextualChromeSuppressed(false);
    super.dispose();
  }

  void _syncNavigationChrome() {
    _navigationChrome?.setContextualChromeSuppressed(
      _summary?.isInEditMode ?? false,
    );
  }

  Future<void> _handleCreateHabitPressed() async {
    if (!mounted || _navigationPending) return;
    _navigationPending = true;
    try {
      Navigator.of(context).popUntil((route) => route.isFirst);
      final result = await naviToHabitCreatePage(context: context);
      if (!mounted || result == null) return;
      _handleHabitCreated(result);
    } finally {
      _navigationPending = false;
    }
  }

  void _handleHabitCreated(HabitDBCell result) {
    if (!mounted) return;
    final vm = context.read<HabitSummaryViewModel>();
    if (!vm.mounted) return;
    vm.addNewData(HabitSummaryData.fromDBQueryCell(result));
  }

  Widget? _buildFloatingActionButton(
    AdaptiveNavScope scope,
    HabitDisplayContextualChrome chrome,
    ValueChanged<HabitDBCell> onCreated,
  ) {
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => ValueListenableBuilder<bool>(
        valueListenable: scope.visible,
        builder: (context, visible, child) => HabitDisplayMaterialFab(
          hidden: chrome.hideFloatingActionButton,
          bottomNavVisible: visible,
          bottomNavHeight: scope.barHeight,
          onCreated: onCreated,
        ),
      ),
      AdaptiveStyle.apple => null,
    };
  }

  Future<bool> _handleWillPop() async {
    final state = _habitsTabKey.currentState;
    if (state != null) {
      return await state.onWillPop();
    }
    return true;
  }

  void _handlePageDismiss() {
    _habitsTabKey.currentState?.handlePageDismiss();
  }

  @override
  Widget build(BuildContext context) =>
      PageShortcuts(onDismiss: _handlePageDismiss, child: _build());

  Widget _build() => Selector<HabitSummaryViewModel, bool>(
    selector: (context, vm) => vm.isInEditMode,
    builder: (context, isInEditMode, _) {
      final scope = AdaptiveNavScope.of(context);
      final chrome = context.resolveHabitDisplayContextualChrome(
        isSelectionMode: isInEditMode,
      );
      return ColorfulNavibar(
        child: PopScopeConsumer<HabitSummaryViewModel>(
          onCannotPop: (ctx, vm, result) async {
            if (await _handleWillPop() && ctx.mounted) {
              Navigator.of(ctx).popOrExit(result);
            }
          },
          child: Scaffold(
            extendBody: chrome.extendBody,
            resizeToAvoidBottomInset: false,
            body: HabitsTabPage(
              key: _habitsTabKey,
              onHabitCreated: _handleHabitCreated,
              contextualChrome: chrome,
            ),
            floatingActionButton: _buildFloatingActionButton(
              scope,
              chrome,
              _handleHabitCreated,
            ),
            bottomNavigationBar: chrome.showSelectionBottomToolbar
                ? _habitsTabKey.currentState?.buildSelectionBottomToolbar()
                : null,
          ),
        ),
      );
    },
  );
}

/// Branch root page for the today tab.
///
/// Passes the reserved bar height from [AdaptiveNavScope] to [TodayTabPage].
/// The enclosing shell observes active vertical scrolling directly.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) =>
      TodayPageProviders(child: _build(context));

  Widget _build(BuildContext context) {
    final scope = AdaptiveNavScope.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: TodayTabPage(bottomNavigationHeight: scope.navHeight),
    );
  }
}

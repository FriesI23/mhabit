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

import '../../extensions/navigator_extensions.dart';
import '../../widgets/widgets.dart';
import '../common/widgets.dart';
import '_providers/habit_summary.dart';
import 'page_habits.dart';
import 'page_today.dart';

/// Branch root page for the habits tab.
///
/// Owns the tab's FAB, back-gesture interception, and dismiss intent. The
/// bottom bar and its visibility belong to the enclosing
/// [AdaptiveNavigationShell] and are exposed through [AdaptiveNavScope].
class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  bool _fabRebuildPending = false;

  final GlobalKey<HabitsTabPageState> _habitsTabKey = GlobalKey();

  void _handleBottomNavVisibilityChanged(bool visible) {
    AdaptiveNavScope.maybeOf(context)?.reportScrollWish(visible);
  }

  Widget? _buildFloatingActionButton(AdaptiveNavScope scope) {
    final state = _habitsTabKey.currentState;
    if (state == null) {
      if (!_fabRebuildPending) {
        _fabRebuildPending = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _fabRebuildPending = false;
          setState(() {});
        });
      }
      return null;
    }
    return ValueListenableBuilder<bool>(
      valueListenable: scope.visible,
      builder: (context, visible, child) => state.buildFloatingActionButton(
        bottomNavVisible: visible,
        bottomNavHeight: scope.barHeight,
      ),
    );
  }

  Future<bool> _handleWillPop() async {
    final state = _habitsTabKey.currentState;
    if (state != null) {
      return await state.onWillPop();
    }
    return true;
  }

  void _handleDismissIntent() {
    _habitsTabKey.currentState?.handleDismissIntent();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AdaptiveNavScope.of(context);
    return ColorfulNavibar(
      child: PopScopeConsumer<HabitSummaryViewModel>(
        onCannotPop: (ctx, vm, result) async {
          if (await _handleWillPop() && ctx.mounted) {
            Navigator.of(ctx).popOrExit(result);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Actions(
            actions: {
              DismissIntent: CallbackAction(
                onInvoke: (intent) {
                  _handleDismissIntent();
                  return null;
                },
              ),
            },
            child: HabitsTabPage(
              key: _habitsTabKey,
              onBottomNavVisibilityChanged: _handleBottomNavVisibilityChanged,
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(scope),
        ),
      ),
    );
  }
}

/// Branch root page for the today tab.
///
/// Passes the reserved bar height from [AdaptiveNavScope] to [TodayTabPage]
/// and reports its scroll-driven visibility changes back to the shell.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AdaptiveNavScope.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: TodayTabPage(
        bottomNavigationHeight: scope.navHeight,
        onBottomNavVisibilityChanged: (visible) {
          AdaptiveNavScope.maybeOf(context)?.reportScrollWish(visible);
        },
      ),
    );
  }
}

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

import '../../extensions/navigator_extensions.dart';
import '../../models/habit_summary.dart';
import '../../storage/db/handlers/habit.dart';
import '../../widgets/widgets.dart';
import '../common/widgets.dart';
import '_providers/habit_summary.dart';
import '_widgets/habit_display_contextual_chrome.dart';
import '_widgets/material/habit_display_fab.dart';
import 'page_habits.dart';
import 'page_today.dart';
import 'providers.dart';
import 'shortcuts.dart';

/// Branch root page for the habits tab.
///
/// Owns the tab's FAB, back-gesture interception, and dismiss intent. The
/// enclosing [AdaptiveNavigationShell] owns navigation scroll behavior.
class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  final GlobalKey<HabitsTabPageState> _habitsTabKey = GlobalKey();

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

  void _handleHabitCreated(HabitDBCell result) {
    if (!mounted) return;
    final vm = context.read<HabitSummaryViewModel>();
    if (!vm.mounted) return;
    vm.addNewData(HabitSummaryData.fromDBQueryCell(result));
  }

  @override
  Widget build(BuildContext context) => HabitsPageProviders(
    child: PageShortcuts(onDismiss: _handlePageDismiss, child: _build()),
  );

  Widget _build() => Selector<HabitSummaryViewModel, bool>(
    selector: (context, vm) => vm.isInEditMode,
    builder: (context, isInEditMode, _) {
      final scope = AdaptiveNavScope.of(context);
      final chrome = context.resolveHabitDisplayContextualChrome(
        isSelectionMode: isInEditMode,
      );
      return _AdaptiveNavContextualChromeSuppression(
        enabled: chrome.suppressShellChrome,
        child: ColorfulNavibar(
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
        ),
      );
    },
  );
}

class _AdaptiveNavContextualChromeSuppression extends StatefulWidget {
  const _AdaptiveNavContextualChromeSuppression({
    required this.enabled,
    required this.child,
  });

  final bool enabled;
  final Widget child;

  @override
  State<_AdaptiveNavContextualChromeSuppression> createState() =>
      _AdaptiveNavContextualChromeSuppressionState();
}

class _AdaptiveNavContextualChromeSuppressionState
    extends State<_AdaptiveNavContextualChromeSuppression> {
  AdaptiveNavScope? _scope;
  bool? _reported;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = AdaptiveNavScope.maybeOf(context);
    _reported = null;
    _scheduleReport();
  }

  @override
  void didUpdateWidget(
    covariant _AdaptiveNavContextualChromeSuppression oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) _scheduleReport();
  }

  void _scheduleReport() {
    final suppressed = widget.enabled && TickerMode.valuesOf(context).enabled;
    if (_reported == suppressed) return;
    _reported = suppressed;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _reported != suppressed) return;
      _scope?.reportContextualChromeSuppressed(suppressed);
    });
  }

  @override
  void dispose() {
    if (_reported == true) {
      _scope?.reportContextualChromeSuppressed(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
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

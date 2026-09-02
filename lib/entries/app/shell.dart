// Copyright 2026 Fries_I23
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

import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../models/app_entry.dart';
import '../../providers/app_ui/app_launch_entry.dart';
import '../../routes/app_navigation_branch.dart';
import '../../routes/app_navigation_coordinator.dart';
import '../../widgets/widgets.dart';
import 'navigation_chrome.dart';
import 'navigation_destination.dart';

/// [AdaptiveNavigationShell] wired up for the app: localized destinations,
/// app navigation-bar styling, launch-entry persistence on branch switches,
/// and the route-level bar visibility policy.
class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({
    super.key,
    required this.coordinator,
    required this.chromeController,
    required this.child,
    this.auxiliaryChromeBuilder,
  });

  final AppNavigationCoordinator coordinator;
  final AppNavigationChromeController chromeController;
  final Widget child;

  /// Builds optional auxiliary navigation without coupling the shell to its
  /// route or business meaning.
  final AppNavigationAuxiliaryChromeBuilder? auxiliaryChromeBuilder;

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  late int _lastSelectedIndex;

  @override
  void initState() {
    super.initState();
    _bindCoordinator(widget.coordinator);
  }

  @override
  void didUpdateWidget(covariant AppNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.coordinator, widget.coordinator)) return;
    oldWidget.coordinator.removeListener(_handleNavigationChanged);
    _bindCoordinator(widget.coordinator);
  }

  @override
  void dispose() {
    widget.coordinator.removeListener(_handleNavigationChanged);
    super.dispose();
  }

  void _bindCoordinator(AppNavigationCoordinator coordinator) {
    _lastSelectedIndex = coordinator.selectedIndex;
    coordinator.addListener(_handleNavigationChanged);
  }

  void _handleNavigationChanged() {
    final coordinator = widget.coordinator;
    final nextIndex = coordinator.selectedIndex;
    if (nextIndex != _lastSelectedIndex) {
      _lastSelectedIndex = nextIndex;
      final branch = AppNavigationBranch.fromNavigationIndex(nextIndex);
      if (context.mounted) {
        context.read<AppLaunchEntryViewModel>().setNewLaunchEntry(
          switch (branch) {
            AppNavigationBranch.habits => AppEntrys.habitDisplay,
            AppNavigationBranch.today => AppEntrys.habitToday,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppNavigationCoordinatorScope(
      coordinator: widget.coordinator,
      child: NavigatorPopHandler<Object?>(
        onPopWithResult: (result) {
          final navigator =
              widget.coordinator.appChromeNavigatorKey.currentState;
          if (navigator != null) {
            unawaited(navigator.maybePop<Object?>(result));
          }
        },
        child: ColorfulNavibar(
          child: ListenableBuilder(
            listenable: widget.coordinator,
            builder: (context, _) => _AppNavigationShellChrome(
              chromeController: widget.chromeController,
              selectedIndex: widget.coordinator.selectedIndex,
              onDestinationSelected: widget.coordinator.selectBranch,
              auxiliaryChromeBuilder: widget.auxiliaryChromeBuilder,
              compactRouteVisible: widget.coordinator.compactRouteVisible,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppNavigationShellChrome extends StatelessWidget {
  const _AppNavigationShellChrome({
    required this.chromeController,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.auxiliaryChromeBuilder,
    required this.compactRouteVisible,
    required this.child,
  });

  final AppNavigationChromeController chromeController;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final AppNavigationAuxiliaryChromeBuilder? auxiliaryChromeBuilder;
  final bool compactRouteVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final branch = AppNavigationBranch.fromNavigationIndex(selectedIndex);
    return L10nBuilder(
      builder: (context, l10n) => ListenableBuilder(
        listenable: chromeController,
        builder: (context, _) {
          final chrome = chromeController.chromeFor(branch);
          final auxiliaryChrome =
              auxiliaryChromeBuilder?.call(context) ?? const [];
          final selectedAuxiliaryIndex = auxiliaryChrome.indexWhere(
            (item) => item.selected,
          );
          final resolvedSelectedAuxiliaryIndex = selectedAuxiliaryIndex < 0
              ? null
              : selectedAuxiliaryIndex;
          return AdaptiveNavigationShell(
            selectedIndex: selectedIndex,
            auxiliaryDestinations: [
              for (final item in auxiliaryChrome) item.destination,
            ],
            selectedAuxiliaryIndex: resolvedSelectedAuxiliaryIndex,
            onAuxiliaryDestinationSelected: auxiliaryChrome.isEmpty
                ? null
                : (index) => auxiliaryChrome[index].onSelected(),
            compactRouteVisible: compactRouteVisible,
            contextualChromeSuppressed: chrome.contextualChromeSuppressed,
            applePrimaryAction:
                resolvedSelectedAuxiliaryIndex != null ||
                    chrome.contextualChromeSuppressed
                ? null
                : switch (chrome.primaryAction) {
                    AppNavigationPrimaryAction.createHabit =>
                      CupertinoNavigationPrimaryAction(
                        id: 'habit-display-create-primary-action',
                        label: l10n?.habitDisplay_fab_text ?? 'New Habit',
                        icon: const Icon(CupertinoIcons.add),
                        onPressed: () =>
                            chromeController.invokePrimaryAction(branch),
                      ),
                    null => null,
                  },
            appleBarStyle: const AppleNavigationBarStyle(
              expandedNavigationWidth: 220.0,
            ),
            destinations: [
              AppNavigationDestinations.habits(
                label: l10n?.habitDisplay_tab_habits_label ?? 'Habits',
              ),
              AppNavigationDestinations.today(
                label: l10n?.habitDisplay_tab_today_label ?? 'Today',
              ),
            ],
            onDestinationSelected: onDestinationSelected,
            child: child,
          );
        },
      ),
    );
  }
}

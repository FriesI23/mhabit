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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../common/consts.dart';
import '../../models/app_entry.dart';
import '../../providers/app_ui/app_launch_entry.dart';
import '../../routes/app_router.dart';
import '../../widgets/widgets.dart';

/// [AdaptiveNavigationShell] wired up for the app: localized destinations,
/// app navigation-bar styling, launch-entry persistence on branch switches,
/// and the route-level bar visibility policy.
class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({
    super.key,
    required this.navigationShell,
    this.branchObservers = const [],
  });

  final StatefulNavigationShell navigationShell;
  final List<AdaptiveBranchRouteObserver> branchObservers;

  @override
  Widget build(BuildContext context) {
    void onBranchChanged(int index) {
      final newLaunchEntry = AppEntrys.getFromDBCode(index + 1);
      if (newLaunchEntry == null || !context.mounted) return;
      context.read<AppLaunchEntryViewModel>().setNewLaunchEntry(newLaunchEntry);
    }

    return ColorfulNavibar(
      child: L10nBuilder(
        builder: (context, l10n) => AdaptiveNavigationShell(
          navigationShell: navigationShell,
          wideWidthThreshold: kHabitLargeScreenAdaptWidth.toDouble(),
          branchObservers: branchObservers,
          barVisibilityPolicy: appShellBarVisibilityPolicy,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n?.habitDisplay_tab_habits_label ?? 'Habits',
            ),
            NavigationDestination(
              icon: const Icon(MdiIcons.calendarTodayOutline),
              selectedIcon: const Icon(MdiIcons.calendarToday),
              label: l10n?.habitDisplay_tab_today_label ?? 'Today',
            ),
          ],
          onBranchChanged: onBranchChanged,
        ),
      ),
    );
  }
}

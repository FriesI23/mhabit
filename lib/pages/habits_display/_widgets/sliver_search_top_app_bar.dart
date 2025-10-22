// Copyright 2025 Fries_I23
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
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';

import '../../../common/types.dart';
import '../../../l10n/localizations.dart';
import '../../../providers/app_compact_ui_switcher.dart';
import '../../../providers/app_theme.dart';
import '../../../providers/habit_summary.dart';
import '../../../widgets/widgets.dart';
import '../widgets.dart';

class SliverSearchTopAppBar extends StatelessWidget {
  final bool isClandarExpanded;
  final double? height;
  final ScrollController? verticalScrollController;
  final LinkedScrollControllerGroup? horizonalScrollControllerGroup;
  final ValueChanged<bool>? onCalendarToggleExpandPressed;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;
  final HabitListTilePhysicsBuilder? scrollPhysicsBuilder;

  const SliverSearchTopAppBar({
    super.key,
    this.isClandarExpanded = false,
    this.height,
    this.verticalScrollController,
    this.horizonalScrollControllerGroup,
    this.onCalendarToggleExpandPressed,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
    this.scrollPhysicsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final displayPageOccupyPrt =
        context.select<AppThemeViewModel, int>((vm) => vm.displayPageOccupyPrt);
    final vm = context.read<HabitSummaryViewModel>();
    final compactUI = context.read<AppCompactUISwitcherViewModel>();

    final calendarBar = SliverCalendarBar(
      key: const Key('calendar-bar'),
      verticalScrollController: verticalScrollController,
      horizonalScrollControllerGroup: horizonalScrollControllerGroup,
      startDate: DateChangeProvider.of(context).dateTime,
      endDate: vm.earliestSummaryDataStartDate?.startDate,
      isExtended: isClandarExpanded,
      collapsePrt: displayPageOccupyPrt,
      height: compactUI.appCalendarBarHeight,
      itemPadding: compactUI.appCalendarBarItemPadding,
      onLeftBtnPressed: onCalendarToggleExpandPressed,
      scrollPhysicsBuilder: scrollPhysicsBuilder,
    );

    return _AppBar(
      height: height ?? kSearchAppBarHeight,
      scrolledUnderElevation: kCommonEvalation,
      title: const SliverSearchTopAppBarTitle(),
      bottom: calendarBar,
      onInfoButtonPressed: onInfoButtonPressed,
      onMenuButtonPressed: onMenuButtonPressed,
    );
  }
}

class SliverSearchTopAppBarTitle extends StatefulWidget {
  final double? height;

  const SliverSearchTopAppBarTitle({
    super.key,
    this.height,
  });

  @override
  State<SliverSearchTopAppBarTitle> createState() =>
      _SliverSearchTopAppBarTitleState();
}

class _SliverSearchTopAppBarTitleState
    extends State<SliverSearchTopAppBarTitle> {
  bool _scrolledUnder = false;

  _SliverSearchTopAppBarTitleState();

  /// From Material3 Design Duidelines
  ///
  /// > The search container of the search app bar should fill 100% of the space
  /// > between leading and trailing app bar elements until it reaches 312dp.
  /// > Then, it should only grow further to fill 50% of that space.
  ///
  /// see: https://m3.material.io/components/app-bars/guidelines#3f4c81c8-4af9-402e-a322-5d638dcfb337
  BoxConstraints calcSearchBarConstraints(BoxConstraints constraints) {
    const maxSearchWidth = 312.0;
    final availableWidth = constraints.maxWidth;
    final width = availableWidth <= maxSearchWidth
        ? availableWidth
        : maxSearchWidth + (availableWidth - maxSearchWidth) / 2;
    return BoxConstraints.tightFor(height: widget.height ?? 48.0, width: width);
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final current = settings?.isScrolledUnder ?? false;
    if (_scrolledUnder != current) {
      _scrolledUnder = current;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SearchBar(
          backgroundColor: _scrolledUnder
              ? WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surfaceContainerLow)
              : null,
          elevation: const WidgetStatePropertyAll(0.0),
          constraints: calcSearchBarConstraints(constraints),
          // TODO(search): l10n
          hintText: "Search Habits",
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_outlined),
          ),
        );
      },
    );
  }
}

class _AppBar extends StatelessWidget {
  final double? scrolledUnderElevation;
  final Widget? title;
  final PreferredSizeWidget? bottom;
  final double? height;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  const _AppBar({
    this.scrolledUnderElevation,
    this.title,
    this.bottom,
    this.height,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: true,
      centerTitle: false,
      toolbarHeight: height ?? kToolbarHeight,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: Theme.of(context).colorScheme.shadow,
      title: title,
      actionsPadding: kSearchAppBarActionPadding,
      actions: [
        IconButton(
          onPressed: onInfoButtonPressed,
          icon: const Icon(Icons.article_outlined),
        ),
        IconButton(
          onPressed: onMenuButtonPressed,
          icon: const Icon(Icons.settings_outlined),
          tooltip: l10n?.habitDisplay_settingButton_tooltip,
        )
      ],
      bottom: bottom,
    );
  }
}

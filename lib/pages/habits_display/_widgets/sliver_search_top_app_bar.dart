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
import 'package:flutter/cupertino.dart' show CupertinoButton, CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../common/consts.dart';
import '../../../extensions/adaptive_style_extensions.dart';
import '../../../extensions/iterable_extensions.dart';
import '../../../extensions/window_size_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_form.dart';
import '../_providers/habit_summary.dart';
import '../styles.dart';
import 'search_filter.dart';

class SliverSearchTopAppBar extends StatefulWidget {
  final AdaptiveStyle style;
  final MenuController? searchFilterMenuController;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;
  final VoidCallback? onSelectButtonPressed;
  final Widget? cupertinoBottom;
  final double cupertinoBottomExtent;

  const SliverSearchTopAppBar.material({
    super.key,
    this.searchFilterMenuController,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
    this.onSelectButtonPressed,
  }) : style = AdaptiveStyle.material,
       cupertinoBottom = null,
       cupertinoBottomExtent = 0.0;

  const SliverSearchTopAppBar.apple({
    super.key,
    this.searchFilterMenuController,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
    this.onSelectButtonPressed,
    this.cupertinoBottom,
    this.cupertinoBottomExtent = 0.0,
  }) : style = AdaptiveStyle.apple,
       assert(cupertinoBottom != null || cupertinoBottomExtent == 0.0);

  @override
  State<SliverSearchTopAppBar> createState() => _SliverSearchTopAppBarState();
}

class _SliverSearchTopAppBarState extends State<SliverSearchTopAppBar>
    with RestorationMixin {
  late HabitSummaryViewModel _vm;
  late final FocusNode _focusNode;
  late final RestorableTextEditingController _controller;
  late bool _previousSearchMode;
  var _changed = false;

  @override
  void initState() {
    super.initState();
    _vm = context.read<HabitSummaryViewModel>()
      ..addListener(_onViewModelNotified);
    _focusNode = FocusNode();
    _controller = RestorableTextEditingController.fromValue(
      TextEditingValue(text: _vm.searchOptions.keyword),
    );
    _previousSearchMode = _vm.isInSearchMode;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = context.read<HabitSummaryViewModel>();
    if (vm == _vm) return;
    _vm.removeListener(_onViewModelNotified);
    _vm = vm..addListener(_onViewModelNotified);
    _controller.value.text = _vm.searchOptions.keyword;
    _previousSearchMode = _vm.isInSearchMode;
    _changed = _controller.value.text.isNotEmpty;
  }

  @override
  void dispose() {
    _vm.removeListener(_onViewModelNotified);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  String? get restorationId => 'controller';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_controller, 'controller');
    final restoredText = _controller.value.text;
    if (restoredText != _vm.searchOptions.keyword) {
      _vm.onSeachKeywordChanged(restoredText, listen: false);
      _previousSearchMode = _vm.isInSearchMode;
      _changed = restoredText.isNotEmpty;
    }
  }

  void _onViewModelNotified() {
    if (!mounted) return;
    final keyword = _vm.searchOptions.keyword;
    if (_controller.value.text != keyword) {
      _controller.value.text = keyword;
      _changed = true;
    }
    if (_previousSearchMode && !_vm.isInSearchMode) {
      _focusNode.unfocus();
    }
    _previousSearchMode = _vm.isInSearchMode;
    if (!_vm.isInSearchMode) _changed = false;
    setState(() {});
  }

  bool get _isViewModelMounted => mounted && _vm.mounted;

  void _dismissSearch() {
    if (!_isViewModelMounted) return;
    _vm.exitSearchMode();
    if (_focusNode.hasFocus) _focusNode.unfocus();
    _changed = false;
  }

  void _onTapOutside(PointerDownEvent event) {
    if (_focusNode.hasFocus) _focusNode.unfocus();
    if (_vm.searchOptions.isNotEmpty || !_changed) return;
    _dismissSearch();
  }

  void _onChanged(String text) {
    if (!_isViewModelMounted) return;
    _vm.onSeachKeywordChanged(text);
    _changed = true;
  }

  void _onSubmitted(String text) {
    if (_changed) _onChanged(text);
  }

  void _onOngoingFilterChanged(bool? value) {
    if (value != null) _vm.onSearchOngoingChanged(value);
  }

  void _onCompletedFilterChanged(bool? value) {
    if (value != null) _vm.onSearchCompletedChanged(value);
  }

  void _onTypeFilterChanged((HabitType, bool?) value) {
    final (type, include) = value;
    if (include == null || type == HabitType.unknown) return;
    _vm.onSearchHabitTypeChanged(type, include);
  }

  void _onClearFilterPressed() => _vm.onClearSearchFilter();

  Future<void> _openSearchFilterBottomSheet() async {
    final result = await showSearchFilterBottomSheet(
      context: context,
      options: _vm.searchOptions,
    );
    if (!mounted || result == null) return;
    _vm.onSearchFilterChanged(result);
  }

  Widget _buildSearchFilter() => Builder(
    builder: (context) {
      final windowSize = WindowSize.of(context);
      final isLargeLayout = switch (DeviceContext.of(context).platform) {
        TargetPlatform.android ||
        TargetPlatform.iOS => windowSize.isTabletFormFactor,
        _ => true,
      };
      return isLargeLayout
          ? SearchFilterPopupMenuButton(
              controller: widget.searchFilterMenuController,
              ongoingChanged: _onOngoingFilterChanged,
              completedChanged: _onCompletedFilterChanged,
              typeChanged: _onTypeFilterChanged,
              onClearFilterPressed: _onClearFilterPressed,
            )
          : SearchFilterIconButton(onPreesed: _openSearchFilterBottomSheet);
    },
  );

  List<CupertinoSliverSearchBarAction> _buildCupertinoSearchFilterActions(
    L10n? l10n,
    bool overflowOnly,
  ) {
    final options = _vm.searchOptions;
    Widget selectionIcon(
      bool selected,
      IconData regular,
      IconData selectedIcon,
    ) => Icon(selected ? selectedIcon : regular);
    final statusSummary = [
      if (options.activated)
        l10n?.habitDisplay_searchFilter_ongoing ?? 'Ongoing',
      if (options.completed)
        l10n?.habitDisplay_searchFilter_completed ?? 'Completed',
    ].joinLocalized(l10n);
    final typeSummary = [
      for (final type in HabitType.values)
        if (type != HabitType.unknown && options.types.contains(type))
          type.getTypeName(l10n),
    ].joinLocalized(l10n);
    return [
      CupertinoSliverSearchBarAction(
        id: 'habit-filter',
        label: l10n?.habitDisplay_searchFilter_tooltips ?? 'Show Filters',
        retentionPriority: -100,
        overflowOnly: overflowOnly,
        icon: Icon(
          options.isFilterEmpty
              ? CupertinoIcons.line_horizontal_3_decrease_circle
              : CupertinoIcons.line_horizontal_3_decrease_circle_fill,
        ),
        children: [
          CupertinoSliverSearchBarAction(
            id: 'habit-filter-status',
            label: l10n?.habitDisplay_sortType_status ?? 'Completion Status',
            subtitle: statusSummary,
            icon: Icon(
              options.activated || options.completed
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.check_mark_circled,
            ),
            children: [
              CupertinoSliverSearchBarAction(
                id: 'habit-filter-ongoing',
                label: l10n?.habitDisplay_searchFilter_ongoing ?? 'Ongoing',
                tooltip: l10n?.habitDisplay_searchFilter_ongoing_desc,
                icon: selectionIcon(
                  options.activated,
                  CupertinoIcons.play_circle,
                  CupertinoIcons.play_circle_fill,
                ),
                onPressed: () => _onOngoingFilterChanged(!options.activated),
              ),
              CupertinoSliverSearchBarAction(
                id: 'habit-filter-completed',
                label: l10n?.habitDisplay_searchFilter_completed ?? 'Completed',
                icon: selectionIcon(
                  options.completed,
                  CupertinoIcons.check_mark_circled,
                  CupertinoIcons.check_mark_circled_solid,
                ),
                onPressed: () => _onCompletedFilterChanged(!options.completed),
              ),
            ],
          ),
          CupertinoSliverSearchBarAction(
            id: 'habit-filter-types',
            label:
                l10n?.habitDisplay_searchFilter_habitType_groupTitle ??
                'Habit Type',
            subtitle: typeSummary,
            icon: Icon(
              options.types.isEmpty
                  ? CupertinoIcons.square_grid_2x2
                  : CupertinoIcons.square_grid_2x2_fill,
            ),
            children: [
              for (final type in HabitType.values)
                if (type != HabitType.unknown)
                  CupertinoSliverSearchBarAction(
                    id: 'habit-filter-type-${type.name}',
                    label: type.getTypeName(l10n),
                    icon: selectionIcon(
                      options.types.contains(type),
                      type == HabitType.normal
                          ? CupertinoIcons.plus_circle
                          : CupertinoIcons.minus_circle,
                      type == HabitType.normal
                          ? CupertinoIcons.plus_circle_fill
                          : CupertinoIcons.minus_circle_fill,
                    ),
                    onPressed: () => _onTypeFilterChanged((
                      type,
                      !options.types.contains(type),
                    )),
                  ),
            ],
          ),
          if (!options.isFilterEmpty)
            const CupertinoSliverSearchBarMenuDivider(),
          if (!options.isFilterEmpty)
            CupertinoSliverSearchBarAction(
              id: 'habit-filter-clear',
              label:
                  l10n?.habitDisplay_searchFilter_clearFilter ??
                  'Clear Filters',
              icon: const Icon(CupertinoIcons.clear_circled_solid),
              isDestructive: true,
              onPressed: _onClearFilterPressed,
            ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => switch (widget.style) {
    AdaptiveStyle.material => _buildMaterial(context),
    AdaptiveStyle.apple => _buildApple(context),
  };
}

extension _MaterialSliverSearchTopAppBarStateExtension
    on _SliverSearchTopAppBarState {
  void _onMaterialSearchActivated() {
    if (!_isViewModelMounted) return;
    _vm.enterSearchMode();
    if (!_isViewModelMounted || !_vm.isInSearchMode) return;
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
  }

  Widget _buildMaterial(BuildContext context) {
    final l10n = L10n.of(context);
    final infoButton = AdaptiveIconButton.material(
      onPressed: widget.onInfoButtonPressed,
      icon: const Icon(Icons.article_outlined),
    );
    final menuButton = AdaptiveIconButton.material(
      onPressed: widget.onMenuButtonPressed,
      icon: const Icon(Icons.settings_outlined),
      tooltip: l10n?.habitDisplay_settingButton_tooltip,
    );
    return AdaptiveSliverSearchBar.material(
      title: Text(l10n?.appName ?? appName),
      actions: [infoButton, menuButton],
      searchTrailing: _buildSearchFilter(),
      controller: _controller.value,
      focusNode: _focusNode,
      isSearchActive: _vm.isInSearchMode,
      keyword: _vm.searchOptions.keyword,
      hintText: l10n?.habitDisplay_searchBar_hintText,
      onChanged: _onChanged,
      onSubmitted: _onSubmitted,
      onSearchActivated: _onMaterialSearchActivated,
      onSearchDismissed: _dismissSearch,
      onTapOutside: _onTapOutside,
      materialStyle: const MaterialSliverSearchBarStyle(
        toolbarHeight: AppAdaptiveStyle.materialToolbarHeight,
        scrolledUnderElevation: kCommonEvalation,
        shadowColor: Colors.transparent,
      ),
    );
  }
}

extension _AppleSliverSearchTopAppBarStateExtension
    on _SliverSearchTopAppBarState {
  void _onAppleSearchActivated() {}

  Widget _buildApple(BuildContext context) {
    final l10n = L10n.of(context);
    final settingsLabel =
        l10n?.habitDisplay_settingButton_tooltip ?? 'Settings';
    final selectLabel = l10n?.habitDisplay_selectButton_label ?? 'Select';
    final compact = WindowSize.of(context).width == WindowSizeClass.compact;
    const statisticsLabel = 'Statistics';
    final cupertinoActions = [
      CupertinoSliverSearchBarAction(
        id: 'habit-select',
        label: selectLabel,
        icon: const Icon(CupertinoIcons.checkmark_alt_circle),
        onPressed: widget.onSelectButtonPressed ?? () {},
        isEnabled: widget.onSelectButtonPressed != null,
        overflowOnly: compact,
        retentionPriority: 100,
        primaryBuilder: (_) => CupertinoButton(
          key: const ValueKey('habit-select-primary'),
          padding: EdgeInsets.zero,
          minimumSize: const Size(44, 44),
          onPressed: widget.onSelectButtonPressed,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(selectLabel, maxLines: 1, softWrap: false),
          ),
        ),
      ),
      CupertinoSliverSearchBarAction(
        id: 'habit-statistics',
        label: statisticsLabel,
        icon: const Icon(Icons.article_outlined),
        onPressed: widget.onInfoButtonPressed ?? () {},
        isEnabled: widget.onInfoButtonPressed != null,
        primaryBuilder: (_) => AdaptiveIconButton.apple(
          onPressed: widget.onInfoButtonPressed,
          icon: const Icon(Icons.article_outlined),
        ),
      ),
      CupertinoSliverSearchBarAction(
        id: 'habit-settings',
        label: settingsLabel,
        tooltip: settingsLabel,
        icon: const Icon(Icons.settings_outlined),
        onPressed: widget.onMenuButtonPressed ?? () {},
        isEnabled: widget.onMenuButtonPressed != null,
        retentionPriority: 50,
        primaryBuilder: (_) => AdaptiveIconButton.apple(
          onPressed: widget.onMenuButtonPressed,
          tooltip: settingsLabel,
          icon: const Icon(Icons.settings_outlined),
        ),
      ),
      ..._buildCupertinoSearchFilterActions(l10n, compact),
    ];
    return AdaptiveSliverSearchBar.apple(
      title: Text(l10n?.appName ?? appName),
      cupertinoActions: cupertinoActions,
      cupertinoBottom: widget.cupertinoBottom,
      cupertinoBottomExtent: widget.cupertinoBottomExtent,
      controller: _controller.value,
      focusNode: _focusNode,
      isSearchActive: _vm.isInSearchMode,
      keyword: _vm.searchOptions.keyword,
      hintText: l10n?.habitDisplay_searchBar_hintText,
      onChanged: _onChanged,
      onSubmitted: _onSubmitted,
      onSearchActivated: _onAppleSearchActivated,
      onSearchDismissed: _dismissSearch,
      onTapOutside: _onTapOutside,
    );
  }
}

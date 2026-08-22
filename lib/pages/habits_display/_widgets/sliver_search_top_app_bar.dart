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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../common/consts.dart';
import '../../../extensions/window_size_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_form.dart';
import '../../../widgets/widgets.dart';
import '../_providers/habit_summary.dart';
import '../styles.dart';
import 'search_filter.dart';

class SliverSearchTopAppBar extends StatefulWidget {
  final double? height;
  final MenuController? searchFilterMenuController;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  const SliverSearchTopAppBar({
    super.key,
    this.height,
    this.searchFilterMenuController,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
  });

  @override
  State<SliverSearchTopAppBar> createState() => _SliverSearchTopAppBarState();
}

class _SliverSearchTopAppBarState extends State<SliverSearchTopAppBar>
    with RestorationMixin {
  static const double _searchBarHeight = 48.0;
  static const double _maxSearchWidth = 312.0;

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

  void _activateSearch() {
    if (!_isViewModelMounted) return;
    _vm.enterSearchMode();
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final infoButton = IconButton(
      onPressed: widget.onInfoButtonPressed,
      icon: const Icon(Icons.article_outlined),
    );
    final menuButton = IconButton(
      onPressed: widget.onMenuButtonPressed,
      icon: const Icon(Icons.settings_outlined),
      tooltip: l10n?.habitDisplay_settingButton_tooltip,
    );
    return AdaptiveSliverSearchBar(
      title: Text(l10n?.appName ?? appName),
      leading: infoButton,
      actions: [menuButton],
      searchTrailing: _buildSearchFilter(),
      controller: _controller.value,
      focusNode: _focusNode,
      isSearchActive: _vm.isInSearchMode,
      keyword: _vm.searchOptions.keyword,
      hintText: l10n?.habitDisplay_searchBar_hintText,
      onChanged: _onChanged,
      onSubmitted: _onSubmitted,
      onSearchActivated: _activateSearch,
      onSearchDismissed: _dismissSearch,
      onTapOutside: _onTapOutside,
      materialStyle: MaterialSliverSearchBarStyle(
        toolbarHeight: widget.height ?? kSearchAppBarHeight,
        searchBarHeight: _searchBarHeight,
        maxSearchWidth: _maxSearchWidth,
        scrolledUnderElevation: kCommonEvalation,
        shadowColor: Colors.transparent,
      ),
    );
  }
}

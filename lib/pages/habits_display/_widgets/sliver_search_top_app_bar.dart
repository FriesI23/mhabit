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

import 'package:flutter/material.dart' hide PreferredSize;
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../providers/habit_summary.dart';
import '../../../widgets/widgets.dart';
import '../styles.dart';

class SliverSearchTopAppBar extends StatelessWidget {
  final double? height;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  const SliverSearchTopAppBar({
    super.key,
    this.height,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _AppBar(
      height: height ?? kSearchAppBarHeight,
      scrolledUnderElevation: kCommonEvalation,
      title: const _SearchBar(height: 48.0),
      bottom: PreferredSize.zero,
      shawdowColor: Colors.transparent,
      onInfoButtonPressed: onInfoButtonPressed,
      onMenuButtonPressed: onMenuButtonPressed,
    );
  }
}

class _SearchBar extends StatefulWidget {
  final double? height;

  const _SearchBar({this.height});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

enum SearchEnterMode { click, other }

class _SearchBarState extends State<_SearchBar> {
  late HabitSummaryViewModel _vm;
  late bool _scrolledUnder;
  late FocusNode _focusNode;
  late TextEditingController _controller;
  late bool _prevSearchMode;

  SearchEnterMode? _enterMode;

  @override
  void initState() {
    super.initState();
    _vm = context.read<HabitSummaryViewModel>()
      ..addListener(_onViewModelNotified);
    _scrolledUnder = false;
    _focusNode = FocusNode();
    _controller = TextEditingController(text: _vm.searchOptions.keyword);
    _prevSearchMode = _vm.isInSearchMode;
    if (_vm.isInSearchMode) _enterMode = SearchEnterMode.other;
  }

  @override
  void didUpdateWidget(covariant _SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final vm = context.read<HabitSummaryViewModel>();
    if (vm != _vm) {
      _vm.removeListener(_onViewModelNotified);
      _vm = vm..addListener(_onViewModelNotified);
      _controller.text = _vm.searchOptions.keyword;
      _prevSearchMode = _vm.isInSearchMode;
      _enterMode = _vm.isInSearchMode ? SearchEnterMode.other : null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _vm.removeListener(_onViewModelNotified);
    super.dispose();
  }

  void _onViewModelNotified() {
    if (_controller.text != _vm.searchOptions.keyword) {
      _controller.text = _vm.searchOptions.keyword;
    }
    if (_prevSearchMode && !_vm.isInSearchMode) {
      _focusNode.unfocus();
    }
    _prevSearchMode = _vm.isInSearchMode;
    if (!_vm.isInSearchMode) _enterMode = null;
  }

  bool get isViewModelMounted => mounted && _vm.mounted;

  void _enterSeach({SearchEnterMode mode = SearchEnterMode.other}) {
    if (!isViewModelMounted) return;
    _vm.enterSearchMode();
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
    _enterMode = mode;
  }

  void _exitSearch() {
    if (!isViewModelMounted) return;
    _vm.exitSearchMode();
    if (_focusNode.hasFocus) _focusNode.unfocus();
    _enterMode = null;
  }

  void _onSearchButtonPressed() {
    _enterSeach(mode: SearchEnterMode.click);
  }

  void _onCloseButtonPressed() {
    _exitSearch();
  }

  void _onTapOutside(PointerDownEvent event) {
    if (_vm.searchOptions.isNotEmpty || _enterMode == SearchEnterMode.click) {
      return;
    }
    _exitSearch();
  }

  void _onChanged(String text) {
    if (!isViewModelMounted) return;
    _vm.onSeachKeywordChanged(text);
  }

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
          focusNode: _focusNode,
          controller: _controller,
          backgroundColor: _scrolledUnder
              ? WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surfaceContainerLow)
              : null,
          elevation: const WidgetStatePropertyAll(0.0),
          constraints: calcSearchBarConstraints(constraints),
          // TODO(search): l10n
          hintText: "Search Habits",
          leading: _SearchIconButton(
            onSearchButtonPressed: _onSearchButtonPressed,
            onCloseButtonPressed: _onCloseButtonPressed,
          ),
          onTapOutside: _onTapOutside,
          onChanged: _onChanged,
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
  final Color? shawdowColor;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  const _AppBar({
    this.scrolledUnderElevation,
    this.title,
    this.bottom,
    this.height,
    this.shawdowColor,
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
      shadowColor: shawdowColor,
      title: title,
      actionsPadding: kSearchAppBarActionPadding,
      bottom: bottom,
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
    );
  }
}

class _SearchIconButton extends StatelessWidget {
  static const animateDuration = Duration(milliseconds: 300);

  final VoidCallback? onSearchButtonPressed;
  final VoidCallback? onCloseButtonPressed;

  const _SearchIconButton({
    this.onSearchButtonPressed,
    this.onCloseButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isInSearchMode =
        context.select<HabitSummaryViewModel, bool>((vm) => vm.isInSearchMode);
    return AnimatedCrossFade(
        firstChild: IconButton(
          key: const ValueKey(1),
          onPressed: onCloseButtonPressed,
          icon: const Icon(Icons.close),
        ),
        secondChild: IconButton(
          key: const ValueKey(2),
          onPressed: onSearchButtonPressed,
          icon: const Icon(Icons.search_outlined),
        ),
        crossFadeState: isInSearchMode
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: animateDuration);
  }
}

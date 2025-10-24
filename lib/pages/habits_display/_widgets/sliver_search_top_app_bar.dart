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

import '../../../common/consts.dart';
import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';
import '../../../providers/habit_summary.dart';
import '../../../widgets/widgets.dart';
import '../styles.dart';

class SliverSearchTopAppBar extends StatefulWidget {
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
  State<SliverSearchTopAppBar> createState() => _SliverSearchTopAppBarState();
}

class _SliverSearchTopAppBarState extends State<SliverSearchTopAppBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppBar(
      height: widget.height ?? kSearchAppBarHeight,
      scrolledUnderElevation: kCommonEvalation,
      searchBar: _SearchBar(
        key: const ValueKey("search-bar"),
        height: 48.0,
        controller: _controller,
      ),
      bottom: PreferredSize.zero,
      shawdowColor: Colors.transparent,
      onInfoButtonPressed: widget.onInfoButtonPressed,
      onMenuButtonPressed: widget.onMenuButtonPressed,
    );
  }
}

enum SearchEnterMode { click, other }

class _SearchBar extends StatefulWidget {
  static const kSearchFullWidthLimit = 312.0;

  final FocusNode? focusNode;
  final TextEditingController? controller;
  final double? height;

  const _SearchBar({super.key, this.height, this.controller})
      : focusNode = null;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> with RestorationMixin {
  late HabitSummaryViewModel _vm;
  late bool _scrolledUnder;
  late bool _prevSearchMode;
  FocusNode? _focusNode;
  RestorableTextEditingController? _controller;

  SearchEnterMode? _enterMode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());
  TextEditingController get _effectiveController =>
      widget.controller ?? (_controller!.value);

  @override
  void initState() {
    super.initState();

    _vm = context.read<HabitSummaryViewModel>()
      ..addListener(_onViewModelNotified);
    _scrolledUnder = false;
    _prevSearchMode = _vm.isInSearchMode;
    if (widget.controller == null) {
      _createLocalController(TextEditingValue(text: _vm.searchOptions.keyword));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_vm.isInSearchMode) {
      _enterMode = SearchEnterMode.other;
      _effectiveFocusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(covariant _SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_controller!);
      _controller!.dispose();
      _controller = null;
    }

    final vm = context.read<HabitSummaryViewModel>();
    if (vm != _vm) {
      _vm.removeListener(_onViewModelNotified);
      _vm = vm..addListener(_onViewModelNotified);
      _effectiveController.text = _vm.searchOptions.keyword;
      _prevSearchMode = _vm.isInSearchMode;
      _enterMode = _vm.isInSearchMode ? SearchEnterMode.other : null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode?.dispose();
    _vm.removeListener(_onViewModelNotified);
    super.dispose();
  }

  //#region controller
  @override
  String? get restorationId => null;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }
  //#endregion

  void _onViewModelNotified() {
    if (_effectiveController.text != _vm.searchOptions.keyword) {
      _effectiveController.text = _vm.searchOptions.keyword;
    }
    if (_prevSearchMode && !_vm.isInSearchMode) {
      _effectiveFocusNode.unfocus();
    }
    _prevSearchMode = _vm.isInSearchMode;
    if (!_vm.isInSearchMode) _enterMode = null;
  }

  bool get isViewModelMounted => mounted && _vm.mounted;

  void _enterSeach({SearchEnterMode mode = SearchEnterMode.other}) {
    if (!isViewModelMounted) return;
    _vm.enterSearchMode();
    if (!_effectiveFocusNode.hasFocus) _effectiveFocusNode.requestFocus();
    _enterMode = mode;
  }

  void _exitSearch() {
    if (!isViewModelMounted) return;
    _vm.exitSearchMode();
    if (_effectiveFocusNode.hasFocus) _effectiveFocusNode.unfocus();
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
    const maxSearchWidth = _SearchBar.kSearchFullWidthLimit;
    final availableWidth = constraints.maxWidth;
    final width = availableWidth <= maxSearchWidth
        ? availableWidth
        : maxSearchWidth + (availableWidth - maxSearchWidth) / 2;
    return BoxConstraints.tightFor(height: widget.height ?? 48.0, width: width);
  }

  WidgetStateProperty<Color?>? getLightOverlayColor(ColorScheme colors) =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colors.onSurfaceVariant.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.onSurfaceVariant.withValues(alpha: 0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return Colors.transparent;
        }
        return Colors.transparent;
      });

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
        final colors = Theme.of(context).colorScheme;
        final brightness = Theme.of(context).brightness;
        return SearchBar(
          focusNode: _effectiveFocusNode,
          controller: _effectiveController,
          keyboardType: TextInputType.streetAddress,
          overlayColor: getLightOverlayColor(colors),
          backgroundColor: _scrolledUnder
              ? WidgetStatePropertyAll(brightness == Brightness.dark
                  ? colors.surfaceContainer
                  : colors.surfaceContainerLowest)
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
  final Widget? searchBar;
  final PreferredSizeWidget? bottom;
  final double? height;
  final Color? shawdowColor;
  final VoidCallback? onInfoButtonPressed;
  final VoidCallback? onMenuButtonPressed;

  const _AppBar({
    this.scrolledUnderElevation,
    this.searchBar,
    this.bottom,
    this.height,
    this.shawdowColor,
    this.onInfoButtonPressed,
    this.onMenuButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    final infoButton = IconButton(
      onPressed: onInfoButtonPressed,
      icon: const Icon(Icons.article_outlined),
    );
    final menuButton = IconButton(
      onPressed: onMenuButtonPressed,
      icon: const Icon(Icons.settings_outlined),
      tooltip: l10n?.habitDisplay_settingButton_tooltip,
    );
    final searchBar = this.searchBar;
    const sliverAppBarKey = ValueKey("bar");
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final uiLayout = computeLayoutType(
            width: constraints.crossAxisExtent,
            height: constraints.viewportMainAxisExtent);
        return switch (uiLayout) {
          UiLayoutType.s => SliverAppBar(
              key: sliverAppBarKey,
              floating: true,
              snap: true,
              pinned: true,
              centerTitle: false,
              toolbarHeight: height ?? kToolbarHeight,
              scrolledUnderElevation: scrolledUnderElevation,
              shadowColor: shawdowColor,
              title: searchBar,
              actionsPadding: kSearchAppBarActionPadding,
              bottom: bottom,
              actions: [infoButton, menuButton],
            ),
          UiLayoutType.l => SliverAppBar(
              key: sliverAppBarKey,
              floating: true,
              snap: true,
              pinned: true,
              centerTitle: false,
              toolbarHeight: height ?? kToolbarHeight,
              scrolledUnderElevation: scrolledUnderElevation,
              shadowColor: shawdowColor,
              leading: infoButton,
              title: Text(l10n?.appName ?? appName),
              actionsPadding: kSearchAppBarActionPadding,
              bottom: bottom,
              actions: [
                if (searchBar != null)
                  ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(
                          width: _SearchBar.kSearchFullWidthLimit),
                      child: searchBar),
                menuButton
              ],
            ),
        };
      },
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

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
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide PreferredSize;
import 'package:markdown_widget/config/configs.dart';
import 'package:provider/provider.dart';

import '../../../common/consts.dart';
import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_form.dart';
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
      searchBar: const _SearchBar(key: ValueKey("search-bar"), height: 48.0),
      bottom: PreferredSize.zero,
      shawdowColor: Colors.transparent,
      onInfoButtonPressed: onInfoButtonPressed,
      onMenuButtonPressed: onMenuButtonPressed,
    );
  }
}

class _SearchBar extends StatefulWidget {
  static const double kSearchFullWidthLimit = 312.0;
  static const double kSearchHeight = 48.0;

  final FocusNode? focusNode;
  final TextEditingController? controller;
  final double? height;

  const _SearchBar({super.key, this.height})
      : focusNode = null,
        controller = null;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> with RestorationMixin {
  late HabitSummaryViewModel _vm;
  late bool _scrolledUnder;
  late bool _prevSearchMode;
  FocusNode? _focusNode;
  RestorableTextEditingController? _controller;
  bool _changed = false;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());
  TextEditingController get _effectiveController =>
      widget.controller ?? (_controller!.value);

  double get _effectiveHeight => widget.height ?? _SearchBar.kSearchHeight;

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
      if (_effectiveController.text.isNotEmpty) _changed = true;
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
  String? get restorationId => 'controller';

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
      _changed = true;
    }
    if (_prevSearchMode && !_vm.isInSearchMode) {
      _effectiveFocusNode.unfocus();
    }
    _prevSearchMode = _vm.isInSearchMode;
    if (!_vm.isInSearchMode) _changed = false;
  }

  bool get isViewModelMounted => mounted && _vm.mounted;

  void _enterSeach() {
    if (!isViewModelMounted) return;
    _vm.enterSearchMode();
    if (!_effectiveFocusNode.hasFocus) _effectiveFocusNode.requestFocus();
  }

  void _exitSearch() {
    if (!isViewModelMounted) return;
    _vm.exitSearchMode();
    if (_effectiveFocusNode.hasFocus) _effectiveFocusNode.unfocus();
    _changed = false;
  }

  void _onSearchButtonPressed() {
    _enterSeach();
  }

  void _onCloseButtonPressed() {
    _exitSearch();
  }

  void _onTapOutside(PointerDownEvent event) {
    if (_effectiveFocusNode.hasFocus) _effectiveFocusNode.unfocus();
    if (_vm.searchOptions.isNotEmpty || !_changed) return;
    _exitSearch();
  }

  void _onChanged(String text) {
    if (!isViewModelMounted) return;
    _vm.onSeachKeywordChanged(text);
    _changed = true;
  }

  void _onSubmitted(String text) => _changed ? _onChanged(text) : null;

  void _onOngingFilterChanged(bool? value) {
    if (value == null) return;
    _vm.onSearchOngoingChanged(value);
  }

  void _onCompletedFilterChanged(bool? value) {
    if (value == null) return;
    _vm.onSearchCompletedChanged(value);
  }

  void _onTypeFilterChanged((HabitType, bool?) value) {
    final (type, include) = value;
    if (include == null || type == HabitType.unknown) return;
    _vm.onSearchHabitTypeChanged(type, include);
  }

  void _onClearFilterPressed() {
    _vm.onClearSearchFilter();
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
    return BoxConstraints.tightFor(height: _effectiveHeight, width: width);
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
        final l10n = L10n.of(context);
        final colors = Theme.of(context).colorScheme;
        final brightness = Theme.of(context).brightness;
        return SearchBar(
          focusNode: _effectiveFocusNode,
          controller: _effectiveController,
          textInputAction: TextInputAction.search,
          overlayColor: getLightOverlayColor(colors),
          backgroundColor: _scrolledUnder
              ? WidgetStatePropertyAll(brightness == Brightness.dark
                  ? colors.surfaceContainer
                  : colors.surfaceContainerLowest)
              : null,
          elevation: const WidgetStatePropertyAll(0.0),
          constraints: calcSearchBarConstraints(constraints),
          hintText: l10n?.habitDisplay_searchBar_hintText,
          leading: _SearchIconButton(
            onSearchButtonPressed: _onSearchButtonPressed,
            onCloseButtonPressed: _onCloseButtonPressed,
          ),
          trailing: [
            _SearchFilterIconButton(
              position: PopupMenuPosition.over,
              offset: Offset(-18.0, _effectiveHeight / 2),
              ongoingChanged: _onOngingFilterChanged,
              completedChanged: _onCompletedFilterChanged,
              typeChanged: _onTypeFilterChanged,
              onClearFilterPressed: _onClearFilterPressed,
            ),
          ],
          onTapOutside: _onTapOutside,
          onChanged: _onChanged,
          onSubmitted: _onSubmitted,
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

class _SearchFilterIconButton extends StatefulWidget {
  final PopupMenuPosition? position;
  final Offset? offset;
  final ValueCallback<bool?>? ongoingChanged;
  final ValueCallback<bool?>? completedChanged;
  final ValueCallback<(HabitType, bool?)>? typeChanged;
  final VoidCallback? onClearFilterPressed;

  const _SearchFilterIconButton({
    this.position,
    this.offset,
    this.ongoingChanged,
    this.completedChanged,
    this.typeChanged,
    this.onClearFilterPressed,
  });

  @override
  State<_SearchFilterIconButton> createState() =>
      _SearchFilterIconButtonState();
}

class _SearchFilterIconButtonState extends State<_SearchFilterIconButton> {
  bool _menuOpen = false;

  PopupMenuEntry _popMenuItemBuilder(BuildContext context,
      {required WidgetBuilder builder, HabitSummaryViewModel? vm}) {
    final widget = vm != null
        ? ChangeNotifierProvider.value(
            value: vm, builder: (context, child) => builder(context))
        : builder(context);
    return switch (widget) {
      PopupMenuEntry() => widget,
      _ => PopupMenuItem(padding: EdgeInsets.zero, child: widget)
    };
  }

  @override
  Widget build(BuildContext context) {
    const div = PopupMenuDivider();
    final typeChanged = widget.typeChanged;
    final l10n = L10n.of(context);
    final options =
        context.select<HabitSummaryViewModel, HabitDisplaySearchOptions>(
            (vm) => vm.searchOptions);
    final vm = context.read<HabitSummaryViewModel>();
    return PopupMenuButton<void>(
      onOpened: () {
        setState(() {
          _menuOpen = true;
        });
      },
      onCanceled: () {
        setState(() {
          _menuOpen = false;
        });
      },
      onSelected: (value) {
        setState(() {
          _menuOpen = false;
        });
      },
      position: widget.position,
      offset: widget.offset ?? Offset.zero,
      itemBuilder: (context) => [
        _popMenuItemBuilder(
          context,
          vm: vm,
          builder: (context) => CheckboxListTile(
            value: context
                .select<HabitSummaryViewModel, HabitDisplaySearchOptions>(
                    (vm) => vm.searchOptions)
                .activated,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: widget.ongoingChanged,
            title: Text("Ongoing"),
          ),
        ),
        _popMenuItemBuilder(
          context,
          vm: vm,
          builder: (context) => CheckboxListTile(
            value: context
                .select<HabitSummaryViewModel, HabitDisplaySearchOptions>(
                    (vm) => vm.searchOptions)
                .completed,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: widget.completedChanged,
            title: Text(
                l10n?.habitDisplay_statsMenu_completedTileText ?? "Completed"),
          ),
        ),
        div,
        const PopupMenuItem(
            enabled: false,
            child: GroupTitleListTile(title: Text("Habit Type"))),
        ...HabitType.values
            .whereNot((e) => e == HabitType.unknown)
            .map((e) => _popMenuItemBuilder(
                  context,
                  vm: vm,
                  builder: (context) => CheckboxListTile(
                    value: context
                        .select<HabitSummaryViewModel,
                            HabitDisplaySearchOptions>((vm) => vm.searchOptions)
                        .types
                        .contains(e),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: typeChanged != null
                        ? (value) => typeChanged((e, value))
                        : null,
                    title: Text(e.getTypeName(l10n)),
                  ),
                )),
        if (!options.isFilterEmpty) ...[
          div,
          PopupMenuItem(
              onTap: widget.onClearFilterPressed,
              child: ListTile(
                leading: Icon(Icons.filter_alt_off_outlined),
                title: Text("Clear Filters"),
                iconColor: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.error,
              )),
        ]
      ],
      icon: _SearchFilterIcon(
        filtered: !options.isFilterEmpty,
        opacity: _menuOpen ? 0.2 : 1.0,
      ),
    );
  }
}

class _SearchFilterIcon extends StatelessWidget {
  final double opacity;
  final bool filtered;

  const _SearchFilterIcon({required this.filtered, this.opacity = 1.0});

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: filtered,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: kThemeAnimationDuration,
        child: const Icon(Icons.filter_alt_outlined),
      ),
    );
  }
}

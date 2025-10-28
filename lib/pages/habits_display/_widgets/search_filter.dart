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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_form.dart';
import '../../../providers/habit_summary.dart';
import '../../../widgets/widgets.dart';

Future<HabitDisplaySearchOptions?> showSearchFilterBottomSheet({
  required BuildContext context,
  HabitDisplaySearchOptions? options,
}) =>
    showModalBottomSheet<HabitDisplaySearchOptions>(
      context: context,
      enableDrag: false,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => SearchFilterBottomSheet(
        options: options,
        keepOptions: true,
      ),
    );

class SearchFilterIcon extends StatelessWidget {
  final double opacity;
  final bool filtered;

  const SearchFilterIcon(
      {super.key, required this.filtered, this.opacity = 1.0});

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

class SearchFilterPopupMenuButton extends StatefulWidget {
  final PopupMenuPosition? position;
  final Offset? offset;
  final ValueChanged<bool?>? ongoingChanged;
  final ValueChanged<bool?>? completedChanged;
  final ValueChanged<(HabitType, bool?)>? typeChanged;
  final VoidCallback? onClearFilterPressed;

  const SearchFilterPopupMenuButton({
    super.key,
    this.position,
    this.offset,
    this.ongoingChanged,
    this.completedChanged,
    this.typeChanged,
    this.onClearFilterPressed,
  });

  @override
  State<SearchFilterPopupMenuButton> createState() =>
      _SearchFilterPopupMenuButtonState();
}

class _SearchFilterPopupMenuButtonState
    extends State<SearchFilterPopupMenuButton> {
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
                leading: const Icon(Icons.filter_alt_off_outlined),
                title: Text("Clear Filters"),
                iconColor: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.error,
              )),
        ]
      ],
      icon: SearchFilterIcon(
        filtered: !options.isFilterEmpty,
        opacity: _menuOpen ? 0.2 : 1.0,
      ),
    );
  }
}

class SearchFilterIconButton extends StatelessWidget {
  final VoidCallback? onPreesed;

  const SearchFilterIconButton({super.key, this.onPreesed});

  @override
  Widget build(BuildContext context) {
    final options =
        context.select<HabitSummaryViewModel, HabitDisplaySearchOptions>(
            (vm) => vm.searchOptions);
    return IconButton(
      icon: SearchFilterIcon(filtered: !options.isFilterEmpty),
      onPressed: onPreesed,
    );
  }
}

class SearchFilterBottomSheet extends StatefulWidget {
  final HabitDisplaySearchOptions initOptions;
  final bool keepOptions;

  const SearchFilterBottomSheet({
    super.key,
    HabitDisplaySearchOptions? options,
    this.keepOptions = false,
  }) : initOptions = options ?? const HabitDisplaySearchOptions.empty();

  @override
  State<StatefulWidget> createState() => _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late HabitDisplaySearchOptions _options;

  bool get canSave => widget.initOptions != _options;

  bool get filtered => !_options.isFilterEmpty;

  @override
  void initState() {
    super.initState();
    _options = widget.initOptions;
  }

  @override
  void didUpdateWidget(covariant SearchFilterBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.keepOptions) _options = widget.initOptions;
  }

  void _pop([HabitDisplaySearchOptions? result]) =>
      Navigator.of(context).pop(result ?? _options);

  void _onPopInvokedWithResult(bool didPop, HabitDisplaySearchOptions? result) {
    if (didPop || !mounted) return;
    _pop(result);
  }

  void _onOngoingChanged(bool? value) {
    if (value == null || value == _options.activated) return;
    setState(() {
      _options = _options.copyWith(activated: value);
    });
  }

  void _onCompletedChanged(bool? value) {
    if (value == null || value == _options.completed) return;
    setState(() {
      _options = _options.copyWith(completed: value);
    });
  }

  void _onHabitTypeChanged(HabitType type, bool? value) {
    if (value == null) return;
    final newTypes =
        value ? {..._options.types, type} : ({..._options.types}..remove(type));
    setState(() {
      _options = _options.copyWith(types: newTypes);
    });
  }

  void _doClearFilter() {
    _pop(const HabitDisplaySearchOptions.empty());
  }

  void _doSave() => _pop();

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return PopScope<HabitDisplaySearchOptions>(
      canPop: !filtered,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: EnhancedSafeArea.all(
        top: false,
        left: true,
        right: true,
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CheckboxListTile(
                      value: _options.activated,
                      controlAffinity: ListTileControlAffinity.leading,
                      visualDensity: VisualDensity.compact,
                      onChanged: _onOngoingChanged,
                      title: Text("Ongoing"),
                    ),
                    CheckboxListTile(
                      value: _options.completed,
                      controlAffinity: ListTileControlAffinity.leading,
                      visualDensity: VisualDensity.compact,
                      onChanged: _onCompletedChanged,
                      title: Text(
                          l10n?.habitDisplay_statsMenu_completedTileText ??
                              "Completed"),
                    ),
                    const HabitDivider(),
                    const GroupTitleListTile(
                      title: Text("Habit Type"),
                      visualDensity: VisualDensity.compact,
                    ),
                    ...HabitType.values
                        .whereNot((e) => e == HabitType.unknown)
                        .map(
                          (e) => CheckboxListTile(
                            value: _options.types.contains(e),
                            visualDensity: VisualDensity.compact,
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (value) => _onHabitTypeChanged(e, value),
                            title: Text(e.getTypeName(l10n)),
                          ),
                        ),
                  ],
                ),
              ),
            ),
            AppUiLayoutBuilder(builder: (context, uiLayout, child) {
              final filtered =
                  this.filtered || !widget.initOptions.isFilterEmpty;

              final saveButton = ListTile(
                minVerticalPadding: 0.0,
                title: FilledButton(
                    onPressed: canSave ? _doSave : null, child: Text("Save")),
              );

              final clearButton = ListTile(
                enabled: filtered,
                minVerticalPadding: 0.0,
                title: TextButton.icon(
                    onPressed: filtered ? _doClearFilter : null,
                    label: Text("Clear Filters"),
                    icon: const Icon(Icons.filter_alt_off_outlined)),
              );

              return switch (uiLayout) {
                UiLayoutType.s => ExpandedSection(
                    expand: filtered || canSave,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HabitDivider(),
                        ExpandedSection(expand: canSave, child: saveButton),
                        ExpandedSection(expand: filtered, child: clearButton),
                      ],
                    ),
                  ),
                UiLayoutType.l => ExpandedSection(
                    expand: filtered || canSave,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HabitDivider(),
                        Row(
                            children: [saveButton, clearButton]
                                .map((e) => Expanded(child: e))
                                .toList()),
                      ],
                    ),
                  ),
              };
            }),
          ],
        ),
      ),
    );
  }
}

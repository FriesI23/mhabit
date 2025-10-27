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

import '../../../l10n/localizations.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_form.dart';
import '../../../providers/habit_summary.dart';
import '../../../widgets/widgets.dart';

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

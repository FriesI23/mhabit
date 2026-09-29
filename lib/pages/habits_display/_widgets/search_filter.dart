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
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_form.dart';
import '../../../widgets/widgets.dart';
import '../_providers/habit_summary.dart';

class SearchFilterIcon extends StatelessWidget {
  final double opacity;
  final bool filtered;

  const SearchFilterIcon({
    super.key,
    required this.filtered,
    this.opacity = 1.0,
  });

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
  final MenuController? controller;
  final ValueChanged<bool?>? ongoingChanged;
  final ValueChanged<bool?>? completedChanged;
  final ValueChanged<(HabitType, bool?)>? typeChanged;
  final VoidCallback? onClearFilterPressed;

  const SearchFilterPopupMenuButton({
    super.key,
    this.controller,
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
  late final FocusNode _triggerFocusNode;
  final _firstMenuItemFocusNode = FocusNode(
    debugLabel: 'Search filter first menu item',
  );
  bool _keyboardActivationPending = false;

  @override
  void initState() {
    super.initState();
    _triggerFocusNode = FocusNode(
      debugLabel: 'Search filter menu trigger',
      onKeyEvent: _handleTriggerKeyEvent,
    );
  }

  KeyEventResult _handleTriggerKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter ||
            event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
      _keyboardActivationPending = true;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _triggerFocusNode.dispose();
    _firstMenuItemFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const div = PopupMenuDivider();
    final typeChanged = widget.typeChanged;
    final l10n = L10n.of(context);
    final options = context
        .select<HabitSummaryViewModel, HabitDisplaySearchOptions>(
          (vm) => vm.searchOptions,
        );
    return MenuAnchor(
      controller: widget.controller,
      animated: true,
      childFocusNode: _triggerFocusNode,
      builder: (context, controller, child) {
        void onPressed() {
          if (controller.isOpen) {
            controller.close();
            return;
          }
          final focusMenu = _keyboardActivationPending;
          _keyboardActivationPending = false;
          controller.open();
          if (!focusMenu) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && controller.isOpen) {
              _firstMenuItemFocusNode.requestFocus();
            }
          });
        }

        return IconButton(
          focusNode: _triggerFocusNode,
          icon: SearchFilterIcon(
            filtered: !options.isFilterEmpty,
            opacity: controller.isOpen ? 0.2 : 1.0,
          ),
          tooltip: l10n?.habitDisplay_searchFilter_tooltips,
          onPressed: onPressed,
        );
      },
      menuChildren: [
        Tooltip(
          message: l10n?.habitDisplay_searchFilter_ongoing_desc,
          child: CheckboxListTile(
            focusNode: _firstMenuItemFocusNode,
            value: options.activated,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: widget.ongoingChanged,
            title: Text(l10n?.habitDisplay_searchFilter_ongoing ?? "Onging"),
          ),
        ),
        CheckboxListTile(
          value: options.completed,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: widget.completedChanged,
          title: Text(l10n?.habitDisplay_searchFilter_completed ?? "Completed"),
        ),
        div,
        GroupTitleListTile(
          title: Text(
            l10n?.habitDisplay_searchFilter_habitType_groupTitle ??
                "Habit Type",
          ),
        ),
        ...HabitType.values
            .whereNot((e) => e == HabitType.unknown)
            .map(
              (e) => CheckboxListTile(
                value: options.types.contains(e),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: typeChanged != null
                    ? (value) => typeChanged((e, value))
                    : null,
                title: Text(e.getTypeName(l10n)),
              ),
            ),
        if (!options.isFilterEmpty) ...[
          div,
          ListTile(
            leading: const Icon(Icons.filter_alt_off_outlined),
            title: Text(
              l10n?.habitDisplay_searchFilter_clearFilter ?? "Clear Filters",
            ),
            iconColor: Theme.of(context).colorScheme.error,
            textColor: Theme.of(context).colorScheme.error,
            onTap: widget.onClearFilterPressed,
          ),
        ],
      ],
    );
  }
}

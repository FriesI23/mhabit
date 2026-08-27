// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../../l10n/localizations.dart';
import '../../../../routes/navigator_helpers.dart';
import '../../../../storage/db/handlers/habit.dart';

/// Registers the Apple Habits-display FAB with the adaptive shell.
///
/// The shell owns the persistent button and its placement. This feature
/// adapter owns only the localized action description and callback.
class HabitDisplayAppleFab extends StatefulWidget {
  const HabitDisplayAppleFab({
    super.key,
    required this.visible,
    required this.onCreated,
    required this.child,
  });

  final bool visible;
  final ValueChanged<HabitDBCell> onCreated;
  final Widget child;

  @override
  State<HabitDisplayAppleFab> createState() => _HabitDisplayAppleFabState();
}

class _HabitDisplayAppleFabState extends State<HabitDisplayAppleFab> {
  CupertinoNavigationPrimaryAction? _action;
  bool _navigationPending = false;

  CupertinoNavigationPrimaryAction _resolveAction(BuildContext context) {
    final label = L10n.of(context)?.habitDisplay_fab_text ?? 'New Habit';
    final current = _action;
    if (current != null && current.label == label) return current;
    return _action = CupertinoNavigationPrimaryAction(
      label: label,
      icon: const Icon(CupertinoIcons.add),
      onPressed: () => unawaited(_handlePressed()),
    );
  }

  Future<void> _handlePressed() async {
    if (!mounted || _navigationPending) return;
    _navigationPending = true;
    try {
      Navigator.of(context).popUntil((route) => route.isFirst);
      final result = await naviToHabitCreatePage(context: context);
      if (!mounted || result == null) return;
      widget.onCreated(result);
    } finally {
      _navigationPending = false;
    }
  }

  @override
  Widget build(BuildContext context) => CupertinoNavigationPrimaryActionRegion(
    action: widget.visible ? _resolveAction(context) : null,
    child: widget.child,
  );
}

// Copyright 2026 Fries_I23
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

import 'package:flutter/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../storage/db/handlers/habit.dart';
import 'apple/habit_display_fab.dart';

/// Dispatches the Habits-display FAB region to the active visual style.
///
/// Material owns its FAB through the enclosing Scaffold slot. Apple declares
/// its action here while the adaptive shell owns the persistent button.
class HabitDisplayFabRegion extends StatelessWidget {
  const HabitDisplayFabRegion({
    super.key,
    required this.appleVisible,
    required this.onCreated,
    required this.child,
  });

  final bool appleVisible;
  final ValueChanged<HabitDBCell> onCreated;
  final Widget child;

  @override
  Widget build(BuildContext context) => switch (AdaptiveStyle.of(context)) {
    AdaptiveStyle.material => child,
    AdaptiveStyle.apple => HabitDisplayAppleFab(
      visible: appleVisible,
      onCreated: onCreated,
      child: child,
    ),
  };
}

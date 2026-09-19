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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../common/consts.dart';
import '../../../extensions/custom_color_extensions.dart';
import '../../../extensions/group_icon_extensions.dart';
import '../../../models/habit_group.dart';
import '../../../theme/color.dart';
import 'group_manage_item_actions.dart';

part 'group_manage_grid_item.dart';
part 'group_manage_list_item.dart';

Color _appleItemSurface(BuildContext context, {required bool selected}) {
  final colors = Theme.of(context).colorScheme;
  final sectionSurface = CupertinoDynamicColor.resolve(
    AdaptiveListTheme.of(context).surfaceColor ?? colors.surfaceContainer,
    context,
  );
  return selected
      ? Color.alphaBlend(
          CupertinoTheme.of(context).primaryColor.withValues(alpha: 0.15),
          sectionSurface,
        )
      : sectionSurface;
}

class _GroupIndicator extends StatelessWidget {
  const _GroupIndicator({required this.group, required this.selected});

  final HabitGroupData group;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = group.color;
    final iconColor = color == null
        ? null
        : Theme.of(context).extension<CustomColors>()?.getColor(
            color,
            brightness: Theme.of(context).brightness,
          );
    return _SelectionIndicator(
      selected: selected,
      icon: group.icon?.iconData ?? defaultGroupIcon,
      color: iconColor,
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({
    required this.selected,
    required this.icon,
    required this.color,
  });
  final bool selected;
  final IconData icon;
  final Color? color;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 24,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: selected
          ? switch (AdaptiveStyle.of(context)) {
              AdaptiveStyle.apple => Icon(
                CupertinoIcons.check_mark_circled_solid,
                key: const ValueKey('selected'),
                color: CupertinoTheme.of(context).primaryColor,
                size: 24,
              ),
              AdaptiveStyle.material => Container(
                key: const ValueKey('selected'),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            }
          : Icon(icon, key: const ValueKey('icon'), color: color, size: 24),
    ),
  );
}

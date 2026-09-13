// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../extensions/adaptive_style_extensions.dart';
import '../../../extensions/custom_color_extensions.dart';
import '../../../models/habit_color.dart';
import '../../../theme/color.dart';

class HabitDetailAppBar extends StatelessWidget {
  final HabitColor? color;
  final Widget? title;
  final WidgetBuilder? actionBuilder;

  const HabitDetailAppBar({
    super.key,
    this.color,
    this.title,
    this.actionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = color != null
        ? theme.extension<CustomColors>()?.getColor(
            color!,
            brightness: theme.brightness,
          )
        : null;
    final effectiveTitle = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: title != null
          ? DefaultTextStyle.merge(
              style: TextStyle(color: foregroundColor),
              child: title!,
            )
          : null,
    );
    final actions = [if (actionBuilder != null) actionBuilder!(context)];
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => _MaterialHabitDetailAppBar(
        title: effectiveTitle,
        actions: actions,
        foregroundColor: foregroundColor,
      ),
      AdaptiveStyle.apple => _AppleHabitDetailAppBar(
        title: effectiveTitle,
        actions: actions,
        foregroundColor: foregroundColor,
      ),
    };
  }
}

class _MaterialHabitDetailAppBar extends StatelessWidget {
  const _MaterialHabitDetailAppBar({
    required this.title,
    required this.actions,
    required this.foregroundColor,
  });

  final Widget title;
  final List<Widget> actions;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final useMediumTitle =
        WindowSize.of(context).width == WindowSizeClass.compact;
    const styles = AppBarStyles(
      material: AppBarMaterialStyle(floating: false, snap: false, pinned: true),
    );
    return useMediumTitle
        ? AdaptiveSliverAppBar.materialMedium(
            height: AppAdaptiveStyle.materialToolbarHeight,
            styles: styles,
            title: title,
            leading: AdaptiveBackButton.material(
              type: AdaptiveBackButtonType.back,
              color: foregroundColor,
            ),
            actions: actions,
          )
        : AdaptiveSliverAppBar.material(
            height: AppAdaptiveStyle.materialToolbarHeight,
            styles: styles,
            title: title,
            leading: AdaptiveBackButton.material(
              type: AdaptiveBackButtonType.back,
              color: foregroundColor,
            ),
            actions: actions,
          );
  }
}

class _AppleHabitDetailAppBar extends StatelessWidget {
  const _AppleHabitDetailAppBar({
    required this.title,
    required this.actions,
    required this.foregroundColor,
  });

  final Widget title;
  final List<Widget> actions;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) => AdaptiveSliverAppBar.apple(
    height: AppAdaptiveStyle.appleToolbarHeight,
    styles: AppBarStyles(
      apple: AppBarAppleStyle(
        collapsible: WindowSize.of(context).width == WindowSizeClass.compact,
      ),
    ),
    title: title,
    leading: AdaptiveBackButton.apple(
      type: AdaptiveBackButtonType.back,
      color: foregroundColor,
    ),
    actions: actions,
  );
}

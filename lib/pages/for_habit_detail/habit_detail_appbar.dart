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

import '../../extension/custom_color_extensions.dart';
import '../../model/habit_form.dart';
import '../../theme/color.dart';
import '../../widgets/widgets.dart';

class HabitDetailAppBar extends StatelessWidget {
  final HabitColorType? colorType;
  final Widget? title;
  final WidgetBuilder? actionBuilder;

  const HabitDetailAppBar({
    super.key,
    this.colorType,
    this.title,
    this.actionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final CustomColors? colorData = themeData.extension<CustomColors>();

    final color = colorType != null ? colorData?.getColor(colorType!) : null;
    final titleFont = themeData.textTheme.titleLarge;

    return SliverAppBar(
      pinned: true,
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: title != null
            ? titleFont != null
                ? DefaultTextStyle(
                    style: titleFont.copyWith(color: color), child: title!)
                : title
            : null,
      ),
      leading: PageBackButton(reason: PageBackReason.back, color: color),
      actions: [if (actionBuilder != null) actionBuilder!(context)],
    );
  }
}

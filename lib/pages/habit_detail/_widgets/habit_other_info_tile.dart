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

class HabitOtherInfoTile extends StatelessWidget {
  final Widget? title;
  final Widget? subTitle;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;

  const HabitOtherInfoTile({
    super.key,
    this.title,
    this.subTitle,
    this.leading,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextTheme textTheme = themeData.textTheme;
    Widget? titleWidget = title, subtitleWidget = subTitle;

    if (title != null && textTheme.bodySmall != null) {
      titleWidget = DefaultTextStyle(
        style: textTheme.bodySmall!.copyWith(
          color: themeData.colorScheme.onSurfaceVariant,
        ),
        child: title!,
      );
    }

    if (subTitle != null && textTheme.bodyLarge != null) {
      subtitleWidget = DefaultTextStyle(
        style: textTheme.bodyLarge!,
        child: subTitle!,
      );
    }

    return ListTile(
      dense: true,
      title: titleWidget,
      subtitle: subtitleWidget,
      leading: leading,
      visualDensity: VisualDensity.compact,
      contentPadding: padding ?? EdgeInsets.zero,
    );
  }
}

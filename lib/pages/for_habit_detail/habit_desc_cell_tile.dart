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

class HabitDescCellTile extends StatelessWidget {
  final String titleText;
  final String subtitleText;
  final String? tooltipText;
  final InlineSpan? tooltipRichText;

  const HabitDescCellTile({
    super.key,
    this.titleText = '',
    this.subtitleText = '',
    this.tooltipText,
    this.tooltipRichText,
  });

  @override
  Widget build(BuildContext context) {
    Widget builListTile(BuildContext context) {
      final themeData = Theme.of(context);
      final textTheme = themeData.textTheme;
      final titleStyle = textTheme.bodySmall
          ?.copyWith(color: themeData.colorScheme.onSurfaceVariant);
      return ListTile(
        title: Center(
          child: Text(
            titleText,
            style: titleStyle,
            textAlign: TextAlign.center,
          ),
        ),
        subtitle: Center(
          child: Text(
            subtitleText,
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        contentPadding: EdgeInsets.zero,
      );
    }

    if (tooltipText != null || tooltipRichText != null) {
      return Tooltip(
        message: tooltipText,
        richMessage: tooltipRichText,
        excludeFromSemantics: true,
        triggerMode: TooltipTriggerMode.tap,
        preferBelow: true,
        child: builListTile(context),
      );
    } else {
      return builListTile(context);
    }
  }
}

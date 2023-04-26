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
import 'package:intl/intl.dart';

import '../../extension/datetime_extensions.dart';

class DateContainer extends StatelessWidget {
  final DateTime? date;
  final double? width;
  final EdgeInsetsGeometry? padding;
  const DateContainer({super.key, this.date, this.width, this.padding});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var labelStyle = theme.textTheme.labelMedium
        ?.copyWith(color: theme.colorScheme.onSurface);

    var today = DateTime.now();
    var showDate = date ?? today;
    var content = <Widget>[];
    if (showDate.isSameDate(today)) {
      labelStyle = labelStyle?.copyWith(color: theme.colorScheme.primary);
    } else if (showDate.difference(today).inDays.abs() == 1) {
      labelStyle = labelStyle?.copyWith(color: theme.colorScheme.secondary);
    }
    var localeString = Localizations.localeOf(context).toLanguageTag();
    content.addAll([
      Text(DateFormat("MM/dd", localeString).format(showDate),
          style: labelStyle),
      Text(DateFormat("E", localeString).format(showDate), style: labelStyle),
    ]);
    return Container(
      padding: padding ?? const EdgeInsets.all(8.0),
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: content,
      ),
    );
  }
}

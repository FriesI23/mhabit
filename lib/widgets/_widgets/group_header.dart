// Copyright 2026 Fries_I23
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

import '../../common/consts.dart';
import '../../extensions/custom_color_extensions.dart';
import '../../extensions/group_icon_extensions.dart';
import '../../l10n/localizations.dart';
import '../../models/habit_summary.dart';
import '../../theme/color.dart' show CustomColors;

class GroupHeader extends StatelessWidget {
  final GroupHeaderSortCache header;
  final bool isExpanded;
  final VoidCallback onTap;

  const GroupHeader({
    super.key,
    required this.header,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final customColors = themeData.extension<CustomColors>();
    final colorScheme = themeData.colorScheme;
    final textTheme = themeData.textTheme;

    final resolvedColor =
        (header.color != null && customColors != null
            ? customColors.getColor(
                header.color!,
                brightness: themeData.brightness,
              )
            : null) ??
        colorScheme.primary;

    final iconData =
        header.icon?.iconData ??
        (header.isUncategorized ? noGroupIcon : defaultGroupIcon);

    return InkWell(
      onTap: onTap,
      child: _GroupHeaderRow(
        iconData: iconData,
        resolvedColor: resolvedColor,
        colorScheme: colorScheme,
        textTheme: textTheme,
        name: header.isUncategorized
            ? (L10n.of(context)?.habitGroup_uncategorized ?? 'Uncategorized')
            : header.name,
        count: header.count,
        isExpanded: isExpanded,
      ),
    );
  }
}

class _GroupHeaderRow extends StatelessWidget {
  final IconData iconData;
  final Color resolvedColor;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final String name;
  final int count;
  final bool isExpanded;

  const _GroupHeaderRow({
    required this.iconData,
    required this.resolvedColor,
    required this.colorScheme,
    required this.textTheme,
    required this.name,
    required this.count,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      child: Row(
        children: [
          Icon(iconData, color: resolvedColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: name,
                    style: textTheme.titleSmall?.copyWith(
                      color: resolvedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: '  $count',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ExpandIcon(
            onPressed: null,
            isExpanded: isExpanded,
            disabledColor: resolvedColor,
          ),
        ],
      ),
    );
  }
}

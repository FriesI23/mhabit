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

import '../../../common/consts.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_group_display.dart';
import '../../../theme/icon.dart';

/// A pre-configured [Icon] for a group sort type and direction.
class GroupTypeSortIcon extends StatelessWidget {
  const GroupTypeSortIcon({
    super.key,
    required this.groupType,
    required this.direction,
    this.size,
    this.color,
  });

  final HabitDisplayGroupType groupType;
  final HabitDisplaySortDirection direction;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(groupTypeIcon, size: size, color: color);
  }

  IconData get groupTypeIcon => switch (groupType) {
    HabitDisplayGroupType.name => switch (direction) {
      HabitDisplaySortDirection.asc => HabitSortIcons.sortalphabeticalascending,
      HabitDisplaySortDirection.desc =>
        HabitSortIcons.sortalphabeticaldescending,
    },
    HabitDisplayGroupType.colorType => switch (direction) {
      HabitDisplaySortDirection.asc => HabitSortIcons.sortboolascending,
      HabitDisplaySortDirection.desc => HabitSortIcons.sortbooldescending,
    },
    HabitDisplayGroupType.createDate => switch (direction) {
      HabitDisplaySortDirection.asc => HabitSortIcons.sortcalendarascending,
      HabitDisplaySortDirection.desc => HabitSortIcons.sortcalendardescending,
    },
    HabitDisplayGroupType.habitCount => switch (direction) {
      HabitDisplaySortDirection.asc => HabitSortIcons.sortascending,
      HabitDisplaySortDirection.desc => HabitSortIcons.sortdescending,
    },
    HabitDisplayGroupType.manual => switch (direction) {
      HabitDisplaySortDirection.asc => HabitSortIcons.sortascending,
      HabitDisplaySortDirection.desc => HabitSortIcons.sortdescending,
    },
  };
}

/// An [Icon] for a grouping configuration.
///
/// When [groupType] is `null` (grouping off) shows [hideGroupingIcon];
/// otherwise delegates to [GroupTypeSortIcon].
class GroupingIcon extends StatelessWidget {
  const GroupingIcon({
    super.key,
    this.groupType,
    required this.direction,
    this.size,
    this.color,
  });

  final HabitDisplayGroupType? groupType;
  final HabitDisplaySortDirection direction;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (groupType == null) {
      return Icon(hideGroupingIcon, size: size, color: color);
    }
    return GroupTypeSortIcon(
      groupType: groupType!,
      direction: direction,
      size: size,
      color: color,
    );
  }
}

/// A [Text] widget that renders the localized title for a grouping config.
///
/// When [groupType] is `null` renders the localized "none"/"Flat" label.
/// Otherwise renders the localized group-type name, optionally suffixed
/// with the sort direction when [groupDirection] is non-null.
class GroupingTitle extends StatelessWidget {
  const GroupingTitle({
    super.key,
    required this.groupType,
    this.groupDirection,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final HabitDisplayGroupType? groupType;
  final HabitDisplaySortDirection? groupDirection;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Text(_buildTitle(l10n), style: style);
  }

  String _buildTitle(L10n? l10n) {
    final type = groupType;
    if (type == null) {
      return l10n?.habitDisplay_groupTypeDialog_none ?? 'Flat';
    }

    final directionName = switch (groupDirection) {
      null => '',
      HabitDisplaySortDirection.asc =>
        l10n?.habitDisplay_sortDirection_asc ?? '(Asc)',
      HabitDisplaySortDirection.desc =>
        l10n?.habitDisplay_sortDirection_Desc ?? '(Desc)',
    };

    String withDirection(String title) =>
        directionName.isEmpty ? title : '$title $directionName';

    return switch (type) {
      HabitDisplayGroupType.name => withDirection(
        l10n?.habitDisplay_groupType_name ?? 'By Name',
      ),
      HabitDisplayGroupType.colorType => withDirection(
        l10n?.habitDisplay_groupType_colorType ?? 'By Color',
      ),
      HabitDisplayGroupType.createDate => withDirection(
        l10n?.habitDisplay_groupType_createDate ?? 'By Creation Date',
      ),
      HabitDisplayGroupType.habitCount => withDirection(
        l10n?.habitDisplay_groupType_habitCount ?? 'By Habit Count',
      ),
      HabitDisplayGroupType.manual => withDirection(
        l10n?.habitDisplay_groupType_manual ?? 'Manual',
      ),
    };
  }
}

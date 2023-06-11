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
import 'package:provider/provider.dart';

import '../../l10n/localizations.dart';
import '../../model/habit_display.dart';
import '../../provider/app_theme.dart';
import '../../provider/habits_filter.dart';
import '../../provider/habits_sort.dart';
import '../../theme/color.dart';
import '../../theme/icon.dart';

Future<HabitDisplayMainMenuDialogOpr?> showHabitDisplayMainMenuDialog({
  required BuildContext context,
  required HabitDisplaySortType sortType,
  required HabitDisplaySortDirection sortDirection,
  required HabitsFilterViewModel habitFilter,
  required AppThemeViewModel appTheme,
}) async {
  return showDialog<HabitDisplayMainMenuDialogOpr>(
    context: context,
    builder: (context) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appTheme),
        ChangeNotifierProvider.value(value: habitFilter),
      ],
      child: HabitDisplayMainMenuDialog(
        themeType: context.read<AppThemeViewModel>().themeType,
        sortType: sortType,
        sortDirection: sortDirection,
        onAppThemeModePressed: (brightness) {
          context.read<AppThemeViewModel>().onTapChangeThemeType(brightness);
        },
      ),
    ),
  );
}

enum HabitDisplayMainMenuDialogOpr { none, showSortMenu, openSettings }

class HabitDisplayMainMenuDialog extends StatefulWidget {
  final AppThemeType themeType;
  final HabitDisplaySortType sortType;
  final HabitDisplaySortDirection sortDirection;
  final void Function(Brightness brightness)? onAppThemeModePressed;

  const HabitDisplayMainMenuDialog({
    super.key,
    required this.themeType,
    required this.sortType,
    required this.sortDirection,
    this.onAppThemeModePressed,
  });

  @override
  State<StatefulWidget> createState() => _HabitDisplayMainMenuDialog();
}

class _HabitDisplayMainMenuDialog extends State<HabitDisplayMainMenuDialog> {
  void _naviPopWithOp(BuildContext context, HabitDisplayMainMenuDialogOpr op) {
    Navigator.of(context).pop<HabitDisplayMainMenuDialogOpr>(op);
  }

  @override
  Widget build(BuildContext context) {
    Widget buildHeroIcon(BuildContext context, Brightness brightness) {
      Icon heroIcon;
      if (brightness == Brightness.light) {
        heroIcon = const Icon(Icons.light_mode_outlined);
      } else {
        heroIcon = const Icon(Icons.dark_mode_outlined);
      }
      return heroIcon;
    }

    var sysBrightness = MediaQuery.of(context).platformBrightness;
    var appBrightness = Theme.of(context).brightness;
    var habitFilter = context.read<HabitsFilterViewModel>();

    return AlertDialog(
      scrollable: true,
      icon: buildHeroIcon(context, appBrightness),
      contentPadding: const EdgeInsets.only(bottom: 24, top: 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AppThemeListTile(
            themeType: widget.themeType,
            onPressed: widget.onAppThemeModePressed != null
                ? () => widget.onAppThemeModePressed!(sysBrightness)
                : null,
          ),
          _SortTypeListTile(
            sortType: widget.sortType,
            sortDirection: widget.sortDirection,
            onPressed: () => _naviPopWithOp(
                context, HabitDisplayMainMenuDialogOpr.showSortMenu),
          ),
          const Divider(),
          _HabitsDisplayFilterListView(
            habitsDisplayFilter: habitFilter.habitsDisplayFilter,
            onFetchNewDisplayFilter: (newFilter) => setState(() {
              habitFilter.setNewHabitsDisplayFilter(newFilter);
            }),
          ),
          const Divider(),
          _SettingListTile(
            onPressed: () => _naviPopWithOp(
                context, HabitDisplayMainMenuDialogOpr.openSettings),
          ),
        ],
      ),
    );
  }
}

class _AppThemeListTile extends StatelessWidget {
  final AppThemeType themeType;
  final VoidCallback? onPressed;

  const _AppThemeListTile({required this.themeType, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final Widget text;
    final Widget icon;

    final l10n = L10n.of(context);

    switch (themeType) {
      case AppThemeType.light:
        text = l10n != null
            ? Text(l10n.habitDisplay_mainMenu_lightTheme)
            : const Text("Light Theme");
        icon = const Icon(Icons.light_mode_rounded);
        break;
      case AppThemeType.dark:
        text = l10n != null
            ? Text(l10n.habitDisplay_mainMenu_darkTheme)
            : const Text("Dart Theme");
        icon = const Icon(Icons.dark_mode_rounded);
        break;
      default:
        text = l10n != null
            ? Text(l10n.habitDisplay_mainMenu_followSystemTheme)
            : const Text("Follow System");
        icon = const Icon(Icons.hdr_auto_rounded);
        break;
    }
    return ListTile(
      leading: icon,
      iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
      title: text,
      onTap: onPressed,
    );
  }
}

class _SortTypeListTile extends StatelessWidget {
  final HabitDisplaySortType sortType;
  final HabitDisplaySortDirection sortDirection;
  final VoidCallback? onPressed;

  const _SortTypeListTile({
    required this.sortType,
    required this.sortDirection,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
      leading: Icon(HabitsSortViewModel.getSortIcon(sortType, sortDirection)),
      title: Text(
        HabitsSortViewModel.getSortTitle(sortType, sortDirection,
            l10n: L10n.of(context)),
      ),
      trailing: const Icon(Icons.arrow_right_outlined),
      onTap: onPressed,
    );
  }
}

class _HabitsDisplayFilterListView extends StatelessWidget {
  final HabitsDisplayFilter habitsDisplayFilter;
  final void Function(HabitsDisplayFilter newFilter)? onFetchNewDisplayFilter;

  const _HabitsDisplayFilterListView({
    required this.habitsDisplayFilter,
    this.onFetchNewDisplayFilter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
          title: l10n != null
              ? Text(l10n.habitDisplay_statsMenu_archivedTileText)
              : const Text("Show Archived"),
          secondary: const Icon(Icons.inventory_2_outlined),
          enabled: habitsDisplayFilter.copyWith(allowArchivedHabits: false) !=
              HabitsDisplayFilter.allFalse,
          value: habitsDisplayFilter.allowArchivedHabits,
          onChanged: (value) {
            var newFilter =
                habitsDisplayFilter.copyWith(allowArchivedHabits: value);
            if (newFilter != HabitsDisplayFilter.allFalse) {
              onFetchNewDisplayFilter?.call(newFilter);
            }
          },
        ),
        CheckboxListTile(
          title: l10n != null
              ? Text(l10n.habitDisplay_statsMenu_inProgresTileText)
              : const Text("Show Completed"),
          secondary: const Icon(HabitProgressIcons.progress_50percent),
          enabled: habitsDisplayFilter.copyWith(allowCompleteHabits: false) !=
              HabitsDisplayFilter.allFalse,
          value: habitsDisplayFilter.allowCompleteHabits,
          onChanged: (value) {
            var newFilter =
                habitsDisplayFilter.copyWith(allowCompleteHabits: value);
            if (newFilter != HabitsDisplayFilter.allFalse) {
              onFetchNewDisplayFilter?.call(newFilter);
            }
          },
        ),
        CheckboxListTile(
          title: l10n != null
              ? Text(l10n.habitDisplay_statsMenu_completedTileText)
              : const Text("Show Actived"),
          secondary: const Icon(HabitProgressIcons.progress_100percent),
          enabled: habitsDisplayFilter.copyWith(allowActivedHabits: false) !=
              HabitsDisplayFilter.allFalse,
          value: habitsDisplayFilter.allowActivedHabits,
          onChanged: (value) {
            var newFilter =
                habitsDisplayFilter.copyWith(allowActivedHabits: value);
            if (newFilter != HabitsDisplayFilter.allFalse) {
              onFetchNewDisplayFilter?.call(newFilter);
            }
          },
        ),
      ],
    );
  }
}

class _SettingListTile extends StatelessWidget {
  final VoidCallback? onPressed;

  const _SettingListTile({this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      title: l10n != null
          ? Text(l10n.habitDisplay_mainMenu_settingTileText)
          : const Text("Settings"),
      leading: const Icon(Icons.settings_outlined),
      iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
      onTap: onPressed,
    );
  }
}

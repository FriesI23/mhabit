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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../common/consts.dart';
import '../../../common/utils.dart';
import '../../../extensions/colorscheme_extensions.dart';
import '../../../extensions/group_icon_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_group.dart';
import '../../../widgets/widgets.dart';

class HabitEditGroupTile extends StatelessWidget {
  final List<HabitGroupData> groups;
  final String? currentGroupId;
  final void Function(String?) onSelected;
  final Future<String> Function(String name) onCreateGroup;
  final bool loading;

  const HabitEditGroupTile({
    super.key,
    required this.groups,
    required this.currentGroupId,
    required this.onSelected,
    required this.onCreateGroup,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppUiLayoutBuilder.useScreenSize(
      builder: (context, layoutType, _) {
        final isDesktop = layoutType == UiLayoutType.l;
        return Stack(
          children: [
            Offstage(
              offstage: !isDesktop,
              child: _HabitEditGroupDesktopTile(
                groups: groups,
                currentGroupId: currentGroupId,
                onSelected: onSelected,
                onCreateGroup: onCreateGroup,
                loading: loading,
              ),
            ),
            Offstage(
              offstage: isDesktop,
              child: _HabitEditGroupMobileTile(
                groups: groups,
                currentGroupId: currentGroupId,
                onSelected: onSelected,
                onCreateGroup: onCreateGroup,
                loading: loading,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HabitEditGroupDesktopTile extends StatelessWidget {
  final List<HabitGroupData> groups;
  final String? currentGroupId;
  final void Function(String?) onSelected;
  final Future<String> Function(String name) onCreateGroup;
  final bool loading;

  const _HabitEditGroupDesktopTile({
    required this.groups,
    required this.currentGroupId,
    required this.onSelected,
    required this.onCreateGroup,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final textTheme = themeData.textTheme;
    final currentGroup = currentGroupId != null
        ? groups.firstWhereOrNull((g) => g.uuid == currentGroupId)
        : null;
    final leadingIcon = currentGroup?.icon?.iconData ?? defaultGroupIcon;
    final groupName = currentGroup?.name;
    final noGroupHint = l10n?.habitEdit_groupPicker_noGroup ?? 'No Group';

    final tileTheme = ListTileTheme.of(context);
    final startPadding =
        tileTheme.contentPadding?.resolve(TextDirection.ltr).left ?? 16;
    final leadingWidth = tileTheme.minLeadingWidth ?? 40;
    final menuOffset = Offset(startPadding + leadingWidth, 0);
    final hasGroup = currentGroup != null;

    final menuStyle = MenuStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return FilterableMenuField<String>(
      label: groupName ?? '',
      alignmentOffset: menuOffset,
      menuStyle: menuStyle,
      builder: (context, textCtrl, focusNode, menuCtrl) {
        return ListTile(
          leading: Icon(
            hasGroup ? leadingIcon : noGroupIcon,
            color: themeData.colorScheme.outline,
          ),
          title: hasGroup
              ? GestureDetector(
                  onTap: loading ? null : () => menuCtrl.open(),
                  child: Text(groupName ?? '', style: textTheme.bodyLarge),
                )
              : TextField(
                  controller: textCtrl,
                  focusNode: focusNode,
                  enabled: !loading,
                  onTap: loading ? null : () => menuCtrl.open(),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: loading
                        ? (l10n?.habitEdit_groupPicker_loading ??
                              'Loading\u2026')
                        : noGroupHint,
                    hintStyle: TextStyle(color: colorScheme.outlineOpacity64),
                    border: InputBorder.none,
                  ),
                  style: textTheme.bodyLarge,
                ),
          trailing: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: Icon(menuCtrl.isOpen ? Icons.close : Icons.search),
                  onPressed: () =>
                      menuCtrl.isOpen ? menuCtrl.close() : menuCtrl.open(),
                ),
          titleAlignment: ListTileTitleAlignment.titleHeight,
        );
      },
      menuChildrenBuilder: (query, highlightIndex) =>
          _buildMenuChildren(context, query, highlightIndex),
      onHighlightActivated: (index, query) {
        final filtered = _filterGroups(groups, query);
        final exactMatch = _hasExactMatch(groups, query);
        final hasCreate = query.isNotEmpty && !exactMatch;
        final itemCount = 1 + filtered.length + (hasCreate ? 1 : 0);
        final hi = itemCount == 0
            ? -1
            : ((index % itemCount) + itemCount) % itemCount;
        if (hi == 0) {
          onSelected(null);
        } else if (hi <= filtered.length) {
          onSelected(filtered[hi - 1].uuid);
        } else {
          onCreateGroup(query).then(onSelected);
        }
      },
    );
  }

  List<Widget> _buildMenuChildren(
    BuildContext context,
    String query,
    int highlightIndex,
  ) {
    final l10n = L10n.of(context);
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final highlightedStyle = MenuItemButton.styleFrom(
      backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
    );

    final filtered = _filterGroups(groups, query);
    final exactMatch = _hasExactMatch(groups, query);
    final hasCreate = query.isNotEmpty && !exactMatch;
    final itemCount = 1 + filtered.length + (hasCreate ? 1 : 0);
    final hi = itemCount == 0
        ? -1
        : ((highlightIndex % itemCount) + itemCount) % itemCount;
    final result = <Widget>[];

    result.add(
      MenuItemButton(
        style: hi == 0 ? highlightedStyle : null,
        leadingIcon: Icon(
          noGroupIcon,
          color: currentGroupId == null ? colorScheme.primary : null,
        ),
        onPressed: () => onSelected(null),
        child: Text(
          l10n?.habitEdit_groupPicker_noGroup ?? 'No Group',
          style: TextStyle(
            fontWeight: currentGroupId == null
                ? FontWeight.bold
                : FontWeight.normal,
            color: currentGroupId == null ? colorScheme.primary : null,
          ),
        ),
      ),
    );

    if (filtered.isNotEmpty) {
      result.add(const Divider(height: 1));
      for (var i = 0; i < filtered.length; i++) {
        final g = filtered[i];
        result.add(
          MenuItemButton(
            style: hi == 1 + i ? highlightedStyle : null,
            leadingIcon: Icon(g.icon?.iconData ?? defaultGroupIcon),
            onPressed: () => onSelected(g.uuid),
            child: Text(g.name),
          ),
        );
      }
    }

    if (hasCreate) {
      result.add(
        MenuItemButton(
          style: hi == 1 + filtered.length ? highlightedStyle : null,
          leadingIcon: Icon(Icons.add, color: colorScheme.primary),
          onPressed: () async {
            final newUUID = await onCreateGroup(query);
            onSelected(newUUID);
          },
          child: Text(
            l10n?.habitEdit_groupPicker_createGroup(query) ?? '',
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
      );
    }

    return result;
  }
}

class _HabitEditGroupMobileTile extends StatelessWidget {
  final List<HabitGroupData> groups;
  final String? currentGroupId;
  final void Function(String?) onSelected;
  final Future<String> Function(String name) onCreateGroup;
  final bool loading;

  const _HabitEditGroupMobileTile({
    required this.groups,
    required this.currentGroupId,
    required this.onSelected,
    required this.onCreateGroup,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final themeData = Theme.of(context);
    final currentGroup = currentGroupId != null
        ? groups.firstWhereOrNull((g) => g.uuid == currentGroupId)
        : null;
    final groupName = currentGroup?.name;
    final noGroupHint = l10n?.habitEdit_groupPicker_noGroup ?? 'No Group';
    final leadingIcon = currentGroup?.icon?.iconData ?? defaultGroupIcon;

    return SearchAnchor(
      viewConstraints: BoxConstraints.tight(MediaQuery.sizeOf(context)),
      viewShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context, controller) => ListTile(
        leading: Icon(
          currentGroup != null ? leadingIcon : noGroupIcon,
          color: themeData.colorScheme.outline,
        ),
        title: loading
            ? Text(l10n?.habitEdit_groupPicker_loading ?? 'Loading\u2026')
            : Text(groupName ?? noGroupHint),
        enabled: !loading,
        onTap: loading ? null : () => controller.openView(),
        titleAlignment: ListTileTitleAlignment.titleHeight,
      ),
      suggestionsBuilder: (context, controller) =>
          _buildSuggestions(context, controller.text, controller),
    );
  }

  List<Widget> _buildSuggestions(
    BuildContext context,
    String query,
    SearchController controller,
  ) {
    final l10n = L10n.of(context);
    final filtered = _filterGroups(groups, query);
    final exactMatch = _hasExactMatch(groups, query);
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final currentId = currentGroupId;

    return [
      ListTile(
        leading: Icon(
          noGroupIcon,
          color: currentId == null ? colorScheme.primary : null,
        ),
        title: Text(
          l10n?.habitEdit_groupPicker_noGroup ?? 'No Group',
          style: TextStyle(
            fontWeight: currentId == null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: currentId == null
            ? Icon(Icons.check, color: colorScheme.primary)
            : null,
        onTap: () {
          onSelected(null);
          controller.closeView('');
        },
      ),
      if (filtered.isNotEmpty) ...[
        const Divider(height: 1),
        ...filtered.map(
          (g) => ListTile(
            leading: Icon(g.icon?.iconData ?? defaultGroupIcon),
            title: Text(g.name),
            trailing: currentId == g.uuid
                ? Icon(Icons.check, color: colorScheme.primary)
                : null,
            onTap: () {
              onSelected(g.uuid);
              controller.closeView('');
            },
          ),
        ),
      ],
      if (query.isNotEmpty && !exactMatch)
        ListTile(
          leading: Icon(Icons.add, color: colorScheme.primary),
          title: Text(
            l10n?.habitEdit_groupPicker_createGroup(query) ?? '',
            style: TextStyle(color: colorScheme.primary),
          ),
          onTap: () async {
            final newUUID = await onCreateGroup(query);
            onSelected(newUUID);
            controller.closeView('');
          },
        ),
    ];
  }
}

// ---- Shared helpers ----

List<HabitGroupData> _filterGroups(List<HabitGroupData> groups, String query) {
  if (query.isEmpty) return groups;
  return groups
      .where((g) => g.name.toLowerCase().contains(query.toLowerCase()))
      .toList();
}

bool _hasExactMatch(List<HabitGroupData> groups, String query) {
  return query.isNotEmpty &&
      groups.any((g) => g.name.toLowerCase() == query.toLowerCase());
}

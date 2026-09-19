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

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../common/consts.dart';
import '../../../extensions/custom_color_extensions.dart';
import '../../../extensions/group_icon_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_color.dart';
import '../../../models/habit_group.dart';
import '../../../theme/color.dart' show CustomColors;

/// Presentation data for a root, group, or habit row. IDs must be unique in
/// the tree and stable across rebuilds. Import/progress logic stays with callers.
class HabitGroupTreeEntry {
  const HabitGroupTreeEntry({
    required this.id,
    required this.title,
    this.leading,
    this.trailing,
    this.color,
    this.icon,
    this.children = const [],
    this.initiallyExpanded = false,
    this.isUngrouped = false,
  });

  final String id;
  final Widget title;

  /// Overrides the default icon/color marker when supplied.
  final Widget? leading;
  final Widget? trailing;

  /// Optional group or habit color, resolved using the current app theme.
  final HabitColor? color;

  /// Optional group icon. Without an icon, a configured color gets a dot.
  final GroupIcon? icon;
  final List<HabitGroupTreeEntry> children;
  final bool initiallyExpanded;

  /// Marks the synthetic no-group row, which has no default group icon.
  final bool isUngrouped;
}

/// A sliver of group rows and habit leaves, optionally wrapped in a root row.
/// Expansion belongs to this widget; replacing row decorations preserves it.
/// Row slots should fit the two-line row height, which follows text scaling.
class SliverHabitGroupTree extends StatefulWidget {
  /// Maximum number of edges from a top-level entry to a descendant.
  /// The app's root/group/habit previews use only two edges.
  static const int maxEntryDepth = 32;

  const SliverHabitGroupTree({
    super.key,
    required this.groups,
    this.root,
    this.controller,
    this.onNodeToggle,
    this.showExpansionToggle = true,
    this.treeKey,
    this.expansionToggleKey,
  });

  final List<HabitGroupTreeEntry> groups;

  /// Optional external controller; otherwise a local controller is used.
  /// Attach a controller to only one tree at a time. After mounting, use
  /// `controller.getNodeFor(entry.id)` to control a specific row.
  final TreeSliverController? controller;

  /// Forwards the underlying tree's node-toggle notifications so external
  /// controls can update alongside row interactions.
  final TreeSliverNodeCallback? onNodeToggle;

  /// Whether the optional root row includes the built-in expand/collapse-all
  /// action. Disable when the caller supplies its own controls.
  final bool showExpansionToggle;

  /// Optional header decorations. Its children are supplied by [groups].
  final HabitGroupTreeEntry? root;
  final Key? treeKey;
  final Key? expansionToggleKey;

  @override
  State<SliverHabitGroupTree> createState() => _SliverHabitGroupTreeState();
}

class _SliverHabitGroupTreeState extends State<SliverHabitGroupTree> {
  late final _controller = TreeSliverController();

  TreeSliverController get _effectiveController =>
      widget.controller ?? _controller;
  List<TreeSliverNode<String>> _tree = [];
  Map<String, HabitGroupTreeEntry> _entries = {};
  Set<String> _groupIds = {};
  List<(String, String?)> _structure = [];

  @override
  void initState() {
    super.initState();
    _updateTree();
  }

  @override
  void didUpdateWidget(SliverHabitGroupTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTree();
  }

  void _updateTree() {
    final entries = <String, HabitGroupTreeEntry>{};
    final structure = <(String, String?)>[];

    void collect(HabitGroupTreeEntry entry, String? parent, int depth) {
      if (entries.containsKey(entry.id)) {
        throw ArgumentError.value(
          entry.id,
          'id',
          'Habit group tree entry IDs must be unique',
        );
      }
      if (depth > SliverHabitGroupTree.maxEntryDepth) {
        throw RangeError.range(
          depth,
          0,
          SliverHabitGroupTree.maxEntryDepth,
          'depth',
          'Habit group tree is too deep',
        );
      }
      entries[entry.id] = entry;
      structure.add((entry.id, parent));
      for (final child in entry.children) {
        collect(child, entry.id, depth + 1);
      }
    }

    final root = widget.root;
    if (root != null) {
      entries[root.id] = root;
      structure.add((root.id, null));
    }
    for (final group in widget.groups) {
      collect(group, root?.id, root == null ? 0 : 1);
    }
    _entries = entries;
    _groupIds = widget.groups.map((entry) => entry.id).toSet();
    if (listEquals(_structure, structure)) return;

    final expanded = <String, bool>{};

    void remember(TreeSliverNode<String> node) {
      expanded[node.content] = node.isExpanded;
      for (final child in node.children) {
        remember(child);
      }
    }

    for (final node in _tree) {
      remember(node);
    }

    TreeSliverNode<String> build(
      HabitGroupTreeEntry entry,
      List<HabitGroupTreeEntry> children,
    ) => TreeSliverNode(
      entry.id,
      expanded: expanded[entry.id] ?? entry.initiallyExpanded,
      children: [for (final child in children) build(child, child.children)],
    );

    _tree = root == null
        ? [for (final group in widget.groups) build(group, group.children)]
        : [build(root, widget.groups)];
    _structure = structure;
  }

  bool get _anyExpanded {
    bool expanded(TreeSliverNode<String> node) =>
        (node.children.isNotEmpty && node.isExpanded) ||
        node.children.any(expanded);
    return _tree.any(expanded);
  }

  void _toggleAll() {
    if (_anyExpanded) {
      _effectiveController.collapseAll();
    } else {
      _effectiveController.expandAll();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => TreeSliver<String>(
    key: widget.treeKey,
    tree: _tree,
    controller: _effectiveController,
    indentation: TreeSliverIndentationType.none,
    onNodeToggle: (node) {
      setState(() {});
      widget.onNodeToggle?.call(node);
    },
    treeRowExtentBuilder: (_, _) =>
        _HabitGroupTreeRow.extent(MediaQuery.textScalerOf(context)),
    treeNodeBuilder: (context, node, _) {
      final entry = _entries[node.content]!;
      return _HabitGroupTreeRow(
        entry: entry,
        isGroup: _groupIds.contains(entry.id) && !entry.isUngrouped,
        depth: node.depth ?? 0,
        expanded: node.children.isEmpty ? null : node.isExpanded,
        onTap: node.children.isEmpty
            ? null
            : () => _effectiveController.toggleNode(node),
        toggle: widget.showExpansionToggle && entry.id == widget.root?.id
            ? _TreeExpansionToggle(
                key: widget.expansionToggleKey,
                expanded: _anyExpanded,
                onPressed: _toggleAll,
              )
            : null,
      );
    },
  );
}

class _HabitGroupTreeRow extends StatelessWidget {
  static const _fontSize = 17.0;
  static const _lineHeight = 1.3;
  static const _maxLines = 2;
  static const _minExtent = 56.0;
  static const _verticalPadding = 12.0;
  static const _indentPerLevel = 12.0;
  static const _trailingSpacing = 8.0;
  static const _chevronSize = 16.0;
  static const _titleStyle = TextStyle(
    fontSize: _fontSize,
    height: _lineHeight,
  );

  static double extent(TextScaler textScaler) {
    final scaledLineHeight = textScaler.scale(_fontSize) * _lineHeight;
    final titleHeight = scaledLineHeight * _maxLines;
    return math.max(_minExtent, titleHeight + _verticalPadding * 2);
  }

  const _HabitGroupTreeRow({
    required this.entry,
    required this.isGroup,
    required this.depth,
    required this.expanded,
    required this.onTap,
    this.toggle,
  });
  final HabitGroupTreeEntry entry;
  final bool isGroup;
  final int depth;
  final bool? expanded;
  final VoidCallback? onTap;
  final Widget? toggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = entry.color == null
        ? null
        : theme.extension<CustomColors>()?.getColor(
            entry.color!,
            brightness: theme.brightness,
          );
    final leading =
        entry.leading ??
        (isGroup || entry.icon != null || entry.color != null
            ? Icon(
                entry.icon?.iconData ??
                    (isGroup ? defaultGroupIcon : Icons.circle),
                size: isGroup || entry.icon != null ? 20 : 16,
                color: color,
              )
            : null);
    return Semantics(
      expanded: expanded,
      child: Padding(
        key: ValueKey(entry.id),
        padding: EdgeInsetsDirectional.only(start: depth * _indentPerLevel),
        // Non-flex children receive natural vertical constraints. In particular,
        // CupertinoListTile's title column must not fill the tree row's extent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AdaptiveListTile(
              leading: leading,
              title: DefaultTextStyle.merge(
                style: _titleStyle.copyWith(color: color),
                maxLines: _maxLines,
                overflow: TextOverflow.ellipsis,
                child: entry.title,
              ),
              onTap: onTap,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (expanded case final expanded?) ...[
                    const SizedBox(width: _trailingSpacing),
                    Icon(
                      expanded
                          ? CupertinoIcons.chevron_down
                          : CupertinoIcons.chevron_forward,
                      size: _chevronSize,
                    ),
                  ],
                  ?toggle,
                  if (entry.trailing case final trailing?) ...[
                    const SizedBox(width: _trailingSpacing),
                    trailing,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TreeExpansionToggle extends StatelessWidget {
  const _TreeExpansionToggle({
    super.key,
    required this.expanded,
    required this.onPressed,
  });
  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final icon = Icon(expanded ? Icons.unfold_less : Icons.unfold_more);
    return Semantics(
      toggled: expanded,
      label: expanded
          ? (l10n?.groupHeader_menu_collapseAll ?? 'Collapse all')
          : (l10n?.groupHeader_menu_expandAll ?? 'Expand all'),
      child: AdaptiveStyle.of(context) == AdaptiveStyle.apple
          ? CupertinoButton(
              padding: const EdgeInsets.all(8),
              onPressed: onPressed,
              child: icon,
            )
          : IconButton(onPressed: onPressed, icon: icon),
    );
  }
}

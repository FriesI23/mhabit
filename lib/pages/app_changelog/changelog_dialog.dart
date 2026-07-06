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

import '../../l10n/localizations.dart';
import '../../widgets/widgets.dart';
import 'changelog_parser.dart';

/// Shows an adaptive changelog view.
///
/// Delegates to [showAdaptiveContentSheet] for the adaptive presentation
/// (bottom sheet on phones, dialog on tablets/desktop).
Future<void> showChangelogDialog({
  required BuildContext context,
  required String currentVersionSection,
  required String fullChangelog,
  required String version,
}) {
  final showFullNotifier = ValueNotifier<bool>(false);
  List<ChangelogSection>? fullSections;

  return showAdaptiveContentSheet(
    context: context,
    title: _ChangelogTitle(version: version),
    sheetActionsAlign: Alignment.centerRight,
    contentBuilder: (_) => ValueListenableBuilder<bool>(
      valueListenable: showFullNotifier,
      builder: (_, showFull, _) => showFull
          ? _buildFullList(
              fullSections ??= parseChangelogSections(fullChangelog),
            )
          : _buildCurrentVersion(currentVersionSection),
    ),
    actions: [
      ValueListenableBuilder<bool>(
        valueListenable: showFullNotifier,
        builder: (context, showFull, _) {
          if (showFull) return const SizedBox.shrink();
          final l10n = L10n.of(context);
          return FilledButton(
            onPressed: () => showFullNotifier.value = true,
            child: Text(l10n?.changelog_view_full ?? 'View Full Changelog'),
          );
        },
      ),
    ],
  );
}

Widget _buildCurrentVersion(String data) {
  return ThematicMarkdownBlock(data: data, selectable: false);
}

Widget _buildFullList(List<ChangelogSection> sections) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: sections.map((s) => _ChangelogSectionTile(section: s)).toList(),
  );
}

class _ChangelogTitle extends StatelessWidget {
  final String version;

  const _ChangelogTitle({required this.version});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n?.changelog_dialog_title ?? 'Changelog'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              'v$version',
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChangelogSectionTile extends StatelessWidget {
  final ChangelogSection section;

  const _ChangelogSectionTile({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                'v${section.version}',
                style: theme.textTheme.titleSmall?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ThematicMarkdownBlock(data: section.body, selectable: false),
        ],
      ),
    );
  }
}

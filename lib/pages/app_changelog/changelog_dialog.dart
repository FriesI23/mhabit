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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../l10n/localizations.dart';
import '../../widgets/widgets.dart';
import 'changelog_parser.dart';

/// Shows an adaptive changelog view.
///
/// Delegates to [showAdaptiveSheet] for the adaptive presentation
/// (sheet on compact windows, dialog when both axes are medium or larger).
Future<void> showChangelogDialog({
  required BuildContext context,
  required String currentVersionSection,
  required String fullChangelog,
  required String version,
}) => showAdaptiveSheet<void>(
  context: context,
  builder: (_) => AdaptiveModalNavigator<void>(
    builder: (_) => _ChangelogFlow(
      currentVersionSection: currentVersionSection,
      fullChangelog: fullChangelog,
      version: version,
    ),
  ),
);

class _ChangelogFlow extends StatefulWidget {
  const _ChangelogFlow({
    required this.currentVersionSection,
    required this.fullChangelog,
    required this.version,
  });

  final String currentVersionSection;
  final String fullChangelog;
  final String version;

  @override
  State<_ChangelogFlow> createState() => _ChangelogFlowState();
}

class _ChangelogFlowState extends State<_ChangelogFlow> {
  List<ChangelogSection>? _fullSections;

  void _openFullChangelog() {
    Navigator.of(context).push(
      adaptiveModalPageRoute<void>(
        context: context,
        builder: (_) => _ChangelogPage(
          style: AdaptiveStyle.of(context),
          version: widget.version,
          body: _FullChangelogList(
            sections: _fullSections ??= parseChangelogSections(
              widget.fullChangelog,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _ChangelogPage(
    style: AdaptiveStyle.of(context),
    version: widget.version,
    body: _ChangelogCurrentVersion(data: widget.currentVersionSection),
    onViewFull: _openFullChangelog,
  );
}

class _ChangelogPage extends StatelessWidget {
  const _ChangelogPage({
    required this.style,
    required this.version,
    required this.body,
    this.onViewFull,
  });

  final AdaptiveStyle style;
  final String version;
  final Widget body;
  final VoidCallback? onViewFull;

  @override
  Widget build(BuildContext context) {
    final viewFullLabel =
        L10n.of(context)?.changelog_view_full ?? 'View Full Changelog';
    final viewFullAction = switch ((style, onViewFull)) {
      (_, null) => null,
      (AdaptiveStyle.material, final onPressed?) => FilledButton(
        onPressed: onPressed,
        child: Text(viewFullLabel),
      ),
      (AdaptiveStyle.apple, final onPressed?) => CupertinoButton(
        key: const ValueKey('changelog-apple-view-full'),
        onPressed: onPressed,
        child: Text(viewFullLabel),
      ),
    };
    return AdaptiveModal(
      title: _ChangelogTitle(
        version: version,
        centered: switch (style) {
          AdaptiveStyle.material => false,
          AdaptiveStyle.apple => true,
        },
      ),
      automaticallyImplyLeading: true,
      body: body,
      actions: [?viewFullAction],
    );
  }
}

class _ChangelogCurrentVersion extends StatelessWidget {
  const _ChangelogCurrentVersion({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ThematicMarkdownBlock(data: data, selectable: false),
  );
}

class _FullChangelogList extends StatelessWidget {
  const _FullChangelogList({required this.sections});

  final List<ChangelogSection> sections;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections
          .map((section) => _ChangelogSectionTile(section: section))
          .toList(),
    ),
  );
}

class _ChangelogTitle extends StatelessWidget {
  final String version;
  final bool centered;

  const _ChangelogTitle({required this.version, required this.centered});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n?.changelog_dialog_title ?? 'Changelog'),
        Row(
          key: const ValueKey('changelog-version'),
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
          SizedBox(
            width: double.infinity,
            child: ThematicMarkdownBlock(data: section.body, selectable: false),
          ),
        ],
      ),
    );
  }
}

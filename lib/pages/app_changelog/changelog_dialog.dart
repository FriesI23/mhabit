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

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

import '../../common/consts.dart';
import '../../l10n/localizations.dart';
import '../../widgets/_widgets/markdown_block.dart';

/// Shows an adaptive changelog view.
///
/// On desktop platforms (macOS, Windows, Linux) always renders an
/// [AlertDialog] via [showDialog].
/// On mobile platforms (Android, iOS) renders a [showModalBottomSheet]
/// on phones, and an [AlertDialog] on tablets (width >= 600).
///
/// [context] is used for navigation and localisation lookups.
///
/// [currentVersionSection] is the body markdown for the current app version,
/// extracted by `extractVersionSection()` (Slice 2). This is shown by default.
///
/// [fullChangelog] is the entire CHANGELOG.md content. Displayed when the
/// user taps "View Full Changelog".
///
/// [version] is the `"<semver>+<buildNumber>"` version string for display
/// in the title.
Future<void> showChangelogDialog({
  required BuildContext context,
  required String currentVersionSection,
  required String fullChangelog,
  required String version,
}) {
  final useDialog = switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.fuchsia =>
      MediaQuery.sizeOf(context).width >= kHabitLargeScreenAdaptWidth,
    _ => true,
  };

  if (!useDialog) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _ChangelogBottomSheet(
        currentVersionSection: currentVersionSection,
        fullChangelog: fullChangelog,
        version: version,
      ),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (_) => _ChangelogDialog(
      currentVersionSection: currentVersionSection,
      fullChangelog: fullChangelog,
      version: version,
    ),
  );
}

// ---------------------------------------------------------------------------
// Bottom sheet (small screens) — Material drag handle + unified scroll
// ---------------------------------------------------------------------------

class _ChangelogBottomSheet extends StatefulWidget {
  final String currentVersionSection;
  final String fullChangelog;
  final String version;

  const _ChangelogBottomSheet({
    required this.currentVersionSection,
    required this.fullChangelog,
    required this.version,
  });

  @override
  State<_ChangelogBottomSheet> createState() => _ChangelogBottomSheetState();
}

class _ChangelogBottomSheetState extends State<_ChangelogBottomSheet> {
  var _showFull = false;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final title = _ChangelogTitle(version: widget.version);
    final markdownData = _showFull
        ? widget.fullChangelog
        : widget.currentVersionSection;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.25,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Title + scrollable markdown — unified scroll via DraggableScrollableSheet
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    title,
                    const SizedBox(height: 12),
                    ThematicMarkdownBlock(
                      data: markdownData,
                      selectable: false,
                    ),
                  ],
                ),
              ),
            ),
            // Pinned bottom bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    if (!_showFull)
                      FilledButton(
                        onPressed: () => setState(() => _showFull = true),
                        child: Text(l10n.changelog_view_full),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// AlertDialog (large screens)
// ---------------------------------------------------------------------------

class _ChangelogDialog extends StatefulWidget {
  final String currentVersionSection;
  final String fullChangelog;
  final String version;

  const _ChangelogDialog({
    required this.currentVersionSection,
    required this.fullChangelog,
    required this.version,
  });

  @override
  State<_ChangelogDialog> createState() => _ChangelogDialogState();
}

class _ChangelogDialogState extends State<_ChangelogDialog> {
  var _showFull = false;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final title = _ChangelogTitle(version: widget.version);
    final content = _ChangelogContent(
      data: _showFull ? widget.fullChangelog : widget.currentVersionSection,
    );
    final viewFullButton = !_showFull
        ? FilledButton(
            onPressed: () => setState(() => _showFull = true),
            child: Text(l10n.changelog_view_full),
          )
        : null;

    return AlertDialog(
      title: title,
      content: SizedBox(width: 500, child: content),
      actions: [
        ?viewFullButton,
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Dialog title: "Changelog" heading + version row with icon
// ---------------------------------------------------------------------------

class _ChangelogTitle extends StatelessWidget {
  final String version;

  const _ChangelogTitle({required this.version});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.changelog_dialog_title),
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

// ---------------------------------------------------------------------------
// Shared markdown content
// ---------------------------------------------------------------------------

class _ChangelogContent extends StatelessWidget {
  final String data;

  const _ChangelogContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: ThematicMarkdownBlock(data: data, selectable: false),
        ),
      ),
    );
  }
}

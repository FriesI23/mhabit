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

import '../../common/utils.dart';
import '../../widgets/_widgets/app_ui_layout_builder.dart';
import '../../widgets/_widgets/markdown_block.dart';

/// Shows an adaptive changelog dialog.
///
/// On small screens (width < 600px or height < 400px), renders a fullscreen
/// [Dialog.fullscreen] with a [Scaffold] and close button in the [AppBar].
/// On large screens, renders an [AlertDialog].
///
/// [context] is used for navigation and (post-Slice 5) localisation lookups.
///
/// [currentVersionSection] is the body markdown for the current app version,
/// extracted by `extractVersionSection()` (Slice 2). This is shown by default.
///
/// [fullChangelog] is the entire CHANGELOG.md content. Displayed when the
/// user taps "View Full Changelog".
///
/// [version] is the `"<semver>+<buildNumber>"` version string for display
/// in the dialog title.
Future<void> showChangelogDialog({
  required BuildContext context,
  required String currentVersionSection,
  required String fullChangelog,
  required String version,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AppUiLayoutBuilder(
      ignoreHeight: false,
      ignoreWidth: false,
      builder: (ctx, layoutType, _) {
        return layoutType == UiLayoutType.s
            ? _ChangelogFullscreenDialog(
                currentVersionSection: currentVersionSection,
                fullChangelog: fullChangelog,
                version: version,
              )
            : _ChangelogAlertDialog(
                currentVersionSection: currentVersionSection,
                fullChangelog: fullChangelog,
                version: version,
              );
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// Fullscreen dialog (small screens)
// ---------------------------------------------------------------------------

class _ChangelogFullscreenDialog extends StatelessWidget {
  final String currentVersionSection;
  final String fullChangelog;
  final String version;

  const _ChangelogFullscreenDialog({
    required this.currentVersionSection,
    required this.fullChangelog,
    required this.version,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Changelog ($version)'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _ChangelogContent(
          currentVersionSection: currentVersionSection,
          fullChangelog: fullChangelog,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AlertDialog (large screens)
// ---------------------------------------------------------------------------

class _ChangelogAlertDialog extends StatelessWidget {
  final String currentVersionSection;
  final String fullChangelog;
  final String version;

  const _ChangelogAlertDialog({
    required this.currentVersionSection,
    required this.fullChangelog,
    required this.version,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Changelog ($version)'),
      content: SizedBox(
        width: 500,
        child: _ChangelogContent(
          currentVersionSection: currentVersionSection,
          fullChangelog: fullChangelog,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared content with "View Full Changelog" toggle
// ---------------------------------------------------------------------------

class _ChangelogContent extends StatefulWidget {
  final String currentVersionSection;
  final String fullChangelog;

  const _ChangelogContent({
    required this.currentVersionSection,
    required this.fullChangelog,
  });

  @override
  State<_ChangelogContent> createState() => _ChangelogContentState();
}

class _ChangelogContentState extends State<_ChangelogContent> {
  var _showFull = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            child: SingleChildScrollView(
              primary: true,
              scrollDirection: Axis.vertical,
              child: ThematicMarkdownBlock(
                data: _showFull
                    ? widget.fullChangelog
                    : widget.currentVersionSection,
                selectable: false,
              ),
            ),
          ),
        ),
        if (!_showFull)
          TextButton(
            onPressed: () => setState(() => _showFull = true),
            child: const Text('View Full Changelog'),
          ),
      ],
    );
  }
}

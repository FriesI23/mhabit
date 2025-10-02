// Copyright 2025 Fries_I23
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../extension/colorscheme_extensions.dart';
import '../../../l10n/localizations.dart';
import '../styles.dart';

class DebuggerInfoCard extends StatelessWidget {
  final void Function(BuildContext context)? onOpenPressed;
  final void Function(BuildContext conetxt)? onSavePressed;

  const DebuggerInfoCard({super.key, this.onOpenPressed, this.onSavePressed});

  Widget _buildOpenButton(BuildContext context, [L10n? l10n]) => TextButton(
        onPressed: onOpenPressed != null ? () => onOpenPressed!(context) : null,
        child: Text(
          l10n?.debug_debuggerInfoCard_openButton_text ?? 'Open',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
      );

  Widget _buildSaveButton(BuildContext context, [L10n? l10n]) => TextButton(
        onPressed: onSavePressed != null ? () => onSavePressed!(context) : null,
        child: Text(
          l10n?.debug_debuggerInfoCard_saveButton_text ?? 'Save',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget buildMainButton(BuildContext context) {
      final l10n = L10n.of(context);
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.iOS:
        case TargetPlatform.windows:
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
          return _buildOpenButton(context, l10n);
        default:
          return _buildSaveButton(context, l10n);
      }
    }

    final l10n = L10n.of(context);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainerOpacity32,
      child: Padding(
        padding: kDebuggerCardPadding,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.adb_outlined),
              title:
                  l10n != null ? Text(l10n.debug_debuggerInfoCard_title) : null,
              subtitle: l10n != null
                  ? Text(l10n.debug_debuggerInfoCard_subtitle)
                  : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Builder(builder: buildMainButton),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

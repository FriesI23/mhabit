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

import 'package:flutter/material.dart';

import '../../../extension/colorscheme_extensions.dart';
import '../../../l10n/localizations.dart';
import '../styles.dart';

class DebuggerLogCard extends StatelessWidget {
  final void Function(BuildContext context)? onDownloadPressed;
  final void Function(BuildContext context)? onClearPressed;

  const DebuggerLogCard({
    super.key,
    required this.onDownloadPressed,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainerOpacity32,
      child: Padding(
        padding: kDebuggerCardPadding,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title:
                  l10n != null ? Text(l10n.debug_debuggerLogCard_title) : null,
              subtitle: l10n != null
                  ? Text(l10n.debug_debuggerLogCard_subtitle)
                  : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Builder(builder: (context) {
                  return TextButton(
                    onPressed: onDownloadPressed != null
                        ? () => onDownloadPressed!(context)
                        : null,
                    child: Text(
                      l10n?.debug_debuggerLogCard_saveButton_text ?? 'Downlaod',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Builder(builder: (context) {
                  return TextButton(
                    onPressed: onClearPressed != null
                        ? () => onClearPressed!(context)
                        : null,
                    child: Text(
                      l10n?.debug_debuggerLogCard_clearButton_text ?? 'Clear',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

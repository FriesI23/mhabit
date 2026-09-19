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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../l10n/localizations.dart';
import 'debugger_card.dart';

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
    return DebuggerCard(
      title: l10n?.debug_debuggerLogCard_title ?? 'Logging Information',
      description: l10n?.debug_debuggerLogCard_subtitle,
      materialIcon: Icons.article_outlined,
      appleIcon: CupertinoIcons.doc_text,
      actions: [
        DebuggerCardActionData(
          label: l10n?.debug_debuggerLogCard_saveButton_text ?? 'Download',
          icon: CupertinoIcons.square_arrow_down,
          onPressed: onDownloadPressed,
        ),
        DebuggerCardActionData(
          label: l10n?.debug_debuggerLogCard_clearButton_text ?? 'Clear',
          icon: CupertinoIcons.trash,
          destructive: true,
          onPressed: onClearPressed,
        ),
      ],
    );
  }
}

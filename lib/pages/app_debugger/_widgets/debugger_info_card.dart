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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../l10n/localizations.dart';
import 'debugger_card.dart';

class DebuggerInfoCard extends StatelessWidget {
  final void Function(BuildContext context)? onOpenPressed;
  final void Function(BuildContext context)? onSavePressed;

  const DebuggerInfoCard({super.key, this.onOpenPressed, this.onSavePressed});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final useOpen = switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.macOS => true,
      _ => false,
    };
    final callback = useOpen ? onOpenPressed : onSavePressed;
    final label = useOpen
        ? l10n?.debug_debuggerInfoCard_openButton_text ?? 'Open'
        : l10n?.debug_debuggerInfoCard_saveButton_text ?? 'Save';
    return DebuggerCard(
      title: l10n?.debug_debuggerInfoCard_title ?? 'Debug Info',
      description: l10n?.debug_debuggerInfoCard_subtitle,
      materialIcon: Icons.adb_outlined,
      appleIcon: CupertinoIcons.info_circle,
      actions: [
        DebuggerCardActionData(
          label: label,
          icon: useOpen
              ? CupertinoIcons.doc_text_search
              : CupertinoIcons.square_arrow_down,
          onPressed: callback,
        ),
      ],
    );
  }
}

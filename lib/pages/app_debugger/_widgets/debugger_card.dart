// Copyright 2024 Fries_I23
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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

class DebuggerCardActionData {
  const DebuggerCardActionData({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });
  final String label;
  final IconData icon;
  final ValueChanged<BuildContext>? onPressed;
  final bool destructive;
}

class DebuggerCard extends StatelessWidget {
  const DebuggerCard({
    super.key,
    required this.title,
    required this.description,
    required this.materialIcon,
    required this.appleIcon,
    required this.actions,
  });
  final String title;
  final String? description;
  final IconData materialIcon;
  final IconData appleIcon;
  final List<DebuggerCardActionData> actions;

  @override
  Widget build(BuildContext context) => switch (AdaptiveStyle.of(context)) {
    AdaptiveStyle.material => _MaterialDebuggerCard(
      title: title,
      description: description,
      icon: materialIcon,
      actions: actions,
    ),
    AdaptiveStyle.apple => _AppleDebuggerCard(
      title: title,
      description: description,
      icon: appleIcon,
      actions: actions,
    ),
  };
}

class _MaterialDebuggerCard extends StatelessWidget {
  const _MaterialDebuggerCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.actions,
  });
  final String title;
  final String? description;
  final IconData icon;
  final List<DebuggerCardActionData> actions;

  @override
  Widget build(BuildContext context) => AdaptiveListSection.material(
    children: [
      Column(
        children: [
          AdaptiveListTile.material(
            leading: Icon(icon),
            title: Text(title),
            subtitle: description == null ? null : Text(description!),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  for (final action in actions)
                    Builder(
                      builder: (actionContext) => TextButton(
                        onPressed: action.onPressed == null
                            ? null
                            : () => action.onPressed!(actionContext),
                        style: action.destructive
                            ? TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              )
                            : null,
                        child: Text(action.label),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class _AppleDebuggerCard extends StatelessWidget {
  const _AppleDebuggerCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.actions,
  });
  final String title;
  final String? description;
  final IconData icon;
  final List<DebuggerCardActionData> actions;

  @override
  Widget build(BuildContext context) => AdaptiveListSection.apple(
    header: Text(title),
    hasLeading: true,
    children: [
      if (description != null)
        AdaptiveListTile.apple(leading: Icon(icon), title: Text(description!)),
      for (final action in actions)
        _AppleDebuggerActionRow(
          label: action.label,
          icon: action.icon,
          onPressed: action.onPressed,
          destructive: action.destructive,
        ),
    ],
  );
}

class _AppleDebuggerActionRow extends StatelessWidget {
  const _AppleDebuggerActionRow({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.destructive,
  });
  final String label;
  final IconData icon;
  final ValueChanged<BuildContext>? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null
        ? CupertinoColors.tertiaryLabel.resolveFrom(context)
        : destructive
        ? CupertinoColors.systemRed.resolveFrom(context)
        : CupertinoTheme.of(context).primaryColor;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: AdaptiveListTile.apple(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color)),
        onTap: onPressed == null ? null : () => onPressed!(context),
      ),
    );
  }
}

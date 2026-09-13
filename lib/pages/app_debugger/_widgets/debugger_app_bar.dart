// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:adaptive_actions/core.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../extensions/adaptive_style_extensions.dart';
import '../../../l10n/localizations.dart';

const _appBarActionSlotExtent = 48.0;

enum _DebuggerAction { share }

final _shareActionId = ActionId('app-debugger.share');

class DebuggerAppBar extends StatelessWidget {
  const DebuggerAppBar({super.key, required this.onShare});

  final ValueChanged<BuildContext> onShare;

  @override
  Widget build(BuildContext context) {
    final title = Text(
      L10n.of(context)?.appSetting_debugger_titleText ?? 'Debugger',
    );
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => _MaterialDebuggerAppBar(title: title),
      AdaptiveStyle.apple => _AppleDebuggerAppBar(
        title: title,
        onShare: onShare,
      ),
    };
  }
}

class _MaterialDebuggerAppBar extends StatelessWidget {
  const _MaterialDebuggerAppBar({required this.title});

  final Widget title;

  @override
  Widget build(BuildContext context) => AdaptiveSliverAppBar.material(
    height: AppAdaptiveStyle.materialToolbarHeight,
    title: title,
    leading: const AdaptiveBackButton.material(
      type: AdaptiveBackButtonType.back,
    ),
  );
}

class _AppleDebuggerAppBar extends StatelessWidget {
  const _AppleDebuggerAppBar({required this.title, required this.onShare});

  final Widget title;
  final ValueChanged<BuildContext> onShare;

  void _onInvoke(BuildContext context, _DebuggerAction action) {
    switch (action) {
      case _DebuggerAction.share:
        onShare(context);
    }
  }

  @override
  Widget build(BuildContext context) => AdaptiveSliverAppBar.apple(
    height: AppAdaptiveStyle.appleToolbarHeight,
    title: title,
    leading: const AdaptiveBackButton.apple(type: AdaptiveBackButtonType.back),
    actions: [
      AdaptiveAppBarActions<_DebuggerAction>.apple(
        collection: _buildAppleActions(L10n.of(context)),
        primaryCapacity: _appBarActionSlotExtent,
        maxPrimaryActions: 1,
        onInvoke: _onInvoke,
        apple: CupertinoAppBarActionsConfig(
          iconBuilder: (_, action) => Icon(switch (action.payload) {
            _DebuggerAction.share => CupertinoIcons.share,
            null => CupertinoIcons.ellipsis,
          }),
        ),
      ),
    ],
  );
}

ActionCollection<_DebuggerAction> _buildAppleActions(L10n? l10n) =>
    ActionCollection(
      roots: [
        AdaptiveAction.action(
          id: _shareActionId,
          metadata: ActionMetadata(
            label: l10n?.debug_shareDebugZip_tooltip ?? 'Share debug bundle',
            tooltip: l10n?.debug_shareDebugZip_tooltip ?? 'Share debug bundle',
          ),
          payload: _DebuggerAction.share,
          placementPolicy: ActionPlacementPolicy(
            placement: ActionPlacement.pinned,
          ),
        ),
      ],
    );

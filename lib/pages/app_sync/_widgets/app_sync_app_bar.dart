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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../extensions/adaptive_style_extensions.dart';
import '../../../providers/workflow/app_sync.dart';
import '../../../widgets/widgets.dart';

class AppSyncAppBar extends StatelessWidget {
  const AppSyncAppBar({super.key});

  @override
  Widget build(BuildContext context) => switch (AdaptiveStyle.of(context)) {
    AdaptiveStyle.material => MultiSliver(
      children: [
        _buildAppBar(context),
        const SliverPinnedHeader(child: _MaterialAppSyncEnableBar()),
      ],
    ),
    AdaptiveStyle.apple => _buildAppBar(
      context,
      bottom: const _AppSyncEnableBar(),
    ),
  };

  AdaptiveSliverAppBar _buildAppBar(
    BuildContext context, {
    PreferredSizeWidget? bottom,
  }) => AdaptiveSliverAppBar(
    height: AdaptiveStyle.of(context).appToolbarHeight,
    styles: const AppBarStyles(
      material: AppBarMaterialStyle(floating: false, snap: false, pinned: true),
    ),
    leading: const AdaptiveBackButton(type: AdaptiveBackButtonType.back),
    title: L10nBuilder(
      builder: (context, l10n) =>
          Text(l10n?.appSetting_syncOption_titleText ?? 'Sync'),
    ),
    bottom: bottom,
  );
}

class _MaterialAppSyncEnableBar extends StatelessWidget {
  const _MaterialAppSyncEnableBar();

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    child: const _AppSyncEnableBar(),
  );
}

class _AppSyncEnableBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppSyncEnableBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => Selector<AppSyncSettingsAccess, bool>(
    selector: (ctx, v) => v.enabled,
    shouldRebuild: (previous, next) => previous != next,
    builder: (context, value, child) => SizedBox(
      height: preferredSize.height,
      child: SwitchListTile.adaptive(
        title: L10nBuilder(
          builder: (context, l10n) =>
              Text(l10n?.common_enable_text ?? 'Enable'),
        ),
        value: value,
        onChanged: (value) =>
            context.read<AppSyncSettingsAccess>().setSyncSwitch(value),
      ),
    ),
  );
}

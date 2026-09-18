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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../models/app_sync_options.dart';
import '../../../providers/workflow/app_sync.dart';

Future<AppSyncFetchInterval?> showAppSyncFetchIntervalSwitchDialog({
  required BuildContext context,
  AppSyncFetchInterval? select,
}) => showAdaptiveSheet<AppSyncFetchInterval>(
  context: context,
  builder: (context) => AppSyncFetchIntervalSwitchDialog(select: select),
);

class AppSyncFetchIntervalSwitchDialog extends StatelessWidget {
  final AppSyncFetchInterval? select;

  const AppSyncFetchIntervalSwitchDialog({super.key, required this.select});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AdaptiveModal(
      size: const AdaptiveModalSize.constrained(),
      title: Text(l10n?.appSync_syncIntervalTile_title ?? 'Fetch Interval'),
      body: AdaptiveListSection(
        appleTransparent: true,
        padding: EdgeInsets.zero,
        children: [
          for (final interval in AppSyncFetchInterval.values)
            Semantics(
              key: ValueKey(interval.index),
              selected: select == interval,
              child: AdaptiveListTile(
                title: Text(interval.getShowText(l10n)),
                trailing: select == interval ? const AdaptiveCheckmark() : null,
                onTap: () => Navigator.of(context).pop(interval),
              ),
            ),
        ],
      ),
    );
  }
}

class AppSyncFetchIntervalTile extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppSyncFetchIntervalTile({super.key, this.onPressed});

  Widget buildSubtitle([L10n? l10n]) =>
      Selector<AppSyncSettingsAccess, AppSyncFetchInterval>(
        selector: (context, vm) => vm.fetchInterval,
        builder: (context, value, child) => Text(value.getShowText(l10n)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AdaptiveListTile(
      title: Text(l10n?.appSync_syncIntervalTile_title ?? "Fetch Interval"),
      subtitle: buildSubtitle(l10n),
      trailing: AdaptiveStyle.of(context) == AdaptiveStyle.apple
          ? const Icon(CupertinoIcons.chevron_forward)
          : null,
      onTap: onPressed,
    );
  }
}

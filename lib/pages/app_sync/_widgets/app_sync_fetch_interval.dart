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
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../models/app_sync_options.dart';
import '../../../providers/app_sync.dart';

Future<AppSyncFetchInterval?> showAppSyncFetchIntervalSwitchDialog({
  required BuildContext context,
  AppSyncFetchInterval? select,
}) => showDialog(
  context: context,
  builder: (context) => AppSyncFetchIntervalSwitchDialog(select: select),
);

class AppSyncFetchIntervalSwitchDialog extends StatelessWidget {
  final AppSyncFetchInterval? select;

  const AppSyncFetchIntervalSwitchDialog({super.key, required this.select});

  Widget _buildOption(
    BuildContext context,
    AppSyncFetchInterval interval, [
    L10n? l10n,
  ]) => SimpleDialogOption(
    key: ValueKey(interval.index),
    onPressed: () => Navigator.of(context).pop(interval),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(interval.getShowText(l10n)),
        if (select == interval) const Icon(Icons.check),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return SimpleDialog(
      title: Text(l10n?.appSync_syncIntervalTile_title ?? "Fetch Interval"),
      children: AppSyncFetchInterval.values
          .map((e) => _buildOption(context, e, l10n))
          .toList(),
    );
  }
}

class AppSyncFetchIntervalTile extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppSyncFetchIntervalTile({super.key, this.onPressed});

  Widget buildSubtitle([L10n? l10n]) =>
      Selector<AppSyncViewModel, AppSyncFetchInterval>(
        selector: (context, vm) => vm.fetchInterval,
        builder: (context, value, child) => Text(value.getShowText(l10n)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      title: Text(l10n?.appSync_syncIntervalTile_title ?? "Fetch Interval"),
      subtitle: buildSubtitle(l10n),
      onTap: onPressed,
    );
  }
}

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

import '../../l10n/localizations.dart';
import '../../model/app_sync_options.dart';
import '../../provider/app_sync.dart';

Future<AppSyncFetchInterval?> showAppSyncFetchIntervalSwitchDialog(
        {required BuildContext context, AppSyncFetchInterval? select}) =>
    showDialog(
      context: context,
      builder: (context) => AppSyncFetchIntervalSwitchDialog(select: select),
    );

class AppSyncFetchIntervalSwitchDialog extends StatelessWidget {
  final AppSyncFetchInterval? select;

  const AppSyncFetchIntervalSwitchDialog({super.key, required this.select});

  Widget _buildOption(BuildContext context, AppSyncFetchInterval interval,
          [L10n? l10n]) =>
      SimpleDialogOption(
        key: ValueKey(interval.index),
        onPressed: () => Navigator.of(context).pop(interval),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            switch (interval) {
              AppSyncFetchInterval.manual => Text("Manual"),
              AppSyncFetchInterval.minute5 => Text("5 Minutes"),
              AppSyncFetchInterval.minute15 => Text("15 Minutes"),
              AppSyncFetchInterval.minute30 => Text("30 Minutes"),
              AppSyncFetchInterval.hour1 => Text("1 Hour"),
            },
            if (select == interval) const Icon(Icons.check),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return SimpleDialog(
      title: const Text("Fetch Interval"),
      children: AppSyncFetchInterval.values
          .map((e) => _buildOption(context, e, l10n))
          .toList(),
    );
  }
}

class AppSyncFetchIntervalTile extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppSyncFetchIntervalTile({super.key, this.onPressed});

  Widget buildSubtitle() => Builder(
        builder: (context) {
          final interval =
              context.select<AppSyncViewModel, AppSyncFetchInterval>(
                  (vm) => vm.fetchInterval);
          return switch (interval) {
            AppSyncFetchInterval.manual => Text("Manual"),
            AppSyncFetchInterval.minute5 => Text("5 Minutes"),
            AppSyncFetchInterval.minute15 => Text("15 Minutes"),
            AppSyncFetchInterval.minute30 => Text("30 Minutes"),
            AppSyncFetchInterval.hour1 => Text("1 Hour"),
          };
        },
      );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Fetch Interval"),
      subtitle: buildSubtitle(),
      onTap: onPressed,
    );
  }
}

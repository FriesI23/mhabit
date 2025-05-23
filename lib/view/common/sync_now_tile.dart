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
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../component/widget.dart';
import '../../extension/context_extensions.dart';
import '../../l10n/localizations.dart';
import '../../model/app_sync_task.dart';
import '../../provider/app_sync.dart';
import '../../provider/habit_summary.dart';
import 'sync_loading_indicator.dart';

class AppSyncNowTile extends StatefulWidget {
  const AppSyncNowTile({super.key});

  @override
  State<AppSyncNowTile> createState() => _AppSyncNowTile();
}

class _AppSyncNowTile extends State<AppSyncNowTile> {
  void _onCancelButtonPressed() {
    final vm = context.read<AppSyncViewModel>();
    if (!vm.mounted) return;
    vm.appSyncTask.cancelSync();
  }

  void _onStartButtonPressed() async {
    final vm = context.read<AppSyncViewModel>();
    if (!vm.mounted) return;
    await vm.startSync(initWait: kAppSyncDelayDuration1);
    if (!mounted) return;
    final summary = context.maybeRead<HabitSummaryViewModel>();
    if (summary == null || !summary.mounted) return;
    summary.rockreloadDBToggleSwich();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = context.select<AppSyncViewModel, bool>(
        (vm) => vm.enabled && vm.serverConfig != null);

    Widget buildTitle(BuildContext context) =>
        Selector<AppSyncViewModel, bool?>(
          selector: (context, vm) => vm.appSyncTask.task?.task.isProcessing,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, value, child) {
            final l10n = L10n.of(context);
            return value == true
                ? Text(l10n?.appSync_nowTile_titleText_syncing ?? "Syncing")
                : Text(l10n?.appSync_nowTile_titleText ?? "Sync Now");
          },
        );

    Widget buildSubtitle(BuildContext context) =>
        Selector<AppSyncViewModel, (AppSyncTaskStatus?, bool)>(
          selector: (context, vm) => (
            vm.appSyncTask.task?.task.status,
            vm.appSyncTask.task?.result != null
          ),
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, _, child) {
            final l10n = L10n.of(context);
            final lastSyncTask =
                context.read<AppSyncViewModel>().appSyncTask.task;

            final lastEndedTime = lastSyncTask?.endedTime;
            final lastEndedTimeStr = lastEndedTime != null
                ? (l10n?.appSync_nowTile_dateFormat(
                        lastEndedTime, lastEndedTime) ??
                    DateFormat.yMd(l10n?.localeName)
                        .add_jms()
                        .format(lastEndedTime))
                : null;

            Widget buildLastSyncText() => Text(l10n != null
                ? (lastEndedTimeStr != null
                    ? l10n.appSync_nowTile_text(lastEndedTimeStr)
                    : l10n.appSync_nowTile_text_noDate)
                : "Last Sync: $lastEndedTimeStr");

            if (lastSyncTask == null) return buildLastSyncText();
            switch (lastSyncTask.task.status) {
              case AppSyncTaskStatus.idle:
              case AppSyncTaskStatus.completed:
                if (lastSyncTask.result?.isSuccessed != true) {
                  return Text(l10n != null
                      ? (lastEndedTimeStr != null
                          ? l10n.appSync_nowTile_errorText(lastEndedTimeStr)
                          : l10n.appSync_nowTile_errorText_noDate)
                      : "Last Sync (Error): $lastEndedTimeStr");
                }
                return buildLastSyncText();
              case AppSyncTaskStatus.running:
                return Selector<AppSyncViewModel, num?>(
                  selector: (context, vm) => vm.appSyncTask.task?.percentage,
                  builder: (context, value, child) => value != null
                      ? Text(l10n != null
                          ? l10n.appSync_nowTile_syncingText_withPrt(value)
                          : "Syncing: ${(value * 100).toStringAsFixed(2)}%")
                      : Text(l10n?.appSync_nowTile_syncingText ?? "Syncing..."),
                );
              case AppSyncTaskStatus.cancelling:
                return Text(
                    l10n?.appSync_nowTile_cancellingText ?? "Canceling...");
              case AppSyncTaskStatus.cancelled:
                return Text(l10n != null
                    ? (lastEndedTimeStr != null
                        ? l10n.appSync_nowTile_cancelText(lastEndedTimeStr)
                        : l10n.appSync_nowTile_cancelText_noDate)
                    : "Last Sync (Cancelled): $lastEndedTimeStr");
            }
          },
        );

    Widget buildTrailing(BuildContext context) =>
        Selector<AppSyncViewModel, AppSyncTaskStatus?>(
          selector: (context, vm) => vm.appSyncTask.task?.task.status,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, value, child) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: switch (value) {
              AppSyncTaskStatus.running ||
              AppSyncTaskStatus.cancelling =>
                IconButton(
                  key: const ValueKey(1),
                  onPressed: value == AppSyncTaskStatus.running
                      ? _onCancelButtonPressed
                      : null,
                  icon: const Icon(MdiIcons.close),
                ),
              _ => IconButton(
                  key: const ValueKey(2),
                  onPressed: enabled ? _onStartButtonPressed : null,
                  icon: const Icon(MdiIcons.syncIcon),
                ),
            },
          ),
        );

    Widget buildIndicator(BuildContext context) =>
        Selector<AppSyncViewModel, bool>(
          selector: (context, vm) =>
              vm.appSyncTask.task?.task.isProcessing ?? false,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, value, child) => AnimatedOpacity(
            opacity: value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const AppSyncLoadingIndicator(),
          ),
        );

    return ListTile(
      enabled: enabled,
      contentPadding: kListTileContentPadding,
      title: buildTitle(context),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSubtitle(context),
          buildIndicator(context),
        ],
      ),
      trailing: buildTrailing(context),
    );
  }
}

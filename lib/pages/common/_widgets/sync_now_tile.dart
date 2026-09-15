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

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:intl/intl.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../models/app_sync_tasks.dart';
import '../../../providers/workflow/app_sync.dart';
import 'sync_loading_indicator.dart';

class AppSyncNowTile extends StatefulWidget {
  const AppSyncNowTile({super.key});

  @override
  State<AppSyncNowTile> createState() => _AppSyncNowTile();
}

class _AppSyncNowTile extends State<AppSyncNowTile> {
  void _onCancelButtonPressed() {
    context.read<AppSyncTriggerAccess>().cancelSync();
  }

  void _onStartButtonPressed() {
    context.read<AppSyncTriggerAccess>().startSync(
      initWait: kAppSyncDelayDuration1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = context.select<AppSyncTriggerAccess, bool>(
      (vm) => vm.canStartSync,
    );

    Widget buildTitle(BuildContext context) =>
        Selector<AppSyncStatusSource, bool?>(
          selector: (context, vm) => vm.syncStatus?.isProcessing,
          shouldRebuild: (previous, next) => previous != next,
          builder: (context, value, child) {
            final l10n = L10n.of(context);
            return value == true
                ? Text(l10n?.appSync_nowTile_titleText_syncing ?? "Syncing")
                : Text(l10n?.appSync_nowTile_titleText ?? "Sync Now");
          },
        );

    Widget buildSubtitle(
      BuildContext context,
    ) => Selector<AppSyncStatusSource, AppSyncStatusSnapshot?>(
      selector: (context, vm) => vm.syncStatus,
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, value, child) {
        final l10n = L10n.of(context);
        final lastSyncTask = value;

        final lastEndedTime = lastSyncTask?.endedTime;
        final lastEndedTimeStr = lastEndedTime != null
            ? (l10n?.appSync_nowTile_dateFormat(lastEndedTime, lastEndedTime) ??
                  DateFormat.yMd(
                    l10n?.localeName,
                  ).add_jms().format(lastEndedTime))
            : null;

        Widget buildLastSyncText() => Text(
          l10n != null
              ? (lastEndedTimeStr != null
                    ? l10n.appSync_nowTile_text(lastEndedTimeStr)
                    : l10n.appSync_nowTile_text_noDate)
              : "Last Sync: $lastEndedTimeStr",
        );

        if (lastSyncTask == null) return buildLastSyncText();
        switch (lastSyncTask.status) {
          case AppSyncTaskStatus.idle:
          case AppSyncTaskStatus.completed:
            if (lastSyncTask.result?.isSuccessed != true) {
              return Text(
                l10n != null
                    ? (lastEndedTimeStr != null
                          ? l10n.appSync_nowTile_errorText(lastEndedTimeStr)
                          : l10n.appSync_nowTile_errorText_noDate)
                    : "Last Sync (Error): $lastEndedTimeStr",
              );
            }
            return buildLastSyncText();
          case AppSyncTaskStatus.running:
            final percentage = lastSyncTask.percentage;
            return percentage != null
                ? Text(
                    l10n != null
                        ? l10n.appSync_nowTile_syncingText_withPrt(percentage)
                        : "Syncing: ${(percentage * 100).toStringAsFixed(2)}%",
                  )
                : Text(l10n?.appSync_nowTile_syncingText ?? "Syncing...");
          case AppSyncTaskStatus.cancelling:
            return Text(l10n?.appSync_nowTile_cancellingText ?? "Canceling...");
          case AppSyncTaskStatus.cancelled:
            return Text(
              l10n != null
                  ? (lastEndedTimeStr != null
                        ? l10n.appSync_nowTile_cancelText(lastEndedTimeStr)
                        : l10n.appSync_nowTile_cancelText_noDate)
                  : "Last Sync (Cancelled): $lastEndedTimeStr",
            );
        }
      },
    );

    final status = context.select<AppSyncStatusSource, AppSyncTaskStatus?>(
      (vm) => vm.syncStatus?.status,
    );
    final processing =
        status == AppSyncTaskStatus.running ||
        status == AppSyncTaskStatus.cancelling;
    final VoidCallback? onAction = switch (status) {
      AppSyncTaskStatus.cancelling => null,
      AppSyncTaskStatus.running => _onCancelButtonPressed,
      _ => enabled ? _onStartButtonPressed : null,
    };
    final tooltip = processing
        ? MaterialLocalizations.of(context).cancelButtonLabel
        : L10n.of(context)?.appSync_nowTile_titleText ?? 'Sync Now';
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => _MaterialSyncNowTile(
        title: buildTitle(context),
        subtitle: buildSubtitle(context),
        processing: processing,
        onAction: onAction,
        tooltip: tooltip,
      ),
      AdaptiveStyle.apple => _AppleSyncNowTile(
        title: buildTitle(context),
        subtitle: buildSubtitle(context),
        processing: processing,
        onAction: onAction,
        tooltip: tooltip,
      ),
    };
  }
}

class _MaterialSyncNowTile extends StatelessWidget {
  const _MaterialSyncNowTile({
    required this.title,
    required this.subtitle,
    required this.processing,
    required this.onAction,
    required this.tooltip,
  });
  final Widget title;
  final Widget subtitle;
  final bool processing;
  final VoidCallback? onAction;
  final String tooltip;

  @override
  Widget build(BuildContext context) => AdaptiveListTile.material(
    title: title,
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        subtitle,
        if (processing)
          const AppSyncLoadingIndicator()
        else
          const SizedBox(height: 4),
      ],
    ),
    trailing: AdaptiveIconButton.material(
      key: const ValueKey('sync-action'),
      tooltip: tooltip,
      onPressed: onAction,
      icon: Icon(processing ? MdiIcons.close : MdiIcons.sync),
    ),
  );
}

class _AppleSyncNowTile extends StatelessWidget {
  const _AppleSyncNowTile({
    required this.title,
    required this.subtitle,
    required this.processing,
    required this.onAction,
    required this.tooltip,
  });
  final Widget title;
  final Widget subtitle;
  final bool processing;
  final VoidCallback? onAction;
  final String tooltip;

  @override
  Widget build(BuildContext context) => AdaptiveListTile.apple(
    title: title,
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        subtitle,
        if (processing)
          const AppSyncLoadingIndicator()
        else
          const SizedBox(height: 4),
      ],
    ),
    trailing: AdaptiveIconButton.apple(
      key: const ValueKey('sync-action'),
      tooltip: tooltip,
      onPressed: onAction,
      icon: Icon(
        processing ? CupertinoIcons.xmark : CupertinoIcons.arrow_2_circlepath,
      ),
    ),
  );
}

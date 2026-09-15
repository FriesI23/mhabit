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

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../logging/helper.dart';
import '../../../models/app_sync_tasks.dart';
import '../../../providers/workflow/app_sync.dart';
import '../../../utils/app_path_provider.dart';
import '../../../utils/xshare.dart';
import '../../../widgets/widgets.dart';

class AppSettingSyncFailedTile extends StatefulWidget {
  const AppSettingSyncFailedTile({super.key});

  @override
  State<AppSettingSyncFailedTile> createState() => _AppSettingSyncFailedTile();
}

class _AppSettingSyncFailedTile extends State<AppSettingSyncFailedTile>
    with AutomaticKeepAliveClientMixin, XShare {
  Future? _onPressedFuture;

  @override
  bool get wantKeepAlive => true;

  void _onExportButtonPressed() {
    if (_onPressedFuture != null) return;
    final sessionId = context.read<AppSyncStatusSource>().syncStatus?.sessionId;
    if (sessionId == null) return;

    Future<void> doSave(String sessionId) async {
      if (!mounted) return;
      final path = await AppPathProvider().getSyncFailedLogFilePath(sessionId);
      if (!mounted) return;
      final result = await trySaveFiles(
        [XFile(path)],
        defaultTargetPlatform,
        context: context,
      );
      appLog.appsync.info("export failed log", ex: [sessionId, path, result]);
    }

    _onPressedFuture = doSave(sessionId)
        .catchError((e, s) {
          appLog.appsync.warn(
            "export failed log, got error",
            ex: [sessionId],
            error: e,
            stackTrace: s,
          );
          if (kDebugMode) Error.throwWithStackTrace(e, s);
        })
        .whenComplete(() => _onPressedFuture = null);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Selector<AppSyncStatusSource, (String?, AppSyncTaskResult?)>(
      selector: (context, vm) =>
          (vm.syncStatus?.sessionId, vm.syncStatus?.result),
      builder: (context, value, child) {
        final result = value.$2;
        if (result == null || result.isSuccessed || result.isCancelled) {
          return const SizedBox.shrink();
        }
        return _SyncFailureDetails(
          key: ValueKey(value),
          result: result,
          onExport: _onExportButtonPressed,
        );
      },
    );
  }
}

class _SyncFailureDetails extends StatefulWidget {
  const _SyncFailureDetails({
    super.key,
    required this.result,
    required this.onExport,
  });

  final AppSyncTaskResult result;
  final VoidCallback onExport;

  @override
  State<_SyncFailureDetails> createState() => _SyncFailureDetailsState();
}

class _SyncFailureDetailsState extends State<_SyncFailureDetails> {
  final ExpansibleController controller = ExpansibleController();
  // Expansion state belongs to this failure, including nested categories.
  final PageStorageBucket _storageBucket = PageStorageBucket();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget? _buildErrorSummary(BuildContext context, AppSyncTaskResult result) {
    var error = result.error.error;
    if (error == null && result is WebDavAppSyncTaskMultiResult) {
      for (final entry in result.habitResults.values.followedBy(
        result.groupResults.values,
      )) {
        if (!entry.isSuccessed &&
            !entry.isCancelled &&
            entry.error.error != null) {
          error = entry.error.error;
          break;
        }
      }
    }
    if (error == null) return null;
    final firstLine =
        const LineSplitter().convert(error.toString()).firstOrNull ?? '';
    return L10nBuilder(
      builder: (context, l10n) => Text(
        l10n?.appSync_failedTile_errorText(firstLine) ?? 'Error: $firstLine',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.result;

    List<Widget> buildWebDavErrorInfos(
      BuildContext context,
      WebDavAppSyncTaskResult result,
    ) => [_WebDavFailedDetailTile(result: result)];

    List<Widget> buildBasicErrorInfos(
      BuildContext context,
      AppSyncTaskResult result,
    ) => [
      Padding(
        padding: kListTileContentPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            L10nBuilder(
              builder: (context, l10n) => Text(
                l10n?.appSync_failedTile_errorText(
                      result.error.error.toString(),
                    ) ??
                    "Error: ${result.error.error}",
              ),
            ),
            if (result.error.trace != null) Text(result.error.trace.toString()),
          ],
        ),
      ),
    ];

    return PageStorage(
      bucket: _storageBucket,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) => AdaptiveExpansionTile(
          key: const PageStorageKey<String>(
            'app-settings-sync-failed-expansion',
          ),
          controller: controller,
          subtitle: controller.isExpanded
              ? null
              : _buildErrorSummary(context, value),
          title: L10nBuilder(
            builder: (context, l10n) => Text(
              l10n?.appSync_failedTile_titleText ?? "Check failure logs",
            ),
          ),
          trailing: L10nBuilder(
            builder: (context, l10n) => AdaptiveIconButton(
              key: const ValueKey('sync-export-log'),
              tooltip: l10n?.appSetting_export_titleText ?? 'Export',
              onPressed: widget.onExport,
              icon: switch (AdaptiveStyle.of(context)) {
                AdaptiveStyle.material => const Icon(
                  MdiIcons.fileExportOutline,
                ),
                AdaptiveStyle.apple => const Icon(
                  CupertinoIcons.square_arrow_up,
                ),
              },
            ),
          ),
          children: switch (value) {
            WebDavAppSyncTaskResult() => buildWebDavErrorInfos(context, value),
            AppSyncTaskResult() => buildBasicErrorInfos(context, value),
          },
        ),
      ),
    );
  }
}

class _WebDavFailedDetailTile extends StatelessWidget {
  final WebDavAppSyncTaskResult result;

  const _WebDavFailedDetailTile({required this.result});

  Widget _buildErrSubtitle(
    BuildContext context, [
    Object? error,
    StackTrace? trace,
  ]) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      L10nBuilder(
        builder: (context, l10n) => Text(
          l10n?.appSync_failedTile_errorText(error.toString()) ?? "$error",
        ),
      ),
      if (trace != null) ...[const Divider(), Text("$trace")],
    ],
  );

  Widget _buildFailedTile(
    BuildContext context,
    WebDavAppSyncTaskResult result,
  ) {
    Widget buildTitle(BuildContext context) => L10nBuilder(
      builder: (context, l10n) => Text(
        WebDavAppSyncTaskResultStatus.failed.getStatusTextString(
          result.reason,
          l10n,
        ),
      ),
    );

    return AdaptiveListTile(
      title: buildTitle(context),
      subtitle: result.error.error != null
          ? _buildErrSubtitle(context, result.error.error, result.error.trace)
          : null,
    );
  }

  Widget _buildMultiStatus(BuildContext context) {
    final result = this.result;
    if (result is! WebDavAppSyncTaskMultiResult) {
      if (kDebugMode) throw UnimplementedError();
      return const SizedBox();
    }

    final counter =
        <
          ({
            WebDavAppSyncTaskResultStatus status,
            WebDavAppSyncTaskResultSubStatus? reason,
            bool withError,
          }),
          int
        >{};

    final errors =
        <
          ({
            WebDavAppSyncTaskResultStatus status,
            WebDavAppSyncTaskResultSubStatus? reason,
          }),
          List<({Object? error, StackTrace? trace})>
        >{};
    final results = result.habitResults.values.followedBy(
      result.groupResults.values,
    );
    for (final entry in results) {
      final key = (
        status: entry.status,
        reason: entry.reason,
        withError: entry.withError,
      );
      counter[key] = (counter[key] ?? 0) + 1;
      if (key.withError) {
        errors
            .putIfAbsent((status: entry.status, reason: entry.reason), () => [])
            .add(entry.error);
      }
    }

    if (results.every((entry) => entry.isSuccessed)) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: counter.entries
          .map((e) {
            final errorIter = e.key.withError
                ? errors[(status: e.key.status, reason: e.key.reason)]
                      ?.mapIndexed(
                        (i, e) => Padding(
                          padding: kListTileContentPadding,
                          child: Text("[$i] ${e.error}"),
                        ),
                      )
                : null;
            return AdaptiveExpansionTile(
              key: PageStorageKey<String>(
                'app-settings-sync-failed-${e.key.status.name}-'
                '${e.key.reason?.name ?? 'none'}-${e.key.withError}',
              ),
              enabled: errorIter != null,
              title: L10nBuilder(
                builder: (context, l10n) => Text(
                  l10n?.appSync_failedTile_webdavMulti_counterText(
                        e.key.status.getStatusTextString(e.key.reason, l10n),
                        e.value,
                      ) ??
                      "${e.key.status.getStatusTextString(e.key.reason, l10n)}: "
                          "${e.value}",
                ),
              ),
              children: errorIter?.toList() ?? const [],
            );
          })
          .nonNulls
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (result.status) {
      case WebDavAppSyncTaskResultStatus.success ||
          WebDavAppSyncTaskResultStatus.cancelled:
        return const SizedBox();
      case WebDavAppSyncTaskResultStatus.failed:
        return _buildFailedTile(context, result);
      case WebDavAppSyncTaskResultStatus.multi:
        return _buildMultiStatus(context);
    }
  }
}

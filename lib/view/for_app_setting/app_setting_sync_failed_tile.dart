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

import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../component/widget.dart';
import '../../logging/helper.dart';
import '../../model/app_sync_task.dart';
import '../../provider/app_sync.dart';
import '../../utils/app_path_provider.dart';
import '../common/_mixin.dart';

class AppSettingSyncFailedTile extends StatefulWidget {
  final ExpansionTileController? controller;

  const AppSettingSyncFailedTile({super.key, this.controller});

  @override
  State<AppSettingSyncFailedTile> createState() => _AppSettingSyncFailedTile();
}

class _AppSettingSyncFailedTile extends State<AppSettingSyncFailedTile>
    with AutomaticKeepAliveClientMixin, XShare {
  late ExpansionTileController controller;
  late bool lastExpanded;
  late bool isExpanded;

  Future? _onPressedFuture;

  void setExpand(bool value) {
    if (value != isExpanded) {
      lastExpanded = isExpanded;
      isExpanded = value;
    }
  }

  @override
  void initState() {
    controller = widget.controller ?? ExpansionTileController();
    lastExpanded = isExpanded =
        context.read<AppSyncViewModel>().appSyncTask.task?.result?.withError ==
            true;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    lastExpanded =
        context.read<AppSyncViewModel>().appSyncTask.task?.result?.withError ==
            true;
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => lastExpanded == isExpanded;

  void _onExportButtonPressed() {
    if (_onPressedFuture != null) return;
    final sessionId =
        context.read<AppSyncViewModel>().appSyncTask.task?.task.sessionId;
    if (sessionId == null) return;

    Future<void> doSave(String sessionId) async {
      if (!mounted) return;
      final path = await AppPathProvider().getSyncFailedLogFilePath(sessionId);
      if (!mounted) return;
      final result = await trySaveFiles([XFile(path)], defaultTargetPlatform,
          context: context);
      appLog.appsync.info("export failed log", ex: [sessionId, path, result]);
    }

    _onPressedFuture = doSave(sessionId).catchError((e, s) {
      appLog.appsync.warn("export failed log, got error",
          ex: [sessionId], error: e, stackTrace: s);
      if (kDebugMode) Error.throwWithStackTrace(e, s);
    }).whenComplete(() => _onPressedFuture = null);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<Widget> buildWebDavErrorInfos(
            BuildContext context, WebDavAppSyncTaskResult result) =>
        [_WebDavFailedDetailTile(result: result)];

    List<Widget> buildBasicErrorInfos(
            BuildContext context, AppSyncTaskResult result) =>
        [
          Padding(
            padding: kListTileContentPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Error: ${result.error.error}"),
                if (result.error.trace != null)
                  Text(result.error.trace.toString()),
              ],
            ),
          )
        ];

    return Selector<AppSyncViewModel, AppSyncTaskResult?>(
      selector: (context, vm) => vm.appSyncTask.task?.result,
      shouldRebuild: (previous, next) {
        if (previous == next) return false;
        next?.withError == true ? controller.expand() : controller.collapse();
        setExpand(controller.isExpanded);
        return true;
      },
      builder: (context, value, child) => ExpandedSection(
        expand: value != null && !value.isSuccessed && !value.isCancelled,
        child: ExpansionTile(
          controller: controller,
          initiallyExpanded: isExpanded,
          onExpansionChanged: (value) {},
          expandedAlignment: Alignment.centerLeft,
          title: Text("Check failure logs"),
          trailing: IconButton(
              onPressed: _onExportButtonPressed,
              icon: const Icon(MdiIcons.fileExportOutline)),
          children: switch (value) {
            WebDavAppSyncTaskResult() => buildWebDavErrorInfos(context, value),
            AppSyncTaskResult() => buildBasicErrorInfos(context, value),
            _ => const [SizedBox()],
          },
        ),
      ),
    );
  }
}

class _WebDavFailedDetailTile extends StatelessWidget {
  final WebDavAppSyncTaskResult result;

  const _WebDavFailedDetailTile({required this.result});

  Widget _buildErrSubtitle(BuildContext context,
          [Object? error, StackTrace? trace]) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$error"),
          if (trace != null) ...[
            const Divider(),
            Text("$trace"),
          ]
        ],
      );

  Widget _buildFailedTile(
      BuildContext context, WebDavAppSyncTaskResult result) {
    Widget buildTitle(BuildContext context) {
      final reason = result.reason;
      if (reason == null) return Text("Failed with no specific reason.");
      return Text("Failed with ${reason.getReasonString()}");
    }

    return ListTile(
      dense: true,
      isThreeLine: result.error.error != null,
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

    final counter = <({
      WebDavAppSyncTaskResultStatus status,
      WebDavAppSyncTaskResultSubStatus? reason,
      bool withError,
    }),
        int>{};

    final errors = <({
      WebDavAppSyncTaskResultStatus status,
      WebDavAppSyncTaskResultSubStatus? reason
    }),
        List<({Object? error, StackTrace? trace})>>{};
    for (var entry in result.habitResults.entries) {
      final key = (
        status: entry.value.status,
        reason: entry.value.reason,
        withError: entry.value.withError,
      );
      counter[key] = (counter[key] ?? 0) + 1;
      if (key.withError) {
        errors.putIfAbsent(
            (status: entry.value.status, reason: entry.value.reason),
            () => []).add(entry.value.error);
      }
    }

    final filteredHabits =
        result.habitResults.entries.where((e) => !e.value.isSuccessed).toList();
    if (filteredHabits.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: counter.entries
          .map((e) {
            final errorIter =
                errors[(status: e.key.status, reason: e.key.reason)]
                    ?.mapIndexed(
              (i, e) => Padding(
                  padding: kListTileContentPadding,
                  child: Text("[$i] ${e.error}")),
            );
            return ExpansionTile(
              dense: true,
              showTrailingIcon: errorIter != null,
              enabled: errorIter != null,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              expandedAlignment: Alignment.centerLeft,
              title: Text("${e.key.status.getStatusTextString(e.key.reason)}: "
                  "${e.value}"),
              children: errorIter?.toList() ?? const [],
            );
          })
          .whereNotNull()
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

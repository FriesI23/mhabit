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
        [
          Padding(
            padding: kListTileContentPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status: ${result.status}"),
                Text("Reason: ${result.reason}"),
                if (result.withError) ...[
                  Text("Error: ${result.error.error}"),
                  if (result.error.trace != null)
                    Text(result.error.trace.toString()),
                ]
              ],
            ),
          ),
        ];

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
          title: Text("Check failure logs."),
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

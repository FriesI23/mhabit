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

import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/localizations.dart';
import '../../utils/app_sync.dart';
import '../common/_mixin.dart';

class AppSyncFailLogsTile extends StatefulWidget {
  final String? path;
  final Duration refreshInterval;

  const AppSyncFailLogsTile(
      {super.key,
      required this.path,
      this.refreshInterval = const Duration(seconds: 10)});

  @override
  State<AppSyncFailLogsTile> createState() => _AppSyncFailLogsTile();
}

class _AppSyncFailLogsTile extends State<AppSyncFailLogsTile> with XShare {
  late CancelableCompleter<void> completer;

  Directory? dir;
  bool? isEmpty;

  CancelableCompleter<void> _refreshLoop() {
    final completer = CancelableCompleter<void>();

    Future<void> doRefreshLoop() {
      if (!mounted || completer.isCompleted) return Future.value();
      final startT = DateTime.now().millisecondsSinceEpoch;
      return (dir?.list().toList() ??
              Future<List<FileSystemEntity>?>(() => null))
          .timeout(widget.refreshInterval)
          .then<bool?>((value) => value?.isEmpty)
          .onError<TimeoutException>((e, s) {
        if (kDebugMode) Error.throwWithStackTrace(e, s);
        return isEmpty;
      }).then((result) {
        if (!mounted || completer.isCompleted) return Future.value();
        if (result != isEmpty) {
          setState(() {
            isEmpty = result;
          });
        }
        final timeDiff = DateTime.now().millisecondsSinceEpoch - startT;
        final dura = widget.refreshInterval - Duration(milliseconds: timeDiff);
        return dura.isNegative
            ? doRefreshLoop()
            : Future.delayed(dura).then((_) => doRefreshLoop());
      });
    }

    doRefreshLoop();
    return completer;
  }

  @override
  void initState() {
    final path = widget.path;
    dir = path != null ? Directory(path) : null;
    completer = _refreshLoop();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AppSyncFailLogsTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final path = widget.path;
    dir = path != null ? Directory(path) : null;
    completer.operation.cancel();
    completer = _refreshLoop();
  }

  bool get enabled => isEmpty == false;

  void _onTilePressed() async {
    final zipFilePath = await generateZippedSyncFailedLogs();
    if (!mounted) return;
    trySaveFiles([XFile(zipFilePath)], defaultTargetPlatform,
        subject: L10n.of(context)?.appSync_exportAllLogsTile_exportSubjectText,
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListTile(
        title: Text(l10n?.appSync_exportAllLogsTile_titleText ??
            "Export Failed Sync Logs"),
        subtitle: l10n != null
            ? Text(
                l10n.appSync_exportAllLogsTile_subtitleText(isEmpty.toString()))
            : null,
        onTap: _onTilePressed,
        enabled: enabled,
      ),
    );
  }
}

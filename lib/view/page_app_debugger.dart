// Copyright 2024 Fries_I23
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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../common/consts.dart';
import '../component/helper.dart';
import '../component/widget.dart';
import '../logging/level.dart';
import '../provider/app_debugger.dart';
import 'common/_mixin.dart';
import 'common/_widget.dart';
import 'for_app_debugger/_widget.dart';

Future<void> naviToAppDebuggerPage({required BuildContext context}) async {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (context) => const PageAppDebugger(),
    ),
  );
}

/// Depend Providers
/// - Required for builder:
///   - [AppDebuggerViewModel]
/// - Required for callback:
/// - Optional:
class PageAppDebugger extends StatelessWidget {
  const PageAppDebugger({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppDebuggerView();
  }
}

class AppDebuggerView extends StatefulWidget {
  const AppDebuggerView({super.key});

  @override
  State<StatefulWidget> createState() => AppDebuggerViewState();
}

class AppDebuggerViewState extends State<AppDebuggerView> with XShare {
  void _onLogLevelChanged(LogLevel newLevel) async {
    if (!mounted) return;
    context.read<AppDebuggerViewModel>().updateLoggingLevel(newLevel);
  }

  void _onCollectLogsSwitcherChanged(bool newStatus) async {
    if (!mounted) return;
    context.read<AppDebuggerViewModel>().setCollectLogsSatus(newStatus);
  }

  void _onDownloadLogButtonPressed(BuildContext context) async {
    final docDir = await getApplicationDocumentsDirectory();
    final filePath = path.join(docDir.path, debuggerLogFileName);
    final fileExist = await File(filePath).exists();
    if (!mounted) return;
    if (!fileExist) {
      _showDebugLogFileDismissSnackbar();
      return;
    }
    // TODO(INDEV): l10n
    const subject = "Downloading debugging logs";
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        pickAndSaveToFile(filePath,
            fileName: debuggerLogFileName, subject: subject);
      default:
        shareXFiles([XFile(filePath)], context: context, subject: subject);
    }
  }

  void _onClearLogButtongPressed(BuildContext context) async {
    final docDir = await getApplicationDocumentsDirectory();
    final file = File(path.join(docDir.path, debuggerLogFileName));
    final fileExist = await file.exists();
    if (!mounted) return;
    if (!fileExist) {
      _showDebugLogFileDismissSnackbar();
      return;
    }
    await file.delete();
    if (!mounted) return;
    // TODO(INDEV): l10n
    final snackbar = BuildWidgetHelper().buildSnackBarWithDismiss(context,
        content: const Text("Debug log cleared"));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void _showDebugLogFileDismissSnackbar() {
    if (!mounted) return;
    // TODO(INDEV): l10n
    final snackbar = BuildWidgetHelper().buildSnackBarWithDismiss(context,
        content: const Text("Log file not exist"));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          Selector<AppDebuggerViewModel, bool>(
            selector: (context, vm) => vm.isCollectLogs,
            shouldRebuild: (previous, next) => previous != next,
            builder: (context, isCollectLogs, child) {
              return ChangeLogsSwitcherTile(
                value: isCollectLogs,
                onChanged: _onCollectLogsSwitcherChanged,
              );
            },
          ),
          Selector<AppDebuggerViewModel, LogLevel>(
            selector: (context, vm) => vm.loggingLevel,
            shouldRebuild: (previous, next) => previous != next,
            builder: (context, logLevel, child) {
              return LogLevelChangerTile(
                crtLevel: logLevel,
                onSelected: _onLogLevelChanged,
              );
            },
          ),
          const _Sperator(),
          _DownlaodLogButton(onPressed: _onDownloadLogButtonPressed),
          _ClearLogButton(onPressed: _onClearLogButtongPressed),
        ],
      ),
    );
  }
}

class _Sperator extends StatelessWidget {
  const _Sperator();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Spacer(),
        Flexible(
          flex: 10,
          child: Divider(),
        ),
        Spacer(),
      ],
    );
  }
}

class _DownlaodLogButton extends StatelessWidget {
  final void Function(BuildContext context)? onPressed;

  const _DownlaodLogButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FilledButton(
        onPressed: onPressed != null ? () => onPressed!(context) : null,
        // TODO(INDEV): l10n
        child: const Text("Download logs"),
      ),
    );
  }
}

class _ClearLogButton extends StatelessWidget {
  final void Function(BuildContext context)? onPressed;

  const _ClearLogButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FilledButton.tonal(
        onPressed: onPressed != null ? () => onPressed!(context) : null,
        // TODO(INDEV): l10n
        child: const Text("Clear logs"),
      ),
    );
  }
}

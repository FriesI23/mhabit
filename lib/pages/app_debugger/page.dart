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
import 'package:open_file/open_file.dart' show OpenFile;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../common/app_info.dart';
import '../../common/consts.dart';
import '../../common/global.dart' show currentRouteObserver, navigatorKey;
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../logging/level.dart';
import '../../logging/logger_manager.dart';
import '../../providers/app_debugger.dart';
import '../../utils/app_path_provider.dart';
import '../../utils/debug_info.dart';
import '../../utils/xshare.dart';
import '../../widgets/helpers.dart';
import '../../widgets/widgets.dart';
import '../common/widgets.dart';
import 'widgets.dart';

Future<void> onDebuggerNotificationTapped() async {
  final context = navigatorKey.currentContext;
  if (context == null) return;
  final currentRouteName = currentRouteObserver.routeName;
  appLog.debugger.info(
    "onDebuggerNotificationTapped: navi",
    ex: [AppDebuggerPage.routerName, currentRouteName],
  );
  if (currentRouteName != AppDebuggerPage.routerName) {
    naviToAppDebuggerPage(context: context);
  }
}

Future<void> naviToAppDebuggerPage({required BuildContext context}) async {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (context) => const AppDebuggerPage(),
      settings: const RouteSettings(name: AppDebuggerPage.routerName),
    ),
  );
}

/// Depend Providers
/// - Required for builder:
///   - [AppDebuggerViewModel]
/// - Required for callback:
/// - Optional:
class AppDebuggerPage extends StatelessWidget {
  static const routerName = "/app_debugger";

  const AppDebuggerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Page();
  }
}

class _Page extends StatefulWidget {
  const _Page();

  @override
  State<StatefulWidget> createState() => _PageState();
}

class _PageState extends State<_Page> with XShare {
  void _onLogLevelChanged(LogLevel newLevel) async {
    if (!mounted) return;
    context.read<AppDebuggerViewModel>().updateLoggingLevel(newLevel);
  }

  void _onCollectLogsSwitcherChanged(bool newStatus) async {
    if (!mounted) return;
    await context.read<AppDebuggerViewModel>().setCollectLogsSatus(newStatus);
    if (!mounted) return;
    context.read<AppDebuggerViewModel>().processDebuggingNotification(
      L10n.of(context),
    );
  }

  void _onDownloadLogButtonPressed(BuildContext context) async {
    final filePath = await AppPathProvider().getAppDebugLogFilePath();
    final fileExist = await File(filePath).exists();
    if (!context.mounted) return;
    if (!fileExist) return _showDebugLogFileDismissSnackbar();
    final subject = L10n.of(context)?.debug_downladDebugLogs_subject;
    trySaveFiles(
      [XFile(filePath)],
      defaultTargetPlatform,
      context: context,
      subject: subject,
    );
  }

  void _onClearLogButtongPressed(BuildContext context) async {
    final filePath = await AppPathProvider().getAppDebugLogFilePath();
    final fileObj = File(filePath);
    final fileExist = await fileObj.exists();
    if (!context.mounted) return;
    if (!fileExist) return _showDebugLogFileDismissSnackbar();
    await fileObj.delete();
    AppLoggerMananger.reloadDebuggingLogger(filePath: filePath);
    if (!context.mounted) return;
    final snackbar = buildSnackBarWithDismiss(
      context,
      content: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.dbeug_clearDebugLogs_complete_snackbar)
            : const Text("Debug log cleared"),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void _onOpenDebugButtonPressed(BuildContext context) async {
    final filePath = await AppPathProvider().getAppDebugInfoFilePath();
    final debugInfo = await AppInfo().generateAppDebugInfo();
    await File(filePath).writeAsString(debugInfo, mode: FileMode.writeOnly);
    if (!mounted) return;
    OpenFile.open(filePath, type: "text/plain");
  }

  void _onSaveDebugButtonPressed(BuildContext context) async {
    final filePath = await AppPathProvider().getAppDebugInfoFilePath();
    final debugInfo = await AppInfo().generateAppDebugInfo();
    await File(filePath).writeAsString(debugInfo, mode: FileMode.writeOnly);
    if (!context.mounted) return;
    final subject = L10n.of(context)?.debug_downladDebugInfo_subject;
    saveSingleFile(filePath, subject: subject);
  }

  void _onFABPressed(BuildContext context) async {
    final zipFilePath = await generateZippedDebugInfo();
    if (!context.mounted) return;
    final subject = L10n.of(
      context,
    )?.debug_downladDebugZip_subject(debuggerZipFile);
    trySaveFiles(
      [XFile(zipFilePath)],
      defaultTargetPlatform,
      context: context,
      subject: subject,
    );
  }

  void _showDebugLogFileDismissSnackbar() {
    if (!mounted) return;
    final snackbar = buildSnackBarWithDismiss(
      context,
      content: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.debug_missingDebugLogFile_snackbar)
            : const Text("Log file missing"),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            child: const Icon(Icons.share),
            onPressed: () => _onFABPressed(context),
          );
        },
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
          const SizedBox(height: 8),
          Padding(
            padding: kListTileContentPadding,
            child: DebuggerLogCard(
              onDownloadPressed: _onDownloadLogButtonPressed,
              onClearPressed: _onClearLogButtongPressed,
            ),
          ),
          Padding(
            padding: kListTileContentPadding,
            child: DebuggerInfoCard(
              onOpenPressed: _onOpenDebugButtonPressed,
              onSavePressed: _onSaveDebugButtonPressed,
            ),
          ),
          const FixedPagePlaceHolder(minHeight: 82.0),
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
        Flexible(flex: 10, child: Divider()),
        Spacer(),
      ],
    );
  }
}

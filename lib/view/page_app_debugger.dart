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
import 'package:open_file_plus/open_file_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../common/app_info.dart';
import '../common/consts.dart';
import '../component/helper.dart';
import '../component/widget.dart';
import '../extension/colorscheme_extensions.dart';
import '../l10n/localizations.dart';
import '../logging/level.dart';
import '../provider/app_debugger.dart';
import '../utils/debug_info.dart';
import 'common/_mixin.dart';
import 'common/_widget.dart';
import 'for_app_debugger/_widget.dart';

const _kCardPadding = EdgeInsets.only(top: 4.0, bottom: 2.0);

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
    final filePath = await debugLogFilePath;
    final fileExist = await File(filePath).exists();
    if (!mounted) return;
    if (!fileExist) return _showDebugLogFileDismissSnackbar();
    final subject = L10n.of(context)?.debug_downladDebugLogs_subject;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        pickAndSaveToFile(filePath, subject: subject);
      default:
        shareXFiles([XFile(filePath)], context: context, subject: subject);
    }
  }

  void _onClearLogButtongPressed(BuildContext context) async {
    final filePath = await debugLogFilePath;
    final fileObj = File(filePath);
    final fileExist = await fileObj.exists();
    if (!mounted) return;
    if (!fileExist) return _showDebugLogFileDismissSnackbar();
    await fileObj.delete();
    if (!mounted) return;
    final snackbar = BuildWidgetHelper().buildSnackBarWithDismiss(context,
        content: L10nBuilder(
          builder: (context, l10n) => l10n != null
              ? Text(l10n.dbeug_clearDebugLogs_complete_snackbar)
              : const Text("Debug log cleared"),
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void _onOpenDebugButtonPressed(BuildContext context) async {
    final filePath = await debugInfoFilePath;
    final debugInfo = await AppInfo().generateAppDebugInfo();
    await File(filePath).writeAsString(debugInfo, mode: FileMode.writeOnly);
    if (!mounted) return;
    OpenFile.open(filePath, type: "text/plain", uti: "public.plain-text");
  }

  void _onSaveDebugButtonPressed(BuildContext context) async {
    final filePath = await debugInfoFilePath;
    final debugInfo = await AppInfo().generateAppDebugInfo();
    await File(filePath).writeAsString(debugInfo, mode: FileMode.writeOnly);
    if (!mounted) return;
    final subject = L10n.of(context)?.debug_downladDebugInfo_subject;
    pickAndSaveToFile(filePath, subject: subject);
  }

  void _onFABPressed(BuildContext context) async {
    final zipFilePath = await generateZippedDebugInfo();
    if (!mounted) return;
    final subject =
        L10n.of(context)?.debug_downladDebugZip_subject(debuggerZipFile);
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        pickAndSaveToFile(zipFilePath, subject: subject);
      default:
        shareXFiles([XFile(zipFilePath)], context: context, subject: subject);
    }
  }

  void _showDebugLogFileDismissSnackbar() {
    if (!mounted) return;
    final snackbar = BuildWidgetHelper().buildSnackBarWithDismiss(context,
        content: L10nBuilder(
          builder: (context, l10n) => l10n != null
              ? Text(l10n.debug_missingDebugLogFile_snackbar)
              : const Text("Log file missing"),
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          child: const Icon(Icons.share),
          onPressed: () => _onFABPressed(context),
        );
      }),
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
            child: _DebuggerLogCard(
              onDownloadPressed: _onDownloadLogButtonPressed,
              onClearPressed: _onClearLogButtongPressed,
            ),
          ),
          Padding(
            padding: kListTileContentPadding,
            child: _DebuggerInfoCard(
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
        Flexible(
          flex: 10,
          child: Divider(),
        ),
        Spacer(),
      ],
    );
  }
}

class _DebuggerLogCard extends StatelessWidget {
  final void Function(BuildContext context)? onDownloadPressed;
  final void Function(BuildContext context)? onClearPressed;

  const _DebuggerLogCard({
    required this.onDownloadPressed,
    required this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainerOpacity32,
      child: Padding(
        padding: _kCardPadding,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title:
                  l10n != null ? Text(l10n.debug_debuggerLogCard_title) : null,
              subtitle: l10n != null
                  ? Text(l10n.debug_debuggerLogCard_subtitle)
                  : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Builder(builder: (context) {
                  return TextButton(
                    onPressed: onDownloadPressed != null
                        ? () => onDownloadPressed!(context)
                        : null,
                    child: Text(
                      l10n?.debug_debuggerLogCard_saveButton_text ?? 'Downlaod',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Builder(builder: (context) {
                  return TextButton(
                    onPressed: onClearPressed != null
                        ? () => onClearPressed!(context)
                        : null,
                    child: Text(
                      l10n?.debug_debuggerLogCard_clearButton_text ?? 'Clear',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  );
                }),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DebuggerInfoCard extends StatelessWidget {
  final void Function(BuildContext context)? onOpenPressed;
  final void Function(BuildContext conetxt)? onSavePressed;

  const _DebuggerInfoCard({this.onOpenPressed, this.onSavePressed});

  Widget _buildOpenButton(BuildContext context, [L10n? l10n]) => TextButton(
        onPressed: onOpenPressed != null ? () => onOpenPressed!(context) : null,
        child: Text(
          l10n?.debug_debuggerInfoCard_openButton_text ?? 'Open',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
      );

  Widget _buildSaveButton(BuildContext context, [L10n? l10n]) => TextButton(
        onPressed: onSavePressed != null ? () => onSavePressed!(context) : null,
        child: Text(
          l10n?.debug_debuggerInfoCard_saveButton_text ?? 'Save',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget buildMainButton(BuildContext context) {
      final l10n = L10n.of(context);
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
        case TargetPlatform.iOS:
        case TargetPlatform.windows:
        case TargetPlatform.linux:
        case TargetPlatform.macOS:
          return _buildOpenButton(context, l10n);
        default:
          return _buildSaveButton(context, l10n);
      }
    }

    final l10n = L10n.of(context);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainerOpacity32,
      child: Padding(
        padding: _kCardPadding,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.adb_outlined),
              title:
                  l10n != null ? Text(l10n.debug_debuggerInfoCard_title) : null,
              subtitle: l10n != null
                  ? Text(l10n.debug_debuggerInfoCard_subtitle)
                  : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Builder(builder: buildMainButton),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

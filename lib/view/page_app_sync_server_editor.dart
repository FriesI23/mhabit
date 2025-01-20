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

import '../component/widget.dart';
import '../model/app_sync_server.dart';
import '../provider/app_sync_server_form.dart';
import 'common/_widget.dart';
import 'common/app_ui_layout_builder.dart';
import 'for_app_sync_server_editor/_widget.dart';

Future<void> naviToAppSyncServerEditorDialog({
  required BuildContext context,
  AppSyncServer? serverConfig,
  bool? naviWithFullscreenDialog,
}) async {
  return showDialog(
    context: context,
    builder: (context) => PageAppSyncServerEditor(
      serverConfig: serverConfig,
      showInFullscreenDialog: naviWithFullscreenDialog,
    ),
  );
}

class PageAppSyncServerEditor extends StatelessWidget {
  final AppSyncServer? serverConfig;
  final bool? showInFullscreenDialog;

  const PageAppSyncServerEditor({
    super.key,
    this.serverConfig,
    this.showInFullscreenDialog,
  });

  @override
  Widget build(BuildContext context) {
    return PageProviders(
      child: AppUiLayoutBuilder(
        ignoreHeight: false,
        ignoreWidth: false,
        builder: (context, layoutType, child) => AppSyncServerEditorView(
          serverConfig: serverConfig,
          showInFullscreenDialog: showInFullscreenDialog ??
              (layoutType == UiLayoutType.s ? true : false),
        ),
      ),
    );
  }
}

class AppSyncServerEditorView extends StatefulWidget {
  final AppSyncServer? serverConfig;
  final bool showInFullscreenDialog;

  const AppSyncServerEditorView({
    super.key,
    this.serverConfig,
    required this.showInFullscreenDialog,
  });

  @override
  State<StatefulWidget> createState() => _AppSyncServerEditerView();
}

class _AppSyncServerEditerView extends State<AppSyncServerEditorView> {
  _AppSyncServerEditerView();

  void _onSaveButtonPressed() {
    // TODO: implement _onSaveButtonPressed
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = true;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: widget.showInFullscreenDialog
          ? _AppSyncServerEditorFsDialog(
              key: const ValueKey("fullscreen"),
              serverConfig: widget.serverConfig,
              onSaveButtonPressed: _onSaveButtonPressed,
              canSave: canSave,
            )
          : _AppSyncServerEditorDialog(
              key: const ValueKey("dialog"),
              serverConfig: widget.serverConfig,
              onSaveButtonPressed: _onSaveButtonPressed,
              canSave: canSave,
            ),
    );
  }
}

class _AppSyncServerEditorFsDialog extends StatelessWidget {
  final AppSyncServer? serverConfig;
  final bool canSave;
  final VoidCallback? onSaveButtonPressed;

  const _AppSyncServerEditorFsDialog({
    super.key,
    required this.serverConfig,
    required this.canSave,
    required this.onSaveButtonPressed,
  });

  @override
  Widget build(BuildContext context) => Dialog.fullscreen(
        child: ColorfulNavibar(
          child: Scaffold(
            appBar: AppBar(
              leading: const PageBackButton(reason: PageBackReason.close),
              actions: [
                TextButton(
                  onPressed: canSave ? onSaveButtonPressed : null,
                  child: Text("Save"),
                ),
              ],
            ),
            body: ListView(
              children: [
                const AppSyncServerTypeMenu(),
                const AppSyncServerPathTile(),
                const AppSyncServerUsernameTile(),
                const AppSyncServerPasswordTile(),
                const _DebuggerTile(),
              ],
            ),
          ),
        ),
      );
}

class _AppSyncServerEditorDialog extends StatelessWidget {
  final AppSyncServer? serverConfig;
  final bool canSave;
  final VoidCallback? onSaveButtonPressed;

  const _AppSyncServerEditorDialog({
    super.key,
    required this.serverConfig,
    required this.canSave,
    required this.onSaveButtonPressed,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        scrollable: true,
        title: const Text("Modfiy Sync Server"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppSyncServerTypeMenu(width: -1),
            const AppSyncServerPathTile(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Expanded(child: AppSyncServerUsernameTile()),
                const Expanded(child: AppSyncServerPasswordTile()),
              ],
            ),
            const _DebuggerTile(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text("cancel"),
          ),
          TextButton(
            onPressed: canSave ? onSaveButtonPressed : null,
            child: Text("save"),
          ),
        ],
      );
}

class _DebuggerTile extends StatefulWidget {
  const _DebuggerTile();

  @override
  State<_DebuggerTile> createState() => _DebuggerTileState();
}

class _DebuggerTileState extends State<_DebuggerTile> {
  late AppSyncServerFormViewModel formVM;

  void _changeListener() => setState(() {});

  @override
  void initState() {
    super.initState();
    formVM = context.read<AppSyncServerFormViewModel>();
    formVM.pathInputController.addListener(_changeListener);
    formVM.usernameInputController.addListener(_changeListener);
    formVM.passwordInputController.addListener(_changeListener);
  }

  @override
  void dispose() {
    formVM.pathInputController.removeListener(_changeListener);
    formVM.usernameInputController.removeListener(_changeListener);
    formVM.passwordInputController.removeListener(_changeListener);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    formVM = context.read<AppSyncServerFormViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppSyncServerFormViewModel>();
    return Column(
      children: [
        const Divider(),
        ListTile(
          leading:
              Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          title: const Text("DEBUG"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Mounted: ${vm.mounted}"),
              Text("Type: ${vm.type}"),
              Text("Path: ${vm.pathInputController.text}"),
              Text("Username: ${vm.usernameInputController.text}"),
              Text("Password: ${vm.passwordInputController.text}"),
              Text("Form: ${vm.formSnapshot}"),
            ],
          ),
          isThreeLine: true,
        ),
      ],
    );
  }
}

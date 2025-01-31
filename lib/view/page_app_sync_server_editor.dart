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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../common/consts.dart';
import '../component/widget.dart';
import '../model/app_sync_server.dart';
import '../provider/app_sync_server_form.dart';
import 'common/_dialog.dart';
import 'common/_widget.dart';
import 'common/app_ui_layout_builder.dart';
import 'for_app_sync_server_editor/_widget.dart';

Future<AppSyncServerForm?> naviToAppSyncServerEditorDialog({
  required BuildContext context,
  AppSyncServer? serverConfig,
  bool? naviWithFullscreenDialog,
}) async {
  return showDialog<AppSyncServerForm>(
    context: context,
    barrierDismissible: false,
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
      initServerConfig: serverConfig,
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
  late bool showAdvanceConfig;

  _AppSyncServerEditerView();

  @override
  void initState() {
    super.initState();
    showAdvanceConfig = false;
  }

  void _onSaveButtonPressed() async {
    final bool confirmed;
    final vm = context.read<AppSyncServerFormViewModel>();
    assert(vm.canSave, "Can't save current config, got ${vm.formSnapshot}");
    final form = vm.getFinalForm();
    if (vm.edited && vm.crtServerConfig != null) {
      confirmed = await showConfirmDialog(
            context: context,
            title: const Text("Confirm Save Changes"),
            subtitle: const Text(
                "Saving will overwrite previous server configuration."),
            cancelText: const Text("cancel"),
            confirmText: const Text("confirm"),
          ) ??
          false;
    } else {
      confirmed = true;
    }
    if (!mounted || !confirmed) return;
    Navigator.of(context).pop(form);
  }

  bool shouldShowCancelConfirmDialog(AppSyncServerFormViewModel vm) =>
      vm.edited;

  Future<void> cancelConfirmProcess([AppSyncServerForm? result]) async {
    final bool confirmed;
    final vm = context.read<AppSyncServerFormViewModel>();
    if (shouldShowCancelConfirmDialog(vm)) {
      confirmed = await showConfirmDialog(
            context: context,
            title: const Text("Unsaved Changes"),
            subtitle: const Text("Exiting will discard all unsaved changes."),
            cancelText: const Text("cancel"),
            confirmText: const Text("exit"),
          ) ??
          false;
    } else {
      confirmed = true;
    }
    if (!mounted || !confirmed) return;
    Navigator.maybeOf(context)?.pop(result);
  }

  void _onCancelButtonPressed() => cancelConfirmProcess();

  void _onAdvanceConfigExpansionChanged(bool value) =>
      showAdvanceConfig = value;

  @override
  Widget build(BuildContext context) =>
      Selector<AppSyncServerFormViewModel, bool>(
        selector: (context, vm) => shouldShowCancelConfirmDialog(vm),
        builder: (context, value, child) => PopScope<AppSyncServerForm>(
          canPop: !value,
          child: child!,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await cancelConfirmProcess(result);
          },
        ),
        child: AnimatedSwitcher(
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          duration: const Duration(milliseconds: 300),
          child: widget.showInFullscreenDialog
              ? _AppSyncServerEditorFsDialog(
                  key: const ValueKey("fullscreen"),
                  serverConfig: widget.serverConfig,
                  onSaveButtonPressed: _onSaveButtonPressed,
                  onCancelButtonPressed: _onCancelButtonPressed,
                  showAdvanceConfig: showAdvanceConfig,
                  onAdvConfigExpansionChanged: _onAdvanceConfigExpansionChanged,
                )
              : _AppSyncServerEditorDialog(
                  key: const ValueKey("dialog"),
                  serverConfig: widget.serverConfig,
                  onSaveButtonPressed: _onSaveButtonPressed,
                  onCancelButtonPressed: _onCancelButtonPressed,
                  showAdvanceConfig: showAdvanceConfig,
                  onAdvConfigExpansionChanged: _onAdvanceConfigExpansionChanged,
                ),
        ),
      );
}

class _AppSyncServerEditorFsDialog extends StatelessWidget {
  final AppSyncServer? serverConfig;
  final bool showAdvanceConfig;
  final VoidCallback? onSaveButtonPressed;
  final VoidCallback? onCancelButtonPressed;
  final ValueChanged<bool>? onAdvConfigExpansionChanged;

  const _AppSyncServerEditorFsDialog({
    super.key,
    required this.serverConfig,
    required this.showAdvanceConfig,
    required this.onSaveButtonPressed,
    required this.onCancelButtonPressed,
    this.onAdvConfigExpansionChanged,
  });

  @override
  Widget build(BuildContext context) => Dialog.fullscreen(
        child: ColorfulNavibar(
          child: Scaffold(
            appBar: AppBar(
              leading: PageBackButton(
                  reason: PageBackReason.close,
                  onPressed: onCancelButtonPressed),
              actions: [
                AppSyncServerSaveButton(onPressed: onSaveButtonPressed),
              ],
            ),
            body: ListView(
              children: [
                const AppSyncServerTypeMenu(),
                const AppSyncServerPathTile(),
                const AppSyncServerUsernameTile(),
                const AppSyncServerPasswordTile(),
                _AppSyncServerEditorAdvConfigGroup(
                  type: UiLayoutType.s,
                  expanded: showAdvanceConfig,
                  onExpansionChanged: onAdvConfigExpansionChanged,
                ),
                const _DebuggerTile(),
              ],
            ),
          ),
        ),
      );
}

class _AppSyncServerEditorDialog extends StatelessWidget {
  static const dialogMaxWidth = 1240.0;

  final AppSyncServer? serverConfig;
  final bool showAdvanceConfig;
  final VoidCallback? onSaveButtonPressed;
  final VoidCallback? onCancelButtonPressed;
  final ValueChanged<bool>? onAdvConfigExpansionChanged;

  const _AppSyncServerEditorDialog({
    super.key,
    required this.serverConfig,
    required this.showAdvanceConfig,
    required this.onSaveButtonPressed,
    required this.onCancelButtonPressed,
    this.onAdvConfigExpansionChanged,
  });

  Widget _buildUserTiles(BuildContext context) => Builder(
        builder: (context) => MediaQuery.of(context).size.width >=
                kHabitLargeScreenAdaptWidth * 1.5
            ? const Row(
                key: ValueKey("large"),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(child: AppSyncServerUsernameTile()),
                  Expanded(child: AppSyncServerPasswordTile()),
                ],
              )
            : const Column(
                key: ValueKey("small"),
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSyncServerUsernameTile(),
                  AppSyncServerPasswordTile(),
                ],
              ),
      );

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints.expand(width: dialogMaxWidth),
        child: AlertDialog(
          scrollable: true,
          title: const Text("Modfiy Sync Server"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSyncServerTypeMenu(width: -1),
              const AppSyncServerPathTile(),
              _buildUserTiles(context),
              _AppSyncServerEditorAdvConfigGroup(
                type: UiLayoutType.l,
                expanded: showAdvanceConfig,
                onExpansionChanged: onAdvConfigExpansionChanged,
              ),
              const _DebuggerTile(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: onCancelButtonPressed,
              child: Text("cancel"),
            ),
            AppSyncServerSaveButton(onPressed: onSaveButtonPressed),
          ],
        ),
      );
}

class _AppSyncServerEditorAdvConfigGroup extends StatelessWidget {
  final UiLayoutType type;
  final bool? expanded;
  final ValueChanged<bool>? onExpansionChanged;

  const _AppSyncServerEditorAdvConfigGroup({
    required this.type,
    this.expanded,
    this.onExpansionChanged,
  });

  List<Widget> _buildForSmallScreen() => [
        const AppSyncServerIgnoreSSLTile(),
        const AppSyncServerTimeoutTile(),
        const AppSyncServerConnTimeoutTile(),
        const AppSyncServerConnRetryCountTile(),
        const AppSyncServerNetworkTypeTile(),
      ];

  List<Widget> _buildForLargeScreen() => [
        const AppSyncServerIgnoreSSLTile(),
        const AppSyncServerTimeoutTile(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Expanded(child: AppSyncServerConnTimeoutTile()),
            const Expanded(child: AppSyncServerConnRetryCountTile()),
          ],
        ),
        const AppSyncServerNetworkTypeTile(),
      ];

  @override
  Widget build(BuildContext context) => ExpansionTile(
        title: const Text("Advance Configs"),
        leading: Icon(MdiIcons.dotsHorizontal),
        tilePadding: ExpansionTileTheme.of(context)
            .tilePadding
            ?.add(const EdgeInsets.symmetric(vertical: 4.0)),
        shape: const Border(),
        initiallyExpanded: expanded ?? false,
        onExpansionChanged: onExpansionChanged,
        children: switch (type) {
          UiLayoutType.l => _buildForLargeScreen(),
          _ => _buildForSmallScreen()
        },
      );
}

class _DebuggerTile extends StatefulWidget {
  const _DebuggerTile();

  @override
  State<_DebuggerTile> createState() => _DebuggerTileState();
}

class _DebuggerTileState extends State<_DebuggerTile> {
  late AppSyncServerFormViewModel formVM;
  late bool hided;

  void _changeListener() => setState(() {});

  @override
  void initState() {
    super.initState();
    hided = false;
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
    return Visibility(
      visible: !hided,
      child: Column(
        children: [
          const Divider(),
          ListTile(
            leading: IconButton(
                onPressed: () => setState(() => hided = true),
                icon: Icon(Icons.error,
                    color: Theme.of(context).colorScheme.error)),
            title: const Text("DEBUG"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mounted: ${vm.mounted}"),
                Text("Type: ${vm.type}"),
                Text("Path: ${vm.pathInputController.text}"),
                Text("Username: ${vm.usernameInputController.text}"),
                Text("Password: ${vm.passwordInputController.text}"),
                Text("IgnoreSSL: ${vm.ignoreSSL}"),
                Text("Timeout: ${vm.timeout?.inSeconds}"),
                Text("Conn Timeout: ${vm.connectTimeout?.inSeconds}"),
                Text("Conn RetryCount: ${vm.connectRetryCount}"),
                Text("Form: ${vm.formSnapshot.toDebugString()}"),
              ],
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}

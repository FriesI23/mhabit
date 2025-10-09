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

import '../../common/consts.dart';
import '../../l10n/localizations.dart';
import '../../models/app_sync_server.dart';
import '../../models/app_sync_server_form.dart';
import '../../providers/app_developer.dart';
import '../../providers/app_sync.dart';
import '../../providers/app_sync_server_form.dart';
import '../../widgets/widgets.dart';
import 'widgets.dart';

enum AppSyncServerEditorResultOp { update, delete }

class AppSyncServerEditorResult {
  final AppSyncServerEditorResultOp op;
  final AppSyncServerForm? form;

  const AppSyncServerEditorResult({required this.op, required this.form});

  const AppSyncServerEditorResult.update(this.form)
      : op = AppSyncServerEditorResultOp.update;

  const AppSyncServerEditorResult.delete()
      : op = AppSyncServerEditorResultOp.delete,
        form = null;

  @override
  String toString() => "AppSyncServerEditorResult(op=$op,form=$form)";
}

Future<AppSyncServerEditorResult?> naviToAppSyncServerEditorDialog({
  required BuildContext context,
  AppSyncServer? serverConfig,
  bool? naviWithFullscreenDialog,
}) async {
  return showDialog<AppSyncServerEditorResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AppSyncServerEditorPage(
      serverConfig: serverConfig,
      showInFullscreenDialog: naviWithFullscreenDialog,
    ),
  );
}

class AppSyncServerEditorPage extends StatelessWidget {
  final AppSyncServer? serverConfig;
  final bool? showInFullscreenDialog;

  const AppSyncServerEditorPage({
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
        builder: (context, layoutType, child) => _Page(
          serverConfig: serverConfig,
          showInFullscreenDialog: showInFullscreenDialog ??
              (layoutType == UiLayoutType.s ? true : false),
        ),
      ),
    );
  }
}

class _Page extends StatefulWidget {
  final AppSyncServer? serverConfig;
  final bool showInFullscreenDialog;

  const _Page({
    this.serverConfig,
    required this.showInFullscreenDialog,
  });

  @override
  State<StatefulWidget> createState() => _PageState();
}

class _PageState extends State<_Page> {
  late bool showAdvanceConfig;

  _PageState();

  @override
  void initState() {
    super.initState();
    showAdvanceConfig = false;
  }

  void _onSaveButtonPressed() async {
    final bool confirmed;
    final vm = context.read<AppSyncServerFormViewModel>();
    final form = vm.form.copy();
    assert(vm.canSave, "Can't save current config, got $form");
    if (vm.edited && vm.serverConfig != null) {
      confirmed = await showNormalizedConfirmDialog(
            context: context,
            title: L10nBuilder(
                builder: (context, l10n) => Text(
                    l10n?.appSync_serverEditor_saveDialog_titleText ??
                        "Confirm Save Changes")),
            subtitle: L10nBuilder(
                builder: (context, l10n) => Text(
                    l10n?.appSync_serverEditor_saveDialog_subtitleText ?? "")),
          ) ??
          false;
    } else {
      confirmed = true;
    }
    if (!mounted || !confirmed) return;
    Navigator.of(context)
        .pop<AppSyncServerEditorResult>(AppSyncServerEditorResult.update(form));
  }

  bool shouldShowCancelConfirmDialog(AppSyncServerFormViewModel vm) =>
      vm.edited;

  Future<void> cancelConfirmProcess([AppSyncServerEditorResult? result]) async {
    final bool confirmed;
    final vm = context.read<AppSyncServerFormViewModel>();
    if (shouldShowCancelConfirmDialog(vm)) {
      confirmed = await showNormalizedConfirmDialog(
            context: context,
            type: NormalizeConfirmDialogType.exit,
            title: L10nBuilder(
                builder: (context, l10n) => Text(
                    l10n?.appSync_serverEditor_exitDialog_titleText ??
                        "Unsaved Changes")),
            subtitle: L10nBuilder(
                builder: (context, l10n) => Text(
                    l10n?.appSync_serverEditor_exitDialog_subtitleText ?? "")),
          ) ??
          false;
    } else {
      confirmed = true;
    }
    if (!mounted || !confirmed) return;
    Navigator.maybeOf(context)?.pop<AppSyncServerEditorResult>(result);
  }

  void _onCancelButtonPressed() => cancelConfirmProcess();

  void _onDeleteButtonPressed() async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: L10nBuilder(
          builder: (context, l10n) => Text(
              l10n?.appSync_serverEditor_deleteDialog_titleText ??
                  "Confirm Delete")),
      subtitle: L10nBuilder(
          builder: (context, l10n) =>
              Text(l10n?.appSync_serverEditor_deleteDialog_subtitleText ?? "")),
      cancelText: L10nBuilder(
          builder: (context, l10n) =>
              Text(l10n?.confirmDialog_cancel_text ?? "Cancel")),
      confirmTextBuilder: (context) => L10nBuilder(
          builder: (context, l10n) => Text(
              l10n?.confirmDialog_confirm_text(
                      NormalizeConfirmDialogType.delete.name) ??
                  "Delete",
              style: TextStyle(color: Theme.of(context).colorScheme.error))),
    );
    if (!mounted || confirmed != true) return;
    Navigator.of(context).pop<AppSyncServerEditorResult>(
        const AppSyncServerEditorResult.delete());
  }

  void _onAdvanceConfigExpansionChanged(bool value) =>
      showAdvanceConfig = value;

  @override
  Widget build(BuildContext context) =>
      Selector<AppSyncServerFormViewModel, bool>(
        selector: (context, vm) => shouldShowCancelConfirmDialog(vm),
        builder: (context, value, child) => PopScope<AppSyncServerEditorResult>(
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
              ? _PageFullScreenDialog(
                  key: const ValueKey("fullscreen"),
                  serverConfig: widget.serverConfig,
                  onSaveButtonPressed: _onSaveButtonPressed,
                  onCancelButtonPressed: _onCancelButtonPressed,
                  onDeleteButtonPressed: _onDeleteButtonPressed,
                  showAdvanceConfig: showAdvanceConfig,
                  onAdvConfigExpansionChanged: _onAdvanceConfigExpansionChanged,
                )
              : _PageDialog(
                  key: const ValueKey("dialog"),
                  serverConfig: widget.serverConfig,
                  onSaveButtonPressed: _onSaveButtonPressed,
                  onCancelButtonPressed: _onCancelButtonPressed,
                  onDeleteButtonPressed: _onDeleteButtonPressed,
                  showAdvanceConfig: showAdvanceConfig,
                  onAdvConfigExpansionChanged: _onAdvanceConfigExpansionChanged,
                ),
        ),
      );
}

class _PageFullScreenDialog extends StatelessWidget {
  final AppSyncServer? serverConfig;
  final bool showAdvanceConfig;
  final VoidCallback? onSaveButtonPressed;
  final VoidCallback? onCancelButtonPressed;
  final VoidCallback? onDeleteButtonPressed;
  final ValueChanged<bool>? onAdvConfigExpansionChanged;

  const _PageFullScreenDialog({
    super.key,
    required this.serverConfig,
    required this.showAdvanceConfig,
    required this.onSaveButtonPressed,
    required this.onCancelButtonPressed,
    required this.onDeleteButtonPressed,
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
                const _PathTile(),
                const _UsernameTile(),
                const _PasswordTile(),
                _PageAdvancedSection(
                  type: UiLayoutType.s,
                  expanded: showAdvanceConfig,
                  onExpansionChanged: onAdvConfigExpansionChanged,
                ),
                AppSyncServerDeleteButton.fullscreen(
                    onPressed: onDeleteButtonPressed),
                if (context.read<AppDeveloperViewModel>().isInDevelopMode)
                  const _DebugTile(),
              ],
            ),
          ),
        ),
      );
}

class _PageDialog extends StatelessWidget {
  static const dialogMaxWidth = 1240.0;

  final AppSyncServer? serverConfig;
  final bool showAdvanceConfig;
  final VoidCallback? onSaveButtonPressed;
  final VoidCallback? onCancelButtonPressed;
  final VoidCallback? onDeleteButtonPressed;
  final ValueChanged<bool>? onAdvConfigExpansionChanged;

  const _PageDialog({
    super.key,
    required this.serverConfig,
    required this.showAdvanceConfig,
    required this.onSaveButtonPressed,
    required this.onCancelButtonPressed,
    required this.onDeleteButtonPressed,
    this.onAdvConfigExpansionChanged,
  });

  Widget _buildUserTiles(BuildContext context) => Builder(
        builder: (context) => MediaQuery.of(context).size.width >=
                kHabitLargeScreenAdaptWidth * 1.5
            ? const Row(
                key: ValueKey("large"),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(child: _UsernameTile()),
                  Expanded(child: _PasswordTile()),
                ],
              )
            : const Column(
                key: ValueKey("small"),
                mainAxisSize: MainAxisSize.min,
                children: [
                  _UsernameTile(),
                  _PasswordTile(),
                ],
              ),
      );

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints.expand(width: dialogMaxWidth),
        child: AlertDialog(
          scrollable: true,
          title: Selector<AppSyncViewModel, bool>(
            selector: (context, vm) => vm.serverConfig != null,
            builder: (context, value, child) {
              final l10n = L10n.of(context);
              return Text(l10n != null
                  ? (value
                      ? l10n.appSync_serverEditor_titleText_modify
                      : l10n.appSync_serverEditor_titleText_add)
                  : "Sync Server");
            },
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSyncServerTypeMenu(width: -1),
              const _PathTile(),
              _buildUserTiles(context),
              _PageAdvancedSection(
                type: UiLayoutType.l,
                expanded: showAdvanceConfig,
                onExpansionChanged: onAdvConfigExpansionChanged,
              ),
              if (context.read<AppDeveloperViewModel>().isInDevelopMode)
                const _DebugTile(),
            ],
          ),
          actions: [
            AppSyncServerDeleteButton.normal(onPressed: onDeleteButtonPressed),
            TextButton(
              onPressed: onCancelButtonPressed,
              child: L10nBuilder(
                  builder: (context, l10n) =>
                      Text(l10n?.confirmDialog_cancel_text ?? "cancel")),
            ),
            AppSyncServerSaveButton(onPressed: onSaveButtonPressed),
          ],
        ),
      );
}

class _PageAdvancedSection extends StatelessWidget {
  final UiLayoutType type;
  final bool? expanded;
  final ValueChanged<bool>? onExpansionChanged;

  const _PageAdvancedSection({
    required this.type,
    this.expanded,
    this.onExpansionChanged,
  });

  List<Widget> _buildForSmallScreen() => const [
        _IgnoreSSLTile(),
        _ServerTimeoutTile(),
        _ConnTimeoutTile(),
        _ConnRetryCountTile(),
        _NetworkTypeTile(),
      ];

  List<Widget> _buildForLargeScreen() => const [
        _IgnoreSSLTile(),
        _ServerTimeoutTile(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: _ConnTimeoutTile()),
            Expanded(child: _ConnRetryCountTile()),
          ],
        ),
        _NetworkTypeTile(),
      ];

  @override
  Widget build(BuildContext context) => ExpansionTile(
        title: L10nBuilder(
            builder: (context, l10n) => Text(
                l10n?.appSync_serverEditor_advance_titleText ?? "Advanced")),
        leading: const Icon(MdiIcons.dotsHorizontal),
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

class _DebugTile extends StatefulWidget {
  const _DebugTile();

  @override
  State<_DebugTile> createState() => _DebugTileState();
}

class _DebugTileState extends State<_DebugTile> {
  late bool hided;

  @override
  void initState() {
    super.initState();
    hided = false;
  }

  @override
  void dispose() {
    super.dispose();
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
                ...switch (vm.type) {
                  AppSyncServerType.webdav => [
                      Text("Path: ${vm.webdav?.path}"),
                      Text("Username: ${vm.webdav?.username}"),
                      Text("Password: ${vm.webdav?.password}"),
                      Text("IgnoreSSL: ${vm.webdav?.ignoreSSL}"),
                      Text("Timeout: ${vm.webdav?.timeout?.inSeconds}"),
                      Text(
                          "Conn Timeout: ${vm.webdav?.connectTimeout?.inSeconds}"),
                      Text("Conn RetryCount: ${vm.webdav?.connectRetryCount}"),
                    ],
                  _ => const [],
                },
                Text("Form: ${vm.form.toDebugString()}"),
              ],
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}

final class _IgnoreSSLTile extends StatelessWidget {
  const _IgnoreSSLTile();

  @override
  Widget build(BuildContext context) =>
      Selector<AppSyncServerFormViewModel, AppSyncServerType>(
        selector: (context, vm) => vm.type,
        builder: (context, value, child) => switch (value) {
          AppSyncServerType.unknown ||
          AppSyncServerType.fake =>
            const SizedBox.shrink(),
          AppSyncServerType.webdav => const AppWebDavSyncServerIgnoreSSLTile(),
        },
      );
}

final class _NetworkTypeTile extends StatelessWidget {
  const _NetworkTypeTile();

  @override
  Widget build(BuildContext context) =>
      Selector<AppSyncServerFormViewModel, AppSyncServerType>(
        selector: (context, vm) => vm.type,
        builder: (context, value, child) => switch (value) {
          AppSyncServerType.unknown ||
          AppSyncServerType.fake =>
            const SizedBox.shrink(),
          AppSyncServerType.webdav =>
            const AppWebDavSyncServerNetworkTypeTile(),
        },
      );
}

final class _ConnRetryCountTile extends StatelessWidget {
  const _ConnRetryCountTile();

  @override
  Widget build(BuildContext context) => AppSyncServerFormInputField(
        getValue: (_, vm) => switch (vm.type) {
          AppSyncServerType.unknown || AppSyncServerType.fake => "",
          AppSyncServerType.webdav =>
            vm.webdav?.connectRetryCount?.toString() ?? "",
        },
        builder: (context, value, controller, child) => switch (value) {
          AppSyncServerType.unknown ||
          AppSyncServerType.fake =>
            const SizedBox.shrink(),
          AppSyncServerType.webdav =>
            AppWebDavSyncServerConnRetryCountTile(controller: controller),
        },
      );
}

final class _ConnTimeoutTile extends StatelessWidget {
  const _ConnTimeoutTile();

  @override
  Widget build(BuildContext context) => AppSyncServerFormInputField(
        getValue: (_, vm) => switch (vm.type) {
          AppSyncServerType.unknown || AppSyncServerType.fake => "",
          AppSyncServerType.webdav =>
            vm.webdav?.connectTimeout?.inSeconds.toString() ?? "",
        },
        builder: (context, value, controller, child) => switch (value) {
          AppSyncServerType.unknown ||
          AppSyncServerType.fake =>
            const SizedBox.shrink(),
          AppSyncServerType.webdav =>
            AppWebDavSyncServerConnTimeoutTile(controller: controller),
        },
      );
}

final class _ServerTimeoutTile extends StatelessWidget {
  const _ServerTimeoutTile();

  @override
  Widget build(BuildContext context) => AppSyncServerFormInputField(
        getValue: (_, vm) => switch (vm.type) {
          AppSyncServerType.unknown || AppSyncServerType.fake => "",
          AppSyncServerType.webdav =>
            vm.webdav?.timeout?.inSeconds.toString() ?? "",
        },
        builder: (context, value, controller, child) => switch (value) {
          AppSyncServerType.unknown ||
          AppSyncServerType.fake =>
            const SizedBox.shrink(),
          AppSyncServerType.webdav =>
            AppWebDavSyncServerTimeoutTile(controller: controller),
        },
      );
}

final class _UsernameTile extends StatelessWidget {
  const _UsernameTile();

  @override
  Widget build(BuildContext context) => AppSyncServerFormInputField(
        getValue: (_, vm) => switch (vm.type) {
          AppSyncServerType.unknown || AppSyncServerType.fake => "",
          AppSyncServerType.webdav => vm.webdav?.username ?? "",
        },
        builder: (context, value, controller, child) => switch (value) {
          AppSyncServerType.unknown ||
          AppSyncServerType.fake =>
            const SizedBox.shrink(),
          AppSyncServerType.webdav =>
            AppWebDavSyncServerUsernameTile(controller: controller),
        },
      );
}

final class _PathTile extends StatelessWidget {
  const _PathTile();

  @override
  Widget build(BuildContext context) => AppSyncServerFormInputField(
        getValue: (_, vm) => switch (vm.type) {
          AppSyncServerType.unknown || AppSyncServerType.fake => "",
          AppSyncServerType.webdav => vm.webdav?.path ?? "",
        },
        builder: (context, value, controller, child) => switch (value) {
          AppSyncServerType.unknown ||
          AppSyncServerType.fake =>
            const SizedBox.shrink(),
          AppSyncServerType.webdav =>
            AppWebDavSyncServerPathTile(controller: controller),
        },
      );
}

final class _PasswordTile extends StatelessWidget {
  const _PasswordTile();

  @override
  Widget build(BuildContext context) => AppSyncServerFormInputField(
        getValue: (_, vm) => "",
        builder: (context, value, controller, child) => switch (value) {
          AppSyncServerType.unknown ||
          AppSyncServerType.fake =>
            const SizedBox.shrink(),
          AppSyncServerType.webdav =>
            AppWebDavSyncServerPasswordTile(controller: controller),
        },
      );
}

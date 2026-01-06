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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../logging/helper.dart';
import '../../providers/app_developer.dart';
import '../../providers/app_sync.dart';
import '../../utils/app_clock.dart';
import '../../utils/app_path_provider.dart';
import '../../widgets/widgets.dart';
import '../app_sync_server_editor/page.dart' as app_sync_server_editor;
import 'widgets.dart';

Future<void> naviToAppSyncPage({required BuildContext context}) async {
  return Navigator.of(
    context,
  ).push<void>(MaterialPageRoute(builder: (context) => const AppSyncPage()));
}

final class AppSyncPage extends StatelessWidget {
  const AppSyncPage({super.key});

  @override
  Widget build(BuildContext context) => const _Page();
}

final class _Page extends StatefulWidget {
  const _Page();

  @override
  State<StatefulWidget> createState() => _PageState();
}

final class _PageState extends State<_Page> {
  @override
  void initState() {
    appLog.build.debug(context, ex: ["init"]);
    super.initState();
  }

  @override
  void dispose() {
    appLog.build.debug(context, ex: ["dispose"], widget: widget);
    super.dispose();
  }

  void _onServerConfigPressed() async {
    final config = context.read<AppSyncViewModel>().serverConfig;
    appLog.build.debug(
      context,
      ex: ["onServerConfigPressed", config?.toDebugString()],
    );
    final result = await app_sync_server_editor.naviToAppSyncServerEditorDialog(
      context: context,
      serverConfig: config,
    );
    if (!mounted) return;
    appLog.build.debug(context, ex: ["onServerConfigPressed", "Done", result]);
    if (result == null) return;
    switch (result.op) {
      case app_sync_server_editor.AppSyncServerEditorResultOp.update:
        final saveResult = await context
            .read<AppSyncViewModel>()
            .saveWithConfigForm(result.form);
        if (!mounted) return;
        appLog.build.info(
          context,
          ex: ["onServerConfigPressed", "Saved[$saveResult]", result],
        );
      case app_sync_server_editor.AppSyncServerEditorResultOp.delete:
        final saveResult = await context
            .read<AppSyncViewModel>()
            .saveWithConfigForm(null, removable: true);
        if (!mounted) return;
        appLog.build.info(
          context,
          ex: ["onServerConfigPressed", "Deleted[$saveResult]", result],
        );
    }
  }

  void _onServerFetchIntervalPressed() async {
    final interval = context.read<AppSyncViewModel>().fetchInterval;
    appLog.build.debug(context, ex: ["onServerFetchIntervalPressed", interval]);
    final result = await showAppSyncFetchIntervalSwitchDialog(
      context: context,
      select: interval,
    );
    if (!mounted || result == null) return;
    context.read<AppSyncViewModel>().setFetchInterval(result);
    appLog.build.debug(
      context,
      ex: ["onServerFetchIntervalPressed", "Done", result],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: const PageBackButton(reason: PageBackReason.back),
            title: L10nBuilder(
              builder: (context, l10n) =>
                  Text(l10n?.appSetting_syncOption_titleText ?? "Sync"),
            ),
            pinned: true,
          ),
          SliverPinnedHeader(
            child: Selector<AppSyncViewModel, bool>(
              selector: (ctx, v) => v.enabled,
              shouldRebuild: (previous, next) => previous != next,
              builder: (context, value, child) => ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: SwitchListTile.adaptive(
                  title: L10nBuilder(
                    builder: (context, l10n) =>
                        Text(l10n?.common_enable_text ?? "Enable"),
                  ),
                  value: value,
                  onChanged: (value) =>
                      context.read<AppSyncViewModel>().setSyncSwitch(value),
                ),
              ),
            ),
          ),
          Selector<AppSyncViewModel, bool>(
            selector: (ctx, v) => v.enabled,
            shouldRebuild: (previous, next) => previous != next,
            builder: (context, value, child) => SliverToBoxAdapter(
              child: _AppSyncConfigSubgroup(
                enabled: value,
                onConfigPressed: _onServerConfigPressed,
                onFetchIntervalPressed: _onServerFetchIntervalPressed,
              ),
            ),
          ),
          SliverList.list(
            children: [
              const Divider(),
              FutureBuilder(
                future: AppPathProvider().getSyncFailLogDir(),
                builder: (context, snapshot) =>
                    AppSyncFailLogsTile(path: snapshot.data?.path),
              ),
            ],
          ),
          if (context.read<AppDeveloperViewModel>().isInDevelopMode)
            SliverList.list(children: [const Divider(), const _DebugTile()]),
        ],
      ),
    );
  }
}

class _AppSyncConfigSubgroup extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onConfigPressed;
  final VoidCallback? onFetchIntervalPressed;

  const _AppSyncConfigSubgroup({
    required this.enabled,
    this.onConfigPressed,
    this.onFetchIntervalPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandedSection(
      expand: enabled,
      child: Column(
        children: [
          const Divider(),
          AppSyncSummaryTile(onPressed: onConfigPressed),
          AppSyncFetchIntervalTile(onPressed: onFetchIntervalPressed),
        ],
      ),
    );
  }
}

class _DebugTile extends StatelessWidget {
  const _DebugTile();

  @override
  Widget build(BuildContext context) {
    final appSync = context.watch<AppSyncViewModel>();
    return ListTile(
      leading: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
      isThreeLine: true,
      title: const Text('DEBUG'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("LastRefresh: ${AppClock().now()}"),
          Text("Enabled: ${appSync.enabled}"),
          Text("FetchInterval: ${appSync.fetchInterval}"),
          Text("ServerConfig: ${appSync.serverConfig?.toDebugString()}"),
          FutureBuilder(
            future: appSync.readPassword(),
            builder: (context, snapshot) {
              final pwd = snapshot.data ?? '';
              final pwd2 = kDebugMode ? pwd : "*" * pwd.length;
              return Text("Password: $pwd2");
            },
          ),
        ],
      ),
    );
  }
}

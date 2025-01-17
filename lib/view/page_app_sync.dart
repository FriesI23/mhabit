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

import '../component/widgets/page_back_button.dart';
import '../logging/helper.dart';
import '../provider/app_developer.dart';
import '../provider/app_sync.dart';

Future<void> naviToAppSyncPage({required BuildContext context}) async {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (context) => const PageAppSync(),
    ),
  );
}

final class PageAppSync extends StatelessWidget {
  const PageAppSync({super.key});

  @override
  Widget build(BuildContext context) => const AppSyncView();
}

final class AppSyncView extends StatefulWidget {
  const AppSyncView({super.key});

  @override
  State<StatefulWidget> createState() => _AppSyncView();
}

final class _AppSyncView extends State<AppSyncView> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PageBackButton(reason: PageBackReason.back),
        title: const Text("Sync"),
      ),
      body: ListView(
        children: [
          Selector<AppSyncViewModel, bool>(
            selector: (ctx, v) => v.enabled,
            shouldRebuild: (previous, next) => previous != next,
            builder: (context, value, child) => SwitchListTile.adaptive(
              title: const Text("Enable"),
              value: value,
              onChanged: (value) =>
                  context.read<AppSyncViewModel>().setSyncSwitch(value),
            ),
          ),
          const Divider(),
          if (context.read<AppDeveloperViewModel>().isInDevelopMode) ...[
            const Divider(),
            const _DebugShowTile(),
          ],
        ],
      ),
    );
  }
}

class _DebugShowTile extends StatelessWidget {
  const _DebugShowTile();

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
          Text("Enabled: ${appSync.enabled}"),
          Text("ServerConfig: ${appSync.serverConfig?.toDebugString()}"),
        ],
      ),
    );
  }
}

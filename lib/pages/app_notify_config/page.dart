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

import '../../l10n/localizations.dart';
import '../../providers/app_notify_config.dart';
import '../../reminders/notification_channel.dart';
import '../../widgets/widgets.dart';

Future<void> naviToNotifyConfigPage({required BuildContext context}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (context) => const AppNotifyConfigPage()),
  );
}

class AppNotifyConfigPage extends StatelessWidget {
  const AppNotifyConfigPage({super.key});

  @override
  Widget build(BuildContext context) => const AppNotifyConfigView();
}

class AppNotifyConfigView extends StatefulWidget {
  const AppNotifyConfigView({super.key});

  @override
  State<StatefulWidget> createState() => _AppNotifyConfigView();
}

class _AppNotifyConfigView extends State<AppNotifyConfigView> {
  static const List<NotificationChannelId> _availableIds = [
    NotificationChannelId.appSyncing,
    NotificationChannelId.appSyncFailed,
  ];
  _AppNotifyConfigView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PageBackButton(reason: PageBackReason.back),
        title: L10nBuilder(
          builder: (context, l10n) =>
              Text(l10n?.appSetting_notify_titleTile ?? "Notifications"),
        ),
      ),
      body: ListView.builder(
        itemCount: _availableIds.length,
        itemBuilder: (context, index) {
          final channelId = _availableIds[index];
          return Selector<AppNotifyConfigViewModel, bool>(
            selector: (context, vm) =>
                vm.notifyConfig.isChannelEnabled(channelId),
            shouldRebuild: (previous, next) => previous != next,
            builder: (context, value, child) {
              final channelName = channelId.getL10nChannelName(
                L10n.of(context),
              );
              final channelDesc = channelId.getL10nChannelDesc(
                L10n.of(context),
              );
              return SwitchListTile.adaptive(
                title: Text(channelName),
                subtitle: channelDesc != null ? Text(channelDesc) : null,
                value: value,
                onChanged: (value) {
                  final config = context.read<AppNotifyConfigViewModel>();
                  if (!config.mounted) return;
                  config.updateNotifyConfig(
                    config.notifyConfig.copyWith({channelId: value}),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

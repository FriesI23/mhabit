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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../extensions/adaptive_style_extensions.dart';
import '../../l10n/localizations.dart';
import '../../providers/workflow/app_notify_config.dart';
import '../../reminders/notification_channel.dart';
import '../../widgets/widgets.dart';

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
      appBar: AdaptiveAppBar(
        toolbarHeight: AdaptiveStyle.of(context).appToolbarHeight,
        leading: const AdaptiveBackButton(type: AdaptiveBackButtonType.back),
        automaticallyImplyLeading: false,
        title: L10nBuilder(
          builder: (context, l10n) =>
              Text(l10n?.appSetting_notify_titleTile ?? "Notifications"),
        ),
      ),
      body: ListView.builder(
        itemCount: _availableIds.length,
        itemBuilder: (context, index) {
          final channelId = _availableIds[index];
          return Selector<AppNotifyConfigAccess, bool>(
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
                  final config = context.read<AppNotifyConfigAccess>();
                  if (!config.mounted) return;
                  config.updateConfig(
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

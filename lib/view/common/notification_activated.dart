// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../reminders/notification_service.dart';

Future<void> showNotificationActivatedDialog({
  required BuildContext context,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) => const NotificationActivatedDialog(),
  );
}

class NotificationActivatedDialog extends StatefulWidget {
  const NotificationActivatedDialog({super.key});

  @override
  State<StatefulWidget> createState() => _NotificationActivatedDialog();
}

class _NotificationActivatedDialog extends State<NotificationActivatedDialog> {
  Future? _loadFutre;
  List<ActiveNotification> actives = const [];

  @override
  void initState() {
    super.initState();
    _loadFutre = _loadData();
  }

  Future<void> _loadData() async {
    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt < 23) {
        debugPrint('"getActiveNotifications" is available '
            'only for Android 6.0 or newer');
        return;
      }
    }

    if (Platform.isIOS) {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      final List<String> fullVersion = iosInfo.systemVersion!.split('.');
      if (fullVersion.isNotEmpty) {
        final int? version = int.tryParse(fullVersion[0]);
        if (version != null && version < 10) {
          debugPrint('"getActiveNotifications" is available '
              'only for iOS 10.0 or newer');
          return;
        }
      }
    }

    try {
      actives = await NotificationService().plugin.getActiveNotifications();
    } on PlatformException catch (error) {
      debugPrint('Error calling "getActiveNotifications"\n'
          'code: ${error.code}\n'
          'message: ${error.message}');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadFutre,
      builder: (context, snapshot) {
        return AlertDialog(
          scrollable: true,
          title: Center(child: Text('${actives.length}')),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Active Notifications',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),
              if (actives.isEmpty) const Text('No active notifications'),
              if (actives.isNotEmpty)
                for (ActiveNotification activeNotification in actives)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'id: ${activeNotification.id}\n'
                        'channelId: ${activeNotification.channelId}\n'
                        'groupKey: ${activeNotification.groupKey}\n'
                        'tag: ${activeNotification.tag}\n'
                        'title: ${activeNotification.title}\n'
                        'body: ${activeNotification.body}',
                      ),
                      const Divider(),
                    ],
                  ),
            ],
          ),
          actions: const [CloseButton()],
          actionsAlignment: MainAxisAlignment.center,
        );
      },
    );
  }
}

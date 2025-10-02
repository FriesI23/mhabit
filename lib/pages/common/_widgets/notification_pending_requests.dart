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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../reminders/notification_service.dart';

Future<void> showNotificationPendingRequestsDialog({
  required BuildContext context,
}) async {
  return showDialog(
    context: context,
    builder: (context) => const NotificationPendingRequestsDialog(),
  );
}

class NotificationPendingRequestsDialog extends StatefulWidget {
  const NotificationPendingRequestsDialog({super.key});

  @override
  State<StatefulWidget> createState() => _NotificationPendingRequestsDialog();
}

class _NotificationPendingRequestsDialog
    extends State<NotificationPendingRequestsDialog> {
  Future? _loadFutre;
  List<PendingNotificationRequest> pendingRequests = const [];

  @override
  void initState() {
    super.initState();
    _loadFutre = _loadData();
  }

  Future<void> _loadData() async {
    pendingRequests = await NotificationService().pendingNotificationRequests();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadFutre,
      builder: (context, snapshot) {
        return AlertDialog(
          scrollable: true,
          title: Center(child: Text('${pendingRequests.length}')),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pending Requests Notifications',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Divider(),
              if (pendingRequests.isEmpty) const Text('No pending requests'),
              if (pendingRequests.isNotEmpty)
                ...List.generate(
                  math.max(pendingRequests.length * 2 - 1, 0),
                  (index) {
                    if (index.isOdd) {
                      return const Divider();
                    } else {
                      final notification = pendingRequests[index ~/ 2];
                      return ListTile(
                        isThreeLine: true,
                        title: Text(notification.title ?? ''),
                        subtitle: Text(
                          "id: ${notification.id}\n"
                          "body: ${notification.body ?? ''}\n"
                          "payload: ${notification.payload ?? ''}",
                        ),
                      );
                    }
                  },
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

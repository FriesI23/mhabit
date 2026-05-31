// Copyright 2026 Fries_I23
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

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/app_info.dart';
import 'package:mhabit/providers/app_ui/app_debugger.dart';
import 'package:mhabit/reminders/notification_channel.dart';
import 'package:mhabit/reminders/notification_data.dart';
import 'package:mhabit/reminders/notification_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

final class _FakeNotificationService implements NotificationService {
  int? lastId;
  String? lastTitle;
  String? lastBody;
  NotificationDataType? lastType;
  NotificationChannelId? lastChannelId;
  NotificationDetails? lastDetails;
  List<PendingNotificationRequest> pendingRequests = const [];

  @override
  Future<List<PendingNotificationRequest>>
  pendingNotificationRequests() async => pendingRequests;

  @override
  Future<bool> show({
    required int id,
    required String title,
    String? body,
    String? extra,
    required NotificationDataType type,
    required NotificationChannelId channelId,
    required NotificationDetails details,
    Duration? timeout,
  }) async {
    lastId = id;
    lastTitle = title;
    lastBody = body;
    lastType = type;
    lastChannelId = channelId;
    lastDetails = details;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    PackageInfo.setMockInitialValues(
      appName: 'mhabit',
      packageName: 'io.github.friesi23.mhabit',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await AppInfo().init();
  });

  group('AppDebuggerViewModel notification routing', () {
    test(
      'showDemoNotification routes through debug notification channel',
      () async {
        final service = _FakeNotificationService();
        final viewModel = AppDebuggerViewModel(notificationService: service)
          ..setNotificationChannelData(NotificationChannelData());

        await viewModel.showDemoNotification(
          at: DateTime.utc(2026, 5, 26, 12, 34, 56),
        );

        expect(service.lastId, isNotNull);
        expect(service.lastTitle, 'debug only');
        expect(service.lastBody, 'timestamp: 2026-05-26 12:34:56.000Z');
        expect(service.lastType, NotificationDataType.debug);
        expect(service.lastChannelId, NotificationChannelId.debug);
        expect(service.lastDetails, isNotNull);

        viewModel.dispose();
      },
    );

    test(
      'loadPendingNotificationRequests routes through notification service',
      () async {
        final service = _FakeNotificationService()
          ..pendingRequests = const [
            PendingNotificationRequest(1, 'title', 'body', 'payload'),
          ];
        final viewModel = AppDebuggerViewModel(notificationService: service);

        final result = await viewModel.loadPendingNotificationRequests();

        expect(result, hasLength(1));
        expect(result.single.id, 1);
        expect(result.single.title, 'title');

        viewModel.dispose();
      },
    );
  });
}

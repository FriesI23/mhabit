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

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

extension AndroidFlutterLocalNotificationsPluginExtension
    on AndroidFlutterLocalNotificationsPlugin {
  Future<void> createNotificationChannelByDetail(
      AndroidNotificationDetails details) {
    final channel = AndroidNotificationChannel(
      details.channelId,
      details.channelName,
      description: details.channelDescription,
      groupId: details.groupKey,
      importance: details.importance,
      playSound: details.playSound,
      sound: details.sound,
      enableLights: details.enableLights,
      vibrationPattern: details.vibrationPattern,
      showBadge: details.channelShowBadge,
      enableVibration: details.enableVibration,
      ledColor: details.ledColor,
      audioAttributesUsage: details.audioAttributesUsage,
    );
    return createNotificationChannel(channel);
  }
}

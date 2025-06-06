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
import 'dart:typed_data';
import 'dart:ui';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

part 'notification_details.g.dart';

@CopyWith(skipFields: true)
final class NotificationDetails implements fln.NotificationDetails {
  @override
  final AndroidNotificationDetails? android;
  @override
  final DarwinNotificationDetails? iOS;
  @override
  final DarwinNotificationDetails? macOS;
  @override
  final LinuxNotificationDetails? linux;
  @override
  final WindowsNotificationDetails? windows;

  const NotificationDetails({
    this.android,
    this.iOS,
    this.macOS,
    this.linux,
    this.windows,
  });
}

@CopyWith(skipFields: true)
final class AndroidNotificationDetails extends fln.AndroidNotificationDetails {
  const AndroidNotificationDetails(
    super.channelId,
    super.channelName, {
    super.channelDescription,
    super.icon,
    super.importance,
    super.channelBypassDnd,
    super.priority,
    super.styleInformation,
    super.playSound,
    super.sound,
    super.enableVibration,
    super.vibrationPattern,
    super.groupKey,
    super.setAsGroupSummary,
    super.groupAlertBehavior,
    super.autoCancel,
    super.ongoing,
    super.silent,
    super.color,
    super.largeIcon,
    super.onlyAlertOnce,
    super.showWhen,
    super.when,
    super.usesChronometer,
    super.chronometerCountDown,
    super.channelShowBadge,
    super.showProgress,
    super.maxProgress,
    super.progress,
    super.indeterminate,
    super.channelAction,
    super.enableLights,
    super.ledColor,
    super.ledOnMs,
    super.ledOffMs,
    super.ticker,
    super.visibility,
    super.timeoutAfter,
    super.category,
    super.fullScreenIntent,
    super.shortcutId,
    super.additionalFlags,
    super.subText,
    super.tag,
    super.actions,
    super.colorized,
    super.number,
    super.audioAttributesUsage,
  });
}

@CopyWith(skipFields: true)
final class DarwinNotificationDetails extends fln.DarwinNotificationDetails {
  const DarwinNotificationDetails({
    super.presentAlert,
    super.presentBadge,
    super.presentSound,
    super.presentBanner,
    super.presentList,
    super.sound,
    super.badgeNumber,
    super.attachments,
    super.subtitle,
    super.threadIdentifier,
    super.categoryIdentifier,
    super.interruptionLevel,
    super.criticalSoundVolume,
  });
}

@CopyWith(skipFields: true)
final class LinuxNotificationDetails extends fln.LinuxNotificationDetails {
  const LinuxNotificationDetails({
    super.icon,
    super.sound,
    super.category,
    super.urgency,
    super.timeout,
    super.resident = false,
    super.suppressSound = false,
    super.transient = false,
    super.location,
    super.defaultActionName,
    super.actions,
    super.actionKeyAsIconName = false,
  });
}

@CopyWith(skipFields: true)
final class WindowsNotificationDetails extends fln.WindowsNotificationDetails {
  const WindowsNotificationDetails({
    super.actions,
    super.inputs,
    super.images,
    super.rows,
    super.progressBars,
    super.bindings,
    super.header,
    super.audio,
    super.duration,
    super.scenario,
    super.timestamp,
    super.subtitle,
  });
}

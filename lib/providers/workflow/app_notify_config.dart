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

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../models/app_notify_config.dart';
import '../../reminders/notification_channel.dart';
import '../../reminders/notification_service.dart';
import '../../storage/profile/handlers/app_notify_config.dart';
import '../../storage/profile_provider.dart';
import '../support/commons.dart';

enum ReminderStatusReason { channelDisabled, permissionDenied }

@immutable
final class ReminderStatus {
  final ReminderStatusReason? reason;

  const ReminderStatus._({required this.reason});

  const ReminderStatus.ready() : this._(reason: null);

  const ReminderStatus.channelDisabled()
    : this._(reason: ReminderStatusReason.channelDisabled);

  const ReminderStatus.permissionDenied()
    : this._(reason: ReminderStatusReason.permissionDenied);

  bool get isReady => reason == null;

  bool get isChannelDisabled => reason == ReminderStatusReason.channelDisabled;

  bool get isPermissionDenied =>
      reason == ReminderStatusReason.permissionDenied;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderStatus && reason == other.reason;

  @override
  int get hashCode => reason.hashCode;
}

abstract interface class AppNotifyConfigAccess
    implements ChangeNotifier, ProviderMounted, ProfileHandlerLoadedMixin {
  AppNotifyConfig get notifyConfig;
  bool isChannelEnabled(NotificationChannelId channelId);
  ReminderStatus getReminderStatus(NotificationChannelId channelId);

  FutureOr<void> updateConfig(AppNotifyConfig newConfig, {bool listen = true});

  factory AppNotifyConfigAccess() {
    /// Android uses system notification channels to manage notifications.
    if (Platform.isAndroid) return AppNotifyConfigAndroidOwner();
    return AppNotifyConfigOwner();
  }
}

final class AppNotifyConfigOwner
    with ChangeNotifier, ProfileHandlerLoadedMixin
    implements AppNotifyConfigAccess {
  bool _mounted = true;
  AppNotifyConfigProfileHandler? _config;
  final NotificationService _notificationService;

  AppNotifyConfigOwner({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService() {
    addListener(() {
      _notificationService.onAppNotiConfigUpdate(notifyConfig);
    });
  }

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    _notificationService.onAppNotiConfigUpdate(null);
    super.dispose();
  }

  @override
  bool get mounted => _mounted;

  @override
  void updateProfile(ProfileViewModel newProfile) {
    _config = newProfile.getHandler<AppNotifyConfigProfileHandler>();
    _notificationService.onAppNotiConfigUpdate(notifyConfig);
    super.updateProfile(newProfile);
  }

  @override
  AppNotifyConfig get notifyConfig => _config?.get() ?? const AppNotifyConfig();

  @override
  bool isChannelEnabled(NotificationChannelId channelId) =>
      notifyConfig.isChannelEnabled(channelId);

  @override
  ReminderStatus getReminderStatus(NotificationChannelId channelId) =>
      isChannelEnabled(channelId)
      ? const ReminderStatus.ready()
      : const ReminderStatus.channelDisabled();

  @override
  Future<void> updateConfig(
    AppNotifyConfig newConfig, {
    bool listen = true,
  }) async {
    if (_config?.get() != newConfig) {
      await _config?.set(newConfig);
      if (listen) notifyListeners();
    }
  }
}

final class AppNotifyConfigAndroidOwner
    with ChangeNotifier, ProfileHandlerLoadedMixin
    implements AppNotifyConfigAccess {
  @override
  final AppNotifyConfig notifyConfig = const AppNotifyConfig();

  @override
  bool isChannelEnabled(NotificationChannelId channelId) =>
      notifyConfig.isChannelEnabled(channelId);

  @override
  ReminderStatus getReminderStatus(NotificationChannelId channelId) =>
      isChannelEnabled(channelId)
      ? const ReminderStatus.ready()
      : const ReminderStatus.channelDisabled();

  bool _mounted = true;

  AppNotifyConfigAndroidOwner();

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    super.dispose();
  }

  @override
  bool get mounted => _mounted;

  @override
  Future<void> updateConfig(AppNotifyConfig newConfig, {bool listen = true}) =>
      Future.value();
}

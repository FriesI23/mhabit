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

import '../models/app_notify_config.dart';
import '../reminders/notification_service.dart';
import '../storage/profile/handlers/app_notify_config.dart';
import '../storage/profile_provider.dart';
import 'commons.dart';

abstract interface class AppNotifyConfigViewModel
    implements ChangeNotifier, ProviderMounted, ProfileHandlerLoadedMixin {
  AppNotifyConfig get notifyConfig;
  FutureOr<void> updateNotifyConfig(
    AppNotifyConfig newConfig, {
    bool listen = true,
  });

  factory AppNotifyConfigViewModel() {
    /// Android uses system notification channels to manage notifications.
    if (Platform.isAndroid) return AppNotifyConfigViewModelAndroidImpl();
    return AppNotifyConfigViewModelImpl();
  }
}

final class AppNotifyConfigViewModelImpl
    with ChangeNotifier, ProfileHandlerLoadedMixin
    implements AppNotifyConfigViewModel {
  bool _mounted = true;
  AppNotifyConfigProfileHandler? _config;

  AppNotifyConfigViewModelImpl() {
    addListener(() {
      NotificationService().onAppNotiConfigUpdate(notifyConfig);
    });
  }

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    NotificationService().onAppNotiConfigUpdate(null);
    super.dispose();
  }

  @override
  bool get mounted => _mounted;

  @override
  void updateProfile(ProfileViewModel newProfile) {
    _config = newProfile.getHandler<AppNotifyConfigProfileHandler>();
    NotificationService().onAppNotiConfigUpdate(notifyConfig);
    super.updateProfile(newProfile);
  }

  @override
  AppNotifyConfig get notifyConfig => _config?.get() ?? const AppNotifyConfig();

  @override
  Future<void> updateNotifyConfig(
    AppNotifyConfig newConfig, {
    bool listen = true,
  }) async {
    if (_config?.get() != newConfig) {
      await _config?.set(newConfig);
      if (listen) notifyListeners();
    }
  }
}

final class AppNotifyConfigViewModelAndroidImpl
    with ChangeNotifier, ProfileHandlerLoadedMixin
    implements AppNotifyConfigViewModel {
  @override
  final AppNotifyConfig notifyConfig = const AppNotifyConfig();

  bool _mounted = true;

  AppNotifyConfigViewModelAndroidImpl();

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    super.dispose();
  }

  @override
  bool get mounted => _mounted;

  @override
  Future<void> updateNotifyConfig(
    AppNotifyConfig newConfig, {
    bool listen = true,
  }) => Future.value();
}

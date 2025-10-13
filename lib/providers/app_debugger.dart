// Copyright 2024 Fries_I23
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

import 'package:flutter/foundation.dart';

import '../common/app_info.dart';
import '../common/global.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../logging/level.dart';
import '../logging/logger_manager.dart';
import '../reminders/notification_channel.dart';
import '../reminders/notification_data.dart';
import '../reminders/notification_id_range.dart';
import '../reminders/notification_service.dart';
import '../storage/profile/handlers.dart';
import '../storage/profile_provider.dart';
import 'commons.dart';

class AppDebuggerViewModel
    with
        ChangeNotifier,
        ProfileHandlerLoadedMixin,
        NotificationChannelDataMixin {
  CollectLogswitcherProfileHandler? _collectLogsSwitcher;
  LoggingLevelProfileHandler? _loggingLevel;

  AppDebuggerViewModel();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _collectLogsSwitcher =
        newProfile.getHandler<CollectLogswitcherProfileHandler>();
    _loggingLevel = newProfile.getHandler<LoggingLevelProfileHandler>();
    isCollectLogs
        ? kAppLogLevel = _loggingLevel?.get() ?? kAppLogLevel
        : _loggingLevel?.remove();
    _updateLoggerProcesser();
  }

  bool get isCollectLogs => _collectLogsSwitcher?.get() ?? false;

  Future<void> setCollectLogsSatus(bool newStatus) async {
    if (newStatus != isCollectLogs) {
      Future<String>? appDebugInfo;
      if (newStatus) appDebugInfo = AppInfo().generateAppDebugInfo();
      await _collectLogsSwitcher?.set(newStatus);
      _updateLoggerProcesser();
      await _syncLoggingLevelToProfile(newStatus ? kAppLogLevel : null);
      await appDebugInfo?.then((value) => appLog.debugger.info(value));
      notifyListeners();
    }
  }

  LogLevel get loggingLevel => kAppLogLevel;

  Future<void> updateLoggingLevel(LogLevel newLevel) async {
    if (kAppLogLevel != newLevel) {
      kAppLogLevel = newLevel;
      await _syncLoggingLevelToProfile(newLevel);
      notifyListeners();
    }
  }

  Future<bool>? _syncLoggingLevelToProfile(LogLevel? newLevel) =>
      newLevel != null ? _loggingLevel?.set(newLevel) : _loggingLevel?.remove();

  void _updateLoggerProcesser() => appLog.changeLoggerByType(isCollectLogs
      ? AppLoggerHandlerType.debugging
      : AppLoggerHandlerType.normal);

  void processDebuggingNotification([L10n? l10n]) {
    if (isCollectLogs) {
      NotificationService().show(
          id: appDebuggerNotifyId,
          title: l10n?.debug_debuggerInfo_notificationTitle ??
              "Collecting App's Info...",
          // body: "Tap to view details.",
          type: NotificationDataType.appDebugger,
          channelId: NotificationChannelId.appDebugger,
          details: channelData.appDebugger);
    } else {
      NotificationService().cancel(id: appDebuggerNotifyId);
    }
  }
}

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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart' as l;

import '../common/app_info.dart';
import '../common/global.dart';
import '../logging/helper.dart';
import '../logging/level.dart';
import '../logging/logger_manager.dart';
import '../persistent/profile/handlers.dart';
import '../persistent/profile_provider.dart';
import '../utils/debug_info.dart';

class AppDebuggerViewModel with ChangeNotifier, ProfileHandlerLoadedMixin {
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
      await Future.wait([
        _syncLoggingLevelToProfile(newStatus ? kAppLogLevel : null),
        _updateLoggerProcesser(),
      ].whereNotNull());
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

  Future<void> _updateLoggerProcesser() async {
    final l.Logger newLogger;
    if (isCollectLogs) {
      final filePath = await debugLogFilePath;
      newLogger = AppLoggerMananger.getCollectionLogger(filePath: filePath);
    } else {
      newLogger = AppLoggerMananger.getDefaultLogger();
    }
    await appLog.changeLogger(newLogger);
  }
}

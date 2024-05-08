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
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'async.dart';

class AppInfo implements AsyncInitialization {
  static final AppInfo _singleton = AppInfo._internal();

  AndroidBuildVersion? _androidBuildVersion;
  late String _packageName;
  late String _appName;
  late String _appVersion;

  factory AppInfo() {
    return _singleton;
  }

  AppInfo._internal();

  String get packageName => _packageName;

  String get appName => _appName;

  String get appVersion => _appVersion;

  @override
  Future<void> init() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      _androidBuildVersion = androidInfo.version;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    _packageName = packageInfo.packageName;
    _appName = packageInfo.appName;
    _appVersion = "${packageInfo.version}: ${packageInfo.buildNumber}";

    if (isAndroidAndAdaptToFullScreen()) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  bool isAndroidAndAdaptToFullScreen() {
    return Platform.isAndroid && _androidBuildVersion!.sdkInt >= 29;
  }

  Future<String> generateAppDebugInfo() => _AppDebugInfoBuilder().build();
}

final class _AppDebugInfoBuilder {
  late final DeviceInfoPlugin devicePlugin;

  _AppDebugInfoBuilder({DeviceInfoPlugin? devicePlugin}) {
    this.devicePlugin = devicePlugin ?? DeviceInfoPlugin();
  }

  void _buildInfoByMap(StringBuffer buffer, Map<String, dynamic> data,
      {int intent = 0}) {
    void appendToBuffer(StringBuffer buffer, String key, dynamic value) {
      for (var i = 0; i < intent; i++) {
        buffer.write(" ");
      }
      buffer.writeln('$key: $value');
    }

    for (var entry in data.entries) {
      appendToBuffer(buffer, entry.key, entry.value);
    }
  }

  Future<void> _buildDeviceInfo(StringBuffer buffer, {int intent = 0}) =>
      devicePlugin.deviceInfo
          .then((value) => _buildInfoByMap(buffer, value.data, intent: intent));

  Future<void> _buildPackageInfo(StringBuffer buffer, {int intent = 0}) =>
      PackageInfo.fromPlatform().then((value) {
        _buildInfoByMap(buffer, value.data, intent: intent);
      });

  Future<String> build() async {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln();
    buffer.writeln("┌──────────────── Debug Info: Started ────────────────");
    buffer.writeln("│");
    buffer.writeln("├─ Device Info: ──────────────────────────────────────");
    await _buildDeviceInfo(buffer, intent: 4);
    buffer.writeln("├─ Device Info Ended ─────────────────────────────────");
    buffer.writeln("│");
    buffer.writeln("├─ Package Info: ─────────────────────────────────────");
    await _buildPackageInfo(buffer, intent: 4);
    buffer.writeln("    BuildMode: debug=$kDebugMode, profile=$kProfileMode, "
        "release=$kReleaseMode | isWeb=$kIsWeb");
    buffer.writeln("    TargetPlatform: $defaultTargetPlatform");
    buffer.writeln("├─ Package Info Ended ────────────────────────────────");
    buffer.writeln("│");
    buffer.writeln("└────────────────── Debug Info: Ended ────────────────");
    return buffer.toString();
  }
}

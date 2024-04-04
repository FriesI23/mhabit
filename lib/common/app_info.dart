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
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'async.dart';

class AppInfo implements AsyncInitialization {
  static final AppInfo _singleton = AppInfo._internal();

  AndroidDeviceInfo? _androidDeviceInfo;
  IosDeviceInfo? _iosDeviceInfo;
  late String _packageName;
  late String _appName;
  late String _appVersion;

  factory AppInfo() {
    return _singleton;
  }

  AppInfo._internal();

  AndroidDeviceInfo? get androidDeviceInfo => _androidDeviceInfo;

  IosDeviceInfo? get iosDeviceInfo => _iosDeviceInfo;

  String get packageName => _packageName;

  String get appName => _appName;

  String get appVersion => _appVersion;

  @override
  Future<void> init() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      _androidDeviceInfo = await deviceInfo.androidInfo;
      _iosDeviceInfo = null;
    } else if (Platform.isIOS) {
      _iosDeviceInfo = await deviceInfo.iosInfo;
      _androidDeviceInfo = null;
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
    return Platform.isAndroid &&
        androidDeviceInfo != null &&
        androidDeviceInfo!.version.sdkInt >= 29;
  }
}

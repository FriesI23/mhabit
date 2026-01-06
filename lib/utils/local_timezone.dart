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
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:win2iana_tz_converter/win2iana_tz_converter.dart';

import '../common/async.dart';
import '../logging/helper.dart';
import 'app_clock.dart';

abstract interface class LocalTimeZone {
  TargetPlatform get platform;
  Future<String> getTimeZone();
}

final class LocalTimeZoneManager implements LocalTimeZone, AsyncInitialization {
  static LocalTimeZoneManager? _instance;

  final Map<TargetPlatform, LocalTimeZone> _handlers = {};

  factory LocalTimeZoneManager() => _instance ??= LocalTimeZoneManager._();

  LocalTimeZoneManager._();

  @override
  Future init() async {
    initializeTimeZones();
    clearHandlers();
    regHandlers(const [
      WindowsLocaTimeZone(),
      AndroidLocalTimeZone(),
      IOSLocalTimeZone(),
      MacOSLocalTimeZone(),
      LinuxLocalTimeZone(),
    ]);
    await updateTimeZone();
  }

  @override
  TargetPlatform get platform => defaultTargetPlatform;

  void regHandlers(Iterable<LocalTimeZone> handlers) {
    for (var handler in handlers) {
      _handlers[handler.platform] = handler;
    }
  }

  void clearHandlers() => _handlers.clear();

  @override
  Future<String> getTimeZone() =>
      _handlers[platform]?.getTimeZone() ?? Future.value("");

  Future<void> updateTimeZone() async {
    final String timeZoneName = await getTimeZone();
    appLog.value.debug(
      "updateTimeZone",
      beforeVal: tz.local.name,
      afterVal: timeZoneName,
    );
    tz.setLocalLocation(
      timeZoneName.isNotEmpty ? tz.getLocation(timeZoneName) : tz.UTC,
    );
  }
}

abstract class CurrentTimeZoneBasic implements LocalTimeZone {
  const CurrentTimeZoneBasic();

  @override
  Future<String> getTimeZone() async =>
      FlutterTimezone.getLocalTimezone().then((result) => result.identifier);
}

final class WindowsLocaTimeZone implements LocalTimeZone {
  const WindowsLocaTimeZone();

  @override
  TargetPlatform get platform => TargetPlatform.windows;

  @override
  Future<String> getTimeZone() async =>
      TZConverter()
          .windowsToIana(AppClock().now().timeZoneName)
          .firstOrNull
          ?.iana ??
      '';
}

final class IOSLocalTimeZone extends CurrentTimeZoneBasic {
  const IOSLocalTimeZone();

  @override
  TargetPlatform get platform => TargetPlatform.iOS;
}

final class AndroidLocalTimeZone extends CurrentTimeZoneBasic {
  const AndroidLocalTimeZone();

  @override
  TargetPlatform get platform => TargetPlatform.android;
}

final class MacOSLocalTimeZone extends CurrentTimeZoneBasic {
  const MacOSLocalTimeZone();

  @override
  TargetPlatform get platform => TargetPlatform.macOS;
}

final class LinuxLocalTimeZone extends CurrentTimeZoneBasic {
  const LinuxLocalTimeZone();

  @override
  TargetPlatform get platform => TargetPlatform.linux;
}

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

import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart'
    show WidgetsBinding, WidgetsFlutterBinding, runApp;
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:native_natural_sort/native_natural_sort.dart';
import 'package:provider/provider.dart';

import 'common/app_info.dart';
import 'common/consts.dart';
import 'entries/app/entry.dart';
import 'entries/habit_widget_entry.dart';
import 'logging/logger_manager.dart';
import 'reminders/notification_service.dart';
import 'theme/linux_bundled_font.dart';
import 'utils/local_timezone.dart';
import 'widgets/bingding.dart';

/// Invoked by the native widget action engine without mounting the app UI.
@pragma('vm:entry-point')
Future<void> habitWidgetBackgroundMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runHabitWidgetBackground();
}

Future<void> main() async {
  if (Platform.isIOS) {
    FixedIos26FlutterBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  await loadLinuxBundledFont();
  await AppLoggerMananger(t: AppLoggerHandlerType.debugging).init();
  await AppInfo().init();
  await NotificationService().init();
  await LocalTimeZoneManager().init();

  await NativeSort().config(
    SortOptions(
      windows: SortOptionsWindows.ffi(onLoadFailed: WindowsSort.pigeon),
    ),
  );

  if (Platform.isMacOS) {
    await _runMacOSApp();
  } else if (Platform.isWindows || Platform.isLinux) {
    await _runAppWithNativeTitleBar();
  } else {
    runApp(const AppEntry());
  }
}

Future<void> _runMacOSApp() async {
  final chrome = DesktopWindowChrome(minimumSize: appDesktopWindowMinimumSize);
  await chrome.initialize();
  runApp(
    ChangeNotifierProvider(create: (_) => chrome, child: const AppEntry()),
  );
  await WidgetsBinding.instance.endOfFrame;
  await chrome.show();
}

Future<void> _runAppWithNativeTitleBar() async {
  final titleBar = DesktopWindowTitleBar();
  await titleBar.initialize(minimumSize: appDesktopWindowMinimumSize);
  runApp(
    Provider<DesktopWindowTitleBar>(
      create: (_) => titleBar,
      dispose: (_, owner) => unawaited(owner.dispose()),
      child: const AppEntry(),
    ),
  );
}

// Copyright 2026 Fries_I23
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/app_info.dart';
import 'package:mhabit/models/app_notify_config.dart';
import 'package:mhabit/pages/app_about/page.dart';
import 'package:mhabit/pages/app_notify_config/page.dart';
import 'package:mhabit/pages/expermental_features/page.dart';
import 'package:mhabit/providers/app_ui/app_experimental_feature.dart';
import 'package:mhabit/providers/workflow/app_notify_config.dart';
import 'package:mhabit/reminders/notification_channel.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

final class _FakeAppNotifyConfigAccess extends ChangeNotifier
    with ProfileHandlerLoadedMixin
    implements AppNotifyConfigAccess {
  AppNotifyConfig _notifyConfig = const AppNotifyConfig();
  bool _mounted = true;

  @override
  bool get mounted => _mounted;

  @override
  AppNotifyConfig get notifyConfig => _notifyConfig;

  @override
  bool isChannelEnabled(NotificationChannelId channelId) =>
      notifyConfig.isChannelEnabled(channelId);

  @override
  ReminderStatus getReminderStatus(NotificationChannelId channelId) =>
      isChannelEnabled(channelId)
      ? const ReminderStatus.ready()
      : const ReminderStatus.channelDisabled();

  @override
  void updateConfig(AppNotifyConfig newConfig, {bool listen = true}) {
    _notifyConfig = newConfig;
    if (listen) notifyListeners();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}

final class _FakeExperimentalFeatureViewModel
    extends AppExperimentalFeatureViewModel {
  bool _habitGrouping = false;

  @override
  bool get habitGrouping => _habitGrouping;

  @override
  Future<void> setHabitGrouping(bool value, {bool listen = true}) async {
    _habitGrouping = value;
    if (listen) notifyListeners();
  }
}

Widget _withPageProviders(Widget child) {
  if (child is AppNotifyConfigPage) {
    return ChangeNotifierProvider<AppNotifyConfigAccess>(
      create: (_) => _FakeAppNotifyConfigAccess(),
      child: child,
    );
  }
  if (child is ExpermentalFeaturesPage) {
    return ChangeNotifierProvider<AppExperimentalFeatureViewModel>(
      create: (_) => _FakeExperimentalFeatureViewModel(),
      child: child,
    );
  }
  return child;
}

Widget _host(Widget page, {TargetPlatform platform = TargetPlatform.android}) =>
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _withPageProviders(page),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

void main() {
  setUpAll(() async {
    PackageInfo.setMockInitialValues(
      appName: 'Table Habit',
      packageName: 'io.github.friesi23.mhabit',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await AppInfo().init();
  });

  final pages = <({Widget page, String title})>[
    (page: const AppAboutPage(), title: 'About'),
    (page: const AppNotifyConfigPage(), title: 'Notifications'),
    (page: const ExpermentalFeaturesPage(), title: 'Experimental Features'),
  ];

  for (final testCase in pages) {
    testWidgets('${testCase.title} uses the Material adaptive app bar', (
      tester,
    ) async {
      await tester.pumpWidget(_host(testCase.page));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveAppBar), findsOneWidget);
      expect(find.byType(WindowControlAppBar), findsOneWidget);
      expect(find.text(testCase.title), findsOneWidget);
      expect(
        tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
        AdaptiveBackButtonType.back,
      );
      expect(
        tester
            .widget<AdaptiveAppBar>(find.byType(AdaptiveAppBar))
            .automaticallyImplyLeading,
        isFalse,
      );

      await tester.tap(find.byType(AdaptiveBackButton));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('${testCase.title} uses the Apple adaptive app bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(testCase.page, platform: TargetPlatform.iOS),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AdaptiveAppBar), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
      expect(find.text(testCase.title), findsOneWidget);
    });
  }

  testWidgets('Notify keeps channel updates owned by its provider', (
    tester,
  ) async {
    final access = _FakeAppNotifyConfigAccess();
    addTearDown(access.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppNotifyConfigAccess>.value(
        value: access,
        child: const MaterialApp(home: AppNotifyConfigPage()),
      ),
    );

    expect(access.isChannelEnabled(NotificationChannelId.appSyncing), isTrue);
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pump();

    expect(access.isChannelEnabled(NotificationChannelId.appSyncing), isFalse);
  });

  testWidgets('Experimental keeps feature state and warning behavior', (
    tester,
  ) async {
    final viewModel = _FakeExperimentalFeatureViewModel();
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppExperimentalFeatureViewModel>.value(
        value: viewModel,
        child: const MaterialApp(home: ExpermentalFeaturesPage()),
      ),
    );

    expect(find.byType(MaterialBanner), findsNothing);
    await tester.tap(find.widgetWithText(SwitchListTile, 'Habit Grouping'));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialBanner), findsOneWidget);
  });
}

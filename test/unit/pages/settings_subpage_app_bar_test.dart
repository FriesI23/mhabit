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

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/assets/assets.dart';
import 'package:mhabit/common/app_info.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_notify_config.dart';
import 'package:mhabit/pages/app_about/page.dart';
import 'package:mhabit/pages/app_about/widgets.dart';
import 'package:mhabit/pages/app_notify_config/page.dart';
import 'package:mhabit/pages/expermental_features/page.dart';
import 'package:mhabit/providers/app_ui/app_experimental_feature.dart';
import 'package:mhabit/providers/workflow/app_notify_config.dart';
import 'package:mhabit/reminders/notification_channel.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

final class _FakeAppNotifyConfigAccess extends ChangeNotifier
    with ProfileHandlerLoadedMixin
    implements AppNotifyConfigAccess {
  AppNotifyConfig _notifyConfig = const AppNotifyConfig();
  bool _mounted = true;
  int updateCount = 0;

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
    updateCount++;
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
  bool _naturalSort = false;
  int groupingWrites = 0;
  int naturalSortWrites = 0;
  Completer<void>? pendingWrite;

  @override
  bool get habitGrouping => _habitGrouping;

  @override
  Future<void> setHabitGrouping(bool value, {bool listen = true}) async {
    groupingWrites++;
    await pendingWrite?.future;
    _habitGrouping = value;
    if (listen) notifyListeners();
  }

  @override
  bool get naturalSort => _naturalSort;

  @override
  Future<void> setNaturalSort(bool value, {bool listen = true}) async {
    naturalSortWrites++;
    await pendingWrite?.future;
    _naturalSort = value;
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

      expect(find.byType(AdaptiveSliverAppBar), findsOneWidget);
      expect(find.byType(AdaptiveAppBar), findsNothing);
      expect(find.byType(WindowControlSliverAppBar), findsOneWidget);
      expect(find.byType(WindowControlAppBar), findsNothing);
      expect(find.text(testCase.title), findsOneWidget);
      expect(
        tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
        AdaptiveBackButtonType.back,
      );
      final safeArea = tester.widget<SliverSafeArea>(
        find.byType(SliverSafeArea),
      );
      expect(safeArea.left, isTrue);
      expect(safeArea.top, isFalse);
      expect(safeArea.right, isTrue);
      expect(safeArea.bottom, isTrue);

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

      expect(find.byType(AdaptiveSliverAppBar), findsOneWidget);
      expect(find.byType(AdaptiveAppBar), findsNothing);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      final navigationBar = tester.widget<CupertinoNavigationBar>(
        find.byType(CupertinoNavigationBar),
      );
      expect(navigationBar.automaticBackgroundVisibility, isTrue);
      expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
      expect(find.text(testCase.title), findsOneWidget);
    });
  }

  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final direction in TextDirection.values) {
      testWidgets('Notify grouped channels $platform $direction', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final access = _FakeAppNotifyConfigAccess();
        addTearDown(access.dispose);
        await tester.pumpWidget(
          ChangeNotifierProvider<AppNotifyConfigAccess>.value(
            value: access,
            child: MaterialApp(
              theme: ThemeData(platform: platform),
              localizationsDelegates: L10n.localizationsDelegates,
              supportedLocales: L10n.supportedLocales,
              locale: const Locale('de'),
              builder: (context, child) => Directionality(
                textDirection: direction,
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                ),
              ),
              home: const AppNotifyConfigPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AdaptiveListSection), findsOneWidget);
        final rows = find.byType(AdaptiveSwitchListTile);
        expect(rows, findsNWidgets(2));
        final switchType = platform == TargetPlatform.android
            ? Switch
            : CupertinoSwitch;
        expect(find.byType(switchType), findsNWidgets(2));
        expect(tester.takeException(), isNull);

        // The label and switch are the same action, each writing once.
        final firstRow = tester.widget<AdaptiveSwitchListTile>(rows.first);
        await tester.tap(find.byWidget(firstRow.title));
        await tester.pumpAndSettle();
        expect(access.updateCount, 1);
        expect(
          access.isChannelEnabled(NotificationChannelId.appSyncing),
          isFalse,
        );
        expect(
          access.isChannelEnabled(NotificationChannelId.appSyncFailed),
          isTrue,
        );
        expect(
          tester.widget<AdaptiveSwitchListTile>(rows.first).value,
          isFalse,
        );

        final firstSwitch = find.descendant(
          of: rows.first,
          matching: find.byType(switchType),
        );
        await tester.tap(firstSwitch);
        await tester.pumpAndSettle();
        expect(access.updateCount, 2);
        expect(
          access.isChannelEnabled(NotificationChannelId.appSyncing),
          isTrue,
        );

        final secondSwitch = find.descendant(
          of: rows.last,
          matching: find.byType(switchType),
        );
        await tester.ensureVisible(secondSwitch);
        await tester.tap(secondSwitch);
        await tester.pumpAndSettle();
        expect(access.updateCount, 3);
        expect(
          access.isChannelEnabled(NotificationChannelId.appSyncing),
          isTrue,
        );
        expect(
          access.isChannelEnabled(NotificationChannelId.appSyncFailed),
          isFalse,
        );

        // A provider update must also reach the rendered control.
        access.updateConfig(
          access.notifyConfig.copyWith({
            NotificationChannelId.appSyncFailed: true,
          }),
        );
        await tester.pumpAndSettle();
        expect(tester.widget<AdaptiveSwitchListTile>(rows.last).value, isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  }

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
    await tester.tap(
      find.widgetWithText(AdaptiveSwitchListTile, 'Habit Grouping'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialBanner), findsOneWidget);
    expect(find.byType(EdgeToEdgeMaterialBanner), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(MaterialBanner),
        matching: find.byType(SliverSafeArea),
      ),
      findsNothing,
    );
    final banner = tester.widget<MaterialBanner>(find.byType(MaterialBanner));
    final leadingSafeArea = banner.leading! as EnhancedSafeArea;
    final contentSafeArea = banner.content as EnhancedSafeArea;
    final actionsSafeArea = banner.actions.single as EnhancedSafeArea;
    expect(leadingSafeArea.left, isTrue);
    expect(leadingSafeArea.right, isFalse);
    expect(contentSafeArea.left, isFalse);
    expect(contentSafeArea.right, isTrue);
    expect(actionsSafeArea.left, isTrue);
    expect(actionsSafeArea.right, isTrue);
  });
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final direction in TextDirection.values) {
      testWidgets('Experimental grouped actions $platform $direction', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final vm = _FakeExperimentalFeatureViewModel();
        addTearDown(vm.dispose);
        await tester.pumpWidget(
          ChangeNotifierProvider<AppExperimentalFeatureViewModel>.value(
            value: vm,
            child: MaterialApp(
              theme: ThemeData(platform: platform),
              builder: (context, child) => Directionality(
                textDirection: direction,
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                ),
              ),
              home: const ExpermentalFeaturesPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AdaptiveListSection), findsOneWidget);
        final rows = find.byType(AdaptiveSwitchListTile);
        expect(rows, findsNWidgets(3));
        final switchType = platform == TargetPlatform.android
            ? Switch
            : CupertinoSwitch;
        expect(find.byType(switchType), findsNWidgets(3));
        expect(
          tester.widget<AdaptiveSwitchListTile>(rows.first).onChanged,
          isNull,
        );
        await tester.tap(find.text('Habit Search'));
        await tester.pumpAndSettle();
        expect(vm.groupingWrites + vm.naturalSortWrites, 0);
        expect(find.byType(MaterialBanner), findsNothing);
        await tester.tap(find.text('Habit Grouping'));
        await tester.pumpAndSettle();
        expect(vm.groupingWrites, 1);
        expect(vm.habitGrouping, isTrue);
        expect(vm.naturalSort, isFalse);
        expect(find.byType(MaterialBanner), findsOneWidget);
        await tester.ensureVisible(find.text('DISMISS'));
        await tester.tap(find.text('DISMISS'));
        await tester.pumpAndSettle();
        expect(find.byType(MaterialBanner), findsNothing);
        final naturalSwitch = find.descendant(
          of: rows.last,
          matching: find.byType(switchType),
        );
        await tester.ensureVisible(naturalSwitch);
        await tester.tap(naturalSwitch);
        await tester.pumpAndSettle();
        expect(vm.naturalSortWrites, 1);
        expect(vm.naturalSort, isTrue);
        expect(vm.groupingWrites, 1);
        expect(find.byType(MaterialBanner), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('About grouped layout $platform $direction', (tester) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            locale: const Locale('de'),
            builder: (context, child) => Directionality(
              textDirection: direction,
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
            ),
            home: const AppAboutPage(),
          ),
        );
        await tester.pumpAndSettle();
        for (final type in [
          AppAboutVersionTile,
          AppAboutSourceCodeTile,
          AppAboutIssueTrackerTile,
          AppAboutContactEmailTile,
          AppAboutLicenseTile,
          AppAboutThirdPartyLicenseTile,
          AppAboutPrivacyTile,
          if (!AppInfo().shouldHideDonate()) AppAboutDonateTile,
        ]) {
          await tester.scrollUntilVisible(find.byType(type), 150);
          await tester.pumpAndSettle();
          expect(
            find.ancestor(
              of: find.byType(type),
              matching: find.byType(AdaptiveListSection),
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        }
      });
    }
    testWidgets('About retains changelog and license actions $platform', (
      tester,
    ) async {
      // Do not reuse asset futures created in a previous test's FakeAsync zone.
      rootBundle.evict(Assets.changelog);
      rootBundle.evict('LICENSE');
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          home: const AppAboutPage(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppAboutVersionTile));
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveModal), findsNothing);
      await tester.longPress(find.byType(AppAboutVersionTile));
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveModal), findsOneWidget);
      Navigator.of(
        tester.element(find.byType(AdaptiveModal)),
        rootNavigator: true,
      ).pop();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byType(AppAboutLicenseTile), 150);
      await tester.tap(find.byType(AppAboutLicenseTile));
      await tester.pumpAndSettle();
      expect(find.byType(AdaptiveModal), findsOneWidget);
      expect(find.text('License').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final title in ['Habit Grouping', 'Natural Sort']) {
    testWidgets('Experimental pending $title update survives leaving page', (
      tester,
    ) async {
      final vm = _FakeExperimentalFeatureViewModel()
        ..pendingWrite = Completer<void>();
      addTearDown(vm.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<AppExperimentalFeatureViewModel>.value(
          value: vm,
          child: const MaterialApp(home: ExpermentalFeaturesPage()),
        ),
      );
      await tester.tap(find.text(title));
      await tester.pumpWidget(const SizedBox.shrink());
      vm.pendingWrite!.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

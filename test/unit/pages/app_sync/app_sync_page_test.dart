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

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/extensions/adaptive_style_extensions.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_sync_options.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/pages/app_sync/page.dart';
import 'package:mhabit/pages/app_sync/widgets.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/providers/workflow/app_sync.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

final class _FakeAppSyncOwner extends AppSyncOwner {
  bool _enabled = false;
  bool? lastSwitchValue;
  int switchWrites = 0;
  int intervalWrites = 0;
  AppSyncFetchInterval _interval = AppSyncFetchInterval.manual;
  AppSyncServer? config;

  @override
  AppSyncServer? get serverConfig => config;

  @override
  AppSyncFetchInterval get fetchInterval => _interval;

  @override
  Future<void> setFetchInterval(
    AppSyncFetchInterval value, {
    bool listen = true,
  }) async {
    intervalWrites++;
    _interval = value;
    if (listen) notifyListeners();
  }

  @override
  Future<String> readPasswordDisplayText() async => '***';

  @override
  bool get enabled => _enabled;

  @override
  Future<void> setSyncSwitch(bool value, {bool listen = true}) async {
    switchWrites++;
    lastSwitchValue = value;
    _enabled = value;
    if (listen) notifyListeners();
  }
}

Widget _host({
  required AppSyncOwner owner,
  TargetPlatform? platform,
  bool develop = false,
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  Locale? locale,
}) {
  final global = Global()..switchDevelopMode(develop);
  final developer = AppDeveloperViewModel(global: global);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppSyncOwner>.value(value: owner),
      ChangeNotifierProvider<AppDeveloperViewModel>.value(value: developer),
    ],
    child: MaterialApp(
      theme: platform == null ? null : ThemeData(platform: platform),
      locale: locale,
      localizationsDelegates: locale == null
          ? null
          : L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      builder: (context, child) => Directionality(
        textDirection: direction,
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
      home: const AppSyncPage(),
    ),
  );
}

void main() {
  testWidgets('Sync preserves its pinned Material small app bar and switch', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 160);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final owner = _FakeAppSyncOwner();
    addTearDown(owner.dispose);
    await tester.pumpWidget(_host(owner: owner));
    await tester.pump();

    final adaptive = tester.widget<AdaptiveSliverAppBar>(
      find.byType(AdaptiveSliverAppBar),
    );
    final wrapper = tester.widget<WindowControlSliverAppBar>(
      find.byType(WindowControlSliverAppBar),
    );
    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(adaptive.height, AppAdaptiveStyle.materialToolbarHeight);
    expect(wrapper.pinned, isTrue);
    expect(wrapper.floating, isFalse);
    expect(wrapper.snap, isFalse);
    expect(appBar.pinned, isTrue);
    expect(appBar.floating, isFalse);
    expect(appBar.snap, isFalse);
    expect(adaptive.bottom, isNotNull);
    expect(appBar.bottom, isNotNull);
    expect(find.byType(SliverPinnedHeader), findsNothing);
    final safeArea = tester.widget<SliverSafeArea>(find.byType(SliverSafeArea));
    expect(safeArea.left, isTrue);
    expect(safeArea.top, isFalse);
    expect(safeArea.right, isTrue);
    expect(safeArea.bottom, isTrue);
    expect(
      find.ancestor(
        of: find.byType(AdaptiveSwitchListTile),
        matching: find.byType(AdaptiveSliverAppBar),
      ),
      findsOneWidget,
    );
    final enableSafeArea = tester.widget<SafeArea>(
      find
          .ancestor(
            of: find.byType(AdaptiveSwitchListTile),
            matching: find.byType(SafeArea),
          )
          .first,
    );
    expect(enableSafeArea.left, isTrue);
    expect(enableSafeArea.top, isFalse);
    expect(enableSafeArea.right, isTrue);
    expect(enableSafeArea.bottom, isFalse);
    expect(
      tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
      AdaptiveBackButtonType.back,
    );

    Material enableSurface() => tester
        .element(find.byType(AdaptiveSwitchListTile))
        .findAncestorWidgetOfExactType<Material>()!;
    Material toolbarSurface() => tester
        .element(find.text('Sync'))
        .findAncestorWidgetOfExactType<Material>()!;
    expect(identical(enableSurface(), toolbarSurface()), isTrue);
    final originalElevation = enableSurface().elevation;
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    scrollable.position.jumpTo(40);
    await tester.pumpAndSettle();
    expect(identical(enableSurface(), toolbarSurface()), isTrue);
    expect(enableSurface().elevation, greaterThan(originalElevation));

    await tester.tap(find.byType(AdaptiveSwitchListTile).first);
    await tester.pump();
    expect(owner.lastSwitchValue, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('Sync uses the fixed Apple small app bar and adaptive back', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 160);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final owner = _FakeAppSyncOwner();
    addTearDown(owner.dispose);
    await tester.pumpWidget(_host(owner: owner, platform: TargetPlatform.iOS));
    await tester.pump();

    expect(find.byType(AdaptiveSliverAppBar), findsOneWidget);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
    expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
    expect(
      tester.getCenter(find.text('Enable')).dy,
      closeTo(tester.getCenter(find.byType(CupertinoSwitch)).dy, 1),
    );
    final adaptive = tester.widget<AdaptiveSliverAppBar>(
      find.byType(AdaptiveSliverAppBar),
    );
    final bar = tester.widget<WindowControlCupertinoNavigationBar>(
      find.byType(WindowControlCupertinoNavigationBar),
    );
    expect(adaptive.bottom?.preferredSize.height, kToolbarHeight);
    expect(bar.automaticBackgroundVisibility, isTrue);
    expect(bar.enableBackgroundFilterBlur, isTrue);
    expect(bar.backgroundColor, CupertinoColors.transparent);
    expect(find.byType(SliverPinnedHeader), findsNothing);
    expect(
      find.ancestor(
        of: find.byType(AdaptiveSwitchListTile),
        matching: find.byType(AdaptiveSliverAppBar),
      ),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(CupertinoNavigationBar)).height,
      AppAdaptiveStyle.appleToolbarHeight + kToolbarHeight,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
  });
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final direction in TextDirection.values) {
      testWidgets('Sync groups and interval result $platform $direction', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 1200);
        addTearDown(tester.view.reset);
        final owner = _FakeAppSyncOwner();
        addTearDown(owner.dispose);
        await tester.pumpWidget(
          _host(
            owner: owner,
            platform: platform,
            direction: direction,
            textScale: 2,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AppSyncSummaryTile).hitTestable(), findsNothing);
        expect(find.byType(AppSyncFailLogsTile), findsOneWidget);
        expect(find.text('DEBUG'), findsNothing);
        expect(find.byType(Divider), findsNothing);
        final switchType = platform == TargetPlatform.android
            ? Switch
            : CupertinoSwitch;
        expect(find.byType(switchType), findsOneWidget);
        expect(
          tester.getCenter(find.text('Enable')).dy,
          closeTo(tester.getCenter(find.byType(switchType)).dy, 1),
        );
        await tester.tap(find.text('Enable'));
        await tester.pumpAndSettle();
        expect(owner.switchWrites, 1);
        expect(owner.enabled, isTrue);
        expect(find.byType(AppSyncSummaryTile).hitTestable(), findsOneWidget);
        expect(find.byType(AdaptiveListSection), findsNWidgets(2));
        final logRow = tester.widget<AdaptiveListTile>(
          find.descendant(
            of: find.byType(AppSyncFailLogsTile),
            matching: find.byType(AdaptiveListTile),
          ),
        );
        expect(logRow.onTap, isNull);
        await tester.tap(find.byType(AppSyncFetchIntervalTile));
        await tester.pumpAndSettle();
        expect(find.byType(AppSyncFetchIntervalSwitchDialog), findsOneWidget);
        await tester.tap(
          find.byKey(ValueKey(AppSyncFetchInterval.minute15.index)),
        );
        await tester.pumpAndSettle();
        expect(owner.fetchInterval, AppSyncFetchInterval.minute15);
        expect(owner.intervalWrites, 1);
        expect(find.text('15 Minutes'), findsOneWidget);
        await tester.tap(find.byType(AppSyncFetchIntervalTile));
        await tester.pumpAndSettle();
        Navigator.of(
          tester.element(find.byType(AppSyncFetchIntervalSwitchDialog)),
        ).pop();
        await tester.pumpAndSettle();
        expect(owner.intervalWrites, 1);
        await tester.tap(find.byType(switchType));
        await tester.pumpAndSettle();
        expect(owner.switchWrites, 2);
        expect(owner.enabled, isFalse);
        expect(find.byType(AppSyncSummaryTile).hitTestable(), findsNothing);
        expect(find.byType(AppSyncFailLogsTile), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 10));
      });
    }
    testWidgets('Sync configured server and debug layout $platform', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 1200);
      addTearDown(tester.view.reset);
      final owner = _FakeAppSyncOwner()
        ..config = AppWebDavSyncServer.newServer(
          identity: 'test-server',
          path: 'https://example.com/a-very-long-server-name/habits/backup',
        );
      addTearDown(owner.dispose);
      await owner.setSyncSwitch(true);
      await tester.pumpWidget(
        _host(
          owner: owner,
          platform: platform,
          develop: true,
          textScale: 2,
          locale: const Locale('de'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(owner.config!.name), findsOneWidget);
      final summary = tester.widget<AdaptiveListTile>(
        find.descendant(
          of: find.byType(AppSyncSummaryTile),
          matching: find.byType(AdaptiveListTile),
        ),
      );
      expect(
        (summary.trailing as Icon).icon,
        platform == TargetPlatform.android ? Icons.edit : CupertinoIcons.pencil,
      );
      await tester.scrollUntilVisible(find.text('DEBUG'), 150);
      await tester.pumpAndSettle();
      expect(find.text('DEBUG'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 10));
    });
    testWidgets('Sync log export availability $platform', (tester) async {
      final dir = await tester.runAsync(
        () => Directory.systemTemp.createTemp('mhabit-sync-tile-'),
      );
      addTearDown(() => dir!.delete(recursive: true));
      Widget host() => MaterialApp(
        theme: ThemeData(platform: platform),
        home: Scaffold(
          body: AdaptiveListSection(
            children: [AppSyncFailLogsTile(path: dir!.path)],
          ),
        ),
      );
      await tester.runAsync(() async {
        await tester.pumpWidget(host());
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      AdaptiveListTile row() =>
          tester.widget<AdaptiveListTile>(find.byType(AdaptiveListTile));
      expect(row().onTap, isNull);
      await tester.runAsync(
        () => File('${dir!.path}/failure.log').writeAsString('failure'),
      );
      // Rebuilding refreshes the existing tile without exporting real files.
      await tester.runAsync(() async {
        await tester.pumpWidget(host());
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(row().onTap, isNotNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 10));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Sync bottom follows actual layout and platform changes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 1200);
    addTearDown(tester.view.reset);
    final owner = _FakeAppSyncOwner();
    addTearDown(owner.dispose);
    double height() => tester
        .widget<AdaptiveSliverAppBar>(find.byType(AdaptiveSliverAppBar))
        .bottom!
        .preferredSize
        .height;
    for (final platform in [
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
      TargetPlatform.android,
    ]) {
      await tester.pumpWidget(_host(owner: owner, platform: platform));
      await tester.pumpAndSettle();
      final normalHeight = height();
      expect(normalHeight, greaterThanOrEqualTo(kToolbarHeight));
      tester.view.physicalSize = const Size(240, 1200);
      await tester.pumpWidget(
        _host(
          owner: owner,
          platform: platform,
          textScale: 3,
          direction: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();
      expect(height(), greaterThan(normalHeight));
      expect(
        height(),
        closeTo(
          tester.getSize(find.byType(AdaptiveSwitchListTile)).height,
          0.01,
        ),
      );
      final switchType = platform == TargetPlatform.android
          ? Switch
          : CupertinoSwitch;
      expect(
        tester.getCenter(find.text('Enable')).dy,
        closeTo(tester.getCenter(find.byType(switchType)).dy, 1),
      );
      expect(tester.takeException(), isNull);
      tester.view.physicalSize = const Size(900, 1200);
      await tester.pumpWidget(_host(owner: owner, platform: platform));
      await tester.pumpAndSettle();
      expect(height(), normalHeight);
    }
    // Remove the page in the frame after a new size is reported.
    tester.view.physicalSize = const Size(240, 1200);
    await tester.pumpWidget(
      _host(owner: owner, platform: TargetPlatform.iOS, textScale: 3),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
    expect(tester.takeException(), isNull);
  });
}

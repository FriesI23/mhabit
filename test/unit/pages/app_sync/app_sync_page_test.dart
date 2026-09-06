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
import 'package:mhabit/extensions/adaptive_style_extensions.dart';
import 'package:mhabit/pages/app_sync/page.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/providers/workflow/app_sync.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

final class _FakeAppSyncOwner extends AppSyncOwner {
  bool _enabled = false;
  bool? lastSwitchValue;

  @override
  bool get enabled => _enabled;

  @override
  Future<void> setSyncSwitch(bool value, {bool listen = true}) async {
    lastSwitchValue = value;
    _enabled = value;
    if (listen) notifyListeners();
  }
}

Widget _host({required AppSyncOwner owner, TargetPlatform? platform}) {
  final global = Global()..switchDevelopMode(false);
  final developer = AppDeveloperViewModel(global: global);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppSyncOwner>.value(value: owner),
      ChangeNotifierProvider<AppDeveloperViewModel>.value(value: developer),
    ],
    child: MaterialApp(
      theme: platform == null ? null : ThemeData(platform: platform),
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
    expect(adaptive.bottom, isNull);
    expect(appBar.bottom, isNull);
    expect(find.byType(SliverPinnedHeader), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(SwitchListTile),
        matching: find.byType(SliverPinnedHeader),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
      AdaptiveBackButtonType.back,
    );

    await tester.tap(find.byType(SwitchListTile).first);
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
        of: find.byType(SwitchListTile),
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
}

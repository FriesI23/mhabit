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
import 'dart:io';

import 'package:flutter/cupertino.dart'
    show CupertinoButton, CupertinoIcons, CupertinoNavigationBar;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_debugger/page.dart';
import 'package:mhabit/providers/app_ui/app_debugger.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

Future<void> _pumpPage(
  WidgetTester tester, {
  required TargetPlatform platform,
  Size size = const Size(500, 800),
  TextDirection direction = TextDirection.ltr,
  bool pushPage = false,
  AsyncValueGetter<String>? debugBundleBuilder,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final viewModel = AppDebuggerViewModel();
  addTearDown(viewModel.dispose);
  final page = debugBundleBuilder == null
      ? const AppDebuggerPage()
      : AppDebuggerPage.testOnly(debugBundleBuilder: debugBundleBuilder);
  await tester.pumpWidget(
    ChangeNotifierProvider<AppDebuggerViewModel>.value(
      value: viewModel,
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        builder: (context, child) =>
            Directionality(textDirection: direction, child: child!),
        home: pushPage ? const Scaffold(body: Text("Origin")) : page,
      ),
    ),
  );
  await tester.pump();
  if (pushPage) {
    unawaited(
      Navigator.of(
        tester.element(find.text('Origin')),
      ).push<void>(MaterialPageRoute(builder: (_) => page)),
    );
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('uses the Material adaptive app bar and keeps page content', (
    tester,
  ) async {
    await _pumpPage(tester, platform: TargetPlatform.android);

    expect(find.byType(AdaptiveSliverAppBar), findsOneWidget);
    expect(find.byType(WindowControlSliverAppBar), findsOneWidget);
    expect(find.text('Debug Info'), findsOneWidget);
    expect(find.text('Logging Information'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(AdaptiveAppBarActions), findsNothing);
    expect(
      tester
          .widget<AdaptiveSliverAppBar>(find.byType(AdaptiveSliverAppBar))
          .height,
      64.0,
    );
    expect(
      tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
      AdaptiveBackButtonType.back,
    );
    final safeArea = tester.widget<SliverSafeArea>(find.byType(SliverSafeArea));
    expect(safeArea.left, isTrue);
    expect(safeArea.top, isFalse);
    expect(safeArea.right, isTrue);
    expect(safeArea.bottom, isTrue);
  });

  testWidgets('uses the Apple adaptive app bar with a share action', (
    tester,
  ) async {
    await _pumpPage(tester, platform: TargetPlatform.iOS);

    expect(find.byType(AdaptiveSliverAppBar), findsOneWidget);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.text('Debug Info'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byIcon(CupertinoIcons.share), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.ellipsis), findsNothing);
    expect(
      tester
          .widget<AdaptiveSliverAppBar>(find.byType(AdaptiveSliverAppBar))
          .height,
      44.0,
    );
    expect(
      tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
      AdaptiveBackButtonType.back,
    );
    expect(
      tester
          .widget<WindowControlCupertinoNavigationBar>(
            find.byType(WindowControlCupertinoNavigationBar),
          )
          .automaticBackgroundVisibility,
      isTrue,
    );
  });
  for (final platform in [TargetPlatform.iOS, TargetPlatform.macOS]) {
    testWidgets('share action semantics resize RTL and back $platform', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        platform: platform,
        direction: TextDirection.rtl,
        pushPage: true,
      );
      for (final size in [
        const Size(390, 800),
        const Size(900, 800),
        const Size(800, 390),
      ]) {
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        final semantics = tester.ensureSemantics();
        expect(find.bySemanticsLabel('Share debug bundle'), findsOneWidget);
        semantics.dispose();
        expect(find.byTooltip('Share debug bundle'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
        expect(find.byType(FixedPagePlaceHolder), findsNothing);
        expect(find.byIcon(CupertinoIcons.ellipsis), findsNothing);
        final button = find
            .ancestor(
              of: find.byIcon(CupertinoIcons.share),
              matching: find.byType(CupertinoButton),
            )
            .first;
        expect(tester.getSize(button).width, greaterThanOrEqualTo(44));
        expect(tester.getSize(button).height, greaterThanOrEqualTo(44));
        expect(
          tester.widget<SliverSafeArea>(find.byType(SliverSafeArea)).bottom,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      }
      await tester.tap(find.byType(AdaptiveBackButton));
      await tester.pumpAndSettle();
      expect(find.text('Origin'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.share), findsNothing);
    });
  }

  for (final disposeBeforeReady in [false, true]) {
    testWidgets('shares generated bundle; disposed=$disposeBeforeReady', (
      tester,
    ) async {
      final directory = Directory.systemTemp.createTempSync(
        'debugger-share-test-',
      );
      addTearDown(() => directory.deleteSync(recursive: true));
      final bundle = File('${directory.path}/$debuggerZipFile')
        ..writeAsBytesSync([1, 2, 3]);
      final bundleReady = Completer<String>();
      var buildCount = 0;
      final shareCalls = <MethodCall>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
      messenger.setMockMethodCallHandler(shareChannel, (call) async {
        shareCalls.add(call);
        return 'success';
      });
      addTearDown(() => messenger.setMockMethodCallHandler(shareChannel, null));
      final originalTargetPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await _pumpPage(
          tester,
          platform: TargetPlatform.iOS,
          pushPage: true,
          debugBundleBuilder: () {
            buildCount++;
            return bundleReady.future;
          },
        );
        await tester.tap(find.byIcon(CupertinoIcons.share));
        await tester.pump();
        expect(buildCount, 1);
        expect(shareCalls, isEmpty);
        if (disposeBeforeReady) {
          await tester.tap(find.byType(AdaptiveBackButton));
          await tester.pumpAndSettle();
          expect(find.byType(AppDebuggerPage), findsNothing);
        }
        bundleReady.complete(bundle.path);
        await tester.pumpAndSettle();
        if (disposeBeforeReady) {
          expect(shareCalls, isEmpty);
        } else {
          expect(shareCalls, hasLength(1));
          final arguments = shareCalls.single.arguments as Map;
          expect(arguments['paths'], [bundle.path]);
          final context = tester.element(find.byType(AppDebuggerPage));
          expect(
            arguments['subject'],
            L10n.of(context)!.debug_downladDebugZip_subject(debuggerZipFile),
          );
        }
        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = originalTargetPlatform;
      }
    });
  }
}

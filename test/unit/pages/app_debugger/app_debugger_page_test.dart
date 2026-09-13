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

import 'package:archive/archive.dart';
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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

Future<void> _pumpPage(
  WidgetTester tester, {
  required TargetPlatform platform,
  Size size = const Size(500, 800),
  TextDirection direction = TextDirection.ltr,
  bool pushPage = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final viewModel = AppDebuggerViewModel();
  addTearDown(viewModel.dispose);
  await tester.pumpWidget(
    ChangeNotifierProvider<AppDebuggerViewModel>.value(
      value: viewModel,
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        builder: (context, child) =>
            Directionality(textDirection: direction, child: child!),
        home: pushPage
            ? const Scaffold(body: Text("Origin"))
            : const AppDebuggerPage(),
      ),
    ),
  );
  await tester.pump();
  if (pushPage) {
    unawaited(
      Navigator.of(
        tester.element(find.text('Origin')),
      ).push<void>(MaterialPageRoute(builder: (_) => const AppDebuggerPage())),
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
    testWidgets('share generates original zip; disposed=$disposeBeforeReady', (
      tester,
    ) async {
      final directory = Directory.systemTemp.createTempSync(
        'debugger-share-test-',
      );
      addTearDown(() => directory.deleteSync(recursive: true));
      final signals = (await tester.runAsync(
        () async =>
            (Completer<void>(), Completer<void>(), Completer<MethodCall>()),
      ))!;
      final (deviceRequested, deviceReady, shared) = signals;
      final messenger = tester.binding.defaultBinaryMessenger;
      const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
      const deviceChannel = MethodChannel(
        'dev.fluttercommunity.plus/device_info',
      );
      const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
      messenger.setMockMethodCallHandler(
        pathChannel,
        (_) async => directory.path,
      );
      messenger.setMockMethodCallHandler(deviceChannel, (_) async {
        deviceRequested.complete();
        await deviceReady.future;
        return <String, Object>{
          'computerName': 'Test',
          'hostName': 'Test',
          'arch': 'arm64',
          'model': 'Test',
          'modelName': 'Test',
          'kernelVersion': 'Test',
          'osRelease': 'Test',
          'majorVersion': 1,
          'minorVersion': 0,
          'patchVersion': 0,
          'activeCPUs': 1,
          'memorySize': 1024,
          'cpuFrequency': 1,
        };
      });
      messenger.setMockMethodCallHandler(shareChannel, (call) async {
        shared.complete(call);
        return 'success';
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(pathChannel, null);
        messenger.setMockMethodCallHandler(deviceChannel, null);
        messenger.setMockMethodCallHandler(shareChannel, null);
      });
      PackageInfo.setMockInitialValues(
        appName: 'mhabit',
        packageName: 'mhabit',
        version: '1',
        buildNumber: '1',
        buildSignature: '',
      );
      // Keep the platform boundary in XShare on its mobile sharing path.
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      File(
        '${directory.path}/$debuggerLogFileName',
      ).writeAsStringSync('test debug log');
      await _pumpPage(tester, platform: TargetPlatform.iOS, pushPage: true);
      await tester.runAsync(() async {
        tester
            .widget<CupertinoButton>(
              find
                  .ancestor(
                    of: find.byIcon(CupertinoIcons.share),
                    matching: find.byType(CupertinoButton),
                  )
                  .first,
            )
            .onPressed!();
        await deviceRequested.future.timeout(const Duration(seconds: 5));
      });
      if (disposeBeforeReady) {
        await tester.tap(find.byType(AdaptiveBackButton));
        await tester.pumpAndSettle();
      }
      await tester.runAsync(() async {
        deviceReady.complete();
        final zip = File('${directory.path}/$debuggerZipFile');
        if (!disposeBeforeReady) {
          final call = await shared.future.timeout(const Duration(seconds: 5));
          final arguments = call.arguments as Map;
          expect(arguments['paths'], [zip.path]);
          final context = tester.element(find.byType(AppDebuggerPage));
          expect(
            arguments['subject'],
            L10n.of(context)!.debug_downladDebugZip_subject(debuggerZipFile),
          );
        } else {
          // Wait for zip completion before checking the post-await mounted guard.
          for (
            var attempt = 0;
            attempt < 100 && (!zip.existsSync() || zip.lengthSync() == 0);
            attempt++
          ) {
            await Future<void>.delayed(const Duration(milliseconds: 10));
          }
          await Future<void>.delayed(const Duration(milliseconds: 50));
          expect(shared.isCompleted, isFalse);
        }
        final archive = ZipDecoder().decodeBytes(zip.readAsBytesSync());
        expect(
          archive.files.map((file) => file.name),
          containsAll([debuggerLogFileName, debuggerInfoFileName]),
        );
      });
      await tester.pumpAndSettle();
      debugDefaultTargetPlatformOverride = null;
      expect(tester.takeException(), isNull);
    });
  }
}

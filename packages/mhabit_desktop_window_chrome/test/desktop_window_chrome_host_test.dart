import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_window_utils/widgets/macos_toolbar_passthrough.dart';
import 'package:macos_window_utils/window_manipulator.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';

import 'support/fakes.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('macos_window_utils/window_manipulator');
  final calls = <MethodCall>[];

  setUpAll(() async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call);
      return null;
    });
    await WindowManipulator.initialize(enableWindowDelegate: false);
  });
  setUp(calls.clear);
  tearDownAll(
    () =>
        binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null),
  );

  testWidgets(
    'package owns target updates and removal during standard fullscreen',
    (tester) async {
      final api = FakeDesktopWindowChromeApi();
      final chrome = DesktopWindowChrome(api: api);
      addTearDown(chrome.dispose);
      await chrome.initialize();
      await tester.pumpWidget(
        MaterialApp(
          builder: (_, child) =>
              DesktopWindowChromeHost(controller: chrome, child: child!),
          home: const Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: DesktopWindowInteractionRegion(
                child: SizedBox(width: 44, height: 44),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 20));
      // The package's initialization future was completed in setUpAll, outside
      // this widget test's fake clock. Flush its real asynchronous channel work.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      expect(find.byType(MacosToolbarPassthrough), findsOneWidget);
      expect(
        calls.where((call) => call.method == 'updateToolbarPassthroughView'),
        isNotEmpty,
      );
      expect(tester.getTopLeft(find.byType(Scaffold)), Offset.zero);

      api.events!.willEnterFullScreen();
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      expect(find.byType(MacosToolbarPassthrough), findsNothing);
      expect(
        calls.where((call) => call.method == 'removeToolbarPassthroughView'),
        hasLength(1),
      );

      api.events!.onWindowLeaveFullScreen();
      await chrome.refresh();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 20));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      expect(find.byType(MacosToolbarPassthrough), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      expect(
        calls.where((call) => call.method == 'removeToolbarPassthroughView'),
        hasLength(2),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets(
    'unsupported platform does not install package targets',
    (tester) async {
      final chrome = DesktopWindowChrome(api: FakeDesktopWindowChromeApi());
      addTearDown(chrome.dispose);
      await chrome.initialize();
      await tester.pumpWidget(
        DesktopWindowChromeHost(
          controller: chrome,
          child: const DesktopWindowInteractionRegion(
            child: SizedBox(width: 44, height: 44),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MacosToolbarPassthrough), findsNothing);
      expect(calls, isEmpty);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );
}

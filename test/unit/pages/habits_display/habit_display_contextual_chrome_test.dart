import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/pages/habits_display/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _testApp({required TargetPlatform platform, required Widget child}) =>
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: AdaptiveNavScope(
        barHeight: 60,
        navHeight: 84,
        child: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('Material selection suppresses the shell but keeps its FAB', (
    tester,
  ) async {
    late HabitDisplayContextualChrome chrome;
    await tester.pumpWidget(
      _testApp(
        platform: TargetPlatform.android,
        child: Builder(
          builder: (context) {
            chrome = context.resolveHabitDisplayContextualChrome(
              isSelectionMode: true,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(chrome.suppressShellChrome, isTrue);
    expect(chrome.hideFloatingActionButton, isFalse);
    expect(chrome.showSelectionBottomToolbar, isFalse);
    expect(chrome.extendBody, isFalse);
    expect(chrome.bottomPlaceholderHeight, 84);
    expect(chrome.fixedButtonNavigationHeight, isTrue);
  });

  testWidgets(
    'compact Apple selection resolves the contextual toolbar chrome',
    (tester) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      tester.view.viewPadding = const FakeViewPadding(bottom: 24);
      addTearDown(tester.view.reset);
      late HabitDisplayContextualChrome chrome;
      await tester.pumpWidget(
        _testApp(
          platform: TargetPlatform.iOS,
          child: Builder(
            builder: (context) {
              chrome = context.resolveHabitDisplayContextualChrome(
                isSelectionMode: true,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(chrome.suppressShellChrome, isTrue);
      expect(chrome.hideFloatingActionButton, isTrue);
      expect(chrome.showSelectionBottomToolbar, isTrue);
      expect(chrome.extendBody, isTrue);
      expect(chrome.bottomPlaceholderHeight, 68);
      expect(chrome.fixedButtonNavigationHeight, isFalse);
    },
  );

  testWidgets('wide Apple selection suppresses chrome without a bottom bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late HabitDisplayContextualChrome chrome;
    await tester.pumpWidget(
      _testApp(
        platform: TargetPlatform.macOS,
        child: Builder(
          builder: (context) {
            chrome = context.resolveHabitDisplayContextualChrome(
              isSelectionMode: true,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(chrome.suppressShellChrome, isTrue);
    expect(chrome.hideFloatingActionButton, isTrue);
    expect(chrome.showSelectionBottomToolbar, isFalse);
    expect(chrome.extendBody, isFalse);
    expect(chrome.bottomPlaceholderHeight, 84);
    expect(chrome.fixedButtonNavigationHeight, isTrue);
  });
}

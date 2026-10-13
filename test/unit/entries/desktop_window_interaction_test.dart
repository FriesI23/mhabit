import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/entries/common/app_root_view.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:provider/provider.dart';

import '../../support/desktop_window_chrome_fakes.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    testWidgets('$style retains toolbar targets and modal close', (
      tester,
    ) async {
      final api = FakeDesktopWindowChromeApi();
      final chrome = DesktopWindowChrome(api: api);
      addTearDown(chrome.dispose);
      await chrome.initialize();
      late BuildContext pageContext;
      final leading = style == AdaptiveStyle.apple
          ? CupertinoButton(
              key: const ValueKey('target'),
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: const Icon(Icons.menu),
            )
          : IconButton(
              key: const ValueKey('target'),
              onPressed: () {},
              icon: const Icon(Icons.menu),
            );
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: chrome,
          child: AdaptiveStyleScope(
            override: style,
            child: AppRootView.withDefault(
              lightThemeBuilder: (_) =>
                  ThemeData(platform: TargetPlatform.macOS),
              child: Builder(
                builder: (context) {
                  pageContext = context;
                  return Scaffold(
                    appBar: AdaptiveAppBar(
                      title: const Text('Blank drag space'),
                      toolbarHeight: 56,
                      leading: leading,
                      actions: [
                        IconButton(
                          key: const ValueKey('retained-target'),
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    body: const Text('Body'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await chrome.refresh();

      Navigator.of(pageContext).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => const Scaffold(
            appBar: AdaptiveAppBar.material(title: Text('Top modal')),
            body: Text('Modal body'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await chrome.refresh();

      expect(api.configurations, [true]);

      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.text('Modal body'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await chrome.refresh();

      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('custom gesture in RTL leading slot remains tappable', (
    tester,
  ) async {
    var taps = 0;
    final api = FakeDesktopWindowChromeApi();
    final chrome = DesktopWindowChrome(api: api);
    addTearDown(chrome.dispose);
    await chrome.initialize();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: chrome,
        child: AppRootView.withDefault(
          textDirectionOverride: TextDirection.rtl,
          child: Scaffold(
            appBar: AdaptiveAppBar.material(
              title: const Text('Drag space'),
              leading: GestureDetector(
                key: const ValueKey('custom-target'),
                onTap: () => taps++,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.menu),
                ),
              ),
            ),
            body: const Text('Body'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await chrome.refresh();

    await tester.tap(find.byKey(const ValueKey('custom-target')));
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pinned sliver scrolling retains native decoration', (
    tester,
  ) async {
    final api = FakeDesktopWindowChromeApi();
    final chrome = DesktopWindowChrome(api: api);
    addTearDown(chrome.dispose);
    await chrome.initialize();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: chrome,
        child: AppRootView.withDefault(
          child: CustomScrollView(
            slivers: [
              WindowControlSliverAppBar(
                pinned: true,
                toolbarHeight: 44,
                expandedHeight: 180,
                leading: IconButton(
                  key: const ValueKey('sliver-leading'),
                  onPressed: () {},
                  icon: const Icon(Icons.menu),
                ),
                title: const Text('Toolbar'),
                bottom: const PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: SizedBox(
                    height: 60,
                    child: NavigationToolbar(middle: Text('Calendar row')),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 2000)),
            ],
          ),
        ),
      ),
    );
    for (final scroll in [false, true]) {
      if (scroll) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      }
      await tester.pumpAndSettle();

      expect(api.configurations, [true]);
    }
    expect(tester.takeException(), isNull);
  });
}

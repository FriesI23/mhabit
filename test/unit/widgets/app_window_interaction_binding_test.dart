import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:provider/provider.dart';

import '../../support/desktop_window_chrome_fakes.dart';

void main() {
  testWidgets(
    'theme changes preserve the app surface without native color management',
    (tester) async {
      final api = FakeDesktopWindowChromeApi();
      final chrome = DesktopWindowChrome(api: api);
      addTearDown(chrome.dispose);
      await chrome.initialize();
      for (final brightness in Brightness.values) {
        final theme = ThemeData(
          brightness: brightness,
          scaffoldBackgroundColor: Colors.orange,
          appBarTheme: const AppBarThemeData(backgroundColor: Colors.teal),
        );
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: chrome,
            child: MaterialApp(
              theme: theme,
              builder: (_, child) => AppWindowInteractionBinding(child: child!),
              home: Scaffold(
                appBar: AppBar(title: const Text('Theme')),
                body: const Text('Body'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.text('Theme'));
        expect(Theme.of(context).appBarTheme, theme.appBarTheme);
        expect(tester.getTopLeft(find.byType(Scaffold)).dy, 0);
      }
    },
  );

  for (final size in const [Size(350, 520), Size(1000, 700)]) {
    for (final brightness in Brightness.values) {
      testWidgets('Material $size $brightness retains scroll-under colors', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final chrome = DesktopWindowChrome(api: FakeDesktopWindowChromeApi());
        addTearDown(chrome.dispose);
        await chrome.initialize();
        final scheme = ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: brightness,
        );
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: chrome,
            child: AdaptiveStyleScope(
              override: AdaptiveStyle.material,
              child: MaterialApp(
                theme: ThemeData(
                  colorScheme: scheme,
                  navigationRailTheme: NavigationRailThemeData(
                    backgroundColor: scheme.surfaceContainer,
                  ),
                ),
                builder: (_, child) =>
                    AppWindowInteractionBinding(child: child!),
                home: Scaffold(
                  appBar: const AdaptiveAppBar(
                    title: Text('Scroll'),
                    toolbarHeight: 56,
                  ),
                  body: ListView.builder(
                    itemCount: 100,
                    itemBuilder: (_, index) =>
                        SizedBox(height: 60, child: Text('Row $index')),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final barSurface = find
            .descendant(
              of: find.byType(AppBar),
              matching: find.byType(Material),
            )
            .first;
        expect(tester.widget<Material>(barSurface).color, scheme.surface);
        expect(tester.widget<Material>(barSurface).elevation, 0);
        await tester.drag(find.byType(ListView), const Offset(0, -250));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Material>(barSurface).color,
          scheme.surfaceContainer,
        );
        expect(tester.widget<Material>(barSurface).elevation, 3);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('root overlay keeps full viewport and ambient insets', (
    tester,
  ) async {
    final chrome = DesktopWindowChrome(api: FakeDesktopWindowChromeApi());
    addTearDown(chrome.dispose);
    await chrome.initialize();
    late BuildContext pageContext;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: chrome,
        child: MaterialApp(
          builder: (_, child) => MediaQuery(
            data: const MediaQueryData(
              size: Size(350, 520),
              viewPadding: EdgeInsets.only(top: 10, bottom: 12),
              padding: EdgeInsets.only(top: 10, bottom: 12),
              viewInsets: EdgeInsets.only(bottom: 100),
              textScaler: TextScaler.linear(1.5),
            ),
            child: AppWindowInteractionBinding(child: child!),
          ),
          home: Builder(
            builder: (context) {
              pageContext = context;
              final media = MediaQuery.of(context);
              expect(media.padding, const EdgeInsets.only(top: 10, bottom: 12));
              expect(
                media.viewPadding,
                const EdgeInsets.only(top: 10, bottom: 12),
              );
              expect(media.viewInsets.bottom, 100);
              expect(media.textScaler.scale(10), 15);
              return const Scaffold(body: Text('Root'));
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Navigator.of(pageContext, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Overlay')),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .getTopLeft(
            find.ancestor(
              of: find.text('Overlay'),
              matching: find.byType(Scaffold),
            ),
          )
          .dy,
      0,
    );
    expect(tester.takeException(), isNull);
  });
}

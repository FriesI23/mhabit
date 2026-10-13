import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit/entries/common/app_root_view.dart';
import 'package:mhabit/models/app_theme_color.dart';
import 'package:mhabit/theme/app_theme_builder.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:provider/provider.dart';

import '../../support/desktop_window_chrome_fakes.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final direction in TextDirection.values) {
      testWidgets(
        '$style $direction uses full viewport and local avoidance at minimum size',
        (tester) async {
          tester.view.physicalSize = const Size(350, 520);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final api = FakeDesktopWindowChromeApi();
          final chrome = DesktopWindowChrome(api: api);
          addTearDown(chrome.dispose);
          await chrome.initialize();
          await tester.pumpWidget(
            ChangeNotifierProvider.value(
              value: chrome,
              child: AdaptiveStyleScope(
                override: style,
                child: AppRootView.withDefault(
                  textDirectionOverride: direction,
                  lightThemeBuilder: (_) =>
                      ThemeData(platform: TargetPlatform.macOS),
                  child: Scaffold(
                    appBar: const AdaptiveAppBar(
                      title: Text('Title'),
                      toolbarHeight: 56,
                    ),
                    body: Builder(
                      builder: (context) {
                        expect(
                          MediaQuery.sizeOf(context),
                          const Size(350, 520),
                        );
                        expect(
                          AdaptiveWindowControlLayoutScope.appBarAvoidanceOf(
                            context,
                          ),
                          const EdgeInsets.only(left: 61),
                        );
                        expect(
                          AdaptiveWindowControlLayoutScope.sideNavigationHorizontalAvoidanceOf(
                            context,
                          ),
                          EdgeInsets.zero,
                        );
                        return const Text('Body');
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.getTopLeft(find.byType(Scaffold)).dy, 0);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('fullscreen transition preserves navigator, input and focus', (
    tester,
  ) async {
    final chrome = DesktopWindowChrome(api: FakeDesktopWindowChromeApi());
    addTearDown(chrome.dispose);
    await chrome.initialize();
    final controller = TextEditingController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: chrome,
        child: AppRootView.withDefault(
          child: Scaffold(
            body: TextField(controller: controller, focusNode: focus),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'keep this search');
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    chrome.willEnterFullScreen();
    await chrome.refresh();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(Scaffold)).dy, 0);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)),
      same(navigator),
    );
    expect(controller.text, 'keep this search');
    expect(focus.hasFocus, isTrue);
    chrome.onWindowLeaveFullScreen();
    await chrome.refresh();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(Scaffold)).dy, 0);
    expect(controller.text, 'keep this search');
    expect(focus.hasFocus, isTrue);
  });

  for (final style in AdaptiveStyle.values) {
    testWidgets(
      '$style dark app icons retain their color across window resize and geometry refresh',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final api = FakeDesktopWindowChromeApi();
        final chrome = DesktopWindowChrome(api: api);
        addTearDown(chrome.dispose);
        await chrome.initialize();
        final darkTheme = ThemeData(
          brightness: Brightness.dark,
          platform: TargetPlatform.macOS,
        );
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: chrome,
            child: AppRootView.withDefault(
              themeMode: ThemeMode.dark,
              lightThemeBuilder: (_) =>
                  ThemeData(platform: TargetPlatform.macOS),
              darkThemeBuilder: (_) => darkTheme,
              child: Scaffold(
                appBar: style == AdaptiveStyle.apple
                    ? const AdaptiveAppBar.apple(
                        title: Text('Dark toolbar'),
                        actions: [
                          Icon(Icons.settings, key: ValueKey('dark-icon')),
                        ],
                      )
                    : const AdaptiveAppBar.material(
                        title: Text('Dark toolbar'),
                        actions: [
                          Icon(Icons.settings, key: ValueKey('dark-icon')),
                        ],
                      ),
                body: const Text('Dark body'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final icon = find.byKey(const ValueKey('dark-icon'));
        Color? glyphColor() => tester
            .widget<RichText>(
              find.descendant(of: icon, matching: find.byType(RichText)),
            )
            .text
            .style
            ?.color;
        final originalColor = glyphColor();
        expect(originalColor, isNotNull);
        expect(originalColor, isNot(Colors.black));
        for (final size in const [
          Size(350, 520),
          Size(1000, 700),
          Size(350, 520),
        ]) {
          tester.view.physicalSize = size;
          api.snapshot = snapshotGeometry(
            width: size.width,
            height: size.height,
          );
          chrome.geometryChanged();
          await chrome.refresh();
          await tester.pumpAndSettle();
          expect(Theme.of(tester.element(icon)).brightness, Brightness.dark);
          expect(glyphColor(), originalColor);
          expect(glyphColor(), isNot(Colors.black));
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets(
    'Apple resize retains the theme without reconstruction and keeps icons white',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final api = FakeDesktopWindowChromeApi();
      final chrome = DesktopWindowChrome(api: api);
      addTearDown(chrome.dispose);
      await chrome.initialize();
      var themeBuilds = 0;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: chrome,
          child: AppRootView.withDefault(
            themeMode: ThemeMode.dark,
            darkThemeBuilder: (_) {
              themeBuilds++;
              return const AppThemeBuilder()
                  .buildDark(
                    themeColor: const SystemAppThemeColor(),
                    themeMainColor: Colors.blue,
                  )
                  .copyWith(platform: TargetPlatform.macOS);
            },
            child: Scaffold(
              appBar: AdaptiveAppBar.apple(
                title: const Text('Dynamic toolbar'),
                actions: [
                  NeutralCupertinoButton(
                    onPressed: () {},
                    child: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      int? glyphColor() => tester
          .widget<RichText>(
            find.descendant(
              of: find.byIcon(Icons.settings),
              matching: find.byType(RichText),
            ),
          )
          .text
          .style
          ?.color
          ?.toARGB32();
      expect(glyphColor(), Colors.white.toARGB32());
      for (final size in const [
        Size(350, 520),
        Size(1000, 700),
        Size(350, 520),
      ]) {
        final previousBuilds = themeBuilds;
        tester.view.physicalSize = size;
        api.snapshot = snapshotGeometry(width: size.width, height: size.height);
        chrome.geometryChanged();
        await chrome.refresh();
        await tester.pump();
        expect(themeBuilds, previousBuilds);
        for (var frame = 0; frame < 14; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(
            glyphColor(),
            Colors.white.toARGB32(),
            reason: '$size animation frame $frame',
          );
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  for (final usesRouter in [false, true]) {
    testWidgets(
      '${usesRouter ? 'router' : 'home'} geometry updates only layout consumers and preserves live theme changes',
      (tester) async {
        final api = FakeDesktopWindowChromeApi();
        final chrome = DesktopWindowChrome(api: api);
        addTearDown(chrome.dispose);
        await chrome.initialize();
        final mode = ValueNotifier(ThemeMode.dark);
        final controller = TextEditingController();
        final focus = FocusNode();
        addTearDown(mode.dispose);
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        var themeBuilds = 0;
        var bodyBuilds = 0;
        var layoutBuilds = 0;
        late EdgeInsets avoidance;
        final page = Scaffold(
          appBar: AdaptiveAppBar.apple(
            title: Builder(
              builder: (context) {
                layoutBuilds++;
                avoidance = AdaptiveWindowControlLayoutScope.appBarAvoidanceOf(
                  context,
                );
                return const Text('Layout consumer');
              },
            ),
            actions: [
              NeutralCupertinoButton(
                onPressed: () {},
                child: const Icon(Icons.settings),
              ),
            ],
          ),
          body: Builder(
            builder: (_) {
              bodyBuilds++;
              return TextField(controller: controller, focusNode: focus);
            },
          ),
        );
        final router = GoRouter(
          routes: [GoRoute(path: '/', builder: (_, _) => page)],
        );
        addTearDown(router.dispose);
        ThemeData buildTheme(Brightness brightness) {
          themeBuilds++;
          const builder = AppThemeBuilder();
          final theme = brightness == Brightness.dark
              ? builder.buildDark(
                  themeColor: const SystemAppThemeColor(),
                  themeMainColor: Colors.blue,
                )
              : builder.buildLight(
                  themeColor: const SystemAppThemeColor(),
                  themeMainColor: Colors.blue,
                );
          return theme.copyWith(platform: TargetPlatform.macOS);
        }

        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: chrome,
            child: ValueListenableBuilder(
              valueListenable: mode,
              builder: (_, themeMode, _) => usesRouter
                  ? AppRootView.router(
                      themeMode: themeMode,
                      lightThemeBuilder: (_) => buildTheme(Brightness.light),
                      darkThemeBuilder: (_) => buildTheme(Brightness.dark),
                      config: router,
                    )
                  : AppRootView(
                      themeMode: themeMode,
                      lightThemeBuilder: (_) => buildTheme(Brightness.light),
                      darkThemeBuilder: (_) => buildTheme(Brightness.dark),
                      child: page,
                    ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'keep this input');
        await tester.pumpAndSettle();
        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        final inputState = tester.state(find.byType(TextField));
        final initialThemeBuilds = themeBuilds;
        final initialBodyBuilds = bodyBuilds;
        final initialLayoutBuilds = layoutBuilds;
        expect(avoidance, const EdgeInsets.only(left: 61));
        api.snapshot = snapshotGeometry(right: true);
        await chrome.refresh();
        await tester.pumpAndSettle();
        expect(avoidance, const EdgeInsets.only(right: 60));
        expect(layoutBuilds, greaterThan(initialLayoutBuilds));
        expect(bodyBuilds, initialBodyBuilds);
        expect(themeBuilds, initialThemeBuilds);
        expect(
          tester.widget<MaterialApp>(find.byType(MaterialApp)),
          same(materialApp),
        );
        chrome.willEnterFullScreen();
        await tester.pumpAndSettle();
        expect(avoidance, EdgeInsets.zero);
        chrome.onWindowLeaveFullScreen();
        await chrome.refresh();
        await tester.pumpAndSettle();
        expect(avoidance, const EdgeInsets.only(right: 60));
        expect(themeBuilds, initialThemeBuilds);
        expect(bodyBuilds, initialBodyBuilds);
        expect(
          tester.state<NavigatorState>(find.byType(Navigator)),
          same(navigator),
        );
        expect(tester.state(find.byType(TextField)), same(inputState));
        expect(controller.text, 'keep this input');
        expect(focus.hasFocus, isTrue);
        mode.value = ThemeMode.light;
        await tester.pumpAndSettle();
        expect(themeBuilds, greaterThan(initialThemeBuilds));
        expect(
          Theme.of(tester.element(find.byType(TextField))).brightness,
          Brightness.light,
        );
        expect(
          tester.state<NavigatorState>(find.byType(Navigator)),
          same(navigator),
        );
        expect(controller.text, 'keep this input');
        expect(focus.hasFocus, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

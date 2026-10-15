import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/entries/app_error/entry.dart';
import 'package:mhabit/entries/common/app_root_view.dart';
import 'package:mhabit/providers/app_ui/app_window_appearance.dart';
import 'package:mhabit/widgets/_widgets/app_window_title_bar_binding.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:provider/provider.dart';

class _Api implements DesktopWindowTitleBarApi {
  @override
  bool get supported => true;
  final appearances = <DesktopTitleBarAppearance>[];
  @override
  Future<void> initialize({Size? minimumSize}) async {}
  @override
  Future<bool> applyAppearance(DesktopTitleBarAppearance appearance) async {
    appearances.add(appearance);
    return true;
  }

  @override
  Future<void> reset() async {}
}

class _SurfaceAccess implements AppWindowNavigationSurfaceAccess {
  final reports = <(Object, Color?)>[];
  final releases = <Object>[];

  @override
  void reportSurface({required Object source, required Color? background}) =>
      reports.add((source, background));

  @override
  void clearSurface(Object source) => releases.add(source);
}

void main() {
  testWidgets(
    'binding merges idle reports and cancels submissions after removal',
    (tester) async {
      final api = _Api();
      final titleBar = DesktopWindowTitleBar(api: api);
      await titleBar.initialize();
      addTearDown(() => unawaited(titleBar.dispose()));
      late AppWindowNavigationSurfaceAccess access;
      final theme = ThemeData(colorSchemeSeed: Colors.blue);
      await tester.pumpWidget(
        Provider<DesktopWindowTitleBar>.value(
          value: titleBar,
          child: AppRootView.withDefault(
            lightThemeBuilder: (_) => theme,
            child: Builder(
              builder: (context) {
                access = context.read<AppWindowNavigationSurfaceAccess>();
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(api.appearances, hasLength(1));
      final source = Object();
      access.reportSurface(source: source, background: Colors.amber);
      access.clearSurface(source);
      access.reportSurface(source: source, background: Colors.green);
      expect(api.appearances, hasLength(1));
      await tester.pumpAndSettle();
      expect(api.appearances, hasLength(2));
      expect(api.appearances.last.background, Colors.green);

      access.reportSurface(source: source, background: Colors.red);
      await tester.pumpWidget(const SizedBox.shrink());
      // A removed reporter can still hold its access during teardown.
      access.clearSurface(source);
      access.reportSurface(source: source, background: Colors.amber);
      await tester.pumpAndSettle();
      expect(api.appearances, hasLength(2));

      // Disposing the binding does not dispose the separately owned native API.
      final application = titleBar.applyAppearance(
        DesktopTitleBarAppearance(
          background: theme.colorScheme.surface,
          foreground: theme.colorScheme.onSurface,
          brightness: theme.brightness,
        ),
      );
      await tester.pump();
      await application;
      expect(api.appearances, hasLength(3));
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets(
    'error entry applies its window theme without profile or navigation providers',
    (tester) async {
      final api = _Api();
      final titleBar = DesktopWindowTitleBar(api: api);
      await titleBar.initialize();
      addTearDown(() => unawaited(titleBar.dispose()));
      await tester.pumpWidget(
        Provider<DesktopWindowTitleBar>.value(
          value: titleBar,
          child: AppErrorEntry(
            errorDetails: FlutterErrorDetails(exception: StateError('startup')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Scaffold).first);
      final theme = Theme.of(context);
      expect(api.appearances.last.background, theme.colorScheme.surface);
      expect(api.appearances.last.foreground, theme.colorScheme.onSurface);
      expect(api.appearances.last.brightness, theme.brightness);
      expect(context.read<AppWindowNavigationSurfaceAccess>(), isNotNull);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets('reporter releases replaced access and preserves its source', (
    tester,
  ) async {
    final first = _SurfaceAccess();
    final second = _SurfaceAccess();
    final key = GlobalKey();
    Future<void> pump(
      AppWindowNavigationSurfaceAccess access,
      Color color,
    ) async {
      await tester.pumpWidget(
        Provider<AppWindowNavigationSurfaceAccess>.value(
          value: access,
          child: AdaptiveNavScope(
            form: NavigationShellForm.expandedSide,
            barHeight: 0,
            navHeight: 0,
            navigationSurfaceColor: color,
            child: AppWindowNavigationSurfaceReporter(
              key: key,
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      );
    }

    await pump(first, Colors.amber);
    final state = tester.state(find.byKey(key));
    final source = first.reports.single.$1;
    expect(first.reports.single.$2, Colors.amber);

    await pump(second, Colors.green);
    expect(tester.state(find.byKey(key)), same(state));
    expect(first.releases, [source]);
    expect(second.reports, [(source, Colors.green)]);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(second.releases, [source]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'resolved rail form, theme and style own native colors; overlays do not',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.reset);
      final api = _Api();
      final owner = DesktopWindowTitleBar(api: api);
      await owner.initialize();
      addTearDown(() => unawaited(owner.dispose()));
      final light = ThemeData(colorSchemeSeed: Colors.blue).copyWith(
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Colors.amber,
        ),
      );
      final dark =
          ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.orange,
          ).copyWith(
            navigationRailTheme: const NavigationRailThemeData(
              backgroundColor: Colors.brown,
            ),
          );
      var style = AdaptiveStyle.material;
      var mode = ThemeMode.light;
      var withShell = true;
      late BuildContext pageContext;
      Future<void> pump() async {
        final page = Builder(
          builder: (context) {
            pageContext = context;
            return Theme(
              data: ThemeData(colorSchemeSeed: Colors.red),
              child: const Scaffold(body: Text('Page local theme')),
            );
          },
        );
        await tester.pumpWidget(
          Provider<DesktopWindowTitleBar>.value(
            value: owner,
            child: AdaptiveStyleScope(
              override: style,
              child: AppRootView(
                themeMode: mode,
                lightThemeBuilder: (_) => light,
                darkThemeBuilder: (_) => dark,
                child: withShell
                    ? AdaptiveNavigationShell(
                        selectedIndex: 0,
                        onDestinationSelected: (_) {},
                        destinations: const [
                          AdaptiveNavigationDestination(
                            label: 'Habits',
                            icons: NavigationDestinationIcons.union(
                              Icon(Icons.check),
                            ),
                          ),
                          AdaptiveNavigationDestination(
                            label: 'Today',
                            icons: NavigationDestinationIcons.union(
                              Icon(Icons.today),
                            ),
                          ),
                        ],
                        child: AppWindowNavigationSurfaceReporter(child: page),
                      )
                    : page,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pump();
      expect(api.appearances.last.background, Colors.amber);
      final calls = api.appearances.length;
      showDialog<void>(
        context: pageContext,
        builder: (_) => Theme(
          data: ThemeData.dark(),
          child: const AlertDialog(title: Text('Modal')),
        ),
      );
      await tester.pumpAndSettle();
      expect(api.appearances.length, calls);
      Navigator.of(pageContext, rootNavigator: true).pop();
      await tester.pumpAndSettle();

      tester.view.physicalSize = const Size(350, 520);
      await tester.pumpAndSettle();
      expect(api.appearances.last.background, light.colorScheme.surface);
      expect(
        AdaptiveWindowControlLayoutScope.maybeOf(
          pageContext,
        )!.hasWindowControlAvoidance,
        false,
      );
      tester.view.physicalSize = const Size(700, 800);
      await tester.pumpAndSettle();
      expect(api.appearances.last.background, Colors.amber);
      mode = ThemeMode.dark;
      await pump();
      expect(api.appearances.last.background, Colors.brown);
      expect(api.appearances.last.foreground, dark.colorScheme.onSurface);
      expect(api.appearances.last.brightness, Brightness.dark);
      style = AdaptiveStyle.apple;
      await pump();
      expect(api.appearances.last.background, dark.colorScheme.surface);
      style = AdaptiveStyle.material;
      withShell = false;
      await pump();
      expect(api.appearances.last.background, dark.colorScheme.surface);
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets(
    'Windows Material root supplies fixed backgrounds; other styles/platforms retain defaults',
    (tester) async {
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      for (final (platform, style, fixed) in [
        (TargetPlatform.windows, AdaptiveStyle.material, true),
        (TargetPlatform.windows, AdaptiveStyle.apple, false),
        (TargetPlatform.macOS, AdaptiveStyle.material, false),
        (TargetPlatform.linux, AdaptiveStyle.material, false),
        (TargetPlatform.android, AdaptiveStyle.material, false),
      ]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          AdaptiveStyleScope(
            override: style,
            child: AppRootView.withDefault(
              child: Builder(
                builder: (context) {
                  expect(
                    MaterialAppBarScrollPolicy.fixedBackgroundOf(context),
                    fixed,
                  );
                  final theme = Theme.of(context);
                  expect(
                    theme.appBarTheme.backgroundColor,
                    fixed ? theme.colorScheme.surface : null,
                  );
                  expect(
                    theme.appBarTheme.surfaceTintColor,
                    fixed ? Colors.transparent : null,
                  );
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      }
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets(
    'navigation surface reports survive reparenting and clear on removal',
    (tester) async {
      final api = _Api();
      final owner = DesktopWindowTitleBar(api: api);
      await owner.initialize();
      addTearDown(() => unawaited(owner.dispose()));
      final reportKey = GlobalKey();
      final theme = ThemeData(colorSchemeSeed: Colors.blue);
      var reparented = false;
      var showRail = true;
      var color = Colors.amber;
      Future<void> pump() async {
        final report = AppWindowNavigationSurfaceReporter(
          key: reportKey,
          child: const Text('Rail content'),
        );
        await tester.pumpWidget(
          Provider<DesktopWindowTitleBar>.value(
            value: owner,
            child: AppRootView.withDefault(
              lightThemeBuilder: (_) => theme,
              child: showRail
                  ? AdaptiveNavScope(
                      form: NavigationShellForm.expandedSide,
                      navigationSurfaceColor: color,
                      barHeight: 0,
                      navHeight: 0,
                      child: NavigationRailTheme(
                        data: NavigationRailThemeData(backgroundColor: color),
                        child: reparented
                            ? Padding(
                                padding: const EdgeInsets.all(8),
                                child: report,
                              )
                            : report,
                      ),
                    )
                  : const Text('No rail'),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pump();
      expect(api.appearances.last.background, Colors.amber);
      final reportState = tester.state(find.byKey(reportKey));
      final calls = api.appearances.length;
      reparented = true;
      color = Colors.brown;
      await pump();
      expect(tester.state(find.byKey(reportKey)), same(reportState));
      expect(api.appearances.length, calls + 1);
      expect(api.appearances.last.background, Colors.brown);
      showRail = false;
      await pump();
      expect(api.appearances.last.background, theme.colorScheme.surface);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets(
    'Windows theme dispatch preserves Navigator, input and focus across UI styles',
    (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      final theme = ThemeData(colorSchemeSeed: Colors.blue);
      var style = AdaptiveStyle.material;
      var mode = ThemeMode.light;
      Future<void> pump() async {
        await tester.pumpWidget(
          AdaptiveStyleScope(
            override: style,
            child: AppRootView(
              themeMode: mode,
              lightThemeBuilder: (_) => theme,
              darkThemeBuilder: (_) => ThemeData.dark(),
              child: Scaffold(
                body: TextField(controller: controller, focusNode: focus),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pump();
      await tester.enterText(find.byType(TextField), 'Retained input');
      await tester.pumpAndSettle();
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      final field = tester.state(find.byType(TextField));
      for (final nextStyle in [AdaptiveStyle.apple, AdaptiveStyle.material]) {
        style = nextStyle;
        mode = ThemeMode.dark;
        await pump();
        expect(
          tester.state<NavigatorState>(find.byType(Navigator)),
          same(navigator),
        );
        expect(tester.state(find.byType(TextField)), same(field));
        expect(controller.text, 'Retained input');
        expect(focus.hasFocus, isTrue);
      }
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets(
    'window consumes navigation surface data independently of Material style',
    (tester) async {
      final api = _Api();
      final owner = DesktopWindowTitleBar(api: api);
      await owner.initialize();
      addTearDown(() => unawaited(owner.dispose()));
      final theme = ThemeData(colorSchemeSeed: Colors.blue);
      Future<void> pump(Color? surface) async {
        await tester.pumpWidget(
          Provider<DesktopWindowTitleBar>.value(
            value: owner,
            child: AdaptiveStyleScope(
              override: AdaptiveStyle.apple,
              child: AppRootView.withDefault(
                lightThemeBuilder: (_) => theme,
                child: AdaptiveNavScope(
                  form: NavigationShellForm.expandedSide,
                  barHeight: 0,
                  navHeight: 0,
                  navigationSurfaceColor: surface,
                  child: const NavigationRailTheme(
                    data: NavigationRailThemeData(backgroundColor: Colors.red),
                    child: AppWindowNavigationSurfaceReporter(
                      child: SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pump(Colors.green);
      expect(api.appearances.last.background, Colors.green);
      await pump(null);
      expect(api.appearances.last.background, theme.colorScheme.surface);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );
}

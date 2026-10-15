import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import 'harness/adaptive_ui_theme.dart';

void main() {
  testWidgets('renderers publish navigation surfaces for their resolved form', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final theme = ThemeData(colorSchemeSeed: Colors.blue).copyWith(
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.amber,
      ),
    );
    AdaptiveNavScope? scope;
    for (final (style, size, expected) in [
      (AdaptiveStyle.material, const Size(350, 800), null),
      (AdaptiveStyle.material, const Size(700, 800), Colors.amber),
      (AdaptiveStyle.material, const Size(1100, 800), Colors.amber),
      (AdaptiveStyle.material, const Size(1100, 400), null),
      (AdaptiveStyle.apple, const Size(350, 800), null),
      (AdaptiveStyle.apple, const Size(1100, 800), null),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: TestAdaptiveUiTheme(
            update: (parentTheme) => parentTheme.copyWith(style: style),
            child: AdaptiveNavigationShell(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                AdaptiveNavigationDestination(
                  label: 'Habits',
                  icons: NavigationDestinationIcons.union(Icon(Icons.check)),
                ),
                AdaptiveNavigationDestination(
                  label: 'Today',
                  icons: NavigationDestinationIcons.union(Icon(Icons.today)),
                ),
              ],
              child: Builder(
                builder: (context) {
                  scope = AdaptiveNavScope.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(scope!.navigationSurfaceColor, expected, reason: '$style $size');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('surface-only scope changes notify consumers', (tester) async {
    Color? surface;
    var builds = 0;
    final consumer = Builder(
      builder: (context) {
        builds++;
        surface = AdaptiveNavScope.of(context).navigationSurfaceColor;
        return const SizedBox.shrink();
      },
    );
    Future<void> pump(Color? color) => tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavScope(
          form: NavigationShellForm.expandedSide,
          barHeight: 0,
          navHeight: 0,
          navigationSurfaceColor: color,
          child: consumer,
        ),
      ),
    );
    await pump(Colors.amber);
    final before = builds;
    await pump(Colors.brown);
    expect(builds, greaterThan(before));
    expect(surface, Colors.brown);
    await pump(null);
    expect(surface, isNull);
  });
}

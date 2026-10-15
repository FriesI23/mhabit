import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import 'harness/adaptive_ui_theme.dart';

Material barMaterial(WidgetTester tester) => tester.widget<Material>(
  find
      .descendant(of: find.byType(AppBar), matching: find.byType(Material))
      .first,
);

void main() {
  for (final variant in [
    'regular',
    'small',
    'medium',
    'large',
    'largeCustomHeight',
  ]) {
    for (final explicit in [false, true]) {
      testWidgets(
        '$variant fixes ${explicit ? "explicit" : "default"} background but retains scroll shadow',
        (tester) async {
          final controller = ScrollController();
          addTearDown(controller.dispose);
          final theme = ThemeData(colorSchemeSeed: Colors.blue);
          final Color? color = explicit
              ? WidgetStateColor.resolveWith(
                  (states) => states.contains(WidgetState.scrolledUnder)
                      ? Colors.red
                      : Colors.green,
                )
              : null;
          const tint = Colors.purple;
          Widget sliver;
          switch (variant) {
            case 'medium':
              sliver = WindowControlSliverAppBar.medium(
                title: const Text('Title'),
                backgroundColor: color,
                surfaceTintColor: tint,
                elevation: 0,
                scrolledUnderElevation: 7,
              );
            case 'large':
              sliver = WindowControlSliverAppBar.large(
                title: const Text('Title'),
                backgroundColor: color,
                surfaceTintColor: tint,
                elevation: 0,
                scrolledUnderElevation: 7,
              );
            case 'largeCustomHeight':
              sliver = WindowControlSliverAppBar.large(
                title: const Text('Title'),
                toolbarHeight: 64,
                backgroundColor: color,
                surfaceTintColor: tint,
                elevation: 0,
                scrolledUnderElevation: 7,
              );
            default:
              sliver = WindowControlSliverAppBar(
                title: const Text('Title'),
                pinned: true,
                backgroundColor: color,
                surfaceTintColor: tint,
                elevation: 0,
                scrolledUnderElevation: 7,
              );
          }
          final body = variant == 'regular'
              ? ListView.builder(
                  controller: controller,
                  itemCount: 50,
                  itemBuilder: (_, i) =>
                      SizedBox(height: 60, child: Text('$i')),
                )
              : CustomScrollView(
                  controller: controller,
                  slivers: [
                    sliver,
                    SliverList.builder(
                      itemCount: 50,
                      itemBuilder: (_, i) =>
                          SizedBox(height: 60, child: Text('$i')),
                    ),
                  ],
                );
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: TestAdaptiveUiTheme(
                update: (parentTheme) => parentTheme.copyWith(
                  appBarTheme: parentTheme.appBarTheme.copyWith(
                    materialFixedScrollBackground: true,
                  ),
                ),
                child: Scaffold(
                  appBar: variant == 'regular'
                      ? WindowControlAppBar(
                          title: const Text('Title'),
                          backgroundColor: color,
                          surfaceTintColor: tint,
                          elevation: 0,
                          scrolledUnderElevation: 7,
                        )
                      : null,
                  body: body,
                ),
              ),
            ),
          );
          final expected = explicit ? Colors.green : theme.colorScheme.surface;
          expect(barMaterial(tester).color, expected);
          controller.jumpTo(400);
          await tester.pumpAndSettle();
          expect(barMaterial(tester).color, expected);
          expect(barMaterial(tester).surfaceTintColor, Colors.transparent);
          expect(barMaterial(tester).elevation, 7);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('fusion keeps Flutter scroll background and elevation', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final theme = ThemeData(colorSchemeSeed: Colors.blue);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: TestAdaptiveUiTheme(
          update: (parentTheme) => parentTheme.copyWith(
            appBarTheme: parentTheme.appBarTheme.copyWith(
              materialFixedScrollBackground: false,
            ),
          ),
          child: Scaffold(
            appBar: const WindowControlAppBar(title: Text('Title')),
            body: ListView.builder(
              controller: controller,
              itemCount: 50,
              itemBuilder: (_, i) => SizedBox(height: 60, child: Text('$i')),
            ),
          ),
        ),
      ),
    );
    expect(barMaterial(tester).color, theme.colorScheme.surface);
    controller.jumpTo(300);
    await tester.pumpAndSettle();
    expect(barMaterial(tester).color, theme.colorScheme.surfaceContainer);
    expect(barMaterial(tester).elevation, greaterThan(0));
  });
}

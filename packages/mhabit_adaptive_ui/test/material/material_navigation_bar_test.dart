import 'dart:ui' show SemanticsRole, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/material/material_navigation_bar.dart';

const _destinations = [
  AdaptiveNavigationDestination(
    label: 'Habits',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.home_outlined, key: ValueKey('habits-icon')),
      materialSelected: Icon(Icons.home, key: ValueKey('habits-selected-icon')),
      apple: Icon(Icons.circle),
      appleSelected: Icon(Icons.circle),
    ),
  ),
  AdaptiveNavigationDestination(
    label: 'Today',
    semanticsLabel: 'Today tab',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.today_outlined, key: ValueKey('today-icon')),
      materialSelected: Icon(Icons.today, key: ValueKey('today-selected-icon')),
      apple: Icon(Icons.circle),
      appleSelected: Icon(Icons.circle),
    ),
  ),
];

enum _Presentation { full, short }

Widget _wrap({
  int selectedIndex = 0,
  ValueChanged<int>? onDestinationSelected,
  EdgeInsets viewPadding = EdgeInsets.zero,
  NavigationBarThemeData? navigationBarTheme,
  _Presentation presentation = _Presentation.short,
}) => MaterialApp(
  theme: ThemeData(navigationBarTheme: navigationBarTheme),
  home: MediaQuery(
    data: MediaQueryData(viewPadding: viewPadding, padding: viewPadding),
    child: Scaffold(
      bottomNavigationBar: switch (presentation) {
        _Presentation.full => MaterialAdaptiveNavigationBar.full(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected ?? (_) {},
          destinations: _destinations,
        ),
        _Presentation.short => MaterialAdaptiveNavigationBar.short(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected ?? (_) {},
          destinations: _destinations,
        ),
      },
    ),
  ),
);

void main() {
  group('MaterialAdaptiveNavigationBar presentations', () {
    testWidgets('full uses the standard height and visible labels', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(presentation: _Presentation.full));

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.height, MaterialAdaptiveNavigationBar.fullHeight);
      expect(
        navigationBar.labelBehavior,
        NavigationDestinationLabelBehavior.alwaysShow,
      );
    });

    testWidgets('short uses an icon-only 64dp bar', (tester) async {
      await tester.pumpWidget(_wrap());

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(navigationBar.height, MaterialAdaptiveNavigationBar.shortHeight);
      expect(
        navigationBar.labelBehavior,
        NavigationDestinationLabelBehavior.alwaysHide,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('short adds safe area after its 64dp content', (tester) async {
      await tester.pumpWidget(
        _wrap(viewPadding: const EdgeInsets.only(bottom: 24)),
      );

      expect(tester.getSize(find.byType(NavigationBar)).height, 88.0);
    });

    testWidgets('short switches destinations through Flutter', (tester) async {
      var selectedIndex = 0;
      late StateSetter setState;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, update) {
            setState = update;
            return _wrap(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => selectedIndex = index),
            );
          },
        ),
      );

      expect(
        find.byKey(const ValueKey('habits-selected-icon')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('today-icon')));
      await tester.pumpAndSettle();

      expect(selectedIndex, 1);
      expect(find.byKey(const ValueKey('today-selected-icon')), findsOneWidget);
    });

    testWidgets('short keeps tooltip and destination semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(selectedIndex: 1));

      final tooltip = tester.widget<Tooltip>(
        find.ancestor(
          of: find.byKey(const ValueKey('today-selected-icon')),
          matching: find.byType(Tooltip),
        ),
      );
      expect(tooltip.message, 'Today tab');
      final node = tester.getSemantics(
        find.byKey(const ValueKey('today-selected-icon')),
      );
      expect(node.role, SemanticsRole.tab);
      expect(node.flagsCollection.isSelected, Tristate.isTrue);
      expect(node.label, contains('Today'));
      semantics.dispose();
    });

    testWidgets('preserves ambient NavigationBarTheme state styling', (
      tester,
    ) async {
      const selectedColor = Colors.red;
      const unselectedColor = Colors.blue;
      await tester.pumpWidget(
        _wrap(
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: Colors.green,
            iconTheme: WidgetStateProperty.resolveWith(
              (states) => IconThemeData(
                color: states.contains(WidgetState.selected)
                    ? selectedColor
                    : unselectedColor,
              ),
            ),
          ),
        ),
      );

      expect(
        IconTheme.of(
          tester.element(find.byKey(const ValueKey('habits-selected-icon'))),
        ).color,
        selectedColor,
      );
      expect(
        IconTheme.of(
          tester.element(find.byKey(const ValueKey('today-icon'))),
        ).color,
        unselectedColor,
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  group('AdaptiveNavigationBar', () {
    testWidgets('forwards height, label behavior and selected index', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AdaptiveNavigationBar(
              selectedIndex: 1,
              onDestinationSelected: (_) {},
              destinations: const [
                AdaptiveNavigationDestination(
                  label: 'Home',
                  icons: NavigationDestinationIcons(
                    material: Icon(
                      Icons.home_outlined,
                      key: ValueKey('m-home'),
                    ),
                    materialSelected: Icon(
                      Icons.home,
                      key: ValueKey('m-home-selected'),
                    ),
                    apple: Icon(Icons.circle, key: ValueKey('a-home')),
                    appleSelected: Icon(
                      Icons.circle,
                      key: ValueKey('a-home-selected'),
                    ),
                  ),
                ),
                AdaptiveNavigationDestination(
                  label: 'Today',
                  semanticsLabel: 'Today tab',
                  icons: NavigationDestinationIcons(
                    material: Icon(Icons.today, key: ValueKey('m-today')),
                    materialSelected: Icon(
                      Icons.today,
                      key: ValueKey('m-today-selected'),
                    ),
                    apple: Icon(Icons.circle, key: ValueKey('a-today')),
                    appleSelected: Icon(
                      Icons.circle,
                      key: ValueKey('a-today-selected'),
                    ),
                  ),
                ),
              ],
              materialStyle: const MaterialNavigationBarStyle(
                height: 80.0,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              ),
            ),
          ),
        ),
      );
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.height, 80.0);
      expect(bar.labelBehavior, NavigationDestinationLabelBehavior.alwaysShow);
      expect(bar.selectedIndex, 1);
      final destinations = bar.destinations.cast<NavigationDestination>();
      expect(destinations.first.icon.key, const ValueKey('m-home'));
      expect(
        destinations.first.selectedIcon?.key,
        const ValueKey('m-home-selected'),
      );
      expect(destinations.first.tooltip, 'Home');
      expect(destinations.last.tooltip, 'Today tab');
      expect(find.byKey(const ValueKey('a-home')), findsNothing);
    });
  });

  group('AdaptiveListTile', () {
    testWidgets('renders a ListTile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdaptiveListTile(title: Text('t'))),
        ),
      );
      expect(find.byType(ListTile), findsOneWidget);
    });
  });

  group('AdaptiveScaffold', () {
    testWidgets('renders a Scaffold', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AdaptiveScaffold(body: SizedBox.shrink())),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

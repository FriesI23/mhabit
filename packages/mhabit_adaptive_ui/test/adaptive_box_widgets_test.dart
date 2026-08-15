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
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
              ],
              height: 80.0,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            ),
          ),
        ),
      );
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.height, 80.0);
      expect(bar.labelBehavior, NavigationDestinationLabelBehavior.alwaysShow);
      expect(bar.selectedIndex, 1);
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

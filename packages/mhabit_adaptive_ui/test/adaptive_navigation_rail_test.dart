import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AdaptiveNavigationRail', () {
    const destinations = [
      AdaptiveNavigationDestination(
        label: 'Habits',
        icons: NavigationDestinationIcons(
          material: Icon(Icons.home_outlined),
          materialSelected: Icon(Icons.home),
          apple: Icon(Icons.home_outlined),
          appleSelected: Icon(Icons.home),
        ),
      ),
    ];

    AdaptiveNavigationRail buildRail({AdaptiveStyle? forced}) {
      final rail = forced == null
          ? AdaptiveNavigationRail(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: destinations,
              extended: true,
              minWidth: 72,
              minExtendedWidth: 256,
            )
          : AdaptiveNavigationRail.material(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: destinations,
              extended: true,
              minWidth: 72,
              minExtendedWidth: 256,
            );
      return rail;
    }

    testWidgets('maps destinations and presentation params onto the rail', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(buildRail()));

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.destinations, hasLength(1));
      expect(rail.destinations.single.label, isA<Text>());
      expect(rail.extended, isTrue);
      expect(rail.minWidth, 72);
      expect(rail.minExtendedWidth, 256);
    });

    testWidgets('apple resolves to the material fallback', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await tester.pumpWidget(_wrap(buildRail()));

      expect(find.byType(NavigationRail), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('.material forces the material rail on apple', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await tester.pumpWidget(_wrap(buildRail(forced: AdaptiveStyle.material)));

      expect(find.byType(NavigationRail), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}

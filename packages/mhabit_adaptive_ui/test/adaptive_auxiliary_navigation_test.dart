import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

const _destinations = [
  AdaptiveNavigationDestination(
    label: 'Habits',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.home_outlined),
      materialSelected: Icon(Icons.home),
      apple: Icon(CupertinoIcons.house),
      appleSelected: Icon(CupertinoIcons.house_fill),
    ),
  ),
  AdaptiveNavigationDestination(
    label: 'Today',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.today_outlined),
      materialSelected: Icon(Icons.today),
      apple: Icon(CupertinoIcons.today),
      appleSelected: Icon(CupertinoIcons.today_fill),
    ),
  ),
];

const _settings = AdaptiveNavigationDestination(
  label: 'Settings',
  icons: NavigationDestinationIcons(
    material: Icon(Icons.settings_outlined),
    materialSelected: Icon(Icons.settings),
    apple: Icon(CupertinoIcons.settings),
    appleSelected: Icon(CupertinoIcons.settings_solid),
  ),
);

const _help = AdaptiveNavigationDestination(
  label: 'Help',
  icons: NavigationDestinationIcons(
    material: Icon(Icons.help_outline),
    materialSelected: Icon(Icons.help),
    apple: Icon(CupertinoIcons.question_circle),
    appleSelected: Icon(CupertinoIcons.question_circle_fill),
  ),
);

Widget _host({
  required TargetPlatform platform,
  required int? selectedAuxiliaryIndex,
  required ValueChanged<int> onSelected,
}) => MaterialApp(
  theme: ThemeData(platform: platform),
  home: AdaptiveNavigationShell(
    selectedIndex: 0,
    destinations: _destinations,
    onDestinationSelected: (_) {},
    auxiliaryDestinations: const [_settings, _help],
    selectedAuxiliaryIndex: selectedAuxiliaryIndex,
    onAuxiliaryDestinationSelected: onSelected,
    child: const ColoredBox(color: Colors.white),
  ),
);

void _setSurface(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('rejects an auxiliary selection outside the destination list', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavigationShell(
          selectedIndex: 0,
          destinations: _destinations,
          onDestinationSelected: (_) {},
          auxiliaryDestinations: const [_settings],
          selectedAuxiliaryIndex: 1,
          onAuxiliaryDestinationSelected: (_) {},
          child: const SizedBox.shrink(),
        ),
      ),
    );

    expect(tester.takeException(), isAssertionError);
  });

  testWidgets('requires a callback for auxiliary destinations', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdaptiveNavigationShell(
          selectedIndex: 0,
          destinations: _destinations,
          onDestinationSelected: (_) {},
          auxiliaryDestinations: const [_settings],
          child: const SizedBox.shrink(),
        ),
      ),
    );

    expect(tester.takeException(), isAssertionError);
  });

  testWidgets('compact navigation does not render auxiliary destination', (
    tester,
  ) async {
    _setSurface(tester, const Size(400, 800));
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.android,
        selectedAuxiliaryIndex: null,
        onSelected: (_) {},
      ),
    );

    expect(
      find.byKey(const ValueKey('material-rail-auxiliary-destination-0')),
      findsNothing,
    );
    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('Material side rail renders and invokes auxiliary destination', (
    tester,
  ) async {
    _setSurface(tester, const Size(700, 800));
    int? selectedIndex;
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.android,
        selectedAuxiliaryIndex: 1,
        onSelected: (index) => selectedIndex = index,
      ),
    );

    final button = find.byKey(
      const ValueKey('material-rail-auxiliary-destination-1'),
    );
    expect(button, findsOneWidget);
    expect(
      find.byKey(const ValueKey('material-rail-auxiliary-destination-0')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Help' &&
            widget.properties.selected == true,
      ),
      findsOneWidget,
    );
    await tester.tap(button);
    expect(selectedIndex, 1);
  });

  testWidgets('Apple Sidebar renders and invokes auxiliary destination', (
    tester,
  ) async {
    _setSurface(tester, const Size(700, 800));
    var invoked = false;
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        selectedAuxiliaryIndex: 0,
        onSelected: (index) => invoked = index == 1,
      ),
    );

    final destination = find.byKey(
      const ValueKey('cupertino-sidebar-auxiliary-destination-1'),
    );
    expect(destination, findsOneWidget);
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-auxiliary-destination-0')),
      findsOneWidget,
    );
    final selectedSemantics = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == 'Settings' &&
          widget.properties.selected == true,
    );
    expect(selectedSemantics, findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Habits' &&
            widget.properties.selected == true,
      ),
      findsNothing,
    );
    await tester.tap(destination);
    expect(invoked, isTrue);
  });
}

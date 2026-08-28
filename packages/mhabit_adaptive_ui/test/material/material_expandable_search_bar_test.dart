import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host({
  required bool expanded,
  required TextEditingController controller,
  required FocusNode focusNode,
  required VoidCallback onActivated,
  required VoidCallback onDismissed,
  Widget collapsedTitle = const Text('Habits'),
  double width = 400,
}) => MaterialApp(
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        child: MaterialExpandableSearchBar(
          expanded: expanded,
          isSearchActive: expanded,
          collapsedTitle: collapsedTitle,
          controller: controller,
          focusNode: focusNode,
          trailing: const Icon(Icons.filter_alt_outlined),
          hintText: 'Search habits',
          onChanged: (_) {},
          onSearchActivated: onActivated,
          onSearchDismissed: onDismissed,
        ),
      ),
    ),
  ),
);

void main() {
  late TextEditingController controller;
  late FocusNode focusNode;
  late int activations;
  late int dismissals;

  setUp(() {
    controller = TextEditingController();
    focusNode = FocusNode();
    activations = 0;
    dismissals = 0;
  });

  tearDown(() {
    controller.dispose();
    focusNode.dispose();
  });

  testWidgets('expands from a 48 wide button without a fade transition', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        expanded: false,
        controller: controller,
        focusNode: focusNode,
        onActivated: () => activations++,
        onDismissed: () => dismissals++,
      ),
    );

    final region = find.byKey(const ValueKey('expandable-search-region'));
    expect(tester.getSize(region).width, 48);
    expect(find.byType(SearchBar), findsNothing);
    final collapsedRegion = tester.widget<AnimatedContainer>(region);
    expect(collapsedRegion.duration, Duration.zero);
    expect(collapsedRegion.curve, Easing.standard);

    await tester.tap(find.byKey(const ValueKey('activate-search')));
    expect(activations, 1);
    await tester.pumpWidget(
      _host(
        expanded: true,
        controller: controller,
        focusNode: focusNode,
        onActivated: () => activations++,
        onDismissed: () => dismissals++,
      ),
    );
    expect(
      tester.widget<AnimatedContainer>(region).duration,
      const Duration(milliseconds: 300),
    );
    await tester.pump(const Duration(milliseconds: 150));

    expect(tester.getSize(region).width, greaterThan(48));
    expect(tester.getSize(region).width, lessThan(312));

    await tester.pumpAndSettle();
    expect(tester.getSize(region).width, 312);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('collapsed-search-title-scroll')))
          .width,
      0,
    );
    expect(tester.getSize(find.byType(SearchBar)).height, 48);

    await tester.tap(find.byKey(const ValueKey('dismiss-search')));
    expect(dismissals, 1);
  });

  testWidgets('long collapsed title scrolls without overflowing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        expanded: false,
        width: 220,
        collapsedTitle: const Text(
          'A very long localized application name for habits',
        ),
        controller: controller,
        focusNode: focusNode,
        onActivated: () => activations++,
        onDismissed: () => dismissals++,
      ),
    );

    final scroll = find.byKey(const ValueKey('collapsed-search-title-scroll'));
    expect(scroll, findsOneWidget);
    expect(tester.takeException(), isNull);

    final before = tester.getTopLeft(find.textContaining('A very long')).dx;
    await tester.drag(scroll, const Offset(-100, 0));
    await tester.pumpAndSettle();
    final after = tester.getTopLeft(find.textContaining('A very long')).dx;
    expect(after, lessThan(before));
    expect(tester.takeException(), isNull);
  });

  testWidgets('expanded width follows resized constraints without animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        expanded: true,
        width: 220,
        controller: controller,
        focusNode: focusNode,
        onActivated: () => activations++,
        onDismissed: () => dismissals++,
      ),
    );

    final region = find.byKey(const ValueKey('expandable-search-region'));
    final title = find.byKey(const ValueKey('collapsed-search-title-scroll'));
    expect(tester.getSize(region).width, 220);
    expect(tester.getSize(title).width, 0);

    await tester.pumpWidget(
      _host(
        expanded: true,
        width: 280,
        controller: controller,
        focusNode: focusNode,
        onActivated: () => activations++,
        onDismissed: () => dismissals++,
      ),
    );

    expect(tester.getSize(region).width, 280);
    expect(tester.getSize(title).width, 0);
    expect(tester.widget<AnimatedContainer>(region).duration, Duration.zero);
  });
}

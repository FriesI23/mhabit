import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host(MaterialSliverSearchBar searchBar) => MaterialApp(
  home: Scaffold(body: CustomScrollView(slivers: [searchBar])),
);

void main() {
  late TextEditingController controller;
  late FocusNode focusNode;
  late List<String> changes;
  late List<String> submissions;
  late int activations;
  late int dismissals;
  late int outsideTaps;

  setUp(() {
    controller = TextEditingController();
    focusNode = FocusNode();
    changes = [];
    submissions = [];
    activations = 0;
    dismissals = 0;
    outsideTaps = 0;
  });

  tearDown(() {
    controller.dispose();
    focusNode.dispose();
  });

  MaterialSliverSearchBar buildBar({
    bool isSearchActive = false,
    MaterialSliverSearchBarStyle style = const MaterialSliverSearchBarStyle(),
  }) => MaterialSliverSearchBar(
    title: const Text('Habits'),
    leading: const Icon(Icons.info_outline, key: ValueKey('info')),
    actions: const [Icon(Icons.settings_outlined, key: ValueKey('settings'))],
    searchTrailing: const Icon(
      Icons.filter_alt_outlined,
      key: ValueKey('filter'),
    ),
    controller: controller,
    focusNode: focusNode,
    isSearchActive: isSearchActive,
    keyword: controller.text,
    hintText: 'Search habits',
    style: style,
    onChanged: changes.add,
    onSubmitted: submissions.add,
    onSearchActivated: () => activations++,
    onSearchDismissed: () => dismissals++,
    onTapOutside: (_) => outsideTaps++,
  );

  testWidgets('compact layout uses the 56 by 48 baseline', (tester) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(buildBar()));

    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(appBar.toolbarHeight, 56);
    expect(appBar.leading, isNull);
    expect(appBar.actions, hasLength(2));
    expect(find.byType(SearchBar), findsNothing);
    expect(find.byKey(const ValueKey('activate-search')), findsOneWidget);
    expect(find.text('Habits'), findsOneWidget);
    expect(find.byKey(const ValueKey('info')), findsOneWidget);
    expect(find.byKey(const ValueKey('settings')), findsOneWidget);
    expect(find.byKey(const ValueKey('filter')), findsNothing);
  });

  testWidgets('medium layout moves search into the trailing region', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(buildBar()));

    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(appBar.leading, isNotNull);
    expect(appBar.title, isA<Text>());
    expect(appBar.actions, hasLength(2));
    expect(tester.getSize(find.byType(SearchBar)).width, 312);
    expect(tester.getSize(find.byType(SearchBar)).height, 48);
  });

  testWidgets('honors custom Material geometry', (tester) async {
    await tester.pumpWidget(
      _host(
        buildBar(
          style: const MaterialSliverSearchBarStyle(
            toolbarHeight: 64,
            searchBarHeight: 44,
          ),
        ),
      ),
    );

    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
    expect(appBar.toolbarHeight, 64);
    expect(searchBar.constraints?.minHeight, 44);
    expect(searchBar.constraints?.maxHeight, 44);
  });

  testWidgets('forwards input, submit, activation, dismissal and outside tap', (
    tester,
  ) async {
    await tester.pumpWidget(_host(buildBar()));

    await tester.tap(find.byKey(const ValueKey('activate-search')));
    expect(activations, 1);

    await tester.pumpWidget(_host(buildBar(isSearchActive: true)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'alpha');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
    final outsideTapsBeforeCallback = outsideTaps;
    searchBar.onTapOutside!(const PointerDownEvent());

    expect(changes, contains('alpha'));
    expect(submissions, ['alpha']);
    expect(outsideTaps, outsideTapsBeforeCallback + 1);

    await tester.tap(find.byKey(const ValueKey('dismiss-search')));
    expect(dismissals, 1);
  });

  testWidgets('rebuild across breakpoints keeps controller and focus node', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar(isSearchActive: true)));
    await tester.pumpAndSettle();

    focusNode.requestFocus();
    await tester.enterText(find.byType(SearchBar), 'kept');
    await tester.pump();
    tester.view.physicalSize = const Size(800, 600);
    await tester.pumpWidget(_host(buildBar(isSearchActive: true)));

    final field = tester.widget<SearchBar>(find.byType(SearchBar));
    expect(field.controller, same(controller));
    expect(field.focusNode, same(focusNode));
    expect(controller.text, 'kept');
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('inactive breakpoint round trip restores the compact button', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar()));

    expect(find.byType(SearchBar), findsNothing);
    expect(find.text('Habits'), findsOneWidget);

    tester.view.physicalSize = const Size(800, 600);
    await tester.pump();
    expect(find.byType(SearchBar), findsOneWidget);

    tester.view.physicalSize = const Size(500, 800);
    await tester.pumpAndSettle();
    expect(find.byType(SearchBar), findsNothing);
    expect(find.byKey(const ValueKey('activate-search')), findsOneWidget);
    expect(find.text('Habits'), findsOneWidget);
  });
}

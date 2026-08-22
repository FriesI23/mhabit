import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host({
  required TargetPlatform platform,
  required AdaptiveSliverSearchBar searchBar,
}) => MaterialApp(
  theme: ThemeData(platform: platform),
  home: Scaffold(body: CustomScrollView(slivers: [searchBar])),
);

void main() {
  late TextEditingController controller;
  late FocusNode focusNode;

  setUp(() {
    controller = TextEditingController(text: 'query');
    focusNode = FocusNode();
  });

  tearDown(() {
    controller.dispose();
    focusNode.dispose();
  });

  AdaptiveSliverSearchBar buildBar({AdaptiveStyle? forcedStyle}) {
    const arguments = (
      title: Text('Habits'),
      leading: Icon(Icons.info_outline),
      actions: [Icon(Icons.settings_outlined)],
      searchTrailing: Icon(Icons.filter_alt_outlined),
    );
    return switch (forcedStyle) {
      null => AdaptiveSliverSearchBar(
        title: arguments.title,
        leading: arguments.leading,
        actions: arguments.actions,
        searchTrailing: arguments.searchTrailing,
        controller: controller,
        focusNode: focusNode,
        isSearchActive: true,
        keyword: 'query',
        hintText: 'Search habits',
        onChanged: (_) {},
        onSearchActivated: () {},
        onSearchDismissed: () {},
      ),
      AdaptiveStyle.material => AdaptiveSliverSearchBar.material(
        title: arguments.title,
        leading: arguments.leading,
        actions: arguments.actions,
        searchTrailing: arguments.searchTrailing,
        controller: controller,
        focusNode: focusNode,
        isSearchActive: true,
        keyword: 'query',
        hintText: 'Search habits',
        onChanged: (_) {},
        onSearchActivated: () {},
        onSearchDismissed: () {},
      ),
      AdaptiveStyle.apple => AdaptiveSliverSearchBar.apple(
        title: arguments.title,
        leading: arguments.leading,
        actions: arguments.actions,
        searchTrailing: arguments.searchTrailing,
        controller: controller,
        focusNode: focusNode,
        isSearchActive: true,
        keyword: 'query',
        hintText: 'Search habits',
        onChanged: (_) {},
        onSearchActivated: () {},
        onSearchDismissed: () {},
      ),
    };
  }

  testWidgets('default Material dispatch builds the Material renderer', (
    tester,
  ) async {
    final bar = buildBar();
    await tester.pumpWidget(
      _host(platform: TargetPlatform.android, searchBar: bar),
    );

    final renderer = tester.widget<MaterialSliverSearchBar>(
      find.byType(MaterialSliverSearchBar),
    );
    expect(renderer.controller, same(controller));
    expect(renderer.focusNode, same(focusNode));
    expect(renderer.isSearchActive, isTrue);
    expect(renderer.keyword, 'query');
    expect(renderer.hintText, 'Search habits');
    expect(renderer.leading, isNotNull);
    expect(renderer.actions, hasLength(1));
    expect(renderer.searchTrailing, isNotNull);
  });

  testWidgets('Apple default dispatch falls back to Material', (tester) async {
    await tester.pumpWidget(
      _host(platform: TargetPlatform.iOS, searchBar: buildBar()),
    );

    expect(find.byType(MaterialSliverSearchBar), findsOneWidget);
    expect(find.byType(SliverAppBar), findsOneWidget);
  });

  testWidgets('.apple explicitly uses the Material fallback', (tester) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.android,
        searchBar: buildBar(forcedStyle: AdaptiveStyle.apple),
      ),
    );

    expect(find.byType(MaterialSliverSearchBar), findsOneWidget);
  });

  testWidgets('.material overrides an Apple platform', (tester) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        searchBar: buildBar(forcedStyle: AdaptiveStyle.material),
      ),
    );

    expect(find.byType(MaterialSliverSearchBar), findsOneWidget);
  });
}

import 'package:adaptive_actions/core.dart';
import 'package:flutter/cupertino.dart' show CupertinoNavigationBar;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host({
  required TargetPlatform platform,
  required AdaptiveSliverSearchBar<String> searchBar,
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

  AdaptiveSliverSearchBar<String> buildBar({
    AdaptiveStyle? forcedStyle,
    bool pinned = true,
  }) {
    const arguments = (
      title: Text('Habits'),
      leading: Icon(Icons.info_outline),
      searchTrailing: Icon(Icons.filter_alt_outlined),
    );
    final collection = ActionCollection<String>(
      roots: [
        AdaptiveAction<String>.action(
          id: ActionId('settings'),
          metadata: const ActionMetadata(
            label: 'Settings',
            iconKey: 'settings',
          ),
          payload: 'settings',
        ),
      ],
    );
    return switch (forcedStyle) {
      null => AdaptiveSliverSearchBar<String>(
        title: arguments.title,
        leading: arguments.leading,
        collection: collection,
        onInvoke: (_, _) {},
        material: MaterialSliverSearchBarConfig(
          searchTrailing: arguments.searchTrailing,
        ),
        controller: controller,
        focusNode: focusNode,
        isSearchActive: true,
        keyword: 'query',
        hintText: 'Search habits',
        onChanged: (_) {},
        onSearchActivated: () {},
        onSearchDismissed: () {},
        pinned: pinned,
      ),
      AdaptiveStyle.material => AdaptiveSliverSearchBar<String>.material(
        title: arguments.title,
        leading: arguments.leading,
        collection: collection,
        onInvoke: (_, _) {},
        material: MaterialSliverSearchBarConfig(
          searchTrailing: arguments.searchTrailing,
        ),
        controller: controller,
        focusNode: focusNode,
        isSearchActive: true,
        keyword: 'query',
        hintText: 'Search habits',
        onChanged: (_) {},
        onSearchActivated: () {},
        onSearchDismissed: () {},
        pinned: pinned,
      ),
      AdaptiveStyle.apple => AdaptiveSliverSearchBar<String>.apple(
        title: arguments.title,
        leading: arguments.leading,
        collection: collection,
        onInvoke: (_, _) {},
        controller: controller,
        focusNode: focusNode,
        isSearchActive: true,
        keyword: 'query',
        hintText: 'Search habits',
        onChanged: (_) {},
        onSearchActivated: () {},
        onSearchDismissed: () {},
        pinned: pinned,
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
    expect(renderer.preferredActionCapacity, 48);
    expect(renderer.searchTrailing, isNotNull);
    final actions = tester.widget<AdaptiveAppBarActions<String>>(
      find.byType(AdaptiveAppBarActions<String>),
    );
    expect(actions.fadeDuration, const Duration(milliseconds: 300));
    expect(actions.resizeDuration, const Duration(milliseconds: 300));
    expect(actions.maxPrimaryActions, 2);
  });

  testWidgets('Apple default dispatch builds the Cupertino renderer', (
    tester,
  ) async {
    final bar = buildBar();
    await tester.pumpWidget(
      _host(platform: TargetPlatform.iOS, searchBar: bar),
    );

    final renderer = tester.widget<CupertinoSliverSearchBar>(
      find.byWidgetPredicate((widget) => widget is CupertinoSliverSearchBar),
    );
    expect(renderer.maxSearchWidth, 240);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.byType(MaterialSliverSearchBar), findsNothing);
  });

  testWidgets('.apple explicitly uses the Cupertino renderer', (tester) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.android,
        searchBar: buildBar(forcedStyle: AdaptiveStyle.apple),
      ),
    );

    expect(
      find.byWidgetPredicate((widget) => widget is CupertinoSliverSearchBar),
      findsOneWidget,
    );
    expect(find.byType(MaterialSliverSearchBar), findsNothing);
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

  testWidgets('forwards the pinned policy to both renderers', (tester) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.android,
        searchBar: buildBar(pinned: false),
      ),
    );
    expect(
      tester
          .widget<MaterialSliverSearchBar>(find.byType(MaterialSliverSearchBar))
          .pinned,
      isFalse,
    );

    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        searchBar: buildBar(forcedStyle: AdaptiveStyle.apple, pinned: false),
      ),
    );
    expect(
      tester
          .widget<CupertinoSliverSearchBar>(
            find.byWidgetPredicate(
              (widget) => widget is CupertinoSliverSearchBar,
            ),
          )
          .pinned,
      isFalse,
    );
  });

  testWidgets('Material expanded search yields action capacity down to More', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final collection = ActionCollection<String>(
      roots: [
        for (var index = 0; index < 4; index++)
          AdaptiveAction<String>.action(
            id: ActionId('action-$index'),
            metadata: ActionMetadata(label: 'Action $index'),
            payload: 'action-$index',
          ),
      ],
    );

    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.windows,
        searchBar: AdaptiveSliverSearchBar<String>.material(
          title: const Text('Habits'),
          collection: collection,
          onInvoke: (_, _) {},
          controller: controller,
          focusNode: focusNode,
          isSearchActive: true,
          keyword: '',
          onChanged: (_) {},
          onSearchActivated: () {},
          onSearchDismissed: () {},
        ),
      ),
    );

    final actions = tester.widget<AdaptiveAppBarActions<String>>(
      find.byType(AdaptiveAppBarActions<String>),
    );
    expect(actions.primaryCapacity, 48);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fixed overflow actions reserve only one shared More slot', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final collection = ActionCollection<String>(
      roots: [
        AdaptiveAction<String>.action(
          id: ActionId('primary'),
          metadata: const ActionMetadata(label: 'Primary'),
          payload: 'primary',
        ),
        for (var index = 0; index < 2; index++)
          AdaptiveAction<String>.action(
            id: ActionId('overflow-$index'),
            metadata: ActionMetadata(label: 'Overflow $index'),
            payload: 'overflow-$index',
            placementPolicy: ActionPlacementPolicy(
              placement: ActionPlacement.overflowOnly,
            ),
          ),
        AdaptiveAction<String>.action(
          id: ActionId('hidden'),
          metadata: const ActionMetadata(label: 'Hidden'),
          payload: 'hidden',
          placementPolicy: ActionPlacementPolicy(
            placement: ActionPlacement.hidden,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.windows,
        searchBar: AdaptiveSliverSearchBar<String>.material(
          title: const Text('Habits'),
          collection: collection,
          onInvoke: (_, _) {},
          controller: controller,
          focusNode: focusNode,
          isSearchActive: true,
          keyword: '',
          onChanged: (_) {},
          onSearchActivated: () {},
          onSearchDismissed: () {},
        ),
      ),
    );

    final renderer = tester.widget<MaterialSliverSearchBar>(
      find.byType(MaterialSliverSearchBar),
    );
    expect(renderer.preferredActionCapacity, 96);
  });

  testWidgets('Material action exposure stays capped at two at every width', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final width in [500.0, 700.0, 900.0, 1300.0, 1700.0]) {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(
        _host(
          platform: TargetPlatform.windows,
          searchBar: buildBar(forcedStyle: AdaptiveStyle.material),
        ),
      );

      final actions = tester.widget<AdaptiveAppBarActions<String>>(
        find.byType(AdaptiveAppBarActions<String>),
      );
      expect(actions.maxPrimaryActions, 2);
    }
  });
}

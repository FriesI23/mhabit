import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

ActionCollection<String> _collection() => ActionCollection<String>(
  roots: [
    AdaptiveAction<String>.action(
      id: ActionId('select'),
      metadata: const ActionMetadata(label: 'Select', iconKey: 'select'),
      payload: 'select',
    ),
    AdaptiveAction<String>.menu(
      id: ActionId('filter'),
      metadata: const ActionMetadata(label: 'Filter', iconKey: 'filter'),
      placementPolicy: ActionPlacementPolicy(
        placement: ActionPlacement.overflowOnly,
      ),
      children: [
        AdaptiveAction<String>.action(
          id: ActionId('ongoing'),
          metadata: const ActionMetadata(label: 'Ongoing'),
          payload: 'ongoing',
        ),
      ],
    ),
  ],
);

Widget _host({
  required TextEditingController controller,
  required FocusNode focusNode,
  required ValueChanged<String> onInvoke,
  TextDirection direction = TextDirection.ltr,
  bool isSearchActive = false,
  VoidCallback? onSearchActivated,
  VoidCallback? onSearchDismissed,
}) => MaterialApp(
  theme: ThemeData(platform: TargetPlatform.iOS),
  home: Directionality(
    textDirection: direction,
    child: CustomScrollView(
      slivers: [
        CupertinoSliverSearchBar<String>(
          title: const Text('Habits'),
          collection: _collection(),
          onInvoke: (_, value) => onInvoke(value),
          actions: CupertinoAppBarActionsConfig(
            iconBuilder: (_, action) => switch (action.id.value) {
              'select' => const Icon(CupertinoIcons.checkmark_alt_circle),
              'filter' => const Icon(CupertinoIcons.line_horizontal_3_decrease),
              _ => null,
            },
          ),
          controller: controller,
          focusNode: focusNode,
          isSearchActive: isSearchActive,
          keyword: controller.text,
          onChanged: (_) {},
          onSearchActivated: onSearchActivated ?? () {},
          onSearchDismissed: onSearchDismissed ?? () {},
        ),
      ],
    ),
  ),
);

void main() {
  testWidgets('renders a typed action collection and invokes nested payloads', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(240, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    String? invoked;

    await tester.pumpWidget(
      _host(
        controller: controller,
        focusNode: focusNode,
        onInvoke: (value) => invoked = value,
      ),
    );

    final host = tester.widget<AdaptiveAppBarActions<String>>(
      find.byType(AdaptiveAppBarActions<String>),
    );
    final filter = host.collection.roots.last;
    expect(filter.id, ActionId('filter'));
    expect(
      (filter.children.single as AdaptiveAction<String>).payload,
      'ongoing',
    );
    host.onInvoke(tester.element(find.byType(CustomScrollView)), 'ongoing');
    expect(invoked, 'ongoing');
  });

  testWidgets('keeps search geometry and RTL overflow behavior', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(240, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      _host(
        controller: controller,
        focusNode: focusNode,
        direction: TextDirection.rtl,
        onInvoke: (_) {},
      ),
    );

    expect(find.byKey(const ValueKey('activate-cupertino-search')), findsOne);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty expanded overflow collapses Search before opening menu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(232, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    var active = false;

    Widget build() => _host(
      controller: controller,
      focusNode: focusNode,
      onInvoke: (_) {},
      isSearchActive: active,
      onSearchActivated: () => active = true,
      onSearchDismissed: () => active = false,
    );
    await tester.pumpWidget(build());
    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpWidget(build());
    await tester.pumpAndSettle();

    expect(active, isTrue);
    final expandedMore = find.byKey(
      const ValueKey('cupertino-search-overflow-expanded'),
    );
    expect(expandedMore, findsOneWidget);
    await tester.tap(expandedMore);
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoPopupSurface), findsNothing);
    expect(find.byType(CupertinoSearchTextField), findsNothing);
    expect(
      find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
      findsOneWidget,
    );
  });

  testWidgets('bottom extends one pinned navigation-bar surface', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: CustomScrollView(
          slivers: [
            CupertinoSliverSearchBar<String>(
              title: const Text('Habits'),
              collection: _collection(),
              onInvoke: (_, _) {},
              controller: controller,
              focusNode: focusNode,
              isSearchActive: false,
              keyword: '',
              onChanged: (_) {},
              onSearchActivated: () {},
              onSearchDismissed: () {},
              bottom: const SizedBox(
                key: ValueKey('search-bottom'),
                height: 48,
              ),
              bottomExtent: 48,
            ),
          ],
        ),
      ),
    );

    final header = tester.widget<SliverPersistentHeader>(
      find.byType(SliverPersistentHeader),
    );
    expect(header.delegate.minExtent, 92);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('search-bottom'))).dy,
      44,
    );
    expect(
      tester
          .widgetList<BackdropFilter>(find.byType(BackdropFilter))
          .where((filter) => filter.enabled),
      hasLength(1),
    );
  });
}

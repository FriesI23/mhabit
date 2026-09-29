import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_focus_halo_clip.dart';

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
  ActionCollection<String>? collection,
  CupertinoActionMenuBuilder<String>? menuBuilderForAction,
  AdaptiveCupertinoFocusThemeData focusTheme =
      const AdaptiveCupertinoFocusThemeData(),
}) => MaterialApp(
  theme: ThemeData(platform: TargetPlatform.iOS, extensions: [focusTheme]),
  home: Directionality(
    textDirection: direction,
    child: CustomScrollView(
      slivers: [
        CupertinoSliverSearchBar<String>(
          title: const Text('Habits'),
          collection: collection ?? _collection(),
          onInvoke: (_, value) => onInvoke(value),
          actions: CupertinoAppBarActionsConfig(
            menuBuilderForAction: menuBuilderForAction,
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
  testWidgets('forwards custom menu content into the Search overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(240, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    final filters = AdaptiveAction<String>.menu(
      id: ActionId('filter'),
      metadata: const ActionMetadata(label: 'Filter'),
      placementPolicy: ActionPlacementPolicy(
        placement: ActionPlacement.overflowOnly,
      ),
    );

    await tester.pumpWidget(
      _host(
        controller: controller,
        focusNode: focusNode,
        onInvoke: (_) {},
        collection: ActionCollection(roots: [filters]),
        menuBuilderForAction: (context, action) => action.id == filters.id
            ? [
                CupertinoMenuItem(
                  requestCloseOnActivate: false,
                  onPressed: () {},
                  child: const Text('Archived'),
                ),
              ]
            : null,
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();

    expect(find.text('Archived'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
        focusTheme: const AdaptiveCupertinoFocusThemeData(haloPaintOutset: 7),
      ),
    );

    expect(find.byKey(const ValueKey('activate-cupertino-search')), findsOne);
    final searchRegion = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('cupertino-expandable-search-region')),
    );
    expect(searchRegion.child, isA<CupertinoButton>());
    final haloClip = tester.widget<ClipRect>(
      find.descendant(
        of: find.byType(CupertinoFocusHaloClip),
        matching: find.byType(ClipRect),
      ),
    );
    final clipSize = tester.getSize(find.byType(CupertinoFocusHaloClip));
    expect(
      haloClip.clipper!.getClip(clipSize),
      Rect.fromLTRB(-7, -7, clipSize.width + 7, clipSize.height + 7),
    );
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

  testWidgets(
    'persistent Search reaches its preferred width after the threshold',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = TextEditingController();
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      final collection = ActionCollection<String>(
        roots: List.generate(
          24,
          (index) => AdaptiveAction<String>.action(
            id: ActionId('action-$index'),
            metadata: ActionMetadata(label: '$index'),
            payload: 'action-$index',
          ),
        ),
      );

      await tester.pumpWidget(
        _host(
          controller: controller,
          focusNode: focusNode,
          onInvoke: (_) {},
          collection: collection,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoSearchTextField), findsOneWidget);
      expect(
        tester
            .getSize(
              find.byKey(const ValueKey('cupertino-expandable-search-region')),
            )
            .width,
        240,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

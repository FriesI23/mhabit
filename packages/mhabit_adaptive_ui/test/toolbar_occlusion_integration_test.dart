import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart'
    show CupertinoSidebar, MaterialSidebar;
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';

import 'harness/adaptive_ui_theme.dart';

const _viewSize = Size(600, 800);
const _safeArea = EdgeInsets.only(right: 96, bottom: 34);

IosOcclusionGeometry _geometry(
  List<Rect> regions, {
  Size viewSize = _viewSize,
}) => IosOcclusionGeometry(
  viewBounds: Offset.zero & viewSize,
  activeOcclusionRegions: regions,
  hasVerticalSystemBar: true,
);

Widget _host({
  required Widget child,
  required IosOcclusionGeometry? geometry,
  TextDirection direction = TextDirection.ltr,
  EdgeInsets safeArea = _safeArea,
}) => MaterialApp(
  theme: ThemeData(platform: TargetPlatform.iOS),
  builder: (context, navigator) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(padding: safeArea, viewPadding: safeArea),
    child: AdaptiveWindowControlLayoutScope(
      horizontalAvoidance: EdgeInsets.zero,
      verticalAvoidance: EdgeInsets.zero,
      owner: WindowControlLayoutOwner.appBar,
      child: AdaptiveOcclusionLayout(
        geometry: geometry,
        systemSafeArea: safeArea,
        cornerRadii: BorderRadius.zero,
        child: OcclusionViewport(
          bounds: Offset.zero & MediaQuery.sizeOf(context),
          child: Directionality(textDirection: direction, child: navigator!),
        ),
      ),
    ),
  ),
  home: child,
);

ActionCollection<String> _actions() => ActionCollection<String>(
  roots: [
    for (var i = 0; i < 3; i++)
      AdaptiveAction<String>.action(
        id: ActionId('action-$i'),
        metadata: ActionMetadata(label: 'Action $i'),
        payload: 'action-$i',
      ),
  ],
);

void main() {
  for (final direction in TextDirection.values) {
    for (final side in ['left', 'right']) {
      for (final columnInset in [48.0, 160.0]) {
        testWidgets(
          'undeclared local toolbar keeps $side Safe Area at $columnInset in $direction',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = _viewSize;
            addTearDown(tester.view.reset);
            const leading = ValueKey('local-leading');
            const action = ValueKey('local-action');
            final leftSide = side == 'left';
            await tester.pumpWidget(
              _host(
                geometry: _geometry(const []),
                direction: direction,
                safeArea: EdgeInsets.only(
                  left: leftSide ? 96 : 0,
                  right: leftSide ? 0 : 96,
                  bottom: 34,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: leftSide ? columnInset : 0,
                    right: leftSide ? 0 : columnInset,
                  ),
                  child: const Scaffold(
                    appBar: WindowControlAppBar(
                      leading: SizedBox.expand(key: leading),
                      title: Text('Local page'),
                      actionsPadding: EdgeInsets.zero,
                      actions: [SizedBox(width: 48, key: action)],
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            final key = leftSide == (direction == TextDirection.ltr)
                ? leading
                : action;
            final rect = tester.getRect(find.byKey(key));
            if (leftSide) {
              expect(rect.left, columnInset + 96);
            } else {
              expect(rect.right, 600 - columnInset - 96);
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  for (final style in AdaptiveStyle.values) {
    for (final direction in TextDirection.values) {
      testWidgets(
        '$style Sidebar toolbar maps each animation frame in $direction',
        (tester) async {
          const viewSize = Size(1000, 800);
          const region = Rect.fromLTWH(920, 0, 80, 72);
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = viewSize;
          addTearDown(tester.view.reset);
          final controller = TextEditingController();
          final focusNode = FocusNode();
          addTearDown(controller.dispose);
          addTearDown(focusNode.dispose);
          await tester.pumpWidget(
            _host(
              geometry: _geometry(const [region], viewSize: viewSize),
              direction: direction,
              child: TestAdaptiveUiTheme(
                update: (theme) => theme.copyWith(style: style),
                child: AdaptiveNavigationShell(
                  selectedIndex: 0,
                  destinations: [
                    for (final label in ['Habits', 'Today', 'Settings'])
                      AdaptiveNavigationDestination(
                        label: label,
                        icons: const NavigationDestinationIcons(
                          material: Icon(Icons.home),
                          materialSelected: Icon(Icons.home),
                          apple: Icon(Icons.home),
                          appleSelected: Icon(Icons.home),
                        ),
                      ),
                  ],
                  onDestinationSelected: (_) {},
                  child: style == AdaptiveStyle.material
                      ? const Scaffold(
                          appBar: WindowControlAppBar(
                            title: Text(
                              'Habits',
                              key: ValueKey('material-sidebar-title'),
                            ),
                            actionsPadding: EdgeInsets.zero,
                            actions: [
                              SizedBox(
                                width: 48,
                                key: ValueKey('material-sidebar-action'),
                              ),
                            ],
                          ),
                        )
                      : Scaffold(
                          body: CustomScrollView(
                            slivers: [
                              CupertinoSliverSearchBar<String>(
                                title: const Text('Habits'),
                                controller: controller,
                                focusNode: focusNode,
                                isSearchActive: false,
                                keyword: '',
                                collection: _actions(),
                                actions: CupertinoAppBarActionsConfig<String>(
                                  actionButtonBuilder:
                                      (
                                        context,
                                        action,
                                        onPressed,
                                        defaultBuilder,
                                      ) => KeyedSubtree(
                                        key: ValueKey(
                                          'sidebar-primary-${action.id.value}',
                                        ),
                                        child: defaultBuilder(
                                          context,
                                          action,
                                          onPressed,
                                        ),
                                      ),
                                ),
                                onInvoke: (_, _) {},
                                onChanged: (_) {},
                                onSearchActivated: () {},
                                onSearchDismissed: () {},
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final sidebarController = style == AdaptiveStyle.apple
              ? tester
                    .widget<CupertinoSidebar>(find.byType(CupertinoSidebar))
                    .controller
              : tester
                    .widget<MaterialSidebar>(find.byType(MaterialSidebar))
                    .controller;
          expect(sidebarController.expanded, isTrue);
          for (final expanded in [false, true]) {
            sidebarController.expanded = expanded;
            for (var frame = 0; frame < 12; frame++) {
              await tester.pump(const Duration(milliseconds: 20));
              expect(tester.takeException(), isNull);
              final row = style == AdaptiveStyle.material
                  ? tester.getRect(
                      find.byKey(
                        ValueKey(
                          direction == TextDirection.ltr
                              ? 'material-sidebar-action'
                              : 'material-sidebar-title',
                        ),
                      ),
                    )
                  : tester
                        .getRect(
                          find.descendant(
                            of: find.byKey(
                              const ValueKey(
                                'cupertino-sidebar-toolbar-start-region',
                              ),
                            ),
                            matching: find.text('Habits'),
                          ),
                        )
                        .expandToInclude(
                          tester.getRect(
                            find.byKey(
                              const ValueKey(
                                'cupertino-expandable-search-region',
                              ),
                            ),
                          ),
                        );
              if (style == AdaptiveStyle.apple) {
                for (var i = 0; i < 3; i++) {
                  final action = find.byKey(
                    ValueKey('sidebar-primary-action-$i'),
                  );
                  if (action.evaluate().isNotEmpty) {
                    expect(
                      tester.getRect(action).right,
                      lessThanOrEqualTo(region.left + .01),
                    );
                  }
                }
              }
              expect(row.right, lessThanOrEqualTo(region.left + 0.01));
            }
            await tester.pumpAndSettle();
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('narrow SliverPadding retains the original toolbar Safe Area', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _viewSize;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(
        geometry: _geometry(const [Rect.fromLTWH(520, 0, 80, 72)]),
        child: const Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(left: 120),
                sliver: WindowControlSliverAppBar(
                  pinned: true,
                  title: Text('Habits'),
                  actionsPadding: EdgeInsets.zero,
                  actions: [
                    SizedBox(width: 48, key: ValueKey('padded-sliver-action')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(const ValueKey('padded-sliver-action'))).right,
      504,
    );
    expect(tester.takeException(), isNull);
  });

  for (final direction in TextDirection.values) {
    testWidgets(
      'Material toolbar consumes physical occlusion once in $direction',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = _viewSize;
        addTearDown(tester.view.reset);
        const leading = ValueKey('occlusion-leading');
        const action = ValueKey('occlusion-action');
        const body = ValueKey('unchanged-body');
        Widget page() => const Scaffold(
          appBar: WindowControlAppBar(
            leading: SizedBox.expand(key: leading),
            title: Text('Habits'),
            actionsPadding: EdgeInsets.zero,
            actions: [SizedBox(width: 48, key: action)],
          ),
          body: SafeArea(child: SizedBox.expand(key: body)),
        );

        await tester.pumpWidget(
          _host(
            geometry: _geometry(const [Rect.fromLTWH(520, 0, 80, 72)]),
            direction: direction,
            child: page(),
          ),
        );
        await tester.pumpAndSettle();
        final rightControl = direction == TextDirection.ltr ? action : leading;
        expect(tester.getRect(find.byKey(rightControl)).right, 504);
        expect(tester.getRect(find.byKey(body)).right, 504);

        // Empty reserved-region geometry does not guarantee that the system
        // status area is absent. Toolbars keep the system's horizontal inset.
        await tester.pumpWidget(
          _host(
            geometry: _geometry(const []),
            direction: direction,
            child: page(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(find.byKey(rightControl)).right, 504);
        expect(tester.getRect(find.byKey(body)).right, 504);
        expect(tester.getRect(find.byKey(body)).bottom, 766);

        await tester.pumpWidget(
          _host(geometry: null, direction: direction, child: page()),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(find.byKey(rightControl)).right, 504);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Cupertino search row shares physical bounds after updates in $direction',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = _viewSize;
        addTearDown(tester.view.reset);
        final controller = TextEditingController(text: 'kept query');
        final focusNode = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focusNode.dispose);
        final collection = _actions();
        Widget page() => Scaffold(
          body: CustomScrollView(
            slivers: [
              CupertinoSliverSearchBar<String>(
                title: const Text('Habits'),
                controller: controller,
                focusNode: focusNode,
                isSearchActive: true,
                keyword: controller.text,
                collection: collection,
                onInvoke: (_, _) {},
                onChanged: (_) {},
                onSearchActivated: () {},
                onSearchDismissed: () {},
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 1800)),
            ],
          ),
        );

        await tester.pumpWidget(
          _host(
            geometry: _geometry(const [Rect.fromLTWH(520, 0, 80, 72)]),
            direction: direction,
            child: page(),
          ),
        );
        await tester.pumpAndSettle();
        focusNode.requestFocus();
        await tester.pump();
        final search = find.byKey(
          const ValueKey('cupertino-expandable-search-region'),
        );
        expect(tester.getRect(search).right, lessThanOrEqualTo(520));
        expect(search.hitTestable(), findsOneWidget);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          _host(
            geometry: _geometry(const [Rect.fromLTWH(0, 0, 80, 72)]),
            direction: direction,
            child: page(),
          ),
        );
        await tester.pumpAndSettle();
        final searchRect = tester.getRect(search);
        expect(searchRect.left, greaterThanOrEqualTo(80));
        expect(searchRect.right, lessThanOrEqualTo(600));
        expect(controller.text, 'kept query');
        expect(focusNode.hasFocus, isTrue);

        // Native invalidation and recovery must not replace the focused field.
        await tester.pumpWidget(
          _host(geometry: null, direction: direction, child: page()),
        );
        await tester.pumpAndSettle();
        expect(focusNode.hasFocus, isTrue);
        await tester.pumpWidget(
          _host(
            geometry: _geometry(const []),
            direction: direction,
            child: page(),
          ),
        );
        await tester.pumpAndSettle();
        expect(controller.text, 'kept query');
        expect(focusNode.hasFocus, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Material search budgets actions inside the adapted sliver', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _viewSize;
    addTearDown(tester.view.reset);
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    var capacity = 0.0;
    Widget page() => Scaffold(
      body: CustomScrollView(
        slivers: [
          MaterialSliverSearchBar(
            title: const Text('Habits'),
            controller: controller,
            focusNode: focusNode,
            isSearchActive: true,
            keyword: '',
            onChanged: (_) {},
            onSearchActivated: () {},
            onSearchDismissed: () {},
            preferredActionCapacity: 240,
            actionsBuilder: (_, available) {
              capacity = available;
              return SizedBox(
                key: const ValueKey('material-occlusion-actions'),
                width: available,
                height: 48,
              );
            },
          ),
        ],
      ),
    );
    await tester.pumpWidget(
      _host(
        geometry: _geometry(const [Rect.fromLTWH(480, 0, 120, 72)]),
        child: page(),
      ),
    );
    await tester.pumpAndSettle();
    final occludedCapacity = capacity;
    expect(
      tester
          .getRect(find.byKey(const ValueKey('material-occlusion-actions')))
          .right,
      lessThanOrEqualTo(480),
    );
    await tester.pumpWidget(
      _host(geometry: _geometry(const []), child: page()),
    );
    await tester.pumpAndSettle();
    expect(capacity, greaterThan(occludedCapacity));
    expect(find.byType(SearchBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fixed Cupertino selection uses its real foreground row', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = _viewSize;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(
        geometry: _geometry(const [Rect.fromLTWH(480, 0, 120, 72)]),
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              CupertinoSliverSelectAppBar<String>(
                title: const Text('Selected 2'),
                selectAllLabel: 'All',
                doneLabel: 'Done',
                onSelectAll: () {},
                onDone: () {},
                collection: _actions(),
                onInvoke: (_, _) {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final done = find.byKey(const ValueKey('cupertino-select-done'));
    expect(tester.getRect(done).right, lessThanOrEqualTo(480));
    expect(done.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

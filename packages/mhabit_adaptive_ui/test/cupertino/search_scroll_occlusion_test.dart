import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../harness/adaptive_ui_theme.dart';

const _size = Size(951, 669);
const _searchAction = ValueKey('real-search-action');
const _searchRegion = ValueKey('cupertino-expandable-search-region');
const _bottom = ValueKey('unchanged-toolbar-bottom');

Widget _host({
  required Widget child,
  required Rect region,
  required TextDirection direction,
}) {
  final padding = EdgeInsets.only(
    left: region.left == 0 ? region.width : 0,
    right: region.right == _size.width ? region.width : 0,
    bottom: 34,
  );
  return MaterialApp(
    theme: ThemeData(platform: TargetPlatform.iOS),
    builder: (context, navigator) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(padding: padding, viewPadding: padding),
      child: AdaptiveWindowControlLayoutScope(
        horizontalAvoidance: EdgeInsets.zero,
        verticalAvoidance: EdgeInsets.zero,
        owner: WindowControlLayoutOwner.appBar,
        child: AdaptiveOcclusionLayout(
          geometry: IosOcclusionGeometry(
            viewBounds: Offset.zero & _size,
            activeOcclusionRegions: [region],
            hasVerticalSystemBar: true,
          ),
          systemSafeArea: padding,
          cornerRadii: BorderRadius.zero,
          child: OcclusionViewport(
            bounds: Offset.zero & MediaQuery.sizeOf(context),
            child: Directionality(textDirection: direction, child: navigator!),
          ),
        ),
      ),
    ),
    home: TestAdaptiveUiTheme(
      update: (theme) => theme.copyWith(style: AdaptiveStyle.apple),
      child: child,
    ),
  );
}

ActionCollection<String> _actions() => ActionCollection<String>(
  roots: [
    for (final id in ['select', 'statistics', 'filter', 'search'])
      AdaptiveAction<String>.action(
        id: ActionId(id),
        metadata: ActionMetadata(label: id),
        payload: id,
      ),
  ],
);

CupertinoAppBarActionsConfig<String> _config() =>
    CupertinoAppBarActionsConfig<String>(
      actionButtonBuilder: (context, action, onPressed, defaultBuilder) =>
          KeyedSubtree(
            key: action.id.value == 'search'
                ? _searchAction
                : ValueKey(action.id.value),
            child: defaultBuilder(context, action, onPressed),
          ),
    );

void _expectOutside(WidgetTester tester, Key key, Rect region, int frame) {
  final finder = find.byKey(key);
  final rect = tester.getRect(finder);
  expect(rect.overlaps(region), isFalse, reason: 'frame $frame: $rect');
  expect(finder.hitTestable(), findsOneWidget);
  expect(tester.takeException(), isNull);
}

void main() {
  for (final direction in TextDirection.values) {
    for (final side in ['left', 'right']) {
      final region = Rect.fromLTWH(side == 'left' ? 0 : 867, 0, 84, 124);

      testWidgets(
        'production view action stays safe when its header pins at $side in $direction',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = _size;
          addTearDown(tester.view.reset);
          final scroll = ScrollController();
          addTearDown(scroll.dispose);
          await tester.pumpWidget(
            _host(
              region: region,
              direction: direction,
              child: Scaffold(
                body: CustomScrollView(
                  controller: scroll,
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 180)),
                    MultiSliver(
                      children: [
                        SliverAnimatedSwitcher(
                          duration: Duration.zero,
                          child: CupertinoSliverSelectAppBar<String>.view(
                            title: const Text('Table Habit'),
                            collection: _actions(),
                            onInvoke: (_, _) {},
                            actions: _config(),
                          ),
                        ),
                        const PinnedHeaderSliver(child: SizedBox(height: 50)),
                      ],
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 3000)),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (var frame = 0; frame < 40; frame++) {
            scroll.jumpTo(frame * 12);
            await tester.pump(const Duration(milliseconds: 16));
            _expectOutside(tester, _searchAction, region, frame);
          }
        },
      );

      testWidgets(
        'search field stays safe while pinning at $side in $direction',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = _size;
          addTearDown(tester.view.reset);
          final controller = TextEditingController();
          final focus = FocusNode();
          final scroll = ScrollController();
          addTearDown(controller.dispose);
          addTearDown(focus.dispose);
          addTearDown(scroll.dispose);
          late EdgeInsets bottomPadding;
          await tester.pumpWidget(
            _host(
              region: region,
              direction: direction,
              child: Scaffold(
                body: CustomScrollView(
                  controller: scroll,
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 180)),
                    MultiSliver(
                      children: [
                        SliverAnimatedSwitcher(
                          duration: Duration.zero,
                          child: CupertinoSliverSearchBar<String>(
                            title: const Text('Table Habit'),
                            controller: controller,
                            focusNode: focus,
                            isSearchActive: false,
                            keyword: '',
                            collection: _actions(),
                            onInvoke: (_, _) {},
                            onChanged: (_) {},
                            onSearchActivated: () {},
                            onSearchDismissed: () {},
                            bottom: Builder(
                              builder: (context) {
                                bottomPadding = MediaQuery.paddingOf(context);
                                return const SizedBox(key: _bottom);
                              },
                            ),
                            bottomExtent: 50,
                          ),
                        ),
                      ],
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 3000)),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final initialBottomPadding = bottomPadding;
          expect(initialBottomPadding.left, side == 'left' ? 84 : 0);
          expect(initialBottomPadding.right, side == 'right' ? 84 : 0);
          expect(initialBottomPadding.bottom, 34);
          for (var frame = 0; frame < 40; frame++) {
            scroll.jumpTo(frame * 12);
            await tester.pump(const Duration(milliseconds: 16));
            _expectOutside(tester, _searchRegion, region, frame);
            expect(bottomPadding, initialBottomPadding);
          }
          await tester.tap(find.byKey(_searchRegion));
          await tester.pumpAndSettle();
          controller.text = 'kept query';
          await tester.pump();
          expect(focus.hasFocus, isTrue);
          _expectOutside(tester, _searchRegion, region, 40);
          scroll.jumpTo(190);
          await tester.pump();
          _expectOutside(tester, _searchRegion, region, 41);
          expect(focus.hasFocus, isTrue);
          expect(controller.text, 'kept query');
        },
      );

      testWidgets(
        'unknown Column mapping retains search safe area at $side in $direction',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = _size;
          addTearDown(tester.view.reset);
          final controller = TextEditingController();
          final focus = FocusNode();
          addTearDown(controller.dispose);
          addTearDown(focus.dispose);
          await tester.pumpWidget(
            _host(
              region: region,
              direction: direction,
              child: Scaffold(
                body: Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          CupertinoSliverSearchBar<String>(
                            title: const Text('Table Habit'),
                            controller: controller,
                            focusNode: focus,
                            isSearchActive: false,
                            keyword: '',
                            collection: _actions(),
                            onInvoke: (_, _) {},
                            onChanged: (_) {},
                            onSearchActivated: () {},
                            onSearchDismissed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          _expectOutside(tester, _searchRegion, region, 0);
        },
      );
    }
  }
}

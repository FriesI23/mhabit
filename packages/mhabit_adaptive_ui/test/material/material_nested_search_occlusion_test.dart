import 'package:adaptive_actions/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';

import '../harness/adaptive_ui_theme.dart';

const _size = Size(951, 669);
const _safeArea = EdgeInsets.only(right: 84, top: 16, bottom: 34);

ActionCollection<String> _actions() => ActionCollection<String>(
  roots: [
    for (final id in ['select', 'statistics', 'filter', 'more'])
      AdaptiveAction<String>.action(
        id: ActionId(id),
        metadata: ActionMetadata(label: id),
        payload: id,
      ),
  ],
);

void main() {
  for (final direction in TextDirection.values) {
    testWidgets(
      'Material search stays safe after switching theme under an ancestor Settings route in $direction',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = _size;
        addTearDown(tester.view.reset);
        final flow = GlobalKey<NavigatorState>();
        final branch = GlobalKey<NavigatorState>();
        final controller = TextEditingController();
        final focus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        var style = AdaptiveStyle.apple;
        late StateSetter changeStyle;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            builder: (context, navigator) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(padding: _safeArea, viewPadding: _safeArea),
              child: AdaptiveWindowControlLayoutScope(
                horizontalAvoidance: EdgeInsets.zero,
                verticalAvoidance: EdgeInsets.zero,
                owner: WindowControlLayoutOwner.appBar,
                child: AdaptiveOcclusionLayout(
                  geometry: IosOcclusionGeometry(
                    viewBounds: Offset.zero & _size,
                    activeOcclusionRegions: const [],
                    hasVerticalSystemBar: true,
                  ),
                  systemSafeArea: _safeArea,
                  cornerRadii: BorderRadius.zero,
                  child: OcclusionViewport(
                    bounds: Offset.zero & MediaQuery.sizeOf(context),
                    child: Directionality(
                      textDirection: direction,
                      child: navigator!,
                    ),
                  ),
                ),
              ),
            ),
            home: StatefulBuilder(
              builder: (context, setState) {
                changeStyle = setState;
                return TestAdaptiveUiTheme(
                  update: (theme) => theme.copyWith(style: style),
                  child: AdaptiveNavigationShell(
                    selectedIndex: 0,
                    appleSidebarStyle: AppleSidebarStyle.edge,
                    destinations: const [
                      AdaptiveNavigationDestination(
                        label: 'Habits',
                        icons: NavigationDestinationIcons(
                          material: Icon(Icons.home),
                          materialSelected: Icon(Icons.home),
                          apple: Icon(Icons.home),
                          appleSelected: Icon(Icons.home),
                        ),
                      ),
                      AdaptiveNavigationDestination(
                        label: 'Today',
                        icons: NavigationDestinationIcons(
                          material: Icon(Icons.today),
                          materialSelected: Icon(Icons.today),
                          apple: Icon(Icons.today),
                          appleSelected: Icon(Icons.today),
                        ),
                      ),
                    ],
                    onDestinationSelected: (_) {},
                    child: Navigator(
                      key: flow,
                      onGenerateRoute: (_) => MaterialPageRoute<void>(
                        builder: (_) => Navigator(
                          key: branch,
                          onGenerateRoute: (_) => MaterialPageRoute<void>(
                            builder: (_) => Scaffold(
                              body: CustomScrollView(
                                slivers: [
                                  AdaptiveSliverSearchBar<String>(
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
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 3000),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        flow.currentState!.push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Settings')),
          ),
        );
        await tester.pumpAndSettle();
        changeStyle(() => style = AdaptiveStyle.material);
        await tester.pumpAndSettle();
        expect(find.text('Settings'), findsOneWidget);
        flow.currentState!.pop();
        await tester.pumpAndSettle();
        final actions = find.byType(AdaptiveAppBarActions<String>);
        expect(actions, findsOneWidget);
        final rect = tester.getRect(actions);
        expect(rect.right, lessThanOrEqualTo(867));
        expect(actions.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byType(SearchBar));
        await tester.pumpAndSettle();
        controller.text = 'kept query';
        await tester.pump();
        expect(focus.hasFocus, isTrue);
        // A later ordinary Settings round trip must restore the same row and
        // field without relying on any scrolling or native geometry update.
        flow.currentState!.push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Settings')),
          ),
        );
        await tester.pumpAndSettle();
        flow.currentState!.pop();
        await tester.pumpAndSettle();
        expect(tester.getRect(actions).right, lessThanOrEqualTo(867));
        expect(controller.text, 'kept query');
        expect(focus.hasFocus, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

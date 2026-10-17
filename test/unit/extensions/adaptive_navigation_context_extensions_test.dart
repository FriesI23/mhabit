import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/extensions/adaptive_navigation_context_extensions.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

class _PresentationProbe extends StatelessWidget {
  const _PresentationProbe();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('root back: ${context.showsAppFlowRootBackButton}'),
      Text('collapsed: ${context.hasCollapsedAppleSidebar}'),
      Text('expanded: ${context.hasExpandedAppleSidebar}'),
      Text('app bar actions: ${context.showsAppleAuxiliaryActionsInAppBar}'),
    ],
  );
}

void main() {
  for (final collapsedBarEnabled in [false, true]) {
    testWidgets(
      'Apple presentation updates branch actions with collapsed bar $collapsedBarEnabled',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 600);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: AdaptiveNavigationShell(
              selectedIndex: 0,
              destinations: const [
                AdaptiveNavigationDestination(
                  label: 'Habits',
                  icons: NavigationDestinationIcons.union(Icon(Icons.home)),
                ),
              ],
              onDestinationSelected: (_) {},
              appleCollapsedSidebarEnabled: collapsedBarEnabled,
              child: const AdaptiveScaffold(
                appBar: AdaptiveAppBar(
                  title: Text('Sidebar presentation'),
                  toolbarHeight: kToolbarHeight,
                ),
                body: _PresentationProbe(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final branch = tester.element(find.byType(_PresentationProbe));

        void expectPresentation({required bool expanded}) {
          expect(
            find.text('root back: ${!expanded && !collapsedBarEnabled}'),
            findsOneWidget,
          );
          expect(find.text('collapsed: ${!expanded}'), findsOneWidget);
          expect(find.text('expanded: $expanded'), findsOneWidget);
          expect(find.text('app bar actions: ${!expanded}'), findsOneWidget);
          expect(tester.element(find.byType(_PresentationProbe)), same(branch));
        }

        expectPresentation(expanded: true);
        final toggle = find.byKey(const ValueKey('cupertino-sidebar-toggle'));
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expectPresentation(expanded: false);

        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expectPresentation(expanded: true);
      },
    );
  }
}

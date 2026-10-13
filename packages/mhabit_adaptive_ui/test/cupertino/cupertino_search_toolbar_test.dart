import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show MaterialApp, Scaffold, ThemeData;
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart'
    show CupertinoSidebar;
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_search_toolbar.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets(
      'fullscreen-sized search survives windowed Sidebar collapse in $direction',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1200, 800);
        addTearDown(tester.view.reset);
        final controller = TextEditingController();
        final focusNode = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focusNode.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: AdaptiveStyleScope(
              override: AdaptiveStyle.apple,
              child: Directionality(
                textDirection: direction,
                child: AdaptiveNavigationShell(
                  selectedIndex: 0,
                  destinations: [
                    for (final label in ['Habits', 'Today', 'Settings'])
                      AdaptiveNavigationDestination(
                        label: label,
                        icons: const NavigationDestinationIcons(
                          material: Icon(CupertinoIcons.home),
                          materialSelected: Icon(CupertinoIcons.home),
                          apple: Icon(CupertinoIcons.home),
                          appleSelected: Icon(CupertinoIcons.home),
                        ),
                      ),
                  ],
                  onDestinationSelected: (_) {},
                  child: Scaffold(
                    body: CustomScrollView(
                      slivers: [
                        CupertinoSliverSearchBar<String>(
                          title: const Text('Habits'),
                          collection: ActionCollection<String>(
                            roots: [
                              for (var i = 0; i < 2; i++)
                                AdaptiveAction<String>.action(
                                  id: ActionId('action-$i'),
                                  metadata: ActionMetadata(label: 'Action $i'),
                                  payload: 'action-$i',
                                ),
                            ],
                          ),
                          onInvoke: (_, _) {},
                          controller: controller,
                          focusNode: focusNode,
                          isSearchActive: false,
                          keyword: '',
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
          ),
        );
        await tester.pumpAndSettle();
        final sidebar = find.byType(CupertinoSidebar);
        expect(
          tester.widget<CupertinoSidebar>(sidebar).controller.expanded,
          true,
        );
        expect(find.byType(CupertinoSearchTextField), findsOneWidget);
        final search = find.byKey(
          const ValueKey('cupertino-expandable-search-region'),
        );
        expect(tester.getSize(search).width, 240);

        // Returning to a medium window collapses the Sidebar and Search
        // together while the collapsed navigation capsule takes toolbar space.
        tester.view.physicalSize = const Size(700, 600);
        await tester.pump();
        expect(
          tester.widget<CupertinoSidebar>(sidebar).controller.expanded,
          false,
        );
        for (var frame = 0; frame < 8; frame++) {
          expect(tester.takeException(), isNull);
          final end = tester.getRect(
            find.byKey(const ValueKey('cupertino-sidebar-toolbar-end-region')),
          );
          final searchRect = tester.getRect(search);
          expect(searchRect.left, greaterThanOrEqualTo(end.left));
          expect(searchRect.right, lessThanOrEqualTo(end.right));
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pumpAndSettle();
        expect(tester.getSize(search).width, 44);
        expect(
          find
              .byKey(const ValueKey('cupertino-sidebar-collapsed-capsule'))
              .hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
      variant: const TargetPlatformVariant({TargetPlatform.macOS}),
    );

    testWidgets('search animation fits shrinking toolbar in $direction', (
      tester,
    ) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      var width = 500.0;
      var persistent = true;
      late StateSetter update;
      final collection = ActionCollection<String>(
        roots: [
          for (var i = 0; i < 2; i++)
            AdaptiveAction<String>.action(
              id: ActionId('action-$i'),
              metadata: ActionMetadata(label: 'Action $i'),
              payload: 'action-$i',
            ),
        ],
      );
      await tester.pumpWidget(
        CupertinoApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Directionality(
                textDirection: direction,
                child: Center(
                  child: SizedBox(
                    key: const ValueKey('toolbar'),
                    width: width,
                    height: 44,
                    child: CupertinoSearchToolbar<String>(
                      title: const Text('Habits'),
                      showTitle: true,
                      centerTitle: false,
                      preferPersistentSearch: persistent,
                      sidebarLeading: null,
                      leading: null,
                      collection: collection,
                      onInvoke: (_, _) {},
                      iconBuilder: (_, _) => const Icon(CupertinoIcons.add),
                      actionButtonBuilder: null,
                      menuBuilderForAction: null,
                      presentationForAction: null,
                      manuallyExpanded: false,
                      controller: controller,
                      focusNode: focusNode,
                      maxSearchWidth: 240,
                      onChanged: (_) {},
                      onSearchActivated: () {},
                      onOverflowPressed: (_, openMenu) => openMenu(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      final search = find.byKey(
        const ValueKey('cupertino-expandable-search-region'),
      );
      expect(tester.getSize(search).width, 240);

      // A semantic collapse starts at the previous animated width. The new
      // layout budget must apply immediately, including intermediate frames.
      update(() {
        width = 215;
        persistent = false;
      });
      await tester.pump();
      for (var frame = 0; frame < 7; frame++) {
        expect(tester.takeException(), isNull);
        final toolbarRect = tester.getRect(
          find.byKey(const ValueKey('toolbar')),
        );
        final searchRect = tester.getRect(search);
        expect(searchRect.left, greaterThanOrEqualTo(toolbarRect.left));
        expect(searchRect.right, lessThanOrEqualTo(toolbarRect.right));
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(tester.getSize(search).width, 44);
      expect(
        find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      // Roomy toolbars retain the existing smooth collapse.
      update(() {
        width = 500;
        persistent = true;
      });
      await tester.pumpAndSettle();
      update(() => persistent = false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getSize(search).width, greaterThan(44));
      expect(tester.getSize(search).width, lessThan(240));
      await tester.pumpAndSettle();
      expect(tester.getSize(search).width, 44);
      expect(tester.takeException(), isNull);
    });
  }
}

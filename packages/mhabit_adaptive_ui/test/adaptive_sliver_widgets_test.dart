import 'package:flutter/cupertino.dart'
    show CupertinoNavigationBar, CupertinoSliverNavigationBar;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  group('AdaptiveStyle.of', () {
    testWidgets('maps iOS to apple', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) {
              expect(AdaptiveStyle.of(context), AdaptiveStyle.apple);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('maps Android to material', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Builder(
            builder: (context) {
              expect(AdaptiveStyle.of(context), AdaptiveStyle.material);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });

  group('AdaptiveSliverAppBar', () {
    testWidgets('renders a SliverAppBar via default dispatch', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [AdaptiveSliverAppBar(title: Text('title'))],
            ),
          ),
        ),
      );
      expect(find.byType(SliverAppBar), findsOneWidget);
    });

    testWidgets('.material renders a SliverAppBar on Apple platform', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const Scaffold(
            body: CustomScrollView(
              slivers: [AdaptiveSliverAppBar.material(title: Text('title'))],
            ),
          ),
        ),
      );
      expect(find.byType(SliverAppBar), findsOneWidget);
    });

    testWidgets('apple medium landscape keeps a centered middle title', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const Scaffold(
            body: CustomScrollView(
              slivers: [AdaptiveSliverAppBar(title: Text('title'))],
            ),
          ),
        ),
      );
      expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
      expect(find.byType(SliverAppBar), findsNothing);
      final bar = tester.widget<CupertinoSliverNavigationBar>(
        find.byType(CupertinoSliverNavigationBar),
      );
      expect(bar.middle, isNotNull);
      expect(bar.largeTitle, isNull);
    });

    testWidgets(
      'apple bar renders in portrait without the large-title assert',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const Scaffold(
              body: CustomScrollView(
                slivers: [AdaptiveSliverAppBar(title: Text('title'))],
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
        final bar = tester.widget<CupertinoSliverNavigationBar>(
          find.byType(CupertinoSliverNavigationBar),
        );
        expect(bar.largeTitle, isNotNull);
        expect(bar.middle, isNull);
      },
    );

    testWidgets('compact landscape keeps the collapsing large title', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(500, 300);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const Scaffold(
            body: CustomScrollView(
              slivers: [AdaptiveSliverAppBar(title: Text('title'))],
            ),
          ),
        ),
      );
      final bar = tester.widget<CupertinoSliverNavigationBar>(
        find.byType(CupertinoSliverNavigationBar),
      );
      expect(bar.largeTitle, isNotNull);
      expect(bar.middle, isNull);
    });

    testWidgets('wide landscape uses the centered middle title', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const Scaffold(
            body: CustomScrollView(
              slivers: [AdaptiveSliverAppBar(title: Text('title'))],
            ),
          ),
        ),
      );
      final bar = tester.widget<CupertinoSliverNavigationBar>(
        find.byType(CupertinoSliverNavigationBar),
      );
      expect(bar.middle, isNotNull);
      expect(bar.largeTitle, isNull);
    });

    testWidgets('title mode follows the breakpoint scope chain', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const Scaffold(
            body: CustomScrollView(
              slivers: [
                BreakpointsScope(
                  breakpoints: CustomBreakpoints(width: [1200]),
                  child: AdaptiveSliverAppBar(title: Text('title')),
                ),
              ],
            ),
          ),
        ),
      );
      // 1000 < 1200 classifies as compact under the scoped breakpoints, so
      // the title follows the override and keeps the large title.
      final bar = tester.widget<CupertinoSliverNavigationBar>(
        find.byType(CupertinoSliverNavigationBar),
      );
      expect(bar.largeTitle, isNotNull);
      expect(bar.middle, isNull);
    });

    testWidgets('.apple forces the Cupertino bar on Material platforms', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [AdaptiveSliverAppBar.apple(title: Text('title'))],
            ),
          ),
        ),
      );
      expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
    });

    testWidgets('apple fixed height uses the standalone toolbar renderer', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                AdaptiveSliverAppBar.apple(
                  title: Text('title'),
                  height: 52,
                  actions: [Icon(Icons.settings)],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
      expect(find.text('title'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('apple collapsible config takes precedence over fixed height', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                AdaptiveSliverAppBar.apple(
                  title: Text('title'),
                  height: 52,
                  styles: AppBarStyles(
                    apple: AppBarAppleStyle(collapsible: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsNothing);
    });

    testWidgets('apple fixed toolbar adds window-control avoidance', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveWindowControlLayoutScope(
            horizontalAvoidance: EdgeInsetsDirectional.only(start: 40, end: 12),
            verticalAvoidance: EdgeInsetsDirectional.zero,
            owner: WindowControlLayoutOwner.appBar,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  AdaptiveSliverAppBar.apple(title: Text('title'), height: 52),
                ],
              ),
            ),
          ),
        ),
      );

      final toolbar = tester
          .widgetList<NavigationToolbar>(find.byType(NavigationToolbar))
          .singleWhere((widget) => widget.leading is Padding);
      expect(
        (toolbar.leading! as Padding).padding,
        const EdgeInsetsDirectional.only(start: 56),
      );
      expect(
        (toolbar.trailing! as Padding).padding,
        const EdgeInsetsDirectional.only(end: 28),
      );
    });

    testWidgets('apple collapsible toolbar adds window-control avoidance', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveWindowControlLayoutScope(
            horizontalAvoidance: EdgeInsetsDirectional.only(start: 40, end: 12),
            verticalAvoidance: EdgeInsetsDirectional.zero,
            owner: WindowControlLayoutOwner.appBar,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [AdaptiveSliverAppBar.apple(title: Text('title'))],
              ),
            ),
          ),
        ),
      );

      final appBar = tester.widget<CupertinoSliverNavigationBar>(
        find.byType(CupertinoSliverNavigationBar),
      );
      expect(
        appBar.padding,
        const EdgeInsetsDirectional.only(start: 56, end: 28),
      );
    });

    testWidgets('material knobs pass through to the SliverAppBar', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                AdaptiveSliverAppBar.material(
                  title: Text('title'),
                  styles: AppBarStyles(
                    material: AppBarMaterialStyle(
                      floating: false,
                      snap: false,
                      pinned: false,
                      centerTitle: false,
                      forceElevated: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(appBar.floating, isFalse);
      expect(appBar.snap, isFalse);
      expect(appBar.pinned, isFalse);
      expect(appBar.centerTitle, isFalse);
      expect(appBar.forceElevated, isTrue);
    });

    testWidgets('material config defaults fill in for partial overrides', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                AdaptiveSliverAppBar.material(
                  title: Text('title'),
                  styles: AppBarStyles(
                    material: AppBarMaterialStyle(pinned: false),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(appBar.pinned, isFalse);
      expect(appBar.floating, isTrue);
      expect(appBar.snap, isTrue);
      expect(appBar.centerTitle, isTrue);
    });

    testWidgets('apple config passes through to the Cupertino bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                AdaptiveSliverAppBar.apple(
                  title: Text('title'),
                  styles: AppBarStyles(
                    apple: AppBarAppleStyle(
                      enableBackgroundFilterBlur: false,
                      stretch: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final bar = tester.widget<CupertinoSliverNavigationBar>(
        find.byType(CupertinoSliverNavigationBar),
      );
      expect(bar.enableBackgroundFilterBlur, isFalse);
      expect(bar.stretch, isTrue);
    });

    testWidgets('platform configs override their visual edge padding', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveWindowControlLayoutScope(
            horizontalAvoidance: EdgeInsetsDirectional.only(start: 10),
            verticalAvoidance: EdgeInsetsDirectional.zero,
            owner: WindowControlLayoutOwner.appBar,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  AdaptiveSliverAppBar.material(
                    title: Text('title'),
                    leading: SizedBox.expand(key: ValueKey('leading')),
                    styles: AppBarStyles(
                      material: AppBarMaterialStyle(
                        windowControlEdgePadding: EdgeInsetsDirectional.only(
                          start: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(tester.getTopLeft(find.byKey(const ValueKey('leading'))).dx, 13);

      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveWindowControlLayoutScope(
            horizontalAvoidance: EdgeInsetsDirectional.only(start: 10),
            verticalAvoidance: EdgeInsetsDirectional.zero,
            owner: WindowControlLayoutOwner.appBar,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  AdaptiveSliverAppBar.apple(
                    title: Text('title'),
                    height: 52,
                    styles: AppBarStyles(
                      apple: AppBarAppleStyle(
                        windowControlEdgePadding: EdgeInsetsDirectional.only(
                          start: 5,
                          end: 7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      final toolbar = tester
          .widgetList<NavigationToolbar>(find.byType(NavigationToolbar))
          .singleWhere((widget) => widget.leading is Padding);
      expect(
        (toolbar.leading! as Padding).padding,
        const EdgeInsetsDirectional.only(start: 15),
      );
      expect(
        (toolbar.trailing! as Padding).padding,
        const EdgeInsetsDirectional.only(end: 7),
      );
    });

    testWidgets('forced style ignores the other style config', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                AdaptiveSliverAppBar.material(
                  title: Text('title'),
                  styles: AppBarStyles(apple: AppBarAppleStyle(stretch: true)),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
    });
  });

  group('AppBar style configs', () {
    test('AppBarMaterialStyle.copyWith overrides only the given fields', () {
      const original = AppBarMaterialStyle();
      final updated = original.copyWith(floating: false, pinned: false);
      expect(updated.floating, isFalse);
      expect(updated.pinned, isFalse);
      expect(updated.snap, original.snap);
      expect(updated.centerTitle, original.centerTitle);
      expect(updated.forceElevated, original.forceElevated);
      expect(
        updated.windowControlEdgePadding,
        original.windowControlEdgePadding,
      );
    });

    test('AppBarMaterialStyle equality follows the fields', () {
      const a = AppBarMaterialStyle(floating: false);
      const b = AppBarMaterialStyle(floating: false);
      const c = AppBarMaterialStyle();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('AppBarAppleStyle.copyWith overrides only the given fields', () {
      const original = AppBarAppleStyle();
      final updated = original.copyWith(
        collapsible: true,
        enableBackgroundFilterBlur: false,
      );
      expect(updated.collapsible, isTrue);
      expect(updated.enableBackgroundFilterBlur, isFalse);
      expect(updated.stretch, original.stretch);
      expect(updated.border, original.border);
      expect(
        updated.windowControlEdgePadding,
        original.windowControlEdgePadding,
      );
    });

    test('AppBarStyles.copyWith keeps the other style config', () {
      const material = AppBarMaterialStyle(pinned: false);
      const styles = AppBarStyles(material: material);
      final updated = styles.copyWith(
        apple: const AppBarAppleStyle(stretch: true),
      );
      expect(updated.material, same(material));
      expect(updated.apple, isNotNull);
    });
  });

  group('AdaptiveSliverSearchBar', () {
    testWidgets('renders a sliver search app bar', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                AdaptiveSliverSearchBar(
                  title: const Text('title'),
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
      );
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byType(SearchBar), findsOneWidget);
    });
  });
}

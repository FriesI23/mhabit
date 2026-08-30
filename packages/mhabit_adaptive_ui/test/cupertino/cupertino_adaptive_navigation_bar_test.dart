import 'dart:ui' show Tristate;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart' show FloatingActionButton, Icons, Theme;
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_adaptive_navigation_bar.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_navigation_primary_action.dart';

const _destinations = [
  AdaptiveNavigationDestination(
    label: 'Habits',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.home_outlined),
      materialSelected: Icon(Icons.home),
      apple: Icon(CupertinoIcons.house, key: ValueKey('habits-apple')),
      appleSelected: Icon(
        CupertinoIcons.house_fill,
        key: ValueKey('habits-apple-selected'),
      ),
    ),
  ),
  AdaptiveNavigationDestination(
    label: 'Today',
    semanticsLabel: 'Today tab',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.today_outlined),
      materialSelected: Icon(Icons.today),
      apple: Icon(CupertinoIcons.today, key: ValueKey('today-apple')),
      appleSelected: Icon(
        CupertinoIcons.today_fill,
        key: ValueKey('today-apple-selected'),
      ),
    ),
  ),
  AdaptiveNavigationDestination(
    label: 'Settings',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.settings_outlined),
      materialSelected: Icon(Icons.settings),
      apple: Icon(CupertinoIcons.settings, key: ValueKey('settings-apple')),
      appleSelected: Icon(
        CupertinoIcons.settings_solid,
        key: ValueKey('settings-apple-selected'),
      ),
    ),
  ),
];

const _testPrimaryAction = CupertinoNavigationPrimaryAction(
  id: 'test-primary-action',
  label: 'Primary action',
  icon: Icon(CupertinoIcons.add, key: ValueKey('test-primary-action-icon')),
  onPressed: null,
);

Widget _wrap({
  required AdaptiveNavigationBarPresentation presentation,
  required ValueChanged<int> onDestinationSelected,
  required VoidCallback onExpandRequested,
  int selectedIndex = 1,
  TextDirection textDirection = TextDirection.ltr,
  bool disableAnimations = false,
  EdgeInsets viewPadding = EdgeInsets.zero,
  BorderRadius? displayCornerRadii,
  EdgeInsetsDirectional? horizontalSafeAreaAvoidance,
  EdgeInsetsDirectional? verticalSafeAreaAvoidance,
  BorderRadius? effectiveCornerRadii,
  bool usesRectangularDisplay = false,
  AppleNavigationBarStyle appleStyle = const AppleNavigationBarStyle(),
  CupertinoThemeData? theme,
  CupertinoNavigationPrimaryAction? primaryAction = _testPrimaryAction,
}) {
  return CupertinoApp(
    theme: theme,
    home: MediaQuery(
      data: MediaQueryData(
        disableAnimations: disableAnimations,
        viewPadding: viewPadding,
        displayCornerRadii: displayCornerRadii,
      ),
      child: AdaptiveWindowControlLayoutScope(
        horizontalAvoidance: EdgeInsetsDirectional.zero,
        verticalAvoidance: EdgeInsetsDirectional.zero,
        horizontalSafeAreaAvoidance: horizontalSafeAreaAvoidance,
        verticalSafeAreaAvoidance: verticalSafeAreaAvoidance,
        effectiveCornerRadii: effectiveCornerRadii,
        usesRectangularDisplay: usesRectangularDisplay,
        owner: WindowControlLayoutOwner.appBar,
        child: Directionality(
          textDirection: textDirection,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: CupertinoAdaptiveNavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              onExpandRequested: onExpandRequested,
              destinations: _destinations,
              presentation: presentation,
              primaryAction: primaryAction,
              expandedNavigationWidth: appleStyle.expandedNavigationWidth,
              floatingBottomMargin: appleStyle.floatingBottomMargin,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('CupertinoAdaptiveNavigationBar', () {
    testWidgets('renders and activates the independent primary action', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);
      var pressed = 0;
      final action = CupertinoNavigationPrimaryAction(
        id: 'new-habit',
        label: 'New Habit',
        icon: const Icon(CupertinoIcons.add),
        onPressed: () => pressed += 1,
      );

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          primaryAction: action,
        ),
      );

      final button = find.byType(CupertinoNavigationPrimaryActionButton);
      expect(button, findsOneWidget);
      final fab = find.descendant(
        of: button,
        matching: find.byType(FloatingActionButton),
      );
      expect(fab, findsOneWidget);
      expect(tester.widget<FloatingActionButton>(fab).heroTag, action.id);
      expect(
        find.descendant(of: fab, matching: find.byType(Hero)),
        findsOneWidget,
      );
      expect(tester.getSize(button), const Size.square(50));
      final actionSurface = find.descendant(
        of: button,
        matching: find.byKey(
          const ValueKey('cupertino-primary-action-surface'),
        ),
      );
      expect(actionSurface, findsOneWidget);
      expect(
        find.descendant(
          of: actionSurface,
          matching: find.byType(BackdropFilter),
        ),
        findsOneWidget,
      );
      final actionBackground = tester.widget<ColoredBox>(
        find.descendant(of: actionSurface, matching: find.byType(ColoredBox)),
      );
      final colorScheme = Theme.of(tester.element(button)).colorScheme;
      expect(
        actionBackground.color,
        colorScheme.primaryContainer.withValues(alpha: 0.82),
      );
      expect(
        IconTheme.of(
          tester.element(
            find.descendant(
              of: button,
              matching: find.byIcon(CupertinoIcons.add),
            ),
          ),
        ).size,
        22,
      );
      expect(find.bySemanticsLabel('New Habit'), findsOneWidget);
      await tester.tap(button);
      expect(pressed, 1);

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.minimized,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          primaryAction: action,
          disableAnimations: true,
        ),
      );
      expect(tester.getSize(button), const Size.square(44));
      await tester.tap(button);
      expect(pressed, 2);
    });

    testWidgets('uses the FAB default Hero identity when id is omitted', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);
      const action = CupertinoNavigationPrimaryAction(
        label: 'Default identity action',
        icon: Icon(CupertinoIcons.add),
        onPressed: null,
      );

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          primaryAction: action,
        ),
      );

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      expect(tester.widget<FloatingActionButton>(fab).heroTag, isNotNull);
      expect(
        tester.widget<FloatingActionButton>(fab).heroTag,
        isNot(action.id),
      );
      expect(
        find.descendant(of: fab, matching: find.byType(Hero)),
        findsOneWidget,
      );
    });

    testWidgets('disables Hero identity for an explicit null id', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);
      const action = CupertinoNavigationPrimaryAction(
        id: null,
        label: 'No Hero action',
        icon: Icon(CupertinoIcons.add),
        onPressed: null,
      );

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          primaryAction: action,
        ),
      );

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      expect(tester.widget<FloatingActionButton>(fab).heroTag, isNull);
      expect(
        find.descendant(of: fab, matching: find.byType(Hero)),
        findsNothing,
      );
    });

    testWidgets('renders every Apple destination in the expanded surface', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      final selected = <int>[];
      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: selected.add,
          onExpandRequested: () {},
        ),
      );

      expect(
        tester.getSize(
          find.byKey(const ValueKey('cupertino-adaptive-navigation-bar')),
        ),
        const Size(400, 58),
      );
      expect(
        tester.getSize(
          find.byKey(const ValueKey('cupertino-navigation-surface')),
        ),
        const Size(318, 50),
      );
      expect(
        tester.getSize(
          find.byKey(const ValueKey('cupertino-primary-action-slot')),
        ),
        const Size.square(50),
      );
      expect(find.text('Habits'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('today-apple-selected')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('today-apple')), findsNothing);
      expect(
        tester
                .getBottomLeft(
                  find.byKey(const ValueKey('cupertino-navigation-surface')),
                )
                .dy -
            tester.getBottomLeft(find.text('Today')).dy,
        3,
      );

      await tester.tap(find.text('Settings'));
      expect(selected, [2]);
    });

    testWidgets('keeps selected and unselected foregrounds opaque', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          theme: const CupertinoThemeData(primaryColor: Color(0x80336699)),
        ),
      );

      final selectedIcon = find.byKey(const ValueKey('today-apple-selected'));
      final unselectedIcon = find.byKey(const ValueKey('habits-apple'));
      final selectedIconColor = IconTheme.of(
        tester.element(selectedIcon),
      ).color!;
      final unselectedIconColor = IconTheme.of(
        tester.element(unselectedIcon),
      ).color!;
      final selectedLabelColor = tester
          .widget<Text>(find.text('Today'))
          .style!
          .color!;
      final unselectedLabelColor = tester
          .widget<Text>(find.text('Habits'))
          .style!
          .color!;

      expect(selectedIconColor.a, 1);
      expect(unselectedIconColor.a, 1);
      expect(selectedLabelColor, selectedIconColor);
      expect(unselectedLabelColor, unselectedIconColor);
      expect(unselectedIconColor, CupertinoColors.black);
    });

    testWidgets('aligns dark surfaces with shared elevation treatment', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          theme: const CupertinoThemeData(brightness: Brightness.dark),
        ),
      );

      final navigation = find.byKey(
        const ValueKey('cupertino-navigation-surface'),
      );
      final action = find.byKey(
        const ValueKey('cupertino-primary-action-slot'),
      );
      expect(tester.getTopLeft(navigation).dy, tester.getTopLeft(action).dy);
      expect(
        tester.getBottomLeft(navigation).dy,
        tester.getBottomLeft(action).dy,
      );

      final surfaces = find.byType(CupertinoFloatingGlassSurface);
      expect(surfaces, findsNWidgets(2));
      for (final surface in surfaces.evaluate()) {
        final decoratedBox = find.descendant(
          of: find.byWidget(surface.widget),
          matching: find.byType(DecoratedBox),
        );
        final decorations = tester
            .widgetList<DecoratedBox>(decoratedBox)
            .map((box) => box.decoration)
            .whereType<BoxDecoration>();
        final shadowDecorations = decorations.where(
          (decoration) => decoration.boxShadow?.isNotEmpty ?? false,
        );
        expect(shadowDecorations, hasLength(1));
        final shadowDecoration = shadowDecorations.single;
        expect(shadowDecoration.borderRadius, BorderRadius.circular(25));
        expect(shadowDecoration.boxShadow, hasLength(1));
        expect(
          shadowDecoration.boxShadow!.single.color,
          const Color(0x26000000),
        );
        expect(shadowDecoration.boxShadow!.single.blurRadius, 16);
        expect(shadowDecoration.boxShadow!.single.offset, const Offset(0, 4));

        final borderDecorations = decorations.where(
          (decoration) => decoration.border != null,
        );
        expect(borderDecorations, hasLength(1));
        expect(
          borderDecorations.single.borderRadius,
          BorderRadius.circular(25),
        );
      }
    });

    testWidgets('removes the trailing surface when no action is supplied', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          primaryAction: null,
        ),
      );

      expect(
        find.byKey(const ValueKey('cupertino-primary-action-slot')),
        findsNothing,
      );
      expect(
        tester.getSize(
          find.byKey(const ValueKey('cupertino-navigation-surface')),
        ),
        const Size(376, 50),
      );
    });

    testWidgets('does not treat rectangular view padding as bottom geometry', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          textDirection: TextDirection.rtl,
          viewPadding: const EdgeInsets.only(left: 28, right: 20),
        ),
      );

      final navigation = find.byKey(
        const ValueKey('cupertino-navigation-surface'),
      );
      final placeholder = find.byKey(
        const ValueKey('cupertino-primary-action-slot'),
      );
      expect(tester.getTopRight(navigation).dx, 388);
      expect(tester.getTopLeft(placeholder).dx, 12);
    });

    testWidgets('uses reported display corner radii before its fallback', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      const displayCornerRadii = BorderRadius.only(
        bottomLeft: Radius.circular(62),
        bottomRight: Radius.circular(39),
      );

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          displayCornerRadii: displayCornerRadii,
        ),
      );

      final navigation = find.byKey(
        const ValueKey('cupertino-navigation-surface'),
      );
      final placeholder = find.byKey(
        const ValueKey('cupertino-primary-action-slot'),
      );
      expect(tester.getTopLeft(navigation).dx, inInclusiveRange(31, 32));
      expect(
        400 - tester.getTopRight(placeholder).dx,
        inInclusiveRange(15, 16),
      );

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          viewPadding: const EdgeInsets.only(bottom: 34),
          displayCornerRadii: displayCornerRadii,
        ),
      );
      expect(tester.getBottomLeft(navigation).dy, 772);
      expect(tester.getTopLeft(navigation).dx, 28);
      expect(tester.getTopRight(placeholder).dx, 372);
    });

    testWidgets('uses the conservative iPhone 16 radius on older iOS', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(400, 800);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _wrap(
            presentation: AdaptiveNavigationBarPresentation.expanded,
            onDestinationSelected: (_) {},
            onExpandRequested: () {},
          ),
        );

        final navigation = find.byKey(
          const ValueKey('cupertino-navigation-surface'),
        );
        final placeholder = find.byKey(
          const ValueKey('cupertino-primary-action-slot'),
        );
        expect(tester.getTopLeft(navigation).dx, inInclusiveRange(32, 33));
        expect(
          400 - tester.getTopRight(placeholder).dx,
          inInclusiveRange(32, 33),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('uses ordinary margins for a known rectangular iPhone', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(400, 800);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _wrap(
            presentation: AdaptiveNavigationBarPresentation.expanded,
            onDestinationSelected: (_) {},
            onExpandRequested: () {},
            usesRectangularDisplay: true,
          ),
        );

        final navigation = find.byKey(
          const ValueKey('cupertino-navigation-surface'),
        );
        final placeholder = find.byKey(
          const ValueKey('cupertino-primary-action-slot'),
        );
        expect(tester.getTopLeft(navigation).dx, 12);
        expect(400 - tester.getTopRight(placeholder).dx, 12);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('uses UIKit geometry and allows style override', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          viewPadding: const EdgeInsets.only(bottom: 34),
          horizontalSafeAreaAvoidance: const EdgeInsetsDirectional.only(
            start: 24,
            end: 18,
          ),
          verticalSafeAreaAvoidance: EdgeInsetsDirectional.zero,
          effectiveCornerRadii: const BorderRadius.all(Radius.circular(62)),
          usesRectangularDisplay: true,
        ),
      );

      final navigation = find.byKey(
        const ValueKey('cupertino-navigation-surface'),
      );
      final placeholder = find.byKey(
        const ValueKey('cupertino-primary-action-slot'),
      );
      expect(tester.getBottomLeft(navigation).dy, 772);
      expect(tester.getTopLeft(navigation).dx, 28);
      expect(tester.getTopRight(placeholder).dx, 372);

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          viewPadding: const EdgeInsets.only(bottom: 34),
          horizontalSafeAreaAvoidance: const EdgeInsetsDirectional.only(
            start: 24,
            end: 18,
          ),
          verticalSafeAreaAvoidance: const EdgeInsetsDirectional.only(
            bottom: 34,
          ),
          effectiveCornerRadii: const BorderRadius.all(Radius.circular(62)),
          appleStyle: const AppleNavigationBarStyle(floatingBottomMargin: 28),
        ),
      );

      expect(tester.getBottomLeft(navigation).dy, 772);
    });

    testWidgets('ignores iPad top window-control insets at the bottom', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 600);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          viewPadding: const EdgeInsets.only(left: 80, bottom: 20),
          horizontalSafeAreaAvoidance: const EdgeInsetsDirectional.only(
            start: 96,
            end: 48,
          ),
          verticalSafeAreaAvoidance: EdgeInsetsDirectional.zero,
          effectiveCornerRadii: const BorderRadius.all(Radius.circular(26)),
        ),
      );

      final navigation = find.byKey(
        const ValueKey('cupertino-navigation-surface'),
      );
      final placeholder = find.byKey(
        const ValueKey('cupertino-primary-action-slot'),
      );
      expect(tester.getTopLeft(navigation).dx, 20);
      expect(tester.getTopRight(placeholder).dx, 780);
    });

    testWidgets('keeps surfaces floating across bottom inset geometries', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      Widget build(double bottomViewPadding) => _wrap(
        presentation: AdaptiveNavigationBarPresentation.expanded,
        onDestinationSelected: (_) {},
        onExpandRequested: () {},
        viewPadding: EdgeInsets.only(bottom: bottomViewPadding),
      );
      final bar = find.byKey(
        const ValueKey('cupertino-adaptive-navigation-bar'),
      );
      final surface = find.byKey(
        const ValueKey('cupertino-navigation-surface'),
      );
      final placeholder = find.byKey(
        const ValueKey('cupertino-primary-action-slot'),
      );

      await tester.pumpWidget(build(0));
      expect(tester.getSize(bar).height, 58);
      expect(tester.getBottomLeft(surface).dy, 792);
      expect(tester.getTopLeft(surface).dx, 12);
      expect(tester.getTopRight(placeholder).dx, 388);

      await tester.pumpWidget(build(34));
      expect(tester.getSize(bar).height, 78);
      expect(tester.getBottomLeft(surface).dy, 772);
      expect(tester.getTopLeft(surface).dx, 28);
      expect(tester.getTopRight(placeholder).dx, 372);
    });

    testWidgets('blurs only translucent bar backgrounds', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
        ),
      );
      expect(find.byType(BackdropFilter), findsNWidgets(2));

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          theme: const CupertinoThemeData(
            barBackgroundColor: CupertinoColors.white,
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('drag previews and selects an expanded destination', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      final selected = <int>[];
      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: selected.add,
          onExpandRequested: () {},
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Habits')),
      );
      await gesture.moveTo(tester.getCenter(find.text('Settings')));
      await tester.pump();

      final previewScale = tester.widget<AnimatedScale>(
        find
            .ancestor(
              of: find.byKey(const ValueKey('settings-apple')),
              matching: find.byType(AnimatedScale),
            )
            .first,
      );
      expect(previewScale.scale, 1.1);
      expect(selected, isEmpty);

      await gesture.up();
      await tester.pump();
      expect(selected, [2]);
    });

    testWidgets('drag selection follows logical destination order in RTL', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      final selected = <int>[];
      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: selected.add,
          onExpandRequested: () {},
          textDirection: TextDirection.rtl,
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Habits')),
      );
      await gesture.moveTo(tester.getCenter(find.text('Settings')));
      await tester.pump();
      await gesture.up();

      expect(selected, [2]);
    });

    testWidgets('cancelled drag clears its preview without selecting', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      final selected = <int>[];
      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: selected.add,
          onExpandRequested: () {},
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Habits')),
      );
      await gesture.moveTo(tester.getCenter(find.text('Settings')));
      await tester.pump();
      await gesture.cancel();
      await tester.pump();

      final previewScale = tester.widget<AnimatedScale>(
        find
            .ancestor(
              of: find.byKey(const ValueKey('settings-apple')),
              matching: find.byType(AnimatedScale),
            )
            .first,
      );
      expect(previewScale.scale, 1);
      expect(selected, isEmpty);
    });

    testWidgets('minimized shows only selected icon and requests expansion', (
      tester,
    ) async {
      final semanticsHandle = tester.ensureSemantics();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      final selected = <int>[];
      var expandRequests = 0;
      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.minimized,
          onDestinationSelected: selected.add,
          onExpandRequested: () => expandRequests++,
        ),
      );

      final surface = find.byKey(
        const ValueKey('cupertino-navigation-surface'),
      );
      final placeholder = find.byKey(
        const ValueKey('cupertino-primary-action-slot'),
      );
      expect(tester.getSize(surface), const Size.square(44));
      expect(tester.getTopLeft(surface).dx, 12);
      expect(tester.getSize(placeholder), const Size.square(44));
      expect(tester.getTopRight(placeholder).dx, 388);
      expect(tester.getBottomLeft(surface).dy, 792);
      expect(tester.getBottomRight(placeholder).dy, 792);
      final minimizedLabelOpacity = tester.widget<Opacity>(
        find
            .ancestor(of: find.text('Today'), matching: find.byType(Opacity))
            .first,
      );
      expect(minimizedLabelOpacity.opacity, 0);
      expect(
        find.byKey(const ValueKey('today-apple-selected')),
        findsOneWidget,
      );
      final hiddenDestinationOpacity = tester.widget<Opacity>(
        find
            .ancestor(
              of: find.byKey(const ValueKey('habits-apple')),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(hiddenDestinationOpacity.opacity, 0);
      final semantics = tester.getSemantics(
        find.byKey(const ValueKey('cupertino-navigation-destination-1')),
      );
      expect(semantics.label, 'Today tab');
      expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
      expect(semantics.flagsCollection.isButton, isTrue);
      expect(
        tester.semantics.simulatedAccessibilityTraversal().where(
          (node) => node.getSemanticsData().flagsCollection.isButton,
        ),
        hasLength(2),
      );

      await tester.drag(surface, const Offset(20, 0));
      expect(expandRequests, 0);
      expect(selected, isEmpty);

      await tester.tap(surface);
      expect(expandRequests, 1);
      expect(selected, isEmpty);

      await tester.tap(placeholder, warnIfMissed: false);
      expect(expandRequests, 1);
      expect(selected, isEmpty);
      semanticsHandle.dispose();
    });

    testWidgets('minimized follows logical leading in RTL', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.minimized,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          textDirection: TextDirection.rtl,
        ),
      );

      final surface = find.byKey(
        const ValueKey('cupertino-navigation-surface'),
      );
      final placeholder = find.byKey(
        const ValueKey('cupertino-primary-action-slot'),
      );
      expect(tester.getTopRight(surface).dx, 388);
      expect(tester.getTopLeft(placeholder).dx, 12);
    });

    testWidgets('shrinks both Apple surfaces inside the fixed envelope', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      Widget build(AdaptiveNavigationBarPresentation presentation) => _wrap(
        presentation: presentation,
        onDestinationSelected: (_) {},
        onExpandRequested: () {},
      );

      final navigation = find.byKey(
        const ValueKey('cupertino-navigation-surface'),
      );
      final placeholder = find.byKey(
        const ValueKey('cupertino-primary-action-slot'),
      );
      final bar = find.byKey(
        const ValueKey('cupertino-adaptive-navigation-bar'),
      );

      await tester.pumpWidget(
        build(AdaptiveNavigationBarPresentation.expanded),
      );
      final selectedIconElement = tester.element(
        find.byKey(const ValueKey('today-apple-selected')),
      );
      final placeholderIconElement = tester.element(
        find.byKey(const ValueKey('test-primary-action-icon')),
      );
      await tester.pumpWidget(
        build(AdaptiveNavigationBarPresentation.minimized),
      );
      await tester.pump(const Duration(milliseconds: 125));

      expect(tester.getSize(bar), const Size(400, 58));
      expect(tester.getSize(navigation).height, inExclusiveRange(44, 50));
      expect(tester.getSize(placeholder).height, inExclusiveRange(44, 50));
      expect(
        tester.element(find.byKey(const ValueKey('today-apple-selected'))),
        same(selectedIconElement),
      );
      expect(
        tester.element(find.byKey(const ValueKey('test-primary-action-icon'))),
        same(placeholderIconElement),
      );
      expect(find.byType(AnimatedSwitcher), findsNothing);

      await tester.pumpAndSettle();
      expect(tester.getSize(bar), const Size(400, 58));
      expect(tester.getSize(navigation), const Size.square(44));
      expect(tester.getSize(placeholder), const Size.square(44));
    });

    testWidgets('disables presentation animations from MediaQuery', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.minimized,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          disableAnimations: true,
        ),
      );

      expect(
        tester
            .widget<TweenAnimationBuilder<double>>(
              find.byType(TweenAnimationBuilder<double>),
            )
            .duration,
        Duration.zero,
      );
    });

    testWidgets('uses, fills and clamps the configured navigation width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
        ),
      );
      expect(
        tester.getSize(
          find.byKey(const ValueKey('cupertino-navigation-surface')),
        ),
        const Size(318, 50),
      );

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          appleStyle: const AppleNavigationBarStyle(
            expandedNavigationWidth: double.infinity,
          ),
        ),
      );
      expect(
        tester.getSize(
          find.byKey(const ValueKey('cupertino-navigation-surface')),
        ),
        const Size(318, 50),
      );

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
          appleStyle: const AppleNavigationBarStyle(
            expandedNavigationWidth: 180,
          ),
        ),
      );
      expect(
        tester.getSize(
          find.byKey(const ValueKey('cupertino-navigation-surface')),
        ),
        const Size(180, 50),
      );

      tester.view.physicalSize = const Size(100, 800);
      await tester.pump();
      expect(
        tester.getSize(
          find.byKey(const ValueKey('cupertino-navigation-surface')),
        ),
        const Size(44, 50),
      );
    });

    testWidgets('window resize updates surface and destinations in one frame', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          presentation: AdaptiveNavigationBarPresentation.expanded,
          onDestinationSelected: (_) {},
          onExpandRequested: () {},
        ),
      );

      final surface = find.byKey(
        const ValueKey('cupertino-navigation-surface'),
      );
      final firstDestination = find.byKey(
        const ValueKey('cupertino-navigation-destination-position-0'),
      );
      expect(tester.getSize(surface).width, 318);
      expect(tester.getSize(firstDestination).width, 106);

      tester.view.physicalSize = const Size(300, 800);
      await tester.pump();

      expect(tester.getSize(surface).width, 218);
      expect(tester.getSize(firstDestination).width, closeTo(218 / 3, 0.001));
    });
  });
}

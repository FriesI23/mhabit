import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_adaptive_navigation_bar.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_navigation_primary_action.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';

const _size = Size(900, 650);
const _padding = EdgeInsets.only(right: 90, bottom: 34);
const _corners = BorderRadius.all(Radius.circular(60));
const _barFrame = Rect.fromLTRB(830, 124, 874, 616);
const _destinations = [
  AdaptiveNavigationDestination(
    label: 'Habits',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.home),
      materialSelected: Icon(Icons.home),
      apple: Icon(CupertinoIcons.house),
      appleSelected: Icon(CupertinoIcons.house_fill),
    ),
  ),
  AdaptiveNavigationDestination(
    label: 'Today',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.today),
      materialSelected: Icon(Icons.today),
      apple: Icon(CupertinoIcons.today),
      appleSelected: Icon(CupertinoIcons.today_fill),
    ),
  ),
];
const _action = CupertinoNavigationPrimaryAction(
  id: 'floating-occlusion-test',
  label: 'New Habit',
  icon: Icon(CupertinoIcons.add),
  onPressed: null,
);

Widget _host(IosOcclusionGeometry? geometry, TextDirection direction) =>
    MaterialApp(
      builder: (context, navigator) => MediaQuery(
        data: const MediaQueryData(
          size: _size,
          padding: _padding,
          viewPadding: _padding,
          displayCornerRadii: _corners,
        ),
        child: AdaptiveOcclusionLayout(
          geometry: geometry,
          systemSafeArea: _padding,
          cornerRadii: _corners,
          child: OcclusionViewport(
            bounds: Offset.zero & MediaQuery.sizeOf(context),
            child: Directionality(textDirection: direction, child: navigator!),
          ),
        ),
      ),
      home: Builder(
        builder: (context) => Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          floatingActionButtonLocation:
              CupertinoNavigationPrimaryActionButton.floatingLocationOf(
                context,
              ),
          floatingActionButton: const CupertinoNavigationPrimaryActionButton(
            action: _action,
          ),
          body: const SafeArea(
            child: SizedBox.expand(key: ValueKey('floating-occlusion-body')),
          ),
          bottomNavigationBar: CupertinoAdaptiveNavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            onExpandRequested: () {},
            destinations: _destinations,
            presentation: AdaptiveNavigationBarPresentation.expanded,
            reservePrimaryActionSpace: true,
            expandedNavigationWidth: null,
          ),
        ),
      ),
    );

IosOcclusionGeometry _geometry(List<Rect> regions) => IosOcclusionGeometry(
  viewBounds: Offset.zero & _size,
  activeOcclusionRegions: regions,
  hasVerticalSystemBar: true,
  verticalBarLayoutFrame: _barFrame,
);

void main() {
  for (final direction in TextDirection.values) {
    testWidgets(
      'Apple floating surfaces reclaim only their own band in $direction',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = _size;
        addTearDown(tester.view.reset);
        final nav = find.byKey(const ValueKey('cupertino-navigation-surface'));
        final action = find.byKey(
          const ValueKey('cupertino-primary-action-surface'),
        );
        final body = find.byKey(const ValueKey('floating-occlusion-body'));

        await tester.pumpWidget(_host(null, direction));
        await tester.pumpAndSettle();
        final originalBody = tester.getRect(body);
        final originalAction = tester.getRect(action);
        final originalNav = tester.getRect(nav);

        await tester.pumpWidget(
          _host(_geometry(const [Rect.fromLTWH(810, 0, 90, 100)]), direction),
        );
        await tester.pumpAndSettle();
        final clearAction = tester.getRect(action);
        final clearNav = tester.getRect(nav);
        expect(tester.getRect(body), originalBody);
        expect(clearAction.top, originalAction.top);
        expect(clearNav.top, originalNav.top);
        if (direction == TextDirection.ltr) {
          expect(clearAction.right, greaterThan(originalAction.right));
          expect(clearAction.center.dx, closeTo(_barFrame.center.dx, 0.01));
          // The navigation reservation stays at its existing floating edge;
          // only the independent action moves into the system control column.
          expect(clearNav.right, closeTo(_size.width - 28 - 50 - 8, 0.01));
          expect(clearNav.right, lessThanOrEqualTo(clearAction.left - 8));
        } else {
          expect(clearNav.right, greaterThan(originalNav.right));
          expect(clearNav.left, closeTo(clearAction.right + 8, 0.01));
        }
        expect(clearAction.bottom, lessThanOrEqualTo(_size.height - 28));

        const lowerOcclusion = Rect.fromLTWH(810, 540, 90, 110);
        await tester.pumpWidget(
          _host(_geometry(const [lowerOcclusion]), direction),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(action).overlaps(lowerOcclusion), isFalse);
        expect(tester.getRect(nav).overlaps(lowerOcclusion), isFalse);
        expect(tester.getRect(body), originalBody);

        // Losing the geometry immediately restores the original safe edges.
        await tester.pumpWidget(_host(null, direction));
        await tester.pumpAndSettle();
        expect(tester.getRect(action), originalAction);
        expect(tester.getRect(nav), originalNav);
        expect(tester.getRect(body), originalBody);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart'
    show CupertinoSidebar;
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_search_toolbar.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';

import '../harness/adaptive_ui_theme.dart';

const _size = Size(951, 669);
const _capsule = ValueKey('cupertino-sidebar-collapsed-capsule');
const _placeholder = ValueKey('cupertino-sidebar-fixed-toolbar-placeholder');

ActionCollection<String> _actions() => ActionCollection<String>(
  roots: [
    for (final id in [
      'select',
      'sort',
      'statistics',
      'filter',
      'display',
      'more',
    ])
      AdaptiveAction<String>.action(
        id: ActionId(id),
        metadata: ActionMetadata(label: id == 'select' ? 'Select' : id),
        payload: id,
      ),
  ],
);

Widget _host({
  required EdgeInsets padding,
  required Rect region,
  required TextDirection direction,
  required AppleSidebarStyle style,
  required TextEditingController controller,
  required FocusNode focusNode,
  bool reportsRegion = true,
  bool hasVerticalSystemBar = true,
  bool geometryAvailable = true,
  Size viewSize = _size,
}) => MaterialApp(
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
        geometry: geometryAvailable
            ? IosOcclusionGeometry(
                viewBounds: Offset.zero & viewSize,
                activeOcclusionRegions: reportsRegion ? [region] : const [],
                hasVerticalSystemBar: hasVerticalSystemBar,
              )
            : null,
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
    child: AdaptiveNavigationShell(
      selectedIndex: 0,
      appleSidebarStyle: style,
      destinations: const [
        AdaptiveNavigationDestination(
          label: 'Habits',
          icons: NavigationDestinationIcons(
            material: Icon(Icons.home),
            materialSelected: Icon(Icons.home),
            apple: Icon(CupertinoIcons.home),
            appleSelected: Icon(CupertinoIcons.home),
          ),
        ),
        AdaptiveNavigationDestination(
          label: 'Today',
          icons: NavigationDestinationIcons(
            material: Icon(Icons.calendar_today),
            materialSelected: Icon(Icons.calendar_today),
            apple: Icon(CupertinoIcons.calendar),
            appleSelected: Icon(CupertinoIcons.calendar),
          ),
        ),
      ],
      onDestinationSelected: (_) {},
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            CupertinoSliverSearchBar<String>(
              title: const Text('Table Habit'),
              controller: controller,
              focusNode: focusNode,
              isSearchActive: false,
              keyword: controller.text,
              collection: _actions(),
              actions: CupertinoAppBarActionsConfig<String>(
                iconBuilder: (_, action) => action.id.value == 'select'
                    ? null
                    : const Icon(CupertinoIcons.circle),
                presentationForAction: (_, action) =>
                    action.id.value == 'select'
                    ? CupertinoActionPresentation.extended
                    : CupertinoActionPresentation.iconOnly,
                actionButtonBuilder:
                    (context, action, onPressed, defaultBuilder) =>
                        KeyedSubtree(
                          key: ValueKey('primary-${action.id.value}'),
                          child: defaultBuilder(context, action, onPressed),
                        ),
              ),
              onInvoke: (_, _) {},
              onChanged: (_) {},
              onSearchActivated: () {},
              onSearchDismissed: () {},
            ),
            const SliverFillRemaining(
              child: SafeArea(child: SizedBox.expand(key: ValueKey('body'))),
            ),
          ],
        ),
      ),
    ),
  ),
);

void _expectActionsOutside(WidgetTester tester, Rect region, {Rect? capsule}) {
  for (final key in [
    const ValueKey('activate-cupertino-search'),
    const ValueKey('cupertino-expandable-search-region'),
  ]) {
    final search = find.byKey(key);
    if (search.evaluate().isEmpty) continue;
    final rect = tester.getRect(search);
    expect(
      rect.overlaps(region),
      isFalse,
      reason: 'Search enters system occlusion',
    );
    if (capsule != null) {
      expect(
        rect.overlaps(capsule),
        isFalse,
        reason: 'Search enters actual capsule',
      );
    }
  }
  for (final id in [
    'select',
    'sort',
    'statistics',
    'filter',
    'display',
    'more',
  ]) {
    final finder = find.byKey(ValueKey('primary-$id'));
    if (finder.evaluate().isEmpty) continue;
    final rect = tester.getRect(finder);
    expect(
      rect.overlaps(region),
      isFalse,
      reason: '$id enters system occlusion',
    );
    if (capsule != null) {
      expect(
        rect.overlaps(capsule),
        isFalse,
        reason: '$id enters actual capsule',
      );
    }
  }
}

void main() {
  for (final reportsRegion in [true, false]) {
    for (final style in AppleSidebarStyle.values) {
      for (final direction in TextDirection.values) {
        for (final side in ['left', 'right']) {
          testWidgets(
            '$style Sidebar Search and Select avoid $side in $direction (reportsRegion: $reportsRegion)',
            (tester) async {
              tester.view.devicePixelRatio = 1;
              tester.view.physicalSize = _size;
              addTearDown(tester.view.reset);
              final controller = TextEditingController();
              final focusNode = FocusNode();
              addTearDown(controller.dispose);
              addTearDown(focusNode.dispose);
              final padding = EdgeInsets.only(
                left: side == 'left' ? 84 : 0,
                right: side == 'right' ? 84 : 0,
                bottom: 34,
              );
              final region = Rect.fromLTWH(
                side == 'left' ? 0 : 867,
                0,
                84,
                124,
              );
              await tester.pumpWidget(
                _host(
                  padding: padding,
                  region: region,
                  direction: direction,
                  style: style,
                  controller: controller,
                  focusNode: focusNode,
                  reportsRegion: reportsRegion,
                ),
              );
              await tester.pumpAndSettle();
              final sidebar = tester
                  .widget<CupertinoSidebar>(find.byType(CupertinoSidebar))
                  .controller;
              // Match the production report: expanded Sidebar, empty query and a
              // collapsed Search button in the page's trailing command region.
              sidebar.expanded = true;
              await tester.pumpAndSettle();
              expect(
                find.byKey(const ValueKey('activate-cupertino-search')),
                findsOneWidget,
              );
              final toolbar = tester.getRect(
                find.byType(CupertinoSearchToolbar<String>),
              );
              if (style == AppleSidebarStyle.edge) {
                expect(toolbar.width, 751);
              }
              expect(focusNode.hasFocus, isFalse);
              expect(controller.text, isEmpty);
              _expectActionsOutside(tester, region);
              sidebar.expanded = false;
              await tester.pumpAndSettle();
              final capsule = tester.getRect(find.byKey(_capsule));
              final placeholder = tester.getRect(find.byKey(_placeholder));
              expect(capsule.center.dx, closeTo(_size.width / 2, .01));
              expect(placeholder.center.dx, closeTo(capsule.center.dx, .01));
              expect(
                find.byKey(const ValueKey('primary-select')),
                findsOneWidget,
              );
              _expectActionsOutside(tester, region, capsule: capsule);
              final body = tester.getRect(find.byKey(const ValueKey('body')));
              expect(body.left, padding.left);
              expect(body.right, _size.width - padding.right);

              // Animate the actual production Sidebar, checking rendered actions and
              // layout errors instead of asserting only the placeholder's rectangle.
              for (final expanded in [true, false]) {
                sidebar.expanded = expanded;
                for (var frame = 0; frame < 12; frame++) {
                  await tester.pump(const Duration(milliseconds: 20));
                  expect(tester.takeException(), isNull);
                  _expectActionsOutside(tester, region);
                }
                await tester.pumpAndSettle();
              }
              _expectActionsOutside(
                tester,
                region,
                capsule: tester.getRect(find.byKey(_capsule)),
              );
              await tester.tap(
                find.byKey(const ValueKey('activate-cupertino-search')),
              );
              await tester.pumpAndSettle();
              controller.text = 'kept query';
              await tester.pump();
              expect(focusNode.hasFocus, isTrue);
              _expectActionsOutside(tester, region);
              expect(controller.text, 'kept query');
              for (final expanded in [true, false]) {
                sidebar.expanded = expanded;
                for (var frame = 0; frame < 12; frame++) {
                  await tester.pump(const Duration(milliseconds: 20));
                  expect(tester.takeException(), isNull);
                  _expectActionsOutside(tester, region);
                }
                await tester.pumpAndSettle();
                expect(controller.text, 'kept query');
                expect(focusNode.hasFocus, isTrue);
              }
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }

  for (final direction in TextDirection.values) {
    testWidgets(
      'ordinary landscape iPhone keeps legacy Search bounds in $direction',
      (tester) async {
        const phoneSize = Size(844, 390);
        const padding = EdgeInsets.only(left: 47, right: 47, bottom: 21);
        const region = Rect.fromLTWH(797, 0, 47, 124);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = phoneSize;
        addTearDown(tester.view.reset);
        final controller = TextEditingController();
        final focusNode = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focusNode.dispose);
        Widget page({required bool geometryAvailable}) => _host(
          padding: padding,
          region: region,
          direction: direction,
          style: AppleSidebarStyle.edge,
          controller: controller,
          focusNode: focusNode,
          hasVerticalSystemBar: false,
          geometryAvailable: geometryAvailable,
          viewSize: phoneSize,
        );
        final trigger = find.byKey(const ValueKey('activate-cupertino-search'));
        await tester.pumpWidget(page(geometryAvailable: false));
        await tester.pumpAndSettle();
        expect(trigger, findsOneWidget);
        final legacy = tester.getRect(trigger);
        await tester.pumpWidget(page(geometryAvailable: true));
        await tester.pumpAndSettle();
        expect(tester.getRect(trigger), legacy);
        expect(focusNode.hasFocus, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

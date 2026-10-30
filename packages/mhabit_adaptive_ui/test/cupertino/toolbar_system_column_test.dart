import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';

import '../harness/adaptive_ui_theme.dart';

const _size = Size(678, 466);
const _search = ValueKey('cupertino-expandable-search-region');
const _leading = ValueKey('system-column-leading');
const _action = ValueKey('system-column-statistics');
const _body = ValueKey('system-column-body');
const _materialFab = ValueKey('system-column-material-fab');
const _appleFab = ValueKey('cupertino-primary-action-surface');
const _navigation = ValueKey('cupertino-navigation-surface');

enum _Mode { collapsed, expanded, selection }

Rect _mirror(Rect rect) => Rect.fromLTRB(
  _size.width - rect.right,
  rect.top,
  _size.width - rect.left,
  rect.bottom,
);

IosOcclusionGeometry _geometry({
  bool left = false,
  bool vertical = true,
  Rect? column = const Rect.fromLTWH(
    608,
    2.3333333333333428,
    44,
    381.66666666666669,
  ),
  List<Rect> regions = const [
    Rect.fromLTWH(594, 384, 84, 82),
    Rect.fromLTWH(611.666, 399.666, 37, 37),
  ],
}) => IosOcclusionGeometry(
  viewBounds: Offset.zero & _size,
  activeOcclusionRegions: left ? regions.map(_mirror).toList() : regions,
  hasVerticalSystemBar: vertical,
  verticalBarLayoutFrame: left && column != null ? _mirror(column) : column,
);

// Keep the horizontal FAB column and actual occlusions while reserving the
// top row. This reproduces the conservative toolbar baseline without a switch.
IosOcclusionGeometry _reservedTop(IosOcclusionGeometry geometry) {
  final column = geometry.verticalBarLayoutFrame!;
  return IosOcclusionGeometry(
    viewBounds: geometry.viewBounds,
    activeOcclusionRegions: geometry.activeOcclusionRegions,
    hasVerticalSystemBar: geometry.hasVerticalSystemBar,
    verticalBarLayoutFrame: Rect.fromLTRB(
      column.left,
      124,
      column.right,
      column.bottom,
    ),
  );
}

IosOcclusionGeometry? _withoutColumn(IosOcclusionGeometry? geometry) =>
    geometry == null
    ? null
    : IosOcclusionGeometry(
        viewBounds: geometry.viewBounds,
        activeOcclusionRegions: geometry.activeOcclusionRegions,
        hasVerticalSystemBar: geometry.hasVerticalSystemBar,
      );

ActionCollection<String> _actions() => ActionCollection<String>(
  roots: [
    for (final id in ['select', 'statistics'])
      AdaptiveAction<String>.action(
        id: ActionId(id),
        metadata: ActionMetadata(label: id),
        payload: id,
      ),
  ],
);

Widget _host({
  required AdaptiveStyle style,
  required TextDirection direction,
  required IosOcclusionGeometry? geometry,
  required TextEditingController controller,
  required FocusNode focus,
  required ScrollController scroll,
  bool left = false,
  _Mode mode = _Mode.collapsed,
  double headerOffset = 0,
}) {
  final safeArea = EdgeInsets.only(
    left: left ? 84 : 0,
    right: left ? 0 : 84,
    bottom: 34,
  );

  final bar = mode == _Mode.selection
      ? CupertinoSliverSelectAppBar<String>(
          title: const Text('Selected 0'),
          selectAllLabel: 'All',
          doneLabel: 'Done',
          onSelectAll: () {},
          onDone: () {},
          collection: _actions(),
          onInvoke: (_, _) {},
        )
      : AdaptiveSliverSearchBar<String>(
          title: const Text('Table Habit'),
          leading: IconButton(
            key: _leading,
            onPressed: () {},
            icon: const Icon(Icons.arrow_back),
          ),
          controller: controller,
          focusNode: focus,
          isSearchActive: mode == _Mode.expanded,
          keyword: controller.text,
          onChanged: (_) {},
          onSearchActivated: () {},
          onSearchDismissed: () {},
          collection: _actions(),
          onInvoke: (_, _) {},
          apple: CupertinoSliverSearchBarConfig<String>(
            actions: CupertinoAppBarActionsConfig<String>(
              actionButtonBuilder: (context, action, onPressed, build) =>
                  KeyedSubtree(
                    key: action.id.value == 'statistics' ? _action : null,
                    child: build(context, action, onPressed),
                  ),
            ),
          ),
          material: MaterialSliverSearchBarConfig<String>(
            style: const MaterialSliverSearchBarStyle(
              floating: false,
              snap: false,
            ),
            actions: MaterialAppBarActionsConfig<String>(
              actionButtonBuilder: (context, action, onPressed, build) =>
                  KeyedSubtree(
                    key: action.id.value == 'statistics' ? _action : null,
                    child: build(context, action, onPressed),
                  ),
            ),
          ),
        );
  return MaterialApp(
    theme: ThemeData(platform: TargetPlatform.iOS),
    builder: (context, navigator) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: safeArea.copyWith(top: 2.333333333333333),
        viewPadding: safeArea.copyWith(top: 2.333333333333333),
      ),
      child: Directionality(
        textDirection: direction,
        child: AdaptiveWindowControlLayoutScope(
          horizontalAvoidance: EdgeInsets.zero,
          verticalAvoidance: EdgeInsets.zero,
          horizontalSafeAreaAvoidance: EdgeInsets.zero,
          verticalSafeAreaAvoidance: EdgeInsets.zero,
          effectiveCornerRadii: BorderRadius.zero,
          owner: WindowControlLayoutOwner.appBar,
          child: AdaptiveOcclusionLayout(
            geometry: geometry,
            systemSafeArea: safeArea,
            cornerRadii: BorderRadius.zero,
            child: OcclusionViewport(
              bounds: Offset.zero & MediaQuery.sizeOf(context),
              child: navigator!,
            ),
          ),
        ),
      ),
    ),
    home: TestAdaptiveUiTheme(
      update: (theme) => theme.copyWith(style: style),
      child: AdaptiveNavigationShell(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        destinations: const [
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
        ],
        applePrimaryAction: CupertinoNavigationPrimaryAction(
          id: 'system-column-action',
          label: 'New Habit',
          icon: const Icon(CupertinoIcons.add),
          onPressed: () {},
        ),
        child: Builder(
          builder: (context) => Scaffold(
            floatingActionButtonAnimator:
                AdaptiveOcclusionLayout.floatingActionButtonAnimatorOf(context),
            floatingActionButtonLocation:
                AdaptiveOcclusionFabLocation.resolveOf(context),
            floatingActionButton: style == AdaptiveStyle.material
                ? FloatingActionButton(
                    key: _materialFab,
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  )
                : null,
            body: CustomScrollView(
              controller: scroll,
              slivers: [
                if (headerOffset > 0)
                  SliverToBoxAdapter(child: SizedBox(height: headerOffset)),
                bar,
                const SliverToBoxAdapter(
                  child: SafeArea(child: SizedBox(key: _body, height: 1600)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Key _edgeKey(
  AdaptiveStyle style,
  TextDirection direction,
  bool left, {
  _Mode mode = _Mode.collapsed,
}) {
  final leadingEdge = left == (direction == TextDirection.ltr);
  if (mode == _Mode.selection) {
    return ValueKey(
      leadingEdge ? 'cupertino-select-all-top' : 'cupertino-select-done',
    );
  }
  return leadingEdge
      ? _leading
      : (style == AdaptiveStyle.apple ? _search : _action);
}

Finder _edgeFinder(
  AdaptiveStyle style,
  TextDirection direction,
  bool left, {
  _Mode mode = _Mode.collapsed,
}) {
  if (style == AdaptiveStyle.material) {
    final leadingEdge = left == (direction == TextDirection.ltr);
    return leadingEdge
        ? find.byType(MaterialExpandableSearchBar)
        : find.byType(AdaptiveAppBarActions<String>);
  }
  return find.byKey(_edgeKey(style, direction, left, mode: mode));
}

double _edge(Rect rect, bool left) => left ? rect.left : rect.right;

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final direction in TextDirection.values) {
      for (final left in [false, true]) {
        for (final expanded in [false, true]) {
          testWidgets('$style $direction ${left ? 'left' : 'right'} search '
              'reclaims only its free top row (expanded: $expanded)', (
            tester,
          ) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = _size;
            addTearDown(tester.view.reset);
            final controller = TextEditingController(
              text: expanded ? 'kept' : '',
            );
            final focus = FocusNode();
            final scroll = ScrollController();
            addTearDown(controller.dispose);
            addTearDown(focus.dispose);
            addTearDown(scroll.dispose);
            final mode = expanded ? _Mode.expanded : _Mode.collapsed;
            Widget page({bool reserveTop = false}) => _host(
              style: style,
              direction: direction,
              geometry: reserveTop
                  ? _reservedTop(_geometry(left: left))
                  : _geometry(left: left),
              controller: controller,
              focus: focus,
              scroll: scroll,
              left: left,
              mode: mode,
            );
            final target = _edgeFinder(style, direction, left, mode: mode);
            await tester.pumpWidget(page(reserveTop: true));
            await tester.pumpAndSettle();
            final legacyEdge = _edge(tester.getRect(target), left);
            final body = tester.getRect(find.byKey(_body));
            final fabKey = style == AdaptiveStyle.apple
                ? _appleFab
                : _materialFab;
            final fab = tester.getRect(find.byKey(fabKey));
            final nav = style == AdaptiveStyle.apple
                ? tester.getRect(find.byKey(_navigation))
                : null;
            await tester.pumpWidget(page());
            await tester.pumpAndSettle();
            final actual = tester.getRect(target);
            expect(
              _edge(actual, left) - legacyEdge,
              closeTo(left ? -58 : 58, 0.01),
            );
            expect(tester.getRect(find.byKey(_body)), body);
            expect(tester.getRect(find.byKey(fabKey)), fab);
            if (nav != null) {
              expect(tester.getRect(find.byKey(_navigation)), nav);
            }
            expect(controller.text, expanded ? 'kept' : '');
            expect(target.hitTestable(), findsOneWidget);
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }

  for (final direction in TextDirection.values) {
    for (final left in [false, true]) {
      testWidgets('selection commands recover matching column at $direction '
          '${left ? 'left' : 'right'}', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = _size;
        addTearDown(tester.view.reset);
        final controller = TextEditingController();
        final focus = FocusNode();
        final scroll = ScrollController();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        addTearDown(scroll.dispose);
        Widget page({bool reserveTop = false}) => _host(
          style: AdaptiveStyle.apple,
          direction: direction,
          geometry: reserveTop
              ? _reservedTop(_geometry(left: left))
              : _geometry(left: left),
          controller: controller,
          focus: focus,
          scroll: scroll,
          left: left,
          mode: _Mode.selection,
        );
        final key = _edgeKey(
          AdaptiveStyle.apple,
          direction,
          left,
          mode: _Mode.selection,
        );
        await tester.pumpWidget(page(reserveTop: true));
        await tester.pumpAndSettle();
        final before = _edge(tester.getRect(find.byKey(key)), left);
        await tester.pumpWidget(page());
        await tester.pumpAndSettle();
        expect(
          _edge(tester.getRect(find.byKey(key)), left) - before,
          closeTo(left ? -58 : 58, 0.01),
        );
        expect(find.byKey(key).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final style in AdaptiveStyle.values) {
    for (final direction in TextDirection.values) {
      testWidgets('$style $direction preserves legacy search for unavailable '
          'column or ordinary iPhone', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = _size;
        addTearDown(tester.view.reset);
        final controller = TextEditingController(text: 'kept');
        final focus = FocusNode();
        final scroll = ScrollController();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        addTearDown(scroll.dispose);
        for (final geometry in [
          null,
          _geometry(vertical: false),
          _geometry(column: null),
          _geometry(
            column: const Rect.fromLTWH(608, 124, 44, 308),
            regions: [],
          ),
          _geometry(column: const Rect.fromLTWH(608, 30, 44, 354), regions: []),
        ]) {
          Widget page({bool withoutColumn = false}) => _host(
            style: style,
            direction: direction,
            geometry: withoutColumn ? _withoutColumn(geometry) : geometry,
            controller: controller,
            focus: focus,
            scroll: scroll,
            mode: _Mode.expanded,
          );
          await tester.pumpWidget(page(withoutColumn: true));
          await tester.pumpAndSettle();
          final search = tester.getRect(
            style == AdaptiveStyle.apple
                ? find.byKey(_search)
                : find.byType(SearchBar),
          );
          final leading = tester.getRect(find.byKey(_leading));
          final actionFinder = find.byType(AdaptiveAppBarActions<String>);
          final action = tester.getRect(actionFinder);
          await tester.pumpWidget(page());
          await tester.pumpAndSettle();
          expect(
            tester.getRect(
              style == AdaptiveStyle.apple
                  ? find.byKey(_search)
                  : find.byType(SearchBar),
            ),
            search,
          );
          expect(tester.getRect(find.byKey(_leading)), leading);
          expect(tester.getRect(actionFinder), action);
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('$style $direction pinned search retains text while native '
          'column changes', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = _size;
        addTearDown(tester.view.reset);
        final controller = TextEditingController(text: 'kept');
        final focus = FocusNode();
        final scroll = ScrollController();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        addTearDown(scroll.dispose);
        Widget page(IosOcclusionGeometry geometry) => _host(
          style: style,
          direction: direction,
          geometry: geometry,
          controller: controller,
          focus: focus,
          scroll: scroll,
          mode: _Mode.expanded,
          headerOffset: 120,
        );
        await tester.pumpWidget(page(_geometry()));
        await tester.pumpAndSettle();
        focus.requestFocus();
        await tester.pumpAndSettle();
        final target = _edgeFinder(
          style,
          direction,
          false,
          mode: _Mode.expanded,
        );
        for (var frame = 0; frame < 24; frame++) {
          scroll.jumpTo(frame * 10);
          await tester.pump(const Duration(milliseconds: 16));
          final rect = tester.getRect(target);
          expect(rect.right, lessThanOrEqualTo(652));
          expect(focus.hasFocus, isTrue);
          expect(controller.text, 'kept');
          expect(tester.takeException(), isNull);
        }
        final free = tester.getRect(target);
        await tester.pumpWidget(
          page(
            _geometry(
              column: const Rect.fromLTWH(608, 124, 44, 308),
              regions: [],
            ),
          ),
        );
        await tester.pumpAndSettle();
        final blocked = tester.getRect(target);
        if (direction == TextDirection.ltr) {
          expect(blocked.right, closeTo(free.right - 58, 0.01));
        }
        expect(focus.hasFocus, isTrue);
        expect(controller.text, 'kept');
        await tester.pumpWidget(page(_geometry()));
        await tester.pumpAndSettle();
        expect(tester.getRect(target), free);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

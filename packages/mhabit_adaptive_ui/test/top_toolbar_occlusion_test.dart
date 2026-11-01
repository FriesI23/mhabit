import 'dart:async';

import 'package:adaptive_actions/core.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_toolbar.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'harness/adaptive_ui_theme.dart';

// Device Hub's expanded portrait view. These are fixtures, not breakpoints.
const _size = Size(669, 951);
const _status = Rect.fromLTWH(525, 0, 144, 82);
const _safeArea = EdgeInsets.only(top: 82, bottom: 34);
const _leading = ValueKey('top-toolbar-leading');
const _action = ValueKey('top-toolbar-action');
const _title = ValueKey('top-toolbar-title');
const _body = ValueKey('top-toolbar-body');
const _bottom = ValueKey('top-toolbar-bottom');
const _footerContent = ValueKey('top-toolbar-footer-content');
const _page = ValueKey('top-toolbar-page');
const _detailPage = ValueKey('top-toolbar-detail-page');
const _detailBody = ValueKey('top-toolbar-detail-body');
const _nativeView = Rect.fromLTWH(0, 0, 669, 951);
const TopToolbarLayout _acceptedOverrideLayout = (
  topInset: 28,
  minimumExtent: 82,
  bounds: Rect.fromLTWH(0, 28, 669, 44),
);

class _Readout {
  MediaQueryData? body;
  MediaQueryData? footer;
}

IosOcclusionGeometry _geometry({
  List<Rect> regions = const [_status],
  Size size = _size,
  bool vertical = false,
}) => IosOcclusionGeometry(
  viewBounds: Offset.zero & size,
  activeOcclusionRegions: regions,
  hasVerticalSystemBar: vertical,
);

double _height(AdaptiveStyle style) => style == AdaptiveStyle.apple ? 44 : 64;

Widget _bar(
  AdaptiveStyle style, {
  PreferredSizeWidget? bottom,
  bool pinned = true,
  bool large = false,
  bool centerTitle = false,
  bool includeActions = true,
  String titleText = 'Habits',
  double? minimumTopInset,
}) {
  final title = Text(titleText, key: _title);
  const leading = SizedBox(key: _leading, width: 44, height: 44);
  final actions = includeActions
      ? const [SizedBox(key: _action, width: 44, height: 44)]
      : const <Widget>[];
  if (style == AdaptiveStyle.apple) {
    return AdaptiveSliverAppBar.apple(
      title: title,
      leading: leading,
      actions: actions,
      height: large ? null : 44,
      bottom: bottom,
      appleToolbarTopInset: minimumTopInset,
    );
  }
  final styles = AppBarStyles(
    material: AppBarMaterialStyle(
      pinned: pinned,
      floating: false,
      snap: false,
      centerTitle: centerTitle,
    ),
  );
  return large
      ? AdaptiveSliverAppBar.materialLarge(
          title: title,
          leading: leading,
          actions: actions,
          height: 64,
          styles: styles,
        )
      : AdaptiveSliverAppBar.material(
          title: title,
          leading: leading,
          actions: actions,
          height: 64,
          bottom: bottom,
          styles: styles,
        );
}

Widget _host({
  required AdaptiveStyle style,
  required Widget header,
  required IosOcclusionGeometry? geometry,
  bool allow = true,
  double? topToolbarAlignmentHeight = 64,
  bool knownViewport = true,
  bool windowControls = false,
  TextDirection direction = TextDirection.ltr,
  TargetPlatform platform = TargetPlatform.iOS,
  EdgeInsets padding = _safeArea,
  double keyboard = 0,
  bool resizeToAvoidBottomInset = false,
  BorderRadius? corners = BorderRadius.zero,
  ScrollController? scrollController,
  GlobalKey<NavigatorState>? navigatorKey,
  Widget Function(Widget page)? pageWrapper,
  _Readout? readout,
}) => MaterialApp(
  navigatorKey: navigatorKey,
  theme: ThemeData(platform: platform),
  builder: (context, navigator) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      padding: padding.copyWith(bottom: keyboard > 0 ? 0 : padding.bottom),
      viewPadding: padding,
      viewInsets: EdgeInsets.only(bottom: keyboard),
    ),
    child: AdaptiveWindowControlLayoutScope(
      horizontalAvoidance: EdgeInsets.zero,
      verticalAvoidance: EdgeInsets.zero,
      owner: WindowControlLayoutOwner.appBar,
      child: AdaptiveOcclusionLayout(
        geometry: geometry,
        systemSafeArea: _safeArea,
        cornerRadii: corners,
        hasWindowControls: windowControls,
        allowTopToolbarReclamation: allow,
        topToolbarAlignmentHeight: topToolbarAlignmentHeight,
        child: OcclusionViewport(
          bounds: knownViewport ? Offset.zero & _size : null,
          child: Directionality(textDirection: direction, child: navigator!),
        ),
      ),
    ),
  ),
  home: TestAdaptiveUiTheme(
    update: (theme) => theme.copyWith(style: style),
    child: _wrapPage(
      wrapper: pageWrapper,
      child: Scaffold(
        key: _page,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: CustomScrollView(
          controller: scrollController,
          slivers: [
            header,
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  readout?.body = MediaQuery.of(context);
                  return const SizedBox(key: _body, height: 2200);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

Widget _wrapPage({
  required Widget child,
  Widget Function(Widget page)? wrapper,
}) => wrapper?.call(child) ?? child;

Widget _materialHeader(
  String variant, {
  double toolbarHeight = 64,
  double? collapsedHeight,
  bool floating = false,
  PreferredSizeWidget? bottom,
}) {
  const title = Text('Habits', key: _title);
  const leading = SizedBox(key: _leading, width: 44, height: 44);
  const actions = [SizedBox(key: _action, width: 44, height: 44)];
  return switch (variant) {
    'small' => WindowControlSliverAppBar(
      title: title,
      leading: leading,
      actions: actions,
      pinned: true,
      floating: floating,
      toolbarHeight: toolbarHeight,
      collapsedHeight: collapsedHeight,
      bottom: bottom,
    ),
    'medium' => WindowControlSliverAppBar.medium(
      title: title,
      leading: leading,
      actions: actions,
      pinned: true,
      floating: floating,
      toolbarHeight: toolbarHeight,
      collapsedHeight: collapsedHeight,
      bottom: bottom,
    ),
    _ => WindowControlSliverAppBar.large(
      title: title,
      leading: leading,
      actions: actions,
      pinned: true,
      floating: floating,
      toolbarHeight: toolbarHeight,
      collapsedHeight: collapsedHeight,
      bottom: bottom,
    ),
  };
}

void _configure(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _size;
  addTearDown(tester.view.reset);
}

void _expectToolbarSafe(WidgetTester tester) {
  for (final key in [_leading, _action]) {
    final rect = tester.getRect(find.byKey(key));
    expect(rect.overlaps(_status), isFalse, reason: '$key: $rect');
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(_status.left));
  }
  expect(tester.takeException(), isNull);
}

Widget _searchHeader(
  TextEditingController controller,
  FocusNode focus, {
  Widget? appleBottom,
}) => AdaptiveSliverSearchBar<String>(
  title: const Text('Habits'),
  controller: controller,
  focusNode: focus,
  isSearchActive: true,
  keyword: controller.text,
  collection: ActionCollection<String>(roots: const []),
  onInvoke: (_, _) {},
  onChanged: (_) {},
  onSearchActivated: () {},
  onSearchDismissed: () {},
  apple: appleBottom == null
      ? null
      : CupertinoSliverSearchBarConfig<String>(
          bottom: appleBottom,
          bottomExtent: 28,
        ),
  material: const MaterialSliverSearchBarConfig<String>(
    style: MaterialSliverSearchBarStyle(
      toolbarHeight: 64,
      floating: false,
      snap: false,
    ),
  ),
);

double _headerObstruction(WidgetTester tester) => tester
    .renderObject<RenderSliver>(
      find.byType(SliverPersistentHeader, skipOffstage: false),
    )
    .geometry!
    .maxScrollObstructionExtent;

typedef _PageLayout = ({
  double obstruction,
  double paintExtent,
  Map<String, Rect> rects,
});

_PageLayout _capturePageLayout(
  WidgetTester tester,
  Key pageKey, {
  List<Key> keys = const [_body],
  bool search = false,
}) {
  final page = find.byKey(pageKey, skipOffstage: false);
  final pageBox = tester.renderObject<RenderBox>(page);
  final header = tester.renderObject<RenderSliver>(
    find.descendant(
      of: page,
      matching: find.byType(SliverPersistentHeader, skipOffstage: false),
    ),
  );
  Rect localRect(Finder target) {
    final box = tester.renderObject<RenderBox>(
      find.descendant(of: page, matching: target),
    );
    return MatrixUtils.transformRect(
      box.getTransformTo(pageBox),
      Offset.zero & box.size,
    );
  }

  return (
    obstruction: header.geometry!.maxScrollObstructionExtent,
    paintExtent: header.geometry!.paintExtent,
    rects: {
      for (final key in keys)
        key.toString(): localRect(find.byKey(key, skipOffstage: false)),
      if (search)
        'field': localRect(find.byType(EditableText, skipOffstage: false)),
    },
  );
}

void _expectPageLayout(_PageLayout actual, _PageLayout expected) {
  expect(actual.obstruction, expected.obstruction);
  expect(actual.paintExtent, expected.paintExtent);
  expect(actual.rects.keys, orderedEquals(expected.rects.keys));
  for (final entry in expected.rects.entries) {
    final rect = actual.rects[entry.key]!;
    expect(rect.left, closeTo(entry.value.left, 0.000001));
    expect(rect.top, closeTo(entry.value.top, 0.000001));
    expect(rect.width, closeTo(entry.value.width, 0.000001));
    expect(rect.height, closeTo(entry.value.height, 0.000001));
  }
}

Future<void> _sampleRouteFrames(
  WidgetTester tester,
  VoidCallback expectLayout,
) async {
  await tester.pump();
  expectLayout();
  for (var frame = 0; frame < 32; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
    expectLayout();
  }
}

Widget _fixedDetailPage(AdaptiveStyle style) => TestAdaptiveUiTheme(
  update: (theme) => theme.copyWith(style: style),
  child: Scaffold(
    key: _detailPage,
    resizeToAvoidBottomInset: false,
    body: CustomScrollView(
      slivers: [
        _bar(
          style,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(28),
            child: SafeArea(
              top: false,
              bottom: false,
              child: SizedBox(
                key: _footerContent,
                height: 28,
                width: double.infinity,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(key: _detailBody, height: 2200),
        ),
      ],
    ),
  ),
);

const _fixedDetailKeys = [
  _leading,
  _action,
  _title,
  _footerContent,
  _detailBody,
];

TopToolbarLayout? _resolveToolbar({
  TopToolbarLayoutOverride? topToolbarLayoutOverride,
  Rect viewBounds = _nativeView,
  Size viewSize = _size,
  List<Rect> occlusions = const [_status],
  Rect? pane,
  Rect? row,
}) {
  final viewport = pane ?? viewBounds;
  return TopToolbarLayoutResolver(
    viewBounds: viewBounds,
    viewSize: viewSize,
    occlusions: occlusions,
    pane: viewport,
    row:
        row ??
        Rect.fromLTWH(viewport.left, viewport.top + 82, viewport.width, 44),
    systemTopInset: 82,
    currentTopInset: 82,
    currentViewTopInset: 82,
    minimumTopInset: 0,
    alignmentHeight: 64,
    topToolbarLayoutOverride: topToolbarLayoutOverride,
  ).resolve();
}

void main() {
  group('TopToolbarLayoutResolver layout override contract', () {
    test(
      'a missing override resolves the current native geometry independently',
      () {
        expect(_resolveToolbar(), _acceptedOverrideLayout);
        expect(_resolveToolbar(occlusions: const []), isNull);
      },
    );

    test('an explicit override rejection cannot resolve independently', () {
      expect(
        _resolveToolbar(
          topToolbarLayoutOverride: (layout: null, viewportBounds: _nativeView),
        ),
        isNull,
      );
    });

    test(
      'an accepted override aligns rows in a pane away from the status block',
      () {
        const pane = Rect.fromLTWH(0, 0, 420, 951);
        expect(_resolveToolbar(pane: pane), isNull);
        for (final (height, top) in [(44.0, 28.0), (64.0, 18.0)]) {
          expect(
            _resolveToolbar(
              topToolbarLayoutOverride: (
                layout: _acceptedOverrideLayout,
                viewportBounds: _nativeView,
              ),
              pane: pane,
              row: Rect.fromLTWH(0, 82, 420, height),
            ),
            (
              topInset: top,
              minimumExtent: 82.0,
              bounds: Rect.fromLTWH(0, top, 420, height),
            ),
          );
        }
      },
    );

    test(
      'a nonzero native origin preserves shared alignment and local extent',
      () {
        const origin = Offset(37, 19);
        final view = _nativeView.shift(origin);
        expect(
          _resolveToolbar(
            topToolbarLayoutOverride: (
              layout: (
                topInset: 28.0,
                minimumExtent: 82.0,
                bounds: _acceptedOverrideLayout.bounds.shift(origin),
              ),
              viewportBounds: view,
            ),
            viewBounds: view,
            occlusions: [_status.shift(origin)],
            pane: const Rect.fromLTWH(37, 19, 420, 951),
          ),
          (
            topInset: 28.0,
            minimumExtent: 82.0,
            bounds: const Rect.fromLTWH(37, 47, 420, 44),
          ),
        );
      },
    );

    for (final root in <String, Rect?>{
      'missing': null,
      'different size': const Rect.fromLTWH(0, 0, 668, 951),
      'different origin': const Rect.fromLTWH(1, 0, 669, 951),
    }.entries) {
      test('an override with ${root.key} native root is rejected', () {
        expect(
          _resolveToolbar(
            topToolbarLayoutOverride: (
              layout: _acceptedOverrideLayout,
              viewportBounds: root.value,
            ),
          ),
          isNull,
        );
      });
    }

    test(
      'an accepted override cannot keep geometry after the native view resizes',
      () {
        expect(
          _resolveToolbar(
            topToolbarLayoutOverride: (
              layout: _acceptedOverrideLayout,
              viewportBounds: _nativeView,
            ),
            viewSize: const Size(668, 951),
          ),
          isNull,
        );
      },
    );

    test('an override without usable row geometry is rejected', () {
      expect(
        _resolveToolbar(
          topToolbarLayoutOverride: (
            layout: (topInset: 28.0, minimumExtent: 82.0, bounds: Rect.zero),
            viewportBounds: _nativeView,
          ),
        ),
        isNull,
      );
    });
  });

  for (final style in AdaptiveStyle.values) {
    for (final direction in TextDirection.values) {
      testWidgets(
        '$style portrait reclaims top space on the first layout in $direction',
        (tester) async {
          _configure(tester);
          final readout = _Readout();
          await tester.pumpWidget(
            _host(
              style: style,
              header: _bar(style),
              geometry: _geometry(),
              direction: direction,
              readout: readout,
            ),
          );
          expect(tester.getTopLeft(find.byKey(_body)).dy, 82);
          _expectToolbarSafe(tester);
          final leading = tester.getRect(find.byKey(_leading));
          final action = tester.getRect(find.byKey(_action));
          expect(leading.center.dy, 50);
          expect(action.center.dy, 50);
          if (style == AdaptiveStyle.apple) {
            expect(leading.top, 28);
            expect(leading.bottom, 72);
            expect(leading.height, 44);
          }
          expect(readout.body!.padding, _safeArea);
          expect(readout.body!.viewPadding, _safeArea);
          await tester.pumpAndSettle();
          expect(tester.getTopLeft(find.byKey(_body)).dy, 82);
          _expectToolbarSafe(tester);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      );
    }

    testWidgets(
      '$style keeps its bottom below the reclaimed toolbar',
      (tester) async {
        _configure(tester);
        await tester.pumpWidget(
          _host(
            style: style,
            geometry: _geometry(),
            header: _bar(
              style,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(28),
                child: SizedBox(key: _bottom, height: 28),
              ),
            ),
          ),
        );
        expect(tester.getTopLeft(find.byKey(_bottom)).dy, 82);
        expect(tester.getTopLeft(find.byKey(_body)).dy, 110);
        _expectToolbarSafe(tester);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    for (final fallback in [
      'disabled',
      'unavailable',
      'empty',
      'stale',
      'center camera',
      'full width',
      'lower camera',
      'incomplete camera',
      'interior obstruction',
      'overflow obstruction',
      'unknown viewport',
      'window controls',
      'missing corners',
    ]) {
      testWidgets(
        '$style keeps legacy top Safe Area for $fallback',
        (tester) async {
          _configure(tester);
          final geometry = switch (fallback) {
            'unavailable' => null,
            'empty' => _geometry(regions: const []),
            'stale' => _geometry(size: const Size(951, 669)),
            'center camera' => _geometry(
              regions: const [Rect.fromLTWH(285, 0, 100, 82)],
            ),
            'full width' => _geometry(
              regions: const [Rect.fromLTWH(0, 0, 669, 82)],
            ),
            'lower camera' => _geometry(
              regions: const [Rect.fromLTWH(525, 160, 144, 82)],
            ),
            'incomplete camera' => _geometry(
              regions: const [Rect.fromLTWH(620, 0, 49, 40)],
            ),
            'interior obstruction' => _geometry(
              regions: const [_status, Rect.fromLTWH(280, 24, 64, 32)],
            ),
            'overflow obstruction' => _geometry(
              regions: const [_status, Rect.fromLTWH(560, 40, 80, 64)],
            ),
            _ => _geometry(),
          };
          await tester.pumpWidget(
            _host(
              style: style,
              header: _bar(style),
              geometry: geometry,
              allow: fallback != 'disabled',
              knownViewport: fallback != 'unknown viewport',
              windowControls: fallback == 'window controls',
              corners: fallback == 'missing corners' ? null : BorderRadius.zero,
            ),
          );
          expect(tester.getTopLeft(find.byKey(_body)).dy, 82 + _height(style));
          expect(tester.takeException(), isNull);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      );
    }

    testWidgets(
      '$style resolves all top-right blocks before checking interior regions',
      (tester) async {
        _configure(tester);
        const shortBlock = Rect.fromLTWH(580, 0, 89, 64);
        const interiorBlock = Rect.fromLTWH(560, 40, 80, 35);
        for (final regions in const [
          [shortBlock, interiorBlock, _status],
          [_status, shortBlock, interiorBlock],
          [interiorBlock, _status, shortBlock],
        ]) {
          await tester.pumpWidget(
            _host(
              style: style,
              header: _bar(style),
              geometry: _geometry(regions: regions),
            ),
          );
          expect(tester.getTopLeft(find.byKey(_body)).dy, 82);
          expect(tester.getCenter(find.byKey(_leading)).dy, 50);
          expect(tester.getCenter(find.byKey(_action)).dy, 50);
          _expectToolbarSafe(tester);
        }
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      '$style invalidation and opt-out restore the current Safe Area',
      (tester) async {
        _configure(tester);
        Widget host(IosOcclusionGeometry? geometry, {bool allow = true}) =>
            _host(
              style: style,
              header: _bar(style),
              geometry: geometry,
              allow: allow,
            );
        await tester.pumpWidget(host(_geometry()));
        expect(tester.getTopLeft(find.byKey(_body)).dy, 82);
        await tester.pumpWidget(host(null));
        expect(tester.getTopLeft(find.byKey(_body)).dy, 82 + _height(style));
        await tester.pumpWidget(host(_geometry()));
        expect(tester.getTopLeft(find.byKey(_body)).dy, 82);
        await tester.pumpWidget(host(_geometry(), allow: false));
        expect(tester.getTopLeft(find.byKey(_body)).dy, 82 + _height(style));
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      '$style resized keyboard viewport retains conservative top protection',
      (tester) async {
        _configure(tester);
        await tester.pumpWidget(
          _host(
            style: style,
            header: _bar(style),
            geometry: _geometry(),
            keyboard: 300,
            resizeToAvoidBottomInset: true,
          ),
        );
        expect(tester.getTopLeft(find.byKey(_body)).dy, 82 + _height(style));
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      '$style large title retains safe actions while the toolbar pins',
      (tester) async {
        _configure(tester);
        final scroll = ScrollController();
        addTearDown(scroll.dispose);
        await tester.pumpWidget(
          _host(
            style: style,
            header: _bar(style, large: true),
            geometry: _geometry(),
            scrollController: scroll,
          ),
        );
        final expandedBodyTop = tester.getTopLeft(find.byKey(_body)).dy;
        expect(expandedBodyTop, greaterThan(82));
        _expectToolbarSafe(tester);
        for (final offset in [40.0, 120.0, 240.0]) {
          scroll.jumpTo(offset);
          await tester.pump();
          _expectToolbarSafe(tester);
        }
        final rect = tester.getRect(find.byKey(_action));
        expect(rect.bottom, lessThanOrEqualTo(82));
        expect(_headerObstruction(tester), greaterThanOrEqualTo(82));
        if (style == AdaptiveStyle.apple) {
          final leading = tester.getRect(find.byKey(_leading));
          expect(leading.top, 28);
          expect(leading.bottom, 72);
          expect(leading.height, 44);
          expect(leading.center.dy, 50);
        }
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  for (final variant in [
    'Apple fixed',
    'Apple selection',
    'Apple search',
    'Material fixed',
    'Material fixed without actions',
    'Material search sibling',
  ]) {
    for (final direction
        in variant.startsWith('Material fixed')
            ? TextDirection.values
            : const [TextDirection.ltr]) {
      testWidgets(
        '$variant footer retains its original horizontal Safe Area in $direction',
        (tester) async {
          _configure(tester);
          final readout = _Readout();
          final controller = TextEditingController();
          final focus = FocusNode();
          addTearDown(controller.dispose);
          addTearDown(focus.dispose);
          final style = variant.startsWith('Apple')
              ? AdaptiveStyle.apple
              : AdaptiveStyle.material;
          final footer = Builder(
            builder: (context) {
              readout.footer = MediaQuery.of(context);
              return const SizedBox(
                height: 28,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: SizedBox.expand(key: _footerContent),
                ),
              );
            },
          );
          final header = switch (variant) {
            'Apple selection' => CupertinoSliverSelectAppBar<String>(
              title: const Text('Selected 0'),
              selectAllLabel: 'Select All',
              doneLabel: 'Done',
              onSelectAll: () {},
              onDone: () {},
              collection: ActionCollection<String>(roots: const []),
              onInvoke: (_, _) {},
              bottom: footer,
              bottomExtent: 28,
            ),
            'Apple search' => _searchHeader(
              controller,
              focus,
              appleBottom: footer,
            ),
            'Material search sibling' => MultiSliver(
              children: [
                _searchHeader(controller, focus),
                SliverToBoxAdapter(child: SizedBox(height: 28, child: footer)),
              ],
            ),
            _ => _bar(
              style,
              centerTitle: variant.startsWith('Material fixed'),
              includeActions: variant != 'Material fixed without actions',
              titleText: variant.startsWith('Material fixed')
                  ? 'A long centered title constrained by the safe toolbar slots'
                  : 'Habits',
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: footer,
              ),
            ),
          };
          await tester.pumpWidget(
            _host(
              style: style,
              header: header,
              geometry: _geometry(),
              readout: readout,
              direction: direction,
            ),
          );
          await tester.pumpAndSettle();
          expect(readout.footer!.padding.left, 0);
          expect(readout.footer!.padding.right, 0);
          expect(readout.footer!.viewPadding.left, 0);
          expect(readout.footer!.viewPadding.right, 0);
          final footerRect = tester.getRect(find.byKey(_footerContent));
          expect(footerRect.left, 0);
          expect(footerRect.right, _size.width);
          expect(footerRect.top, 82);
          expect(tester.getTopLeft(find.byKey(_body)).dy, 110);
          expect(readout.body!.padding, _safeArea);
          expect(readout.body!.viewPadding, _safeArea);
          if (variant.startsWith('Material fixed')) {
            for (final key in [
              _leading,
              _title,
              if (variant == 'Material fixed') _action,
            ]) {
              final rect = tester.getRect(find.byKey(key));
              expect(rect.overlaps(_status), isFalse, reason: '$key: $rect');
              expect(rect.left, greaterThanOrEqualTo(0));
              expect(rect.right, lessThanOrEqualTo(_status.left));
            }
          }
          expect(tester.takeException(), isNull);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      );
    }
  }

  for (final platform in TargetPlatform.values) {
    for (final style in AdaptiveStyle.values) {
      for (final allow in [true, false]) {
        testWidgets(
          '$style on $platform honors the explicit portrait opt-in ($allow)',
          (tester) async {
            _configure(tester);
            final readout = _Readout();
            await tester.pumpWidget(
              _host(
                style: style,
                header: _bar(style),
                geometry: _geometry(),
                platform: platform,
                allow: allow,
                readout: readout,
              ),
            );
            expect(
              tester.getTopLeft(find.byKey(_body)).dy,
              allow ? 82 : 82 + _height(style),
            );
            final expectedCenter = allow ? 50 : 82 + _height(style) / 2;
            expect(tester.getCenter(find.byKey(_leading)).dy, expectedCenter);
            expect(tester.getCenter(find.byKey(_action)).dy, expectedCenter);
            expect(readout.body!.padding, _safeArea);
            expect(readout.body!.viewPadding, _safeArea);
            if (allow) _expectToolbarSafe(tester);
            expect(tester.takeException(), isNull);
          },
          variant: TargetPlatformVariant.only(platform),
        );
      }
    }
  }

  for (final variant in ['small', 'medium', 'large']) {
    for (final config in [
      (
        name: 'default row',
        floating: false,
        bottomHeight: null,
        toolbarHeight: 64.0,
        collapsedHeight: null,
        alignmentHeight: 64.0,
        smallExtent: 82.0,
        wideExtent: 82.0,
      ),
      (
        name: 'floating row without bottom',
        floating: true,
        bottomHeight: null,
        toolbarHeight: 64.0,
        collapsedHeight: null,
        alignmentHeight: 64.0,
        smallExtent: 82.0,
        wideExtent: 82.0,
      ),
      (
        name: 'floating row with zero bottom',
        floating: true,
        bottomHeight: 0.0,
        toolbarHeight: 64.0,
        collapsedHeight: null,
        alignmentHeight: 64.0,
        smallExtent: 82.0,
        wideExtent: 82.0,
      ),
      (
        name: 'floating row with footer',
        floating: true,
        bottomHeight: 28.0,
        toolbarHeight: 64.0,
        collapsedHeight: null,
        alignmentHeight: 64.0,
        smallExtent: 110.0,
        wideExtent: 110.0,
      ),
      (
        name: 'fixed row with footer',
        floating: false,
        bottomHeight: 28.0,
        toolbarHeight: 64.0,
        collapsedHeight: null,
        alignmentHeight: 64.0,
        smallExtent: 110.0,
        wideExtent: 110.0,
      ),
      (
        name: 'explicit collapsed height 64',
        floating: false,
        bottomHeight: null,
        toolbarHeight: 64.0,
        collapsedHeight: 64.0,
        alignmentHeight: 64.0,
        smallExtent: 82.0,
        wideExtent: 82.0,
      ),
      (
        name: 'larger caller collapsed height',
        floating: true,
        bottomHeight: 28.0,
        toolbarHeight: 64.0,
        collapsedHeight: 128.0,
        alignmentHeight: 64.0,
        smallExtent: 174.0,
        wideExtent: 128.0,
      ),
      (
        name: '100-point row',
        floating: false,
        bottomHeight: null,
        toolbarHeight: 100.0,
        collapsedHeight: null,
        alignmentHeight: 64.0,
        smallExtent: 100.0,
        wideExtent: 100.0,
      ),
      (
        name: '44-point row in the shared alignment band',
        floating: false,
        bottomHeight: null,
        toolbarHeight: 44.0,
        collapsedHeight: null,
        alignmentHeight: 64.0,
        smallExtent: 82.0,
        wideExtent: 92.0,
      ),
      (
        name: '100-point alignment band with footer',
        floating: true,
        bottomHeight: 28.0,
        toolbarHeight: 64.0,
        collapsedHeight: null,
        alignmentHeight: 100.0,
        smallExtent: 128.0,
        wideExtent: 128.0,
      ),
    ]) {
      testWidgets(
        '$variant applies the shared floor to ${config.name}',
        (tester) async {
          _configure(tester);
          final scroll = ScrollController();
          addTearDown(scroll.dispose);
          final bottomHeight = config.bottomHeight;
          await tester.pumpWidget(
            _host(
              style: AdaptiveStyle.material,
              header: _materialHeader(
                variant,
                toolbarHeight: config.toolbarHeight,
                collapsedHeight: config.collapsedHeight,
                floating: config.floating,
                bottom: bottomHeight == null
                    ? null
                    : PreferredSize(
                        preferredSize: Size.fromHeight(bottomHeight),
                        child: SizedBox(
                          key: _bottom,
                          width: double.infinity,
                          height: bottomHeight,
                        ),
                      ),
              ),
              geometry: _geometry(),
              topToolbarAlignmentHeight: config.alignmentHeight,
              scrollController: scroll,
            ),
          );
          scroll.jumpTo(400);
          await tester.pumpAndSettle();
          final sliver = tester.renderObject<RenderSliver>(
            find.byType(SliverAppBar),
          );
          final expectedExtent = variant == 'small'
              ? config.smallExtent
              : config.wideExtent;
          expect(sliver.geometry!.maxScrollObstructionExtent, expectedExtent);
          expect(sliver.geometry!.paintExtent, expectedExtent);
          if (bottomHeight != null && bottomHeight > 0) {
            final footer = tester.getRect(find.byKey(_bottom));
            expect(footer.top, greaterThanOrEqualTo(_status.bottom));
            expect(footer.left, 0);
            expect(footer.right, _size.width);
          }
          if (config.collapsedHeight == 128) {
            expect(
              tester
                  .widget<SliverAppBar>(find.byType(SliverAppBar))
                  .collapsedHeight,
              128,
            );
          }
          _expectToolbarSafe(tester);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      );
    }
  }

  for (final variant in ['medium', 'large']) {
    for (final fallback in [
      'unavailable',
      'stale',
      'unknown pane',
      'disabled',
    ]) {
      for (final explicitHeight in [false, true]) {
        testWidgets(
          '$variant preserves ${explicitHeight ? 'explicit' : 'default'} '
          'collapsed height for $fallback geometry',
          (tester) async {
            _configure(tester);
            final scroll = ScrollController();
            addTearDown(scroll.dispose);
            await tester.pumpWidget(
              _host(
                style: AdaptiveStyle.material,
                header: _materialHeader(
                  variant,
                  collapsedHeight: explicitHeight ? 64 : null,
                ),
                geometry: switch (fallback) {
                  'unavailable' => null,
                  'stale' => _geometry(size: const Size(668, 951)),
                  _ => _geometry(),
                },
                allow: fallback != 'disabled',
                knownViewport: fallback != 'unknown pane',
                scrollController: scroll,
              ),
            );
            scroll.jumpTo(400);
            await tester.pumpAndSettle();
            expect(
              tester
                  .widget<SliverAppBar>(find.byType(SliverAppBar))
                  .collapsedHeight,
              explicitHeight ? 64 : null,
            );
            expect(_headerObstruction(tester), explicitHeight ? 64 : 146);
            expect(tester.takeException(), isNull);
          },
          variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        );
      }
    }
  }

  testWidgets(
    'non-pinned Material header retains its top Safe Area',
    (tester) async {
      _configure(tester);
      await tester.pumpWidget(
        _host(
          style: AdaptiveStyle.material,
          header: _bar(AdaptiveStyle.material, pinned: false),
          geometry: _geometry(),
        ),
      );
      expect(tester.getTopLeft(find.byKey(_body)).dy, 146);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  for (final localTop in ['minimum', 'consumer']) {
    testWidgets(
      'Apple retains a larger $localTop top inset',
      (tester) async {
        _configure(tester);
        await tester.pumpWidget(
          _host(
            style: AdaptiveStyle.apple,
            header: _bar(
              AdaptiveStyle.apple,
              minimumTopInset: localTop == 'minimum' ? 50 : null,
            ),
            geometry: _geometry(),
            padding: localTop == 'consumer'
                ? const EdgeInsets.only(top: 132, bottom: 34)
                : _safeArea,
            corners: BorderRadius.circular(36),
          ),
        );
        expect(tester.getTopLeft(find.byKey(_body)).dy, 94);
        final leading = tester.getRect(find.byKey(_leading));
        expect(leading.top, 50);
        expect(leading.bottom, 94);
        _expectToolbarSafe(tester);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  testWidgets(
    'Apple retains its original row alignment without an alignment override',
    (tester) async {
      _configure(tester);
      await tester.pumpWidget(
        _host(
          style: AdaptiveStyle.apple,
          header: _bar(AdaptiveStyle.apple),
          geometry: _geometry(),
          topToolbarAlignmentHeight: null,
        ),
      );
      final leading = tester.getRect(find.byKey(_leading));
      expect(leading.top, 38);
      expect(leading.bottom, 82);
      expect(leading.height, 44);
      expect(tester.getTopLeft(find.byKey(_body)).dy, 82);
      _expectToolbarSafe(tester);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  for (final style in AdaptiveStyle.values) {
    testWidgets(
      '$style reclaimed row still clears the physical rounded corner',
      (tester) async {
        _configure(tester);
        await tester.pumpWidget(
          _host(
            style: style,
            header: _bar(style),
            geometry: _geometry(),
            corners: BorderRadius.circular(150),
          ),
        );
        expect(tester.getTopLeft(find.byKey(_body)).dy, 82);
        expect(tester.getRect(find.byKey(_leading)).left, greaterThan(44));
        _expectToolbarSafe(tester);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  testWidgets(
    'Apple selection commands share the reclaimed top row',
    (tester) async {
      _configure(tester);
      await tester.pumpWidget(
        _host(
          style: AdaptiveStyle.apple,
          geometry: _geometry(),
          header: CupertinoSliverSelectAppBar<String>(
            title: const Text('Selected 0'),
            selectAllLabel: 'Select All',
            doneLabel: 'Done',
            onSelectAll: () {},
            onDone: () {},
            collection: ActionCollection<String>(roots: const []),
            onInvoke: (_, _) {},
          ),
        ),
      );
      expect(tester.getTopLeft(find.byKey(_body)).dy, 82);
      for (final key in [
        const ValueKey('cupertino-select-all-top'),
        const ValueKey('cupertino-select-done'),
      ]) {
        final finder = find.byKey(key);
        final rect = tester.getRect(finder);
        expect(rect.overlaps(_status), isFalse);
        expect(rect.right, lessThanOrEqualTo(_status.left));
        expect(finder.hitTestable(), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'non-primary Material toolbar keeps caller-owned top geometry',
    (tester) async {
      _configure(tester);
      await tester.pumpWidget(
        _host(
          style: AdaptiveStyle.material,
          geometry: _geometry(),
          header: const WindowControlSliverAppBar(
            primary: false,
            pinned: true,
            toolbarHeight: 64,
            title: Text('Local toolbar'),
          ),
        ),
      );
      expect(tester.getTopLeft(find.byKey(_body)).dy, 64);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'floating Material search preserves the full protected band after scrolling',
    (tester) async {
      _configure(tester);
      final controller = TextEditingController(text: 'kept query');
      final focus = FocusNode();
      final scroll = ScrollController();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      addTearDown(scroll.dispose);
      await tester.pumpWidget(
        _host(
          style: AdaptiveStyle.material,
          geometry: _geometry(),
          scrollController: scroll,
          header: AdaptiveSliverSearchBar<String>(
            title: const Text('Habits'),
            controller: controller,
            focusNode: focus,
            isSearchActive: true,
            keyword: controller.text,
            collection: ActionCollection<String>(roots: const []),
            onInvoke: (_, _) {},
            onChanged: (_) {},
            onSearchActivated: () {},
            onSearchDismissed: () {},
            material: const MaterialSliverSearchBarConfig<String>(
              style: MaterialSliverSearchBarStyle(toolbarHeight: 64),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final offset in [0.0, 120.0, 240.0]) {
        scroll.jumpTo(offset);
        await tester.pumpAndSettle();
        final header = tester.renderObject<RenderSliver>(
          find.byType(SliverAppBar),
        );
        expect(header.geometry!.paintExtent, greaterThanOrEqualTo(82));
        expect(
          header.geometry!.maxScrollObstructionExtent,
          greaterThanOrEqualTo(82),
        );
        expect(find.byType(EditableText).hitTestable(), findsOneWidget);
        expect(
          tester.getRect(find.byType(EditableText)).overlaps(_status),
          isFalse,
        );
        expect(tester.takeException(), isNull);
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  for (final style in AdaptiveStyle.values) {
    testWidgets(
      '$style route transitions preserve top layout and recover focused search',
      (tester) async {
        _configure(tester);
        final controller = TextEditingController(text: 'kept through routes');
        final focus = FocusNode();
        final navigator = GlobalKey<NavigatorState>();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        await tester.pumpWidget(
          _host(
            style: style,
            geometry: _geometry(),
            navigatorKey: navigator,
            header: _searchHeader(controller, focus),
          ),
        );
        await tester.pumpAndSettle();
        focus.requestFocus();
        await tester.pumpAndSettle();
        final field = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        expect(_headerObstruction(tester), 82);
        final baseline = _capturePageLayout(tester, _page, search: true);
        void expectStableLayout() => _expectPageLayout(
          _capturePageLayout(tester, _page, search: true),
          baseline,
        );

        for (var cycle = 0; cycle < 2; cycle++) {
          unawaited(
            navigator.currentState!.push<void>(
              MaterialPageRoute<void>(
                builder: (context) =>
                    const Scaffold(body: Center(child: Text('Covered route'))),
              ),
            ),
          );
          await _sampleRouteFrames(tester, expectStableLayout);
          expect(controller.text, 'kept through routes');
          expect(
            tester.state<EditableTextState>(
              find.byType(EditableText, skipOffstage: false),
            ),
            same(field),
          );
          await tester.pumpAndSettle();

          navigator.currentState!.pop();
          await _sampleRouteFrames(tester, expectStableLayout);
          await tester.pumpAndSettle();
          expect(_headerObstruction(tester), 82);
          expect(tester.getTopLeft(find.byKey(_body)).dy, 82);
          expect(
            tester.state<EditableTextState>(find.byType(EditableText)),
            same(field),
          );
          expect(focus.hasFocus, isTrue);
          expect(controller.text, 'kept through routes');
          final fieldRect = tester.getRect(find.byType(EditableText));
          expect(fieldRect.overlaps(_status), isFalse);
          expect(fieldRect.right, lessThanOrEqualTo(_status.left));
          expect(tester.takeException(), isNull);
        }
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      '$style incoming and outgoing fixed bars keep their local layout every frame',
      (tester) async {
        _configure(tester);
        final navigator = GlobalKey<NavigatorState>();
        await tester.pumpWidget(
          _host(
            style: style,
            geometry: _geometry(),
            navigatorKey: navigator,
            header: _bar(style),
          ),
        );
        await tester.pumpAndSettle();
        final outgoing = _capturePageLayout(
          tester,
          _page,
          keys: const [_leading, _action, _title, _body],
        );
        unawaited(
          navigator.currentState!.push<void>(
            MaterialPageRoute<void>(builder: (_) => _fixedDetailPage(style)),
          ),
        );
        await tester.pump();
        final incoming = _capturePageLayout(
          tester,
          _detailPage,
          keys: _fixedDetailKeys,
        );
        expect(incoming.obstruction, 110);
        expect(incoming.rects[_detailBody.toString()]!.top, 110);
        expect(incoming.rects[_footerContent.toString()]!.top, 82);
        void expectLayouts() {
          _expectPageLayout(
            _capturePageLayout(
              tester,
              _page,
              keys: const [_leading, _action, _title, _body],
            ),
            outgoing,
          );
          if (find
              .byKey(_detailPage, skipOffstage: false)
              .evaluate()
              .isNotEmpty) {
            _expectPageLayout(
              _capturePageLayout(tester, _detailPage, keys: _fixedDetailKeys),
              incoming,
            );
          }
        }

        expectLayouts();
        await _sampleRouteFrames(tester, expectLayouts);
        await tester.pumpAndSettle();
        _expectToolbarSafe(tester);
        final footer = tester.getRect(find.byKey(_footerContent));
        expect(footer.left, 0);
        expect(footer.right, _size.width);
        navigator.currentState!.pop();
        await _sampleRouteFrames(tester, expectLayouts);
        await tester.pumpAndSettle();
        expect(find.byKey(_detailPage), findsNothing);
        _expectToolbarSafe(tester);
        expect(tester.getTopLeft(find.byKey(_body)).dy, 82);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      '$style ancestor route keeps branch search layout stable every frame',
      (tester) async {
        _configure(tester);
        final flow = GlobalKey<NavigatorState>();
        final branch = GlobalKey<NavigatorState>();
        final controller = TextEditingController(text: 'ancestor query');
        final focus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        await tester.pumpWidget(
          _host(
            style: style,
            geometry: _geometry(),
            header: _searchHeader(controller, focus),
            pageWrapper: (page) => Navigator(
              key: flow,
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => Navigator(
                  key: branch,
                  onGenerateRoute: (_) =>
                      MaterialPageRoute<void>(builder: (_) => page),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        focus.requestFocus();
        await tester.pumpAndSettle();
        final field = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        final baseline = _capturePageLayout(tester, _page, search: true);
        void expectLayout() {
          _expectPageLayout(
            _capturePageLayout(tester, _page, search: true),
            baseline,
          );
          expect(
            ModalRoute.of(
              tester.element(find.byKey(_page, skipOffstage: false)),
            )!.isCurrent,
            isTrue,
          );
          expect(controller.text, 'ancestor query');
        }

        unawaited(
          flow.currentState!.push<void>(
            MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('Settings')),
            ),
          ),
        );
        await _sampleRouteFrames(tester, expectLayout);
        await tester.pumpAndSettle();
        flow.currentState!.pop();
        await _sampleRouteFrames(tester, expectLayout);
        await tester.pumpAndSettle();
        expect(
          tester.state<EditableTextState>(find.byType(EditableText)),
          same(field),
        );
        expect(focus.hasFocus, isTrue);
        expect(
          tester.getRect(find.byType(EditableText)).overlaps(_status),
          isFalse,
        );
        expect(tester.getTopLeft(find.byKey(_body)).dy, 82);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      '$style canceled interactive back gesture keeps both page layouts stable',
      (tester) async {
        _configure(tester);
        final navigator = GlobalKey<NavigatorState>();
        final controller = TextEditingController(text: 'gesture query');
        final focus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        await tester.pumpWidget(
          _host(
            style: style,
            geometry: _geometry(),
            navigatorKey: navigator,
            header: _searchHeader(controller, focus),
          ),
        );
        await tester.pumpAndSettle();
        focus.requestFocus();
        await tester.pumpAndSettle();
        final outgoing = _capturePageLayout(tester, _page, search: true);
        final route = CupertinoPageRoute<void>(
          builder: (_) => _fixedDetailPage(style),
        );
        unawaited(navigator.currentState!.push<void>(route));
        await tester.pumpAndSettle();
        final incoming = _capturePageLayout(
          tester,
          _detailPage,
          keys: _fixedDetailKeys,
        );
        void expectLayouts() {
          _expectPageLayout(
            _capturePageLayout(tester, _page, search: true),
            outgoing,
          );
          _expectPageLayout(
            _capturePageLayout(tester, _detailPage, keys: _fixedDetailKeys),
            incoming,
          );
          expect(controller.text, 'gesture query');
          expect(tester.takeException(), isNull);
        }

        final gesture = await tester.startGesture(const Offset(2, 300));
        await gesture.moveBy(const Offset(20, 0));
        await tester.pump(const Duration(milliseconds: 16));
        await gesture.moveBy(const Offset(120, 0));
        await tester.pump(const Duration(milliseconds: 16));
        expect(navigator.currentState!.userGestureInProgress, isTrue);
        expect(route.animation!.value, inExclusiveRange(0, 1));
        expectLayouts();
        for (var frame = 0; frame < 4; frame++) {
          await gesture.moveBy(Offset(frame.isEven ? 16 : -16, 0));
          await tester.pump(const Duration(milliseconds: 16));
          expectLayouts();
        }
        await gesture.cancel();
        await _sampleRouteFrames(tester, expectLayouts);
        await tester.pumpAndSettle();
        expect(route.isCurrent, isTrue);
        expect(navigator.currentState!.canPop(), isTrue);
        _expectToolbarSafe(tester);
        final footer = tester.getRect(find.byKey(_footerContent));
        expect(footer.left, 0);
        expect(footer.right, _size.width);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      '$style search retains its field and focus through keyboard metrics',
      (tester) async {
        _configure(tester);
        final controller = TextEditingController(text: 'kept query');
        final focus = FocusNode();
        addTearDown(controller.dispose);
        addTearDown(focus.dispose);
        final readout = _Readout();
        Widget host(double keyboard) => _host(
          style: style,
          geometry: _geometry(),
          keyboard: keyboard,
          readout: readout,
          header: _searchHeader(controller, focus),
        );
        await tester.pumpWidget(host(0));
        await tester.pumpAndSettle();
        focus.requestFocus();
        await tester.pumpAndSettle();
        final field = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        for (final keyboard in [300.0, 0.0]) {
          await tester.pumpWidget(host(keyboard));
          await tester.pumpAndSettle();
          expect(
            tester.state<EditableTextState>(find.byType(EditableText)),
            same(field),
          );
          expect(focus.hasFocus, isTrue);
          expect(controller.text, 'kept query');
          expect(tester.getTopLeft(find.byKey(_body)).dy, 82);
          final fieldRect = tester.getRect(find.byType(EditableText));
          expect(fieldRect.overlaps(_status), isFalse);
          expect(fieldRect.right, lessThanOrEqualTo(_status.left));
          expect(readout.body!.viewInsets.bottom, keyboard);
          expect(readout.body!.viewPadding, _safeArea);
          expect(tester.takeException(), isNull);
        }
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }
}

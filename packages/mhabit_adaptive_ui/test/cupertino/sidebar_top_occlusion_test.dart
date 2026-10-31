// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart'
    show
        AdaptiveNavigationController,
        CupertinoSidebar,
        CupertinoSidebarCollapsedBarController,
        CupertinoSidebarToolbarGeometry,
        CupertinoSidebarToolbarRegion,
        SidebarLeadingScope;
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/shell/sidebar_adapter.dart'
    show SidebarTopToolbarLayoutOverrideResolver;
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_layout.dart';
import 'package:mhabit_adaptive_ui/src/window_control/occlusion_toolbar.dart'
    show TopToolbarLayoutOverride;

const _size = Size(669, 951);
const _status = Rect.fromLTWH(525, 0, 144, 82);
const _safeArea = EdgeInsets.only(top: 82, bottom: 34);
const _capsule = ValueKey('cupertino-sidebar-collapsed-capsule');
const _fixedHost = ValueKey('cupertino-sidebar-fixed-toolbar-host');
const _toggle = ValueKey('cupertino-sidebar-toggle');
const _body = ValueKey('sidebar-top-body');
const _footer = ValueKey('sidebar-top-footer');
const _action = ValueKey('sidebar-top-action');
const _leading = ValueKey('sidebar-top-leading');

enum _Header { search, fixed, select }

IosOcclusionGeometry _geometry({
  Rect region = _status,
  Size size = _size,
  bool empty = false,
}) => IosOcclusionGeometry(
  viewBounds: Offset.zero & size,
  activeOcclusionRegions: empty ? const [] : [region],
  hasVerticalSystemBar: false,
);

class _Fixture extends ChangeNotifier {
  _Fixture({
    this.style = AppleSidebarStyle.inset,
    this.direction = TextDirection.ltr,
    this.header = _Header.search,
    this.extent = const SideNavigationExtent(200),
    this.safeArea = _safeArea,
    this.hostLeftInset = 0,
  });

  final AppleSidebarStyle style;
  final TextDirection direction;
  final _Header header;
  final SideNavigationExtent extent;
  final EdgeInsets safeArea;
  final double hostLeftInset;
  final controller = TextEditingController();
  final focus = FocusNode();
  final navigator = GlobalKey<NavigatorState>();
  IosOcclusionGeometry? geometry = _geometry();
  bool allow = true;
  bool knownViewport = true;
  bool windowControls = false;
  CupertinoSidebarToolbarRegion? region;
  MediaQueryData? bodyMedia;
  MediaQueryData? footerMedia;

  void refresh() => notifyListeners();

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }
}

PreferredSizeWidget _footerWidget(_Fixture fixture) => PreferredSize(
  preferredSize: const Size.fromHeight(24),
  child: Builder(
    builder: (context) {
      fixture.footerMedia = MediaQuery.of(context);
      return const SafeArea(
        top: false,
        bottom: false,
        child: SizedBox(key: _footer, width: double.infinity, height: 24),
      );
    },
  ),
);

Widget _header(_Fixture fixture) {
  final footer = _footerWidget(fixture);
  return switch (fixture.header) {
    _Header.fixed => AdaptiveSliverAppBar.apple(
      height: 44,
      title: const Text('Habits'),
      leading: const SizedBox(key: _leading, width: 32, height: 32),
      actions: const [SizedBox(key: _action, width: 32, height: 32)],
      bottom: footer,
    ),
    _Header.select => CupertinoSliverSelectAppBar<String>(
      title: const Text('Selected 0'),
      selectAllLabel: 'Select All',
      doneLabel: 'Done',
      onSelectAll: () {},
      onDone: () {},
      collection: ActionCollection<String>(roots: const []),
      onInvoke: (_, _) {},
      bottom: footer,
      bottomExtent: 24,
    ),
    _Header.search => AdaptiveSliverSearchBar<String>.apple(
      title: const Text('Habits'),
      controller: fixture.controller,
      focusNode: fixture.focus,
      isSearchActive: fixture.controller.text.isNotEmpty,
      keyword: fixture.controller.text,
      collection: ActionCollection<String>(
        roots: [
          AdaptiveAction<String>.action(
            id: ActionId('action'),
            metadata: const ActionMetadata(label: 'Action'),
            payload: 'action',
          ),
        ],
      ),
      apple: CupertinoSliverSearchBarConfig<String>(
        bottom: footer,
        bottomExtent: 24,
        actions: CupertinoAppBarActionsConfig<String>(
          iconBuilder: (_, _) => const Icon(CupertinoIcons.circle),
          presentationForAction: (_, _) => CupertinoActionPresentation.iconOnly,
          actionButtonBuilder: (context, action, onPressed, defaultBuilder) =>
              KeyedSubtree(
                key: _action,
                child: defaultBuilder(context, action, onPressed),
              ),
        ),
      ),
      onInvoke: (_, _) {},
      onChanged: (_) {},
      onSearchActivated: () {},
      onSearchDismissed: () {},
    ),
  };
}

Widget _host(_Fixture fixture) => MaterialApp(
  navigatorKey: fixture.navigator,
  theme: ThemeData(platform: TargetPlatform.iOS),
  builder: (context, navigator) => ListenableBuilder(
    listenable: fixture,
    builder: (context, _) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: fixture.safeArea,
        viewPadding: fixture.safeArea,
        viewInsets: EdgeInsets.zero,
      ),
      child: AdaptiveWindowControlLayoutScope(
        horizontalAvoidance: EdgeInsets.zero,
        verticalAvoidance: EdgeInsets.zero,
        owner: WindowControlLayoutOwner.appBar,
        child: AdaptiveOcclusionLayout(
          geometry: fixture.geometry,
          systemSafeArea: fixture.safeArea,
          cornerRadii: BorderRadius.zero,
          hasWindowControls: fixture.windowControls,
          allowTopToolbarReclamation: fixture.allow,
          topToolbarAlignmentHeight: 64,
          child: OcclusionViewport(
            bounds: fixture.knownViewport
                ? Rect.fromLTWH(
                    fixture.hostLeftInset,
                    0,
                    _size.width - fixture.hostLeftInset,
                    _size.height,
                  )
                : null,
            child: Directionality(
              textDirection: fixture.direction,
              child: Padding(
                padding: EdgeInsets.only(left: fixture.hostLeftInset),
                child: navigator!,
              ),
            ),
          ),
        ),
      ),
    ),
  ),
  home: AppAdaptiveUiTheme(
    data: const AppAdaptiveUiThemeData(
      style: AdaptiveStyle.apple,
      // Exercise the existing Sidebar without changing the App's Duo policy.
      breakpoints: CustomBreakpoints(width: [600, 1000], height: [480, 900]),
    ),
    child: AdaptiveNavigationShell(
      selectedIndex: 0,
      appleSidebarStyle: fixture.style,
      sideNavigationExtent: fixture.extent,
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
            material: Icon(Icons.today),
            materialSelected: Icon(Icons.today),
            apple: Icon(CupertinoIcons.calendar),
            appleSelected: Icon(CupertinoIcons.calendar),
          ),
        ),
      ],
      onDestinationSelected: (_) {},
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: CustomScrollView(
          slivers: [
            ListenableBuilder(
              listenable: fixture,
              builder: (context, _) {
                fixture.region = SidebarLeadingScope.maybeOf(
                  context,
                )?.toolbarRegion;
                return _header(fixture);
              },
            ),
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  fixture.bodyMedia = MediaQuery.of(context);
                  return const SizedBox(key: _body, height: 1800);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

void _configure(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _size;
  addTearDown(tester.view.reset);
}

CupertinoSidebar _sidebar(WidgetTester tester) =>
    tester.widget<CupertinoSidebar>(find.byType(CupertinoSidebar));

Rect _localRect(WidgetTester tester, Finder finder) {
  final element = tester.element(finder);
  final box = tester.renderObject<RenderBox>(finder);
  final scaffold = element.findAncestorStateOfType<ScaffoldState>()!;
  final parent = scaffold.context.findRenderObject()! as RenderBox;
  return box.localToGlobal(Offset.zero, ancestor: parent) & box.size;
}

void _expectRawMedia(_Fixture fixture) {
  for (final data in [fixture.bodyMedia, fixture.footerMedia]) {
    expect(data, isNotNull);
    expect(data!.padding, fixture.safeArea);
    expect(data.viewPadding, fixture.safeArea);
    expect(data.viewInsets, EdgeInsets.zero);
  }
}

void _expectAccepted(
  WidgetTester tester,
  _Fixture fixture, {
  bool capsule = true,
}) {
  expect(fixture.region, isNotNull);
  expect(
    fixture.region!.bounds,
    Rect.fromLTRB(fixture.safeArea.left, 28, 525, 72),
  );
  expect(fixture.region!.minimumExtent, 82);
  expect(fixture.region!.maxCollapsedBarWidth, closeTo(161, .01));
  expect(tester.getRect(find.byKey(_fixedHost)).top, closeTo(28, .01));
  expect(_localRect(tester, find.byKey(_footer)).top, closeTo(82, .01));
  expect(_localRect(tester, find.byKey(_body)).top, closeTo(106, .01));
  expect(
    tester.getSize(find.byKey(_footer)).width,
    closeTo(
      tester.getSize(find.byKey(_body)).width -
          fixture.footerMedia!.padding.horizontal,
      .01,
    ),
  );
  _expectRawMedia(fixture);
  for (final key in [_action, const ValueKey('activate-cupertino-search')]) {
    final finder = find.byKey(key);
    if (finder.evaluate().isEmpty) continue;
    final rect = tester.getRect(finder);
    expect(rect.center.dy, closeTo(50, .01));
    expect(rect.overlaps(_status), isFalse);
    if (capsule) {
      expect(rect.overlaps(tester.getRect(find.byKey(_capsule))), isFalse);
    }
  }
  if (capsule) {
    final rect = tester.getRect(find.byKey(_capsule));
    expect(rect.center.dx, closeTo(_size.width / 2, .01));
    expect(rect.center.dy, closeTo(50, .01));
    expect(rect.width, lessThanOrEqualTo(161.01));
    expect(rect.overlaps(_status), isFalse);
    expect(find.byKey(_toggle).hitTestable(), findsOneWidget);
    final toggle = tester.getRect(find.byKey(_toggle));
    expect(toggle.center.dy, closeTo(50, .01));
    expect(toggle.overlaps(_status), isFalse);
  }
  expect(tester.takeException(), isNull);
}

void _expectLegacy(WidgetTester tester, _Fixture fixture) {
  final footerTop = 82 + _sidebar(tester).toolbarGeometry.height;
  expect(fixture.region, isNull);
  expect(tester.getRect(find.byKey(_fixedHost)).top, closeTo(82, .01));
  expect(_localRect(tester, find.byKey(_footer)).top, closeTo(footerTop, .01));
  expect(
    _localRect(tester, find.byKey(_body)).top,
    closeTo(footerTop + 24, .01),
  );
  _expectRawMedia(fixture);
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets(
    'a nested foreign Sidebar cannot borrow the outer presentation coordinates',
    (tester) async {
      _configure(tester);
      final outer = AdaptiveNavigationController(initialExpanded: false);
      final inner = AdaptiveNavigationController(initialExpanded: false);
      final collapsedBar = CupertinoSidebarCollapsedBarController();
      addTearDown(outer.dispose);
      addTearDown(inner.dispose);
      addTearDown(collapsedBar.dispose);
      const region = CupertinoSidebarToolbarRegion(
        bounds: Rect.fromLTWH(0, 28, 525, 44),
        minimumExtent: 82,
      );
      CupertinoSidebarToolbarRegion? acceptedRegion;
      TopToolbarLayoutOverride? topToolbarLayoutOverride;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: AdaptiveOcclusionLayout(
            geometry: _geometry(),
            systemSafeArea: _safeArea,
            cornerRadii: BorderRadius.zero,
            allowTopToolbarReclamation: true,
            child: CupertinoSidebarPresentationScope(
              controller: outer,
              collapsedBarEnabled: false,
              collapsedBarController: collapsedBar,
              toolbarGeometry: CupertinoSidebarToolbarGeometry.standard,
              child: CupertinoSidebar(
                controller: inner,
                toolbarRegion: region,
                content: const SizedBox.shrink(),
                child: Builder(
                  builder: (context) {
                    acceptedRegion = SidebarLeadingScope.maybeOf(
                      context,
                    )?.toolbarRegion;
                    topToolbarLayoutOverride =
                        SidebarTopToolbarLayoutOverrideResolver(
                          context: context,
                        ).resolve();
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(acceptedRegion, region);
      expect(topToolbarLayoutOverride, isNotNull);
      expect(topToolbarLayoutOverride!.layout, isNull);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  for (final header in _Header.values) {
    testWidgets(
      '$header rejects a Sidebar host that covers only part of the native view',
      (tester) async {
        _configure(tester);
        final fixture = _Fixture(header: header, hostLeftInset: 20);
        addTearDown(fixture.dispose);
        await tester.pumpWidget(_host(fixture));
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(find.byType(CupertinoSidebar)).dx, 20);
        expect(tester.getSize(find.byType(CupertinoSidebar)).width, 649);
        _expectLegacy(tester, fixture);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  for (final style in AppleSidebarStyle.values) {
    for (final direction in TextDirection.values) {
      testWidgets(
        '$style $direction keeps the actual collapsed controls and page aligned',
        (tester) async {
          _configure(tester);
          final fixture = _Fixture(style: style, direction: direction);
          addTearDown(fixture.dispose);
          await tester.pumpWidget(_host(fixture));
          // Layout is final before the capsule's ordinary fade/drop completes.
          _expectAccepted(tester, fixture, capsule: false);
          await tester.pumpAndSettle();
          _expectAccepted(tester, fixture);
          for (final expanded in [true, false]) {
            _sidebar(tester).controller.expanded = expanded;
            for (var frame = 0; frame < 12; frame++) {
              await tester.pump(const Duration(milliseconds: 20));
              _expectAccepted(tester, fixture, capsule: false);
              expect(
                find.byKey(_toggle).hitTestable().evaluate().length,
                lessThanOrEqualTo(1),
              );
            }
            await tester.pumpAndSettle();
            _expectAccepted(tester, fixture, capsule: !expanded);
            expect(find.byKey(_toggle).hitTestable(), findsOneWidget);
            final toggle = tester.getRect(find.byKey(_toggle));
            expect(toggle.center.dy, closeTo(50, .01));
            expect(toggle.overlaps(_status), isFalse);
          }
        },
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
      );
    }
  }

  for (final header in [_Header.fixed, _Header.select]) {
    testWidgets(
      '$header uses the same accepted row and restores its footer',
      (tester) async {
        _configure(tester);
        final fixture = _Fixture(
          style: AppleSidebarStyle.edge,
          direction: TextDirection.rtl,
          header: header,
        );
        addTearDown(fixture.dispose);
        await tester.pumpWidget(_host(fixture));
        await tester.pumpAndSettle();
        _expectAccepted(tester, fixture, capsule: header == _Header.fixed);
        if (header == _Header.select) {
          expect(find.byKey(_capsule).hitTestable(), findsNothing);
        }
        for (final key
            in header == _Header.fixed
                ? [_action]
                : [
                    const ValueKey('cupertino-select-all-top'),
                    const ValueKey('cupertino-select-done'),
                  ]) {
          final rect = tester.getRect(find.byKey(key));
          expect(rect.center.dy, closeTo(50, .01));
          expect(rect.overlaps(_status), isFalse);
        }
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  testWidgets(
    'system left padding protects the real leading without moving the capsule center',
    (tester) async {
      _configure(tester);
      final fixture = _Fixture(
        header: _Header.fixed,
        safeArea: const EdgeInsets.only(left: 20, top: 82, bottom: 34),
      );
      addTearDown(fixture.dispose);
      await tester.pumpWidget(_host(fixture));
      await tester.pumpAndSettle();
      _expectAccepted(tester, fixture);
      final leading = tester.getRect(find.byKey(_leading));
      expect(leading.left, greaterThanOrEqualTo(20));
      expect(leading.center.dy, closeTo(50, .01));
      expect(leading.overlaps(_status), isFalse);
      expect(leading.overlaps(tester.getRect(find.byKey(_capsule))), isFalse);
      expect(tester.getSize(find.byKey(_footer)).width, 649);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'all consumers fall back together and recover without losing search state',
    (tester) async {
      _configure(tester);
      final fixture = _Fixture();
      addTearDown(fixture.dispose);
      await tester.pumpWidget(_host(fixture));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
      await tester.pumpAndSettle();
      fixture.controller.text = 'retained query';
      fixture.refresh();
      await tester.pumpAndSettle();
      fixture.focus.requestFocus();
      await tester.pumpAndSettle();
      final field = tester.state<EditableTextState>(find.byType(EditableText));
      _expectAccepted(tester, fixture, capsule: false);
      final searchRect = tester.getRect(find.byType(EditableText));
      expect(searchRect.top, greaterThanOrEqualTo(28));
      expect(searchRect.bottom, lessThanOrEqualTo(72));
      expect(searchRect.overlaps(_status), isFalse);
      for (final failure in [
        'null',
        'empty',
        'size',
        'unknown',
        'optout',
        'width',
      ]) {
        fixture.geometry = switch (failure) {
          'null' => null,
          'empty' => _geometry(empty: true),
          'size' => _geometry(size: const Size(668, 951)),
          'width' => _geometry(region: const Rect.fromLTWH(400, 0, 269, 82)),
          _ => _geometry(),
        };
        fixture.knownViewport = failure != 'unknown';
        fixture.allow = failure != 'optout';
        fixture.refresh();
        await tester.pump();
        _expectLegacy(tester, fixture);
        expect(fixture.controller.text, 'retained query', reason: failure);
        expect(fixture.focus.hasFocus, isTrue, reason: failure);
        expect(
          tester.state<EditableTextState>(find.byType(EditableText)),
          same(field),
        );
        fixture.geometry = _geometry();
        fixture.knownViewport = true;
        fixture.allow = true;
        fixture.refresh();
        await tester.pump();
        _expectAccepted(tester, fixture, capsule: false);
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'a panel too narrow for the shared row rejects every consumer atomically',
    (tester) async {
      _configure(tester);
      final fixture = _Fixture(
        style: AppleSidebarStyle.edge,
        direction: TextDirection.rtl,
        extent: const SideNavigationExtent(180),
      );
      addTearDown(fixture.dispose);
      await tester.pumpWidget(_host(fixture));
      await tester.pumpAndSettle();
      _expectLegacy(tester, fixture);
      for (final expanded in [true, false]) {
        _sidebar(tester).controller.expanded = expanded;
        for (var frame = 0; frame < 12; frame++) {
          await tester.pump(const Duration(milliseconds: 20));
          _expectLegacy(tester, fixture);
        }
        await tester.pumpAndSettle();
        _expectLegacy(tester, fixture);
        expect(find.byKey(_toggle).hitTestable(), findsOneWidget);
        expect(
          tester.getRect(find.byKey(_toggle)).top,
          greaterThanOrEqualTo(82),
        );
      }
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  for (final allow in [false, true]) {
    testWidgets(
      'ancestor page transitions retain layout and focused query (allow: $allow)',
      (tester) async {
        _configure(tester);
        final fixture = _Fixture(
          style: AppleSidebarStyle.edge,
          direction: TextDirection.rtl,
        );
        fixture.allow = allow;
        addTearDown(fixture.dispose);
        await tester.pumpWidget(_host(fixture));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('activate-cupertino-search')),
        );
        await tester.pumpAndSettle();
        fixture.controller.text = 'kept through routes';
        fixture.refresh();
        fixture.focus.requestFocus();
        await tester.pumpAndSettle();
        final footerTop = allow ? 82.0 : 136.0;
        for (var cycle = 0; cycle < 2; cycle++) {
          unawaited(
            fixture.navigator.currentState!.push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('Settings')),
              ),
            ),
          );
          for (var frame = 0; frame < 20; frame++) {
            await tester.pump(const Duration(milliseconds: 20));
            expect(fixture.region != null, allow);
            final footer = find.byKey(_footer, skipOffstage: false);
            expect(_localRect(tester, footer).top, closeTo(footerTop, .01));
            expect(tester.takeException(), isNull);
          }
          fixture.navigator.currentState!.pop();
          for (var frame = 0; frame < 20; frame++) {
            await tester.pump(const Duration(milliseconds: 20));
            final footer = find.byKey(_footer, skipOffstage: false);
            expect(_localRect(tester, footer).top, closeTo(footerTop, .01));
            expect(tester.takeException(), isNull);
          }
          await tester.pumpAndSettle();
          if (allow) {
            _expectAccepted(tester, fixture, capsule: false);
          } else {
            _expectLegacy(tester, fixture);
          }
          expect(
            tester.widget<EditableText>(find.byType(EditableText)).controller,
            same(fixture.controller),
          );
          expect(fixture.controller.text, 'kept through routes');
          expect(fixture.focus.hasFocus, isTrue);
        }
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }
}

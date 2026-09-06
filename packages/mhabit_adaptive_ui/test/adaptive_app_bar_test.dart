import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_navigation_sidebar.dart';
import 'package:mhabit_adaptive_ui/src/shell/navigation_sidebar_app_bar_leading.dart';

Widget _host({required Widget appBar, TargetPlatform? platform}) => MaterialApp(
  theme: platform == null ? null : ThemeData(platform: platform),
  home: Scaffold(appBar: appBar as PreferredSizeWidget),
);

Widget _sidebarHost({required Widget child}) => MaterialApp(
  theme: ThemeData(platform: TargetPlatform.iOS),
  home: CupertinoNavigationSidebar(
    form: NavigationShellForm.constrainedSide,
    selectedIndex: 0,
    destinations: const [],
    onDestinationSelected: (_) {},
    auxiliaryDestinations: const [],
    selectedAuxiliaryIndex: null,
    onAuxiliaryDestinationSelected: null,
    sideNavigationExtent: const SideNavigationExtent(224),
    dragHandleBuilder: null,
    child: child,
  ),
);

void main() {
  test('Material app bar uses the Material default preferred height', () {
    const appBar = AdaptiveAppBar.material(title: Text('Settings'));

    expect(appBar.preferredSize, const Size.fromHeight(kToolbarHeight));
  });

  testWidgets('dispatches regular app bar to Material', (tester) async {
    await tester.pumpWidget(
      _host(
        appBar: const AdaptiveAppBar.material(
          title: Text('Settings'),
          leading: BackButton(),
          actions: [Icon(Icons.settings)],
          toolbarHeight: 64,
        ),
      ),
    );

    expect(find.byType(WindowControlAppBar), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(tester.getSize(find.byType(AppBar)).height, 64);
  });

  testWidgets('dispatches regular app bar to fixed Apple chrome', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        appBar: const AdaptiveAppBar(
          title: Text('Settings'),
          leading: BackButton(),
          actions: [Icon(CupertinoIcons.settings)],
          toolbarHeight: 44,
        ),
      ),
    );

    final wrapper = tester.widget<WindowControlCupertinoNavigationBar>(
      find.byType(WindowControlCupertinoNavigationBar),
    );
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(wrapper.automaticBackgroundVisibility, isTrue);
    expect(wrapper.enableBackgroundFilterBlur, isTrue);
    expect(wrapper.transitionBetweenRoutes, isFalse);
    expect(wrapper.backgroundColor, CupertinoColors.transparent);
    expect(tester.getSize(find.byType(CupertinoNavigationBar)).height, 44);
  });

  testWidgets('can disable automatic Apple background visibility', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        appBar: const AdaptiveAppBar.apple(
          title: Text('Debugger'),
          automaticBackgroundVisibility: false,
        ),
      ),
    );

    final wrapper = tester.widget<WindowControlCupertinoNavigationBar>(
      find.byType(WindowControlCupertinoNavigationBar),
    );
    expect(wrapper.automaticBackgroundVisibility, isFalse);
    expect(wrapper.enableBackgroundFilterBlur, isTrue);
  });

  testWidgets('Apple app bar keeps its toolbar below the iPad safe area', (
    tester,
  ) async {
    // FakeViewPadding uses physical pixels; the test view DPR is 3.0.
    tester.view.padding = const FakeViewPadding(top: 72);
    tester.view.viewPadding = const FakeViewPadding(top: 72);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        appBar: const AdaptiveAppBar(
          title: Text('Settings'),
          leading: AdaptiveBackButton.apple(),
          toolbarHeight: 44,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(CupertinoNavigationBar)).height, 68);
  });

  testWidgets('Apple app bar keeps sidebar and page leading separate', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: const NavigationSidebarAppBarLeading(
          toolbarAvoidance: EdgeInsets.zero,
          progress: 1,
          child: Scaffold(
            appBar: AdaptiveAppBar(
              title: Text('About'),
              leading: AdaptiveBackButton(type: AdaptiveBackButtonType.back),
              automaticallyImplyLeading: false,
              toolbarHeight: 44,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('cupertino-sidebar-leading-anchor')),
      findsOneWidget,
    );
    expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
  });

  testWidgets(
    'Apple Sidebar aligns regular and sliver 44pt toolbars below its safe area',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 600);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _sidebarHost(
          child: const Scaffold(
            appBar: AdaptiveAppBar.apple(title: Text('Settings')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final regularBar = find.descendant(
        of: find.byType(Scaffold),
        matching: find.byType(CupertinoNavigationBar),
      );
      expect(
        tester
            .widget<AdaptiveAppBar>(find.byType(AdaptiveAppBar))
            .preferredSize
            .height,
        kMinInteractiveDimensionCupertino,
      );
      expect(tester.getSize(regularBar).height, 54);
      final regularTitleCenter = tester.getCenter(find.text('Settings')).dy;

      await tester.pumpWidget(
        _sidebarHost(
          child: const Scaffold(
            body: CustomScrollView(
              slivers: [
                AdaptiveSliverAppBar.apple(
                  height: kMinInteractiveDimensionCupertino,
                  title: Text('Habits'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sliverBar = find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(CupertinoNavigationBar),
      );
      expect(tester.getSize(sliverBar).height, 54);
      expect(tester.getCenter(find.text('Habits')).dy, regularTitleCenter);
      expect(regularTitleCenter, 32);
    },
  );

  test('Apple app bar fixes its preferred toolbar height to 44pt', () {
    const appBar = AdaptiveAppBar.apple(title: Text('Settings'));

    expect(appBar.preferredSize, const Size.fromHeight(44));
  });
}

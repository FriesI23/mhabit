import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host({required Widget appBar, TargetPlatform? platform}) => MaterialApp(
  theme: platform == null ? null : ThemeData(platform: platform),
  home: Scaffold(appBar: appBar as PreferredSizeWidget),
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
    expect(wrapper.automaticBackgroundVisibility, isFalse);
    expect(wrapper.transitionBetweenRoutes, isFalse);
    expect(wrapper.backgroundColor, CupertinoColors.transparent);
    expect(tester.getSize(find.byType(CupertinoNavigationBar)).height, 44);
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

  test('Apple app bar fixes its preferred toolbar height to 44pt', () {
    const appBar = AdaptiveAppBar.apple(title: Text('Settings'));

    expect(appBar.preferredSize, const Size.fromHeight(44));
  });
}

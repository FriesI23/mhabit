import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  const destinations = [
    AdaptiveNavigationDestination(
      label: 'Habits',
      icons: NavigationDestinationIcons(
        material: Icon(Icons.home),
        materialSelected: Icon(Icons.home),
        apple: Icon(CupertinoIcons.home),
        appleSelected: Icon(CupertinoIcons.home),
      ),
    ),
  ];
  const settings = [
    AdaptiveNavigationDestination(
      label: 'Settings',
      icons: NavigationDestinationIcons(
        material: Icon(Icons.settings),
        materialSelected: Icon(Icons.settings),
        apple: Icon(CupertinoIcons.settings),
        appleSelected: Icon(CupertinoIcons.settings),
      ),
    ),
  ];

  for (final style in AppleSidebarStyle.values) {
    for (final direction in TextDirection.values) {
      testWidgets(
        '$style footer keeps primary width with $direction insets',
        (tester) async {
          tester.view.physicalSize = const Size(1000, 650);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: TargetPlatform.iOS),
              builder: (context, child) => Directionality(
                textDirection: direction,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    padding: direction == TextDirection.ltr
                        ? const EdgeInsets.only(right: 84)
                        : const EdgeInsets.only(left: 84),
                  ),
                  child: child!,
                ),
              ),
              home: AdaptiveNavigationShell(
                selectedIndex: 0,
                destinations: destinations,
                auxiliaryDestinations: settings,
                onDestinationSelected: (_) {},
                onAuxiliaryDestinationSelected: (_) {},
                appleSidebarStyle: style,
                child: const Scaffold(body: Text('Page')),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final primary = find.byKey(
            const ValueKey('cupertino-sidebar-destination-0'),
          );
          final auxiliary = find.byKey(
            const ValueKey('cupertino-sidebar-auxiliary-destination-0'),
          );
          expect(
            tester.getSize(auxiliary).width,
            tester.getSize(primary).width,
          );
          expect(tester.getSize(auxiliary).height, greaterThanOrEqualTo(44));
          expect(tester.takeException(), isNull);
        },
        variant: const TargetPlatformVariant({TargetPlatform.iOS}),
      );
    }
  }

  Future<MediaQueryData> resolve(
    WidgetTester tester, {
    required MediaQueryData media,
    EdgeInsets? adaptation,
    bool windowControls = false,
  }) async {
    late MediaQueryData result;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: media,
          child: AdaptiveWindowControlLayoutScope(
            hasWindowControlAvoidance: windowControls,
            horizontalAvoidance: EdgeInsets.zero,
            verticalAvoidance: EdgeInsets.zero,
            owner: WindowControlLayoutOwner.appBar,
            verticalSafeAreaAvoidance: adaptation,
            horizontalSafeAreaAvoidance: adaptation == null
                ? null
                : EdgeInsets.zero,
            effectiveCornerRadii: adaptation == null ? null : BorderRadius.zero,
            child: AdaptiveWindowTopSafeArea(
              child: Builder(
                builder: (context) {
                  result = MediaQuery.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ),
    );
    return result;
  }

  testWidgets('zero ordinary top uses reported corner adaptation', (
    tester,
  ) async {
    final media = await resolve(
      tester,
      media: const MediaQueryData(
        size: Size(900, 650),
        padding: EdgeInsets.only(right: 84, bottom: 34),
        viewPadding: EdgeInsets.only(right: 84, bottom: 34),
      ),
      adaptation: const EdgeInsets.only(top: 16),
    );
    expect(
      media.padding,
      const EdgeInsets.only(top: 16, right: 84, bottom: 34),
    );
    expect(media.viewPadding, media.padding);
    expect(media.size, const Size(900, 650));
  });

  testWidgets('ordinary status area is retained without duplicate top space', (
    tester,
  ) async {
    const original = MediaQueryData(
      padding: EdgeInsets.only(top: 82, bottom: 34),
      viewPadding: EdgeInsets.only(top: 82, bottom: 34),
    );
    expect(
      await resolve(tester, media: original, adaptation: EdgeInsets.zero),
      original,
    );
  });

  testWidgets('window controls keep their horizontal toolbar layout', (
    tester,
  ) async {
    const original = MediaQueryData(
      padding: EdgeInsets.only(bottom: 20),
      viewPadding: EdgeInsets.only(bottom: 20),
    );
    expect(
      await resolve(
        tester,
        media: original,
        adaptation: const EdgeInsets.only(top: 38),
        windowControls: true,
      ),
      original,
    );
  });

  for (final width in [800.0, 1000.0]) {
    for (final sliver in [false, true]) {
      testWidgets(
        'windowed toolbar and body stay aligned width=$width sliver=$sliver',
        (tester) async {
          tester.view.physicalSize = Size(width, 650);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          const bodyKey = ValueKey('windowed-body');
          final page = sliver
              ? const Scaffold(
                  body: CustomScrollView(
                    slivers: [
                      AdaptiveSliverAppBar.apple(
                        height: 44,
                        title: Text('Windowed title'),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(key: bodyKey, height: 100),
                      ),
                    ],
                  ),
                )
              : const Scaffold(
                  appBar: AdaptiveAppBar.apple(title: Text('Windowed title')),
                  body: SizedBox(key: bodyKey, height: 100),
                );
          Future<void> pump(double adaptation) async {
            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(platform: TargetPlatform.iOS),
                builder: (context, child) => AdaptiveWindowControlLayoutScope(
                  hasWindowControlAvoidance: true,
                  horizontalAvoidance: const EdgeInsets.only(left: 80),
                  verticalAvoidance: const EdgeInsets.only(top: 38),
                  horizontalSafeAreaAvoidance: const EdgeInsets.only(left: 80),
                  verticalSafeAreaAvoidance: EdgeInsets.only(top: adaptation),
                  effectiveCornerRadii: BorderRadius.circular(30),
                  owner: WindowControlLayoutOwner.appBar,
                  child: AdaptiveWindowTopSafeArea(child: child!),
                ),
                home: AdaptiveNavigationShell(
                  selectedIndex: 0,
                  destinations: destinations,
                  onDestinationSelected: (_) {},
                  child: page,
                ),
              ),
            );
            await tester.pumpAndSettle();
          }

          await pump(0);
          final title = find.text('Windowed title');
          final toggle = find.byKey(const ValueKey('cupertino-sidebar-toggle'));
          final titleCenter = tester.getCenter(title).dy;
          final bodyTop = tester.getTopLeft(find.byKey(bodyKey)).dy;
          expect(tester.getCenter(toggle).dy, titleCenter);
          await pump(38);
          expect(tester.getCenter(title).dy, titleCenter);
          expect(tester.getCenter(toggle).dy, titleCenter);
          expect(tester.getTopLeft(find.byKey(bodyKey)).dy, bodyTop);
          expect(tester.takeException(), isNull);
        },
        variant: const TargetPlatformVariant({TargetPlatform.iOS}),
      );
    }
  }

  testWidgets('unavailable corner geometry preserves other platforms', (
    tester,
  ) async {
    const original = MediaQueryData(
      padding: EdgeInsets.only(top: 24, left: 12),
      viewPadding: EdgeInsets.only(top: 24, left: 12),
    );
    expect(await resolve(tester, media: original), original);
  });

  testWidgets('corner top preserves keyboard and asymmetric horizontal edges', (
    tester,
  ) async {
    final media = await resolve(
      tester,
      media: const MediaQueryData(
        padding: EdgeInsets.only(left: 84, right: 12),
        viewPadding: EdgeInsets.only(left: 84, right: 12, bottom: 34),
        viewInsets: EdgeInsets.only(bottom: 300),
      ),
      adaptation: const EdgeInsets.only(top: 20),
    );
    expect(media.padding, const EdgeInsets.only(top: 20, left: 84, right: 12));
    expect(media.viewInsets.bottom, 300);
    expect(media.viewPadding.bottom, 34);
  });
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../harness/adaptive_ui_theme.dart';

const _windowChannel = MethodChannel('ios_window_control_layout');
const _eventsChannel = MethodChannel(
  'ios_window_control_layout/occlusion_changes',
);
const _navigationSurface = ValueKey('cupertino-navigation-surface');
const _actionSurface = ValueKey('cupertino-primary-action-surface');
const _list = ValueKey('floating-geometry-scroll-list');
const _safeArea = EdgeInsets.only(right: 84, bottom: 34);

Rect _barFrame(Size size) =>
    Rect.fromLTRB(size.width - 70, 124, size.width - 26, size.height - 34);

Map<String, double> _insets(EdgeInsets insets) => {
  'left': insets.left,
  'top': insets.top,
  'right': insets.right,
  'bottom': insets.bottom,
};

Map<String, Object?> _payload(Size size) => {
  'schemaVersion': 6,
  'isAvailable': true,
  'isPad': false,
  'isFullScreen': true,
  'baseMargins': _insets(EdgeInsets.zero),
  'horizontalMargins': _insets(EdgeInsets.zero),
  'verticalMargins': _insets(EdgeInsets.zero),
  'baseSafeArea': _insets(_safeArea),
  'horizontalSafeArea': _insets(_safeArea),
  'verticalSafeArea': _insets(_safeArea),
  'effectiveCornerRadii': {
    'topLeft': 0.0,
    'topRight': 0.0,
    'bottomLeft': 0.0,
    'bottomRight': 0.0,
  },
  'occlusionGeometry': {
    'viewBounds': {
      'x': 0.0,
      'y': 0.0,
      'width': size.width,
      'height': size.height,
    },
    'activeOcclusionRegions': [
      {'x': size.width - 84, 'y': 0.0, 'width': 84.0, 'height': 124.0},
    ],
    'hasVerticalSystemBar': true,
    'verticalBarLayoutFrame': {
      'x': _barFrame(size).left,
      'y': _barFrame(size).top,
      'width': _barFrame(size).width,
      'height': _barFrame(size).height,
    },
  },
};

Widget _host(ScrollController scroll, TextDirection direction) => MaterialApp(
  theme: ThemeData(platform: TargetPlatform.iOS),
  builder: (context, navigator) => Directionality(
    textDirection: direction,
    child: AdaptiveWindowControlLayout(child: navigator!),
  ),
  home: TestAdaptiveUiTheme(
    update: (theme) => theme.copyWith(style: AdaptiveStyle.apple),
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
        id: 'floating-scroll-geometry-action',
        label: 'New Habit',
        icon: const Icon(CupertinoIcons.add),
        onPressed: () {},
      ),
      child: Scaffold(
        body: ListView.builder(
          key: _list,
          controller: scroll,
          itemCount: 100,
          itemExtent: 60,
          itemBuilder: (context, index) => Text('Habit $index'),
        ),
      ),
    ),
  ),
);

void main() {
  for (final reportUnchangedMetrics in [false, true]) {
    for (final direction in TextDirection.values) {
      testWidgets(
        'Apple floating anchors stay stable during $direction scroll (redundant metrics: $reportUnchangedMetrics)',
        (tester) async {
          debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
          const size = Size(466, 678);
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          tester.view.padding = const FakeViewPadding(right: 84, bottom: 34);
          tester.view.viewPadding = const FakeViewPadding(
            right: 84,
            bottom: 34,
          );
          final scroll = ScrollController();
          final messenger = tester.binding.defaultBinaryMessenger;
          var queryCount = 0;
          final pending = Completer<Map<String, Object?>>();
          messenger.setMockMethodCallHandler(_eventsChannel, (_) async => null);
          messenger.setMockMethodCallHandler(_windowChannel, (_) async {
            queryCount++;
            return queryCount == 1 ? _payload(size) : pending.future;
          });
          try {
            await tester.pumpWidget(_host(scroll, direction));
            await tester.pumpAndSettle();
            expect(queryCount, 1);
            final originalNav = tester.getRect(find.byKey(_navigationSurface));
            final originalAction = tester.getRect(find.byKey(_actionSurface));
            if (direction == TextDirection.ltr) {
              expect(
                originalAction.center.dx,
                closeTo(_barFrame(size).center.dx, 0.01),
              );
            }
            final gesture = await tester.startGesture(
              tester.getCenter(find.byKey(_list)),
            );
            var minimumNavWidth = originalNav.width;
            for (var frame = 0; frame < 30; frame++) {
              await gesture.moveBy(
                const Offset(0, -12),
                timeStamp: Duration(milliseconds: (frame + 1) * 16),
              );
              // iOS can report metrics during scrolling without changing this
              // Flutter view. A slow query must not force an interim 84px inset.
              if (reportUnchangedMetrics) {
                tester.binding.handleMetricsChanged();
              }
              await tester.pump(const Duration(milliseconds: 16));
              final navigation = tester.getRect(find.byKey(_navigationSurface));
              final action = tester.getRect(find.byKey(_actionSurface));
              final navLeading = direction == TextDirection.ltr
                  ? navigation.left
                  : navigation.right;
              final expectedNavLeading = direction == TextDirection.ltr
                  ? originalNav.left
                  : originalNav.right;
              expect(
                navLeading,
                closeTo(expectedNavLeading, 0.01),
                reason: 'navigation anchor at scroll frame $frame',
              );
              // The action on the system's physical right edge is centered
              // in that column even while it shrinks from 50 to 44. The RTL
              // action is on the opposite edge and keeps its legacy anchor.
              final actionAnchor = direction == TextDirection.ltr
                  ? action.center.dx
                  : action.left;
              final expectedActionAnchor = direction == TextDirection.ltr
                  ? originalAction.center.dx
                  : originalAction.left;
              expect(
                actionAnchor,
                closeTo(expectedActionAnchor, 0.01),
                reason: 'action anchor at scroll frame $frame',
              );
              expect(action.bottom, closeTo(originalAction.bottom, 0.01));
              expect(navigation.bottom, closeTo(originalNav.bottom, 0.01));
              if (navigation.width < minimumNavWidth) {
                minimumNavWidth = navigation.width;
              }
            }
            await gesture.up();
            await tester.pumpAndSettle();
            expect(scroll.offset, greaterThan(0));
            expect(minimumNavWidth, lessThan(originalNav.width));
            expect(tester.takeException(), isNull);
          } finally {
            if (!pending.isCompleted) pending.complete(_payload(size));
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump();
            messenger.setMockMethodCallHandler(_windowChannel, null);
            messenger.setMockMethodCallHandler(_eventsChannel, null);
            scroll.dispose();
            tester.view.reset();
            debugDefaultTargetPlatformOverride = null;
          }
        },
      );
    }
  }
}

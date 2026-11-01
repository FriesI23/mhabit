import 'dart:async';
import 'dart:math' as math;

import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../harness/adaptive_ui_theme.dart';

const _windowChannel = MethodChannel('ios_window_control_layout');
const _eventsChannel = MethodChannel(
  'ios_window_control_layout/occlusion_changes',
);
const _size = Size(466, 678);
const _search = ValueKey('cupertino-expandable-search-region');
const _action = ValueKey('cupertino-primary-action-surface');
const _pageKey = GlobalObjectKey<_SearchPageState>('keyboard-search-page');

Map<String, double> _insets(EdgeInsets value) => {
  'left': value.left,
  'top': value.top,
  'right': value.right,
  'bottom': value.bottom,
};

Map<String, Object?> _payload(TextDirection direction, {bool vertical = true}) {
  final left = direction == TextDirection.rtl;
  final safeArea = EdgeInsets.only(
    left: left ? 84 : 0,
    right: left ? 0 : 84,
    bottom: 34,
  );
  return {
    'schemaVersion': 6,
    'isAvailable': true,
    'isPad': false,
    'isFullScreen': true,
    'baseMargins': _insets(EdgeInsets.zero),
    'horizontalMargins': _insets(EdgeInsets.zero),
    'verticalMargins': _insets(EdgeInsets.zero),
    'baseSafeArea': _insets(safeArea),
    'horizontalSafeArea': _insets(safeArea),
    'verticalSafeArea': _insets(safeArea.copyWith(top: 16)),
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
        'width': _size.width,
        'height': _size.height,
      },
      'activeOcclusionRegions': [
        {'x': left ? 0.0 : 382.0, 'y': 0.0, 'width': 84.0, 'height': 174.0},
      ],
      'hasVerticalSystemBar': vertical,
      'verticalBarLayoutFrame': {
        'x': left ? 26.0 : 396.0,
        'y': 174.0,
        'width': 44.0,
        'height': 470.0,
      },
    },
  };
}

Widget _host(TextDirection direction) => MaterialApp(
  theme: ThemeData(platform: TargetPlatform.iOS),
  builder: (context, navigator) => Directionality(
    textDirection: direction,
    child: AdaptiveWindowControlLayout(
      child: AdaptiveWindowTopSafeArea(child: navigator!),
    ),
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
        id: 'keyboard-search-action',
        label: 'New Habit',
        icon: const Icon(CupertinoIcons.add),
        onPressed: () {},
      ),
      child: const _SearchPage(key: _pageKey),
    ),
  ),
);

class _SearchPage extends StatefulWidget {
  const _SearchPage({super.key});

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  final controller = TextEditingController();
  final focus = FocusNode();
  bool active = false;

  void dismiss() {
    focus.unfocus();
    setState(() => active = false);
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        CupertinoSliverSearchBar<String>(
          title: const Text('Table Habit'),
          controller: controller,
          focusNode: focus,
          isSearchActive: active,
          keyword: controller.text,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => dismiss(),
          onSearchActivated: () => setState(() => active = true),
          onSearchDismissed: dismiss,
          collection: ActionCollection<String>(roots: const []),
          onInvoke: (_, _) {},
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 1400)),
      ],
    ),
  );
}

void _keyboardFrame(
  WidgetTester tester,
  TextDirection direction,
  double height,
) {
  // The engine publishes all view metrics together. TestFlutterView setters
  // notify individually, so batch them before one real binding notification.
  final dispatcher = tester.binding.platformDispatcher;
  dispatcher.onMetricsChanged = null;
  tester.view.viewInsets = FakeViewPadding(bottom: height);
  tester.view.padding = FakeViewPadding(
    left: direction == TextDirection.rtl ? 84 : 0,
    right: direction == TextDirection.ltr ? 84 : 0,
    bottom: math.max(0, 34 - height),
  );
  dispatcher.onMetricsChanged = tester.binding.handleMetricsChanged;
  tester.binding.handleMetricsChanged();
}

void _horizontalSafeAreaFrame(
  WidgetTester tester,
  TextDirection direction,
  double inset,
) {
  final dispatcher = tester.binding.platformDispatcher;
  dispatcher.onMetricsChanged = null;
  final padding = FakeViewPadding(
    left: direction == TextDirection.rtl ? inset : 0,
    right: direction == TextDirection.ltr ? inset : 0,
    bottom: 34,
  );
  tester.view.padding = padding;
  tester.view.viewPadding = padding;
  dispatcher.onMetricsChanged = tester.binding.handleMetricsChanged;
  tester.binding.handleMetricsChanged();
}

Future<void> _event(WidgetTester tester, {bool error = false}) {
  final complete = Completer<void>();
  tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    _eventsChannel.name,
    error
        ? const StandardMethodCodec().encodeErrorEnvelope(
            code: 'geometry-unavailable',
            message: 'Native geometry observation failed',
          )
        : const StandardMethodCodec().encodeSuccessEnvelope(null),
    (_) => complete.complete(),
  );
  return complete.future;
}

void main() {
  for (final direction in TextDirection.values) {
    for (final preference in ['brightness', 'text scale', 'accessibility']) {
      testWidgets('Search and FAB retain anchors after platform preference '
          '$preference and duplicate metrics in $direction', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final left = direction == TextDirection.rtl;
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = _size;
        tester.view.padding = FakeViewPadding(
          left: left ? 84 : 0,
          right: left ? 0 : 84,
          bottom: 34,
        );
        tester.view.viewPadding = FakeViewPadding(
          left: left ? 84 : 0,
          right: left ? 0 : 84,
          bottom: 34,
        );
        final pending = Completer<Map<String, Object?>>();
        var queries = 0;
        final messenger = tester.binding.defaultBinaryMessenger;
        final dispatcher = tester.binding.platformDispatcher;
        messenger.setMockMethodCallHandler(_eventsChannel, (_) async => null);
        messenger.setMockMethodCallHandler(_windowChannel, (_) async {
          return ++queries == 1 ? _payload(direction) : pending.future;
        });
        try {
          await tester.pumpWidget(_host(direction));
          await tester.pumpAndSettle();
          final before = tester.getRect(find.byKey(_search));
          final fab = tester.getRect(find.byKey(_action));
          final edge = left ? before.left : before.right;
          final originalMetrics = MediaQueryData.fromView(tester.view);
          switch (preference) {
            case 'brightness':
              dispatcher.platformBrightnessTestValue = Brightness.dark;
            case 'text scale':
              dispatcher.textScaleFactorTestValue = 1.25;
            case 'accessibility':
              dispatcher.accessibilityFeaturesTestValue =
                  const FakeAccessibilityFeatures(highContrast: true);
          }
          await tester.pump(const Duration(milliseconds: 16));
          final changedMetrics = MediaQueryData.fromView(tester.view);
          expect(changedMetrics.size, originalMetrics.size);
          expect(changedMetrics.viewPadding, originalMetrics.viewPadding);
          expect(changedMetrics.viewInsets, originalMetrics.viewInsets);

          // These settings have their own notifications. A later metrics
          // notification must not interpret their historical values as a
          // change to native occlusion coordinates.
          tester.binding.handleMetricsChanged();
          await tester.pump(const Duration(milliseconds: 16));
          expect(queries, greaterThan(1));
          expect(
            IosWindowControlLayout.read(
              _pageKey.currentContext!,
            ).occlusionGeometry,
            isNotNull,
          );
          final after = tester.getRect(find.byKey(_search));
          expect(left ? after.left : after.right, closeTo(edge, 0.01));
          expect(
            tester.getRect(find.byKey(_action)).center.dx,
            closeTo(fab.center.dx, 0.01),
          );

          await tester.tap(
            find.byKey(const ValueKey('activate-cupertino-search')),
          );
          await tester.pump(const Duration(milliseconds: 16));
          for (final height in [18.0, 103.0, 240.0, 310.0]) {
            _keyboardFrame(tester, direction, height);
            await tester.pump(const Duration(milliseconds: 16));
            final search = tester.getRect(find.byKey(_search));
            final action = tester.getRect(find.byKey(_action));
            expect(left ? search.left : search.right, closeTo(edge, 0.01));
            expect(action.center.dx, closeTo(fab.center.dx, 0.01));
            expect(action.bottom, closeTo(fab.bottom, 0.01));
          }
          await tester.testTextInput.receiveAction(TextInputAction.search);
          await tester.pump(const Duration(milliseconds: 16));
          for (final height in [240.0, 72.0, 0.0]) {
            _keyboardFrame(tester, direction, height);
            await tester.pump(const Duration(milliseconds: 16));
            final search = tester.getRect(find.byKey(_search));
            final action = tester.getRect(find.byKey(_action));
            expect(left ? search.left : search.right, closeTo(edge, 0.01));
            expect(action.center.dx, closeTo(fab.center.dx, 0.01));
            expect(action.bottom, closeTo(fab.bottom, 0.01));
          }
          pending.complete(_payload(direction));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        } finally {
          if (!pending.isCompleted) pending.complete(_payload(direction));
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          messenger.setMockMethodCallHandler(_windowChannel, null);
          messenger.setMockMethodCallHandler(_eventsChannel, null);
          dispatcher.clearPlatformBrightnessTestValue();
          dispatcher.clearTextScaleFactorTestValue();
          dispatcher.clearAccessibilityFeaturesTestValue();
          tester.view.reset();
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }
    testWidgets('Search and FAB keep their physical anchors during $direction '
        'keyboard opening and closing', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final left = direction == TextDirection.rtl;
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _size;
      tester.view.padding = FakeViewPadding(
        left: left ? 84 : 0,
        right: left ? 0 : 84,
        bottom: 34,
      );
      tester.view.viewPadding = FakeViewPadding(
        left: left ? 84 : 0,
        right: left ? 0 : 84,
        bottom: 34,
      );
      final pending = Completer<Map<String, Object?>>();
      var queries = 0;
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(_eventsChannel, (_) async => null);
      messenger.setMockMethodCallHandler(_windowChannel, (_) async {
        return ++queries == 1 ? _payload(direction) : pending.future;
      });
      try {
        await tester.pumpWidget(_host(direction));
        await tester.pumpAndSettle();
        final before = tester.getRect(find.byKey(_search));
        final fab = tester.getRect(find.byKey(_action));
        final expectedSearchEdge = left ? before.left : before.right;
        expect(fab.center.dx, closeTo(left ? 48 : 418, 0.01));
        await tester.tap(
          find.byKey(const ValueKey('activate-cupertino-search')),
        );
        await tester.pump(const Duration(milliseconds: 16));
        expect(_pageKey.currentState!.focus.hasFocus, isTrue);
        for (final closing in [false, true]) {
          if (closing) {
            await tester.testTextInput.receiveAction(TextInputAction.search);
            await tester.pump(const Duration(milliseconds: 16));
          }
          final frames = closing
              ? [280.0, 220.0, 150.0, 72.0, 24.0, 0.0]
              : [18.0, 54.0, 103.0, 170.0, 240.0, 310.0];
          for (final height in frames) {
            _keyboardFrame(tester, direction, height);
            await tester.pump(const Duration(milliseconds: 16));
            final search = tester.getRect(find.byKey(_search));
            final action = tester.getRect(find.byKey(_action));
            expect(
              left ? search.left : search.right,
              closeTo(expectedSearchEdge, 0.01),
              reason: 'Search edge at keyboard $height, closing: $closing',
            );
            expect(
              action.center.dx,
              closeTo(fab.center.dx, 0.01),
              reason: 'FAB center at keyboard $height, closing: $closing',
            );
            expect(action.bottom, closeTo(fab.bottom, 0.01));
          }
        }
        expect(queries, greaterThan(1), reason: 'native refreshes still run');
        pending.complete(_payload(direction));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      } finally {
        if (!pending.isCompleted) pending.complete(_payload(direction));
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        messenger.setMockMethodCallHandler(_windowChannel, null);
        messenger.setMockMethodCallHandler(_eventsChannel, null);
        tester.view.reset();
        debugDefaultTargetPlatformOverride = null;
      }
    });
    for (final error in [false, true]) {
      testWidgets('Search retains the current Safe Area after a native '
          '${error ? 'error' : 'invalidation'} in $direction', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final left = direction == TextDirection.rtl;
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = _size;
        tester.view.padding = FakeViewPadding(
          left: left ? 84 : 0,
          right: left ? 0 : 84,
          bottom: 34,
        );
        tester.view.viewPadding = FakeViewPadding(
          left: left ? 84 : 0,
          right: left ? 0 : 84,
          bottom: 34,
        );
        var pending = Completer<Map<String, Object?>>();
        var queries = 0;
        final messenger = tester.binding.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(_eventsChannel, (_) async => null);
        messenger.setMockMethodCallHandler(_windowChannel, (_) async {
          return ++queries == 1 ? _payload(direction) : pending.future;
        });
        try {
          await tester.pumpWidget(_host(direction));
          await tester.pumpAndSettle();
          final before = tester.getRect(find.byKey(_search));
          final expectedEdge = left ? before.left : before.right;

          await _event(tester, error: error);
          await tester.pump(const Duration(milliseconds: 16));
          expect(
            IosWindowControlLayout.of(
              _pageKey.currentContext!,
            ).occlusionGeometry,
            isNull,
            reason: 'Invalid geometry must not be cached to preserve layout',
          );
          if (error) {
            expect(tester.takeException(), isA<PlatformException>());
          }
          final search = tester.getRect(find.byKey(_search));
          expect(
            left ? search.left : search.right,
            closeTo(expectedEdge, 0.01),
          );
          final action = tester.getRect(find.byKey(_action));
          expect(
            left ? action.left : _size.width - action.right,
            greaterThanOrEqualTo(84),
            reason: 'An invalid snapshot must stop FAB space reclamation',
          );
          _horizontalSafeAreaFrame(tester, direction, 96);
          await tester.pump(const Duration(milliseconds: 16));
          final updatedSearch = tester.getRect(find.byKey(_search));
          expect(
            left ? updatedSearch.left : updatedSearch.right,
            closeTo(expectedEdge + (left ? 12 : -12), 0.01),
            reason: 'Fallback consumes current insets, not a cached edge',
          );
          _horizontalSafeAreaFrame(tester, direction, 84);
          await tester.pump(const Duration(milliseconds: 16));

          // A successful nonvertical environment must forget the conservative
          // toolbar signal, including on a later failed/invalidated query.
          if (error) await _event(tester);
          final restoring = pending;
          pending = Completer<Map<String, Object?>>();
          restoring.complete(_payload(direction, vertical: false));
          await tester.pumpAndSettle();
          final ordinary = tester.getRect(find.byKey(_search));
          final ordinaryEdge = left ? ordinary.left : ordinary.right;
          expect(ordinaryEdge, closeTo(left ? 32 : 434, 0.01));
          await _event(tester);
          await tester.pump(const Duration(milliseconds: 16));
          expect(
            IosWindowControlLayout.of(
              _pageKey.currentContext!,
            ).occlusionGeometry,
            isNull,
          );
          final invalidOrdinary = tester.getRect(find.byKey(_search));
          expect(
            left ? invalidOrdinary.left : invalidOrdinary.right,
            closeTo(ordinaryEdge, 0.01),
          );
          pending.complete(_payload(direction, vertical: false));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        } finally {
          if (!pending.isCompleted) {
            pending.complete(_payload(direction, vertical: false));
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          messenger.setMockMethodCallHandler(_windowChannel, null);
          messenger.setMockMethodCallHandler(_eventsChannel, null);
          tester.view.reset();
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }
  }
}

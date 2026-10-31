import 'dart:async';
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldable/foldable.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import 'harness/adaptive_ui_theme.dart';

FoldableData _snapshot(HingeStatus status, {bool horizontal = false}) =>
    FoldableData(
      capabilities: const FoldableCapabilities(
        supportLevel: FoldableSupportLevel.available,
        isFoldable: true,
        hingeApiPresent: true,
        regionApiPresent: true,
        angleUnitVerified: true,
        strategy: 'test',
      ),
      status: status,
      angleDegrees: status == HingeStatus.partiallyOpen ? 90 : 180,
      regions: [
        ReservedRegion(
          kind: ReservedRegionKind.division,
          bounds: horizontal
              ? const Rect.fromLTWH(0, 390, 1000, 20)
              : const Rect.fromLTWH(490, 0, 20, 800),
          isActive: true,
        ),
      ],
      displayFeatures: const [],
    );

class _FoldableSource extends FoldablePlatform {
  final eventsController = StreamController<FoldableData>.broadcast();
  FoldableData initial = _snapshot(HingeStatus.fullyOpen);
  var queries = 0;

  @override
  Future<FoldableData> getSnapshot() async {
    queries++;
    return initial;
  }

  @override
  Stream<FoldableData> get events => eventsController.stream;
}

void main() {
  late FoldablePlatform previous;
  late _FoldableSource source;

  setUp(() {
    previous = FoldablePlatform.instance;
    source = _FoldableSource();
    FoldablePlatform.instance = source;
  });

  tearDown(() async {
    FoldablePlatform.instance = previous;
    await source.eventsController.close();
  });

  Future<void> mount(
    WidgetTester tester,
    AdaptiveStyle style, {
    List<DisplayFeature> features = const [],
    bool adaptiveSheet = false,
    Offset? anchorPoint,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        // Deliberately oppose the native platform: style never chooses the source.
        theme: ThemeData(platform: TargetPlatform.android),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(displayFeatures: features),
          child: AdaptiveDisplayFeatureLayout(
            child: TestAdaptiveUiTheme(
              update: (theme) => theme.copyWith(style: style),
              child: child!,
            ),
          ),
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => adaptiveSheet
                  ? showAdaptiveSheet<void>(
                      context: context,
                      builder: (_) => const AdaptiveModal(
                        title: Text('Question'),
                        body: Text('Existing adaptive sheet'),
                      ),
                    )
                  : showAdaptiveModalDialog<void>(
                      context: context,
                      barrierDismissible: true,
                      anchorPoint: anchorPoint,
                      builder: (_) => const AdaptiveDialog(
                        title: Text('Question'),
                        content: Text('Existing adaptive dialog'),
                      ),
                    ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  for (final style in AdaptiveStyle.values) {
    testWidgets(
      'iOS $style trailing anchor follows fold direction and unfolding',
      (tester) async {
        source.initial = _snapshot(HingeStatus.partiallyOpen);
        await mount(
          tester,
          style,
          anchorPoint: const Offset(double.maxFinite, double.maxFinite),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final question = find.text('Question');
        final element = tester.element(question);
        expect(tester.getRect(question).left, greaterThanOrEqualTo(510));

        source.initial = _snapshot(HingeStatus.partiallyOpen, horizontal: true);
        source.eventsController.add(source.initial);
        await tester.pumpAndSettle();
        expect(tester.getRect(question).top, greaterThanOrEqualTo(410));
        expect(tester.getCenter(question).dx, closeTo(500, 1));
        expect(tester.element(question), same(element));

        source.initial = _snapshot(HingeStatus.fullyOpen, horizontal: true);
        source.eventsController.add(source.initial);
        await tester.pumpAndSettle();
        expect(tester.getCenter(question).dx, closeTo(500, 1));
        expect(tester.getRect(question).top, lessThan(400));
        expect(tester.element(question), same(element));
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'iOS $style reuses the existing adaptive sheet route',
      (tester) async {
        source.initial = _snapshot(HingeStatus.partiallyOpen);
        await mount(tester, style, adaptiveSheet: true);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.text('Question')).right,
          lessThanOrEqualTo(490),
        );
        final foldedCenter = tester.getCenter(find.text('Question')).dx;
        source.eventsController.add(_snapshot(HingeStatus.fullyOpen));
        await tester.pumpAndSettle();
        expect(
          tester.getCenter(find.text('Question')).dx,
          greaterThan(foldedCenter),
        );
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets(
      'Android $style keeps its native features and routes',
      (tester) async {
        const features = [
          DisplayFeature(
            bounds: Rect.fromLTWH(490, 0, 0, 800),
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ];
        await mount(tester, style, features: features);
        expect(find.byType(FoldableProvider), findsNothing);
        expect(source.queries, 0);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.text('Question')).right,
          lessThanOrEqualTo(490),
        );
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );

    testWidgets(
      'iOS $style feeds existing dialog routes without replacing state',
      (tester) async {
        source.initial = _snapshot(HingeStatus.partiallyOpen);
        await mount(tester, style);
        expect(
          tester
              .widget<FoldableProvider>(find.byType(FoldableProvider))
              .bridgeMode,
          DisplayFeatureBridgeMode.full,
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final element = tester.element(find.text('Question'));
        expect(
          tester.getRect(find.text('Question')).right,
          lessThanOrEqualTo(490),
        );
        source.eventsController.add(_snapshot(HingeStatus.fullyOpen));
        await tester.pumpAndSettle();
        expect(tester.element(find.text('Question')), same(element));
        expect(tester.getCenter(find.text('Question')).dx, greaterThan(400));
        source.eventsController.add(_snapshot(HingeStatus.closed));
        await tester.pumpAndSettle();
        expect(
          MediaQuery.displayFeaturesOf(tester.element(find.text('Question'))),
          isEmpty,
        );
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  testWidgets(
    'unsupported iOS retains the existing window',
    (tester) async {
      source.initial = FoldableData.unsupported;
      await mount(tester, AdaptiveStyle.apple);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        MediaQuery.displayFeaturesOf(tester.element(find.text('Question'))),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}

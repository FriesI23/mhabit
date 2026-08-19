import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  group('DeviceContext.of', () {
    testWidgets(
      'reads window size, platform and display features from the tree',
      (tester) async {
        const features = [
          DisplayFeature(
            bounds: Rect.fromLTWH(0, 100, 400, 24),
            type: DisplayFeatureType.fold,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ];
        await tester.pumpWidget(
          Theme(
            data: ThemeData(platform: TargetPlatform.iOS),
            child: const MediaQuery(
              data: MediaQueryData(
                size: Size(800, 600),
                displayFeatures: features,
              ),
              child: SizedBox(key: ValueKey('box')),
            ),
          ),
        );
        final context = tester.element(find.byKey(const ValueKey('box')));
        final device = DeviceContext.of(context);
        expect(device.windowSize, const Size(800, 600));
        expect(device.platform, TargetPlatform.iOS);
        expect(device.displayFeatures, same(features));
      },
    );

    testWidgets('defaults display features when unset', (tester) async {
      await tester.pumpWidget(
        Theme(
          data: ThemeData(platform: TargetPlatform.macOS),
          child: const MediaQuery(
            data: MediaQueryData(size: Size(300, 400)),
            child: SizedBox(key: ValueKey('box')),
          ),
        ),
      );
      final context = tester.element(find.byKey(const ValueKey('box')));
      final device = DeviceContext.of(context);
      expect(device.windowSize, const Size(300, 400));
      expect(device.platform, TargetPlatform.macOS);
      expect(device.displayFeatures, isEmpty);
    });
  });
}

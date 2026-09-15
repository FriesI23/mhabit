// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('Apple form fits and falls back $direction', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Future<void> pump(double width, double scale, bool enabled) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: MediaQuery(
                    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                    child: Directionality(
                      textDirection: direction,
                      child: AdaptiveChoiceListTile<int>.apple(
                        title: const Text('Appearance'),
                        subtitle: const Text('Choose the appearance'),
                        labels: const {
                          0: 'Follow system',
                          1: 'Light',
                          2: 'Dark',
                        },
                        value: 0,
                        onChanged: (_) {},
                        config: AdaptiveChoiceListTileConfig(
                          segmented: enabled
                              ? AdaptiveChoiceLayout.responsive
                              : AdaptiveChoiceLayout.stacked,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await pump(1000, 1, true);
      expect(
        tester.widget<AdaptiveListTile>(find.byType(AdaptiveListTile)).trailing,
        isNotNull,
      );
      final titleRect = tester.getRect(find.text('Appearance'));
      final controlRect = tester.getRect(
        find.byType(CupertinoSlidingSegmentedControl<int>),
      );
      expect(
        direction == TextDirection.ltr
            ? titleRect.right < controlRect.left
            : controlRect.right < titleRect.left,
        isTrue,
      );
      await pump(320, 2, true);
      expect(
        tester.widget<AdaptiveListTile>(find.byType(AdaptiveListTile)).trailing,
        isNull,
      );
      await pump(700, 3, true);
      expect(
        tester.widget<AdaptiveListTile>(find.byType(AdaptiveListTile)).trailing,
        isNull,
      );
      await pump(1000, 1, false);
      expect(
        tester.widget<AdaptiveListTile>(find.byType(AdaptiveListTile)).trailing,
        isNull,
      );
    });
  }
}

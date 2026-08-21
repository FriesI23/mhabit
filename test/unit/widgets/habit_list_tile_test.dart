// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/widgets/widgets.dart';

void main() {
  group('HabitListTileGeometry', () {
    test('calculates regular and compact viewport extents', () {
      const regular = HabitListTileGeometry(
        columnExtent: 60,
        viewportFraction: 0.5,
      );
      const compact = HabitListTileGeometry(
        columnExtent: 44,
        viewportFraction: 0.5,
      );

      expect(regular.computeColumnCount(600), 5);
      expect(regular.computeViewportExtent(600), 300);
      expect(compact.computeColumnCount(600), 6);
      expect(compact.computeViewportExtent(600), 264);
    });

    test('honors the minimum column count', () {
      const geometry = HabitListTileGeometry(
        columnExtent: 60,
        viewportFraction: 0.2,
      );

      expect(geometry.computeColumnCount(100, minCount: 3), 3);
      expect(geometry.computeViewportExtent(100, minCount: 3), 180);
      expect(
        () => geometry.computeColumnCount(100, minCount: 0),
        throwsAssertionError,
      );
    });

    test('resolves viewport fraction from expansion state', () {
      const collapsed = HabitListTileGeometry.fromExpansionState(
        columnExtent: 60,
        isExpanded: false,
        collapsedViewportFraction: 0.5,
        expandedViewportFraction: 0.85,
      );
      const expanded = HabitListTileGeometry.fromExpansionState(
        columnExtent: 60,
        isExpanded: true,
        collapsedViewportFraction: 0.5,
        expandedViewportFraction: 0.85,
      );

      expect(collapsed.viewportFraction, 0.5);
      expect(expanded.viewportFraction, 0.85);
    });
  });

  group('HabitListTile', () {
    const geometry = HabitListTileGeometry(
      columnExtent: 60,
      viewportFraction: 0.5,
    );

    Future<void> pumpTile(
      WidgetTester tester, {
      required double height,
      HabitListTilePhysicsBuilder? physicsBuilder,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: 600,
              height: height,
              child: HabitListTile(
                geometry: geometry,
                canScroll: true,
                itemCount: 10,
                minItemCoun: 1,
                height: height,
                padding: EdgeInsets.zero,
                scrollPhysicsBuilder: physicsBuilder,
                itemBuilder: (context, index, columnExtent) =>
                    SizedBox(key: ValueKey('cell-$index'), width: columnExtent),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'keeps column and viewport extents independent from row height',
      (tester) async {
        double? physicsItemSize;
        double? physicsViewportExtent;
        ScrollPhysics? buildPhysics(double itemSize, double viewportExtent) {
          physicsItemSize = itemSize;
          physicsViewportExtent = viewportExtent;
          return const PageScrollPhysics();
        }

        await pumpTile(tester, height: 64, physicsBuilder: buildPhysics);

        expect(tester.getSize(find.byKey(const ValueKey('cell-0'))).width, 60);
        expect(tester.getSize(find.byType(AnimatedContainer)).width, 300);
        expect(physicsItemSize, 60);
        expect(physicsViewportExtent, 300);
        expect(
          tester.widget<ListView>(find.byType(ListView)).physics,
          isA<PageScrollPhysics>(),
        );

        await pumpTile(tester, height: 96, physicsBuilder: buildPhysics);
        await tester.pumpAndSettle();

        expect(tester.getSize(find.byKey(const ValueKey('cell-0'))).width, 60);
        expect(tester.getSize(find.byType(AnimatedContainer)).width, 300);
        expect(physicsItemSize, 60);
        expect(physicsViewportExtent, 300);
      },
    );

    testWidgets('uses column extent for default magnet physics', (
      tester,
    ) async {
      await pumpTile(tester, height: 64);

      final physics = tester.widget<ListView>(find.byType(ListView)).physics;
      expect(physics, isA<MagnetScrollPhysics>());
      expect((physics! as MagnetScrollPhysics).itemSize, 60);
    });
  });
}

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
import 'package:mhabit/widgets/widgets.dart';

void main() {
  Future<MaterialBanner> pumpBanner(
    WidgetTester tester, {
    required TextDirection textDirection,
    required bool withLeading,
    required bool forceActionsBelow,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: textDirection,
          child: EdgeToEdgeMaterialBanner(
            leading: withLeading ? const Icon(Icons.warning) : null,
            content: const Text('Content'),
            actionArea: TextButton(onPressed: () {}, child: const Text('OK')),
            forceActionsBelow: forceActionsBelow,
          ),
        ),
      ),
    );
    return tester.widget<MaterialBanner>(find.byType(MaterialBanner));
  }

  void expectHorizontalSafeArea(
    EnhancedSafeArea safeArea, {
    required bool left,
    required bool right,
  }) {
    expect(safeArea.left, left);
    expect(safeArea.top, isFalse);
    expect(safeArea.right, right);
    expect(safeArea.bottom, isFalse);
  }

  testWidgets('distributes below-action insets across all LTR slots', (
    tester,
  ) async {
    final banner = await pumpBanner(
      tester,
      textDirection: TextDirection.ltr,
      withLeading: true,
      forceActionsBelow: true,
    );

    expectHorizontalSafeArea(
      banner.leading! as EnhancedSafeArea,
      left: true,
      right: false,
    );
    expectHorizontalSafeArea(
      banner.content as EnhancedSafeArea,
      left: false,
      right: true,
    );
    expectHorizontalSafeArea(
      banner.actions.single as EnhancedSafeArea,
      left: true,
      right: true,
    );
  });

  testWidgets('mirrors slot inset ownership in RTL', (tester) async {
    final banner = await pumpBanner(
      tester,
      textDirection: TextDirection.rtl,
      withLeading: true,
      forceActionsBelow: true,
    );

    expectHorizontalSafeArea(
      banner.leading! as EnhancedSafeArea,
      left: false,
      right: true,
    );
    expectHorizontalSafeArea(
      banner.content as EnhancedSafeArea,
      left: true,
      right: false,
    );
    expectHorizontalSafeArea(
      banner.actions.single as EnhancedSafeArea,
      left: true,
      right: true,
    );
  });

  testWidgets('assigns inline end inset to actions without a duplicate', (
    tester,
  ) async {
    final banner = await pumpBanner(
      tester,
      textDirection: TextDirection.ltr,
      withLeading: true,
      forceActionsBelow: false,
    );

    expectHorizontalSafeArea(
      banner.leading! as EnhancedSafeArea,
      left: true,
      right: false,
    );
    expectHorizontalSafeArea(
      banner.content as EnhancedSafeArea,
      left: false,
      right: false,
    );
    expectHorizontalSafeArea(
      banner.actions.single as EnhancedSafeArea,
      left: false,
      right: true,
    );
  });

  testWidgets('content owns the start inset when leading is absent', (
    tester,
  ) async {
    final banner = await pumpBanner(
      tester,
      textDirection: TextDirection.ltr,
      withLeading: false,
      forceActionsBelow: false,
    );

    expect(banner.leading, isNull);
    expectHorizontalSafeArea(
      banner.content as EnhancedSafeArea,
      left: true,
      right: false,
    );
    expectHorizontalSafeArea(
      banner.actions.single as EnhancedSafeArea,
      left: false,
      right: true,
    );
  });
}

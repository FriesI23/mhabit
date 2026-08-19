// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/widgets/_widgets/app_ui_layout_builder.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Future<void> pumpWithConstraints(
  WidgetTester tester, {
  required double width,
  required double height,
  required Widget child,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, height: height, child: child),
        ),
      ),
    ),
  );
}

Widget Function(BuildContext, WindowSize, Widget?) windowSizeTextBuilder() =>
    (context, windowSize, child) =>
        Text('${windowSize.width.name}/${windowSize.height?.name}');

void main() {
  group('WindowSizeClassLayoutBuilder', () {
    testWidgets('classifies the LayoutBuilder constraints', (tester) async {
      await pumpWithConstraints(
        tester,
        width: 700,
        height: 500,
        child: WindowSizeClassLayoutBuilder(builder: windowSizeTextBuilder()),
      );
      expect(find.text('medium/medium'), findsOneWidget);

      await pumpWithConstraints(
        tester,
        width: 500,
        height: 300,
        child: WindowSizeClassLayoutBuilder(builder: windowSizeTextBuilder()),
      );
      expect(find.text('compact/compact'), findsOneWidget);
    });

    testWidgets('.useScreenSize classifies the MediaQuery size', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(700, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WindowSizeClassLayoutBuilder.useScreenSize(
              builder: windowSizeTextBuilder(),
            ),
          ),
        ),
      );
      expect(find.text('medium/medium'), findsOneWidget);
    });

    testWidgets('custom scope thresholds drive the classification', (
      tester,
    ) async {
      const legacyThresholds = CustomBreakpoints(width: [600], height: [400]);
      await pumpWithConstraints(
        tester,
        width: 700,
        height: 450,
        child: BreakpointsScope(
          breakpoints: legacyThresholds,
          child: WindowSizeClassLayoutBuilder(builder: windowSizeTextBuilder()),
        ),
      );
      expect(find.text('medium/medium'), findsOneWidget);
    });
  });
}

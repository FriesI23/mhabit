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
import 'package:mhabit/widgets/widgets.dart';

void main() {
  testWidgets('provides Material while preserving inherited text style', (
    tester,
  ) async {
    const inheritedStyle = TextStyle(fontSize: 19, color: Colors.purple);
    MaterialInkController? material;
    TextStyle? textStyle;

    await tester.pumpWidget(
      MaterialApp(
        home: DefaultTextStyle(
          style: inheritedStyle,
          child: AdaptiveModalMaterialBridge(
            child: Builder(
              builder: (context) {
                material = Material.maybeOf(context);
                textStyle = DefaultTextStyle.of(context).style;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    expect(material, isNotNull);
    expect(textStyle, inheritedStyle);
  });
}

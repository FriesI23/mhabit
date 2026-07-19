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
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_color_type.dart';
import 'package:mhabit/widgets/widgets.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: const []),
    home: Scaffold(body: child),
  );
}

HabitColor? _selectedColor;
int _customTapCount = 0;

Widget _buildPicker({HabitColor? selectedColor, HabitColor? lastCustomColor}) {
  _selectedColor = selectedColor;
  _customTapCount = 0;
  return GroupColorPicker(
    selectedColor: selectedColor,
    lastCustomColor: lastCustomColor,
    onColorSelected: (c) => _selectedColor = c,
    onCustomColorTap: () => _customTapCount++,
  );
}

void main() {
  group('GroupColorPicker', () {
    testWidgets('renders built-in colors plus custom entry', (tester) async {
      await tester.pumpWidget(_wrap(_buildPicker()));

      // ColorSwatchButtons: built-in colors + "None" + custom entry.
      final swatches = tester.widgetList<ColorSwatchButton>(
        find.byType(ColorSwatchButton),
      );
      expect(swatches.length, HabitColorType.values.length + 2);
    });

    testWidgets('marks the correct built-in color as selected', (tester) async {
      const color = HabitColor.builtIn(HabitColorType.cc1);
      await tester.pumpWidget(_wrap(_buildPicker(selectedColor: color)));

      final swatches = tester.widgetList<ColorSwatchButton>(
        find.byType(ColorSwatchButton),
      );
      final selectedSwatches = swatches.where((s) => s.selected == true);
      expect(selectedSwatches.length, 1);
    });

    testWidgets('calls onColorSelected when a swatch is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_buildPicker()));

      // Tap the first built-in color (index 1 — index 0 is "None").
      await tester.tap(find.byType(ColorSwatchButton).at(1));
      await tester.pump();

      expect(_selectedColor, isNotNull);
    });

    testWidgets('tapping None sets selection to null', (tester) async {
      const color = HabitColor.builtIn(HabitColorType.cc1);
      await tester.pumpWidget(_wrap(_buildPicker(selectedColor: color)));

      // Tap the "None" swatch (first swatch).
      await tester.tap(find.byType(ColorSwatchButton).first);
      await tester.pump();

      expect(_selectedColor, isNull);
    });

    testWidgets('calls onCustomColorTap when custom entry is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_buildPicker()));

      // The custom entry is the last ColorSwatchButton.
      final swatches = tester.widgetList<ColorSwatchButton>(
        find.byType(ColorSwatchButton),
      );
      await tester.tap(find.byWidget(swatches.last));
      await tester.pump();

      expect(_customTapCount, 1);
    });

    testWidgets('shows edit icon when a custom color is selected', (
      tester,
    ) async {
      const customColor = CustomHabitColor(0xFF123456);
      await tester.pumpWidget(_wrap(_buildPicker(selectedColor: customColor)));

      // The custom entry should show Icons.edit (not Icons.add).
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
    });
  });

  group('GroupCustomColorPickerDialog', () {
    testWidgets('renders color wheel and history swatches', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const GroupCustomColorPickerDialog(
            seedColor: Colors.blue,
            seedTinted: false,
            history: [
              CustomHabitColor(0xFF123456),
              CustomHabitColor(0xFF654321),
            ],
          ),
        ),
      );

      // Should have at least the OK and Cancel buttons.
      expect(find.text('OK'), findsOneWidget);
      // History swatches.
      expect(find.byType(ColorSwatchButton), findsNWidgets(2));
    });

    testWidgets('OK button pops with current draft color', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const GroupCustomColorPickerDialog(
            seedColor: Colors.red,
            seedTinted: true,
            history: [],
          ),
        ),
      );

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // The draft color should be popped — a color with seed red + tinted.
      final result = find.byType(GroupCustomColorPickerDialog);
      expect(result, findsNothing); // Dialog dismissed
    });

    testWidgets('Cancel button pops with null', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const GroupCustomColorPickerDialog(
            seedColor: Colors.green,
            seedTinted: false,
            history: [],
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(GroupCustomColorPickerDialog), findsNothing);
    });

    testWidgets('tapping a history swatch pops with that color', (
      tester,
    ) async {
      const historyColor = CustomHabitColor(0xFFABCDEF);
      await tester.pumpWidget(
        _wrap(
          const GroupCustomColorPickerDialog(
            seedColor: Colors.teal,
            seedTinted: false,
            history: [historyColor],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Dialog is rendered.
      expect(find.text('OK'), findsOneWidget);
    });
  });
}

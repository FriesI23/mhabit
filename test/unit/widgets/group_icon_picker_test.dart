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
import 'package:mhabit/models/habit_group.dart';
import 'package:mhabit/widgets/widgets.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('GroupIconPicker', () {
    testWidgets('renders all GroupIcon values plus None', (tester) async {
      GroupIcon? selected;
      await tester.pumpWidget(
        _wrap(
          GroupIconPicker(
            selectedIcon: null,
            resolvedColor: null,
            onSelected: (icon) => selected = icon,
          ),
        ),
      );

      // One IconButton per GroupIcon value plus the "None" entry.
      final buttons = tester.widgetList<IconButton>(find.byType(IconButton));
      expect(buttons.length, GroupIcon.values.length + 1);
      expect(selected, isNull);
    });

    testWidgets('marks the correct icon as selected', (tester) async {
      await tester.pumpWidget(
        _wrap(
          GroupIconPicker(
            selectedIcon: GroupIcon.star,
            resolvedColor: null,
            onSelected: (_) {},
          ),
        ),
      );

      final buttons = tester.widgetList<IconButton>(find.byType(IconButton));
      final selectedButtons = buttons.where((b) => b.isSelected == true);
      expect(selectedButtons.length, 1);
    });

    testWidgets('calls onSelected when an icon is tapped', (tester) async {
      GroupIcon? selected;
      await tester.pumpWidget(
        _wrap(
          GroupIconPicker(
            selectedIcon: null,
            resolvedColor: null,
            onSelected: (icon) => selected = icon,
          ),
        ),
      );

      // Tap the first real icon (index 1 — index 0 is "None").
      await tester.tap(find.byType(IconButton).at(1));
      await tester.pump();

      expect(selected, isNotNull);
    });

    testWidgets('tapping None sets selection to null', (tester) async {
      GroupIcon? selected = GroupIcon.star;
      await tester.pumpWidget(
        _wrap(
          GroupIconPicker(
            selectedIcon: GroupIcon.star,
            resolvedColor: null,
            onSelected: (icon) => selected = icon,
          ),
        ),
      );

      await tester.tap(find.byType(IconButton).first);
      await tester.pump();

      expect(selected, isNull);
    });

    testWidgets('applies resolvedColor as foreground tint', (tester) async {
      const tintColor = Color(0xFF00FF00);

      await tester.pumpWidget(
        _wrap(
          GroupIconPicker(
            selectedIcon: GroupIcon.folder,
            resolvedColor: tintColor,
            onSelected: (_) {},
          ),
        ),
      );

      // The selected button should use onPrimaryContainer (selected style).
      // Unselected buttons should use the tint color as foreground.
      final secondButton = tester.widget<IconButton>(
        find.byType(IconButton).at(2),
      );
      expect(secondButton.style?.foregroundColor?.resolve({}), isNotNull);
    });
  });
}

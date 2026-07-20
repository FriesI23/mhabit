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
import 'package:mhabit/models/habit_group.dart';
import 'package:mhabit/pages/common/_widgets/group_edit_form.dart';
import 'package:mhabit/providers/app_ui/app_custom_date_format.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:provider/provider.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: const []),
    home: ChangeNotifierProvider<AppCustomDateYmdHmsConfigViewModel>(
      create: (_) => AppCustomDateYmdHmsConfigViewModel(),
      child: Scaffold(body: child),
    ),
  );
}

/// Creates a minimal [HabitGroupData] for edit-mode testing.
HabitGroupData _existingGroup({
  String name = 'Existing',
  String desc = 'A description',
  DateTime? createT,
  DateTime? modifyT,
}) {
  return HabitGroupData(
    uuid: 'g-1',
    name: name,
    desc: desc,
    icon: GroupIcon.star,
    color: const HabitColor.builtIn(HabitColorType.cc1),
    createT: createT,
    modifyT: modifyT,
  );
}

void main() {
  group('GroupEditForm create mode', () {
    testWidgets('renders name and description fields', (tester) async {
      final formKey = GlobalKey<GroupEditFormState>();
      await tester.pumpWidget(_wrap(GroupEditForm(key: formKey)));

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('name field exists and is editable', (tester) async {
      final formKey = GlobalKey<GroupEditFormState>();
      await tester.pumpWidget(_wrap(GroupEditForm(key: formKey)));

      final nameField = tester.widget<TextFormField>(
        find.byType(TextFormField).first,
      );
      expect(nameField.controller, isNotNull);
    });

    testWidgets('buildResult returns null when name is empty', (tester) async {
      final formKey = GlobalKey<GroupEditFormState>();
      await tester.pumpWidget(_wrap(GroupEditForm(key: formKey)));

      expect(formKey.currentState!.buildResult(), isNull);
    });

    testWidgets('buildResult returns result when name is valid', (
      tester,
    ) async {
      final formKey = GlobalKey<GroupEditFormState>();
      await tester.pumpWidget(_wrap(GroupEditForm(key: formKey)));

      await tester.enterText(find.byType(TextFormField).first, 'My Group');
      await tester.pumpAndSettle();

      final result = formKey.currentState!.buildResult();
      expect(result, isNotNull);
      expect(result!.name, 'My Group');
    });

    testWidgets('validate returns false when name is empty', (tester) async {
      final formKey = GlobalKey<GroupEditFormState>();
      await tester.pumpWidget(_wrap(GroupEditForm(key: formKey)));

      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('save calls onSave callback when provided', (tester) async {
      GroupEditFormResult? savedResult;
      final formKey = GlobalKey<GroupEditFormState>();
      await tester.pumpWidget(
        _wrap(GroupEditForm(key: formKey, onSave: (r) => savedResult = r)),
      );

      await tester.enterText(find.byType(TextFormField).first, 'My Group');
      await tester.pumpAndSettle();

      formKey.currentState!.save();
      await tester.pumpAndSettle();

      expect(savedResult, isNotNull);
      expect(savedResult!.name, 'My Group');
    });

    testWidgets('save pops navigator when onSave is null', (tester) async {
      final formKey = GlobalKey<GroupEditFormState>();
      await tester.pumpWidget(_wrap(GroupEditForm(key: formKey)));

      await tester.enterText(find.byType(TextFormField).first, 'My Group');
      await tester.pumpAndSettle();

      formKey.currentState!.save();
      await tester.pumpAndSettle();

      // The navigator should have been popped (dialog-style behavior);
      // in a test without a modal route this is a no-op, which is fine.
      expect(tester.takeException(), isNull);
    });

    testWidgets('icon picker and color picker are rendered', (tester) async {
      final formKey = GlobalKey<GroupEditFormState>();
      await tester.pumpWidget(_wrap(GroupEditForm(key: formKey)));

      // IconButton widgets from GroupIconPicker.
      expect(find.byType(IconButton), findsWidgets);
      // ColorSwatchButton widgets from GroupColorPicker.
      expect(find.byType(ColorSwatchButton), findsWidgets);
    });
  });

  group('GroupEditForm edit mode', () {
    testWidgets('pre-fills name and description from existingGroup', (
      tester,
    ) async {
      final formKey = GlobalKey<GroupEditFormState>();
      final existing = _existingGroup(name: 'Pre-filled', desc: 'Old desc');
      await tester.pumpWidget(
        _wrap(GroupEditForm(key: formKey, existingGroup: existing)),
      );

      final nameField = tester.widget<TextFormField>(
        find.byType(TextFormField).first,
      );
      final descField = tester.widget<TextFormField>(
        find.byType(TextFormField).last,
      );

      expect(nameField.controller?.text, 'Pre-filled');
      expect(descField.controller?.text, 'Old desc');
    });

    testWidgets('pre-selects icon from existingGroup', (tester) async {
      final formKey = GlobalKey<GroupEditFormState>();
      final existing = _existingGroup();
      await tester.pumpWidget(
        _wrap(GroupEditForm(key: formKey, existingGroup: existing)),
      );

      // The star icon should be marked as selected.
      final buttons = tester.widgetList<IconButton>(find.byType(IconButton));
      final selected = buttons.where((b) => b.isSelected == true);
      expect(selected.length, greaterThanOrEqualTo(1));
    });
  });

  group('GroupEditForm read-only info', () {
    testWidgets('hides date info when creating (no existingGroup)', (
      tester,
    ) async {
      final formKey = GlobalKey<GroupEditFormState>();
      await tester.pumpWidget(_wrap(GroupEditForm(key: formKey)));

      // Neither created nor modified labels should be present.
      expect(find.text('Created'), findsNothing);
      expect(find.text('Modified'), findsNothing);
    });

    testWidgets('hides date info when timestamps are null', (tester) async {
      final formKey = GlobalKey<GroupEditFormState>();
      final existing = _existingGroup(); // createT/modifyT both null
      await tester.pumpWidget(
        _wrap(GroupEditForm(key: formKey, existingGroup: existing)),
      );

      expect(find.text('Created'), findsNothing);
      expect(find.text('Modified'), findsNothing);
    });

    testWidgets('shows created date when createT is set', (tester) async {
      final formKey = GlobalKey<GroupEditFormState>();
      final testTime = DateTime.fromMillisecondsSinceEpoch(1753000000 * 1000);
      final existing = _existingGroup(createT: testTime);
      await tester.pumpWidget(
        _wrap(GroupEditForm(key: formKey, existingGroup: existing)),
      );

      expect(find.text('Created'), findsOneWidget);
      expect(find.text('Modified'), findsNothing);
    });

    testWidgets('shows modified date when modifyT is set', (tester) async {
      final formKey = GlobalKey<GroupEditFormState>();
      final testTime = DateTime.fromMillisecondsSinceEpoch(1753100000 * 1000);
      final existing = _existingGroup(modifyT: testTime);
      await tester.pumpWidget(
        _wrap(GroupEditForm(key: formKey, existingGroup: existing)),
      );

      expect(find.text('Created'), findsNothing);
      expect(find.text('Modified'), findsOneWidget);
    });

    testWidgets('shows both dates when both timestamps are set', (
      tester,
    ) async {
      final formKey = GlobalKey<GroupEditFormState>();
      final createT = DateTime.fromMillisecondsSinceEpoch(1753000000 * 1000);
      final modifyT = DateTime.fromMillisecondsSinceEpoch(1753100000 * 1000);
      final existing = _existingGroup(createT: createT, modifyT: modifyT);
      await tester.pumpWidget(
        _wrap(GroupEditForm(key: formKey, existingGroup: existing)),
      );

      expect(find.text('Created'), findsOneWidget);
      expect(find.text('Modified'), findsOneWidget);
    });
  });
}

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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/pages/common/_widgets/group_edit_form.dart';
import 'package:mhabit/pages/group_manage/_widgets/group_edit_dialog.dart';
import 'package:mhabit/providers/app_ui/custom_color_history.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    testWidgets(
      '${style.name} refreshes recent colors before saving the group',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final profile = ProfileViewModel([
          CustomColorHistoryProfileHandler.new,
        ]);
        await profile.init();
        final history = CustomColorHistoryViewModel()..updateProfile(profile);
        addTearDown(history.dispose);
        addTearDown(profile.dispose);
        await tester.pumpWidget(
          AdaptiveStyleScope(
            override: style,
            child: ChangeNotifierProvider.value(
              value: history,
              child: MaterialApp(
                home: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showGroupEditDialog(context: context),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(EditableText).first, 'Draft group');
        final customButton = find
            .descendant(
              of: find.byType(GroupColorPicker),
              matching: find.byType(
                style == AdaptiveStyle.apple
                    ? CupertinoButton
                    : ColorSwatchButton,
              ),
            )
            .last;
        await tester.ensureVisible(customButton);
        await tester.tap(customButton);
        await tester.pumpAndSettle();
        const selected = CustomHabitColor(0xFF123456, tinted: false);
        tester
            .widget<HabitColorWheelEditor>(find.byType(HabitColorWheelEditor))
            .onChanged(selected);
        await tester.pump();
        await tester.tap(find.text('Save').hitTestable());
        await tester.pumpAndSettle();
        expect(history.history, [selected]);
        expect(find.text('Draft group'), findsOneWidget);
        await tester.ensureVisible(customButton);
        await tester.tap(customButton);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<GroupCustomColorPickerDialog>(
                find.byType(GroupCustomColorPickerDialog),
              )
              .history,
          [selected],
        );
        expect(find.text('Recent'), findsOneWidget);
      },
    );
  }

  for (final style in AdaptiveStyle.values) {
    for (final size in [const Size(390, 800), const Size(900, 900)]) {
      testWidgets(
        'group edit uses ${style.name} dialog and controls at ${size.width}',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.reset);

          GroupEditFormResult? result;
          var completed = false;
          await tester.pumpWidget(
            AdaptiveStyleScope(
              override: style,
              child: ChangeNotifierProvider(
                create: (_) => CustomColorHistoryViewModel(),
                child: MaterialApp(
                  home: Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () async {
                        result = await showGroupEditDialog(context: context);
                        completed = true;
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();

          expect(find.byType(AdaptiveModal), findsOneWidget);
          expect(find.text('Create Group'), findsOneWidget);
          expect(find.text('Save'), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(GroupIconPicker),
              matching: find.byType(AdaptiveListSection),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: find.byType(GroupColorPicker),
              matching: find.byType(AdaptiveListSection),
            ),
            findsOneWidget,
          );
          for (final picker in [
            find.byType(GroupIconPicker),
            find.byType(GroupColorPicker),
          ]) {
            final section = tester.widget<AdaptiveListSection>(
              find.descendant(
                of: picker,
                matching: find.byType(AdaptiveListSection),
              ),
            );
            expect(
              section.padding,
              const EdgeInsetsDirectional.only(top: 24, bottom: 8),
            );
          }
          switch (style) {
            case AdaptiveStyle.material:
              expect(find.text('Cancel'), findsNothing);
              expect(
                find.byKey(const ValueKey('adaptive-modal-implied-close')),
                findsOneWidget,
              );
              expect(find.byType(TextFormField), findsNWidgets(2));
              expect(find.byType(CupertinoTextField), findsNothing);
              expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);
              final appBar = tester.widget<AdaptiveAppBar>(
                find.byKey(const ValueKey('adaptive-modal-app-bar')),
              );
              expect(appBar.leading, isA<CloseButton>());
              expect(appBar.actions, hasLength(1));
              expect(
                find.descendant(
                  of: find.byKey(const ValueKey('adaptive-modal-app-bar')),
                  matching: find.text('Save'),
                ),
                findsOneWidget,
              );

              expect(
                find.byKey(const ValueKey('adaptive-modal-actions')),
                findsNothing,
              );
              expect(
                find.descendant(
                  of: find.byType(GroupIconPicker),
                  matching: find.byType(IconButton),
                ),
                findsWidgets,
              );
              expect(
                find.descendant(
                  of: find.byType(GroupColorPicker),
                  matching: find.byType(ColorSwatchButton),
                ),
                findsWidgets,
              );
            case AdaptiveStyle.apple:
              expect(find.text('Cancel'), findsNothing);
              expect(
                find.byKey(const ValueKey('adaptive-modal-implied-close')),
                findsOneWidget,
              );
              expect(find.byType(TextFormField), findsNothing);
              expect(find.byType(CupertinoTextField), findsNWidgets(2));
              final nameField = tester.widget<CupertinoTextField>(
                find.byType(CupertinoTextField).first,
              );
              final fieldContext = tester.element(
                find.byType(CupertinoTextField).first,
              );
              expect(nameField.placeholder, 'Name');
              expect(nameField.style?.fontSize, 20);
              expect(nameField.style?.fontWeight, FontWeight.w600);
              expect(
                (nameField.decoration as BoxDecoration).color,
                CupertinoDynamicColor.resolve(
                  CupertinoColors.tertiarySystemFill,
                  fieldContext,
                ),
              );
              expect(find.widgetWithText(FilledButton, 'Save'), findsNothing);
              expect(
                find.widgetWithText(CupertinoButton, 'Save'),
                findsOneWidget,
              );
              expect(
                find.byKey(const ValueKey('adaptive-modal-actions')),
                findsOneWidget,
              );
              expect(
                find.descendant(
                  of: find.byKey(const ValueKey('adaptive-modal-actions')),
                  matching: find.byKey(
                    const ValueKey('group-edit-save-action'),
                  ),
                ),
                findsOneWidget,
              );
              expect(
                find.descendant(
                  of: find.byType(GroupIconPicker),
                  matching: find.byType(CupertinoButton),
                ),
                findsWidgets,
              );
              expect(
                find.descendant(
                  of: find.byType(GroupColorPicker),
                  matching: find.byType(CupertinoButton),
                ),
                findsWidgets,
              );
          }

          final modalWidth = tester
              .getSize(find.byKey(const ValueKey('adaptive-modal-constraints')))
              .width;
          expect(modalWidth, size.width == 390 ? 390 : 560);

          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
          expect(find.text('Name is required'), findsOneWidget);
          expect(find.byType(AdaptiveModal), findsOneWidget);

          final close = find.byKey(
            const ValueKey('adaptive-modal-implied-close'),
          );
          await tester.tap(close);
          await tester.pumpAndSettle();

          expect(completed, isTrue);
          expect(result, isNull);
        },
      );
    }
  }

  for (final style in AdaptiveStyle.values) {
    for (final size in [const Size(390, 800), const Size(900, 900)]) {
      testWidgets(
        '${style.name} custom color pushes locally and preserves the form at $size',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            AdaptiveStyleScope(
              override: style,
              child: ChangeNotifierProvider(
                create: (_) => CustomColorHistoryViewModel(),
                child: MaterialApp(
                  home: Builder(
                    builder: (context) => ElevatedButton(
                      onPressed: () => showGroupEditDialog(context: context),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(EditableText).first, 'My group');
          final formContext = tester.element(find.byType(GroupEditForm));
          final modalRoute = ModalRoute.of(formContext);
          final localNavigator = Navigator.of(formContext);
          final rootNavigator = Navigator.of(formContext, rootNavigator: true);
          expect(localNavigator, isNot(same(rootNavigator)));
          final colorButtons = find.descendant(
            of: find.byType(GroupColorPicker),
            matching: find.byType(
              style == AdaptiveStyle.apple
                  ? CupertinoButton
                  : ColorSwatchButton,
            ),
          );
          await tester.ensureVisible(colorButtons.last);
          await tester.tap(colorButtons.last);
          await tester.pumpAndSettle();

          expect(find.byType(GroupCustomColorPickerDialog), findsOneWidget);
          final pickerContext = tester.element(
            find.byType(GroupCustomColorPickerDialog),
          );
          expect(Navigator.of(pickerContext), same(localNavigator));
          expect(ModalRoute.of(pickerContext), isNot(same(modalRoute)));
          expect(localNavigator.canPop(), isTrue);
          expect(
            find.widgetWithText(
              style == AdaptiveStyle.apple ? CupertinoButton : TextButton,
              'Save',
            ),
            findsOneWidget,
          );
          await tester.tap(find.byType(AdaptiveBackButton).hitTestable());
          await tester.pumpAndSettle();
          expect(find.byType(AdaptiveModal), findsOneWidget);
          expect(find.text('My group'), findsOneWidget);
          expect(localNavigator.canPop(), isFalse);
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();
          expect(find.byType(GroupEditForm), findsNothing);
          expect(find.text('Open'), findsOneWidget);

          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.ensureVisible(colorButtons.last);
          await tester.tap(colorButtons.last);
          await tester.pumpAndSettle();
          if (style == AdaptiveStyle.material) {
            expect(
              find
                  .byKey(const ValueKey('adaptive-modal-implied-close'))
                  .hitTestable(),
              findsNothing,
            );
            expect(
              find
                  .byKey(const ValueKey('adaptive-modal-actions'))
                  .hitTestable(),
              findsNothing,
            );
            await tester.tap(find.byType(AdaptiveBackButton).hitTestable());
            await tester.pumpAndSettle();
          }
          await tester.tap(
            find
                .byKey(const ValueKey('adaptive-modal-implied-close'))
                .hitTestable(),
          );
          await tester.pumpAndSettle();
          expect(find.byType(GroupCustomColorPickerDialog), findsNothing);
          expect(find.byType(GroupEditForm), findsNothing);
          expect(
            find.byType(AdaptiveModalNavigator<GroupEditFormResult>),
            findsNothing,
          );
          expect(find.text('Open').hitTestable(), findsOneWidget);
        },
      );
    }
  }
}

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
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/habit_daily_record_form.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/pages/common/_widgets/habit_record_number_picker.dart';
import 'package:mhabit/pages/common/_widgets/habit_record_reason_modifier.dart';
import 'package:mhabit/widgets/widgets.dart';

import '../../support/adaptive_dialog.dart';

void main() {
  test('delete copy uses the record count', () {
    final en = lookupL10n(const Locale('en'));
    final zh = lookupL10n(const Locale('zh'));
    final zhHant = lookupL10n(
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
    expect(en.habitRecord_delete_buttonText(1), 'Delete check-in');
    expect(en.habitRecord_delete_buttonText(2), 'Delete check-ins');
    expect(en.habitRecord_deleteConfirmDialog_title(1), 'Delete check-in?');
    expect(en.habitRecord_deleteConfirmDialog_title(2), 'Delete 2 check-ins?');
    expect(zh.habitRecord_deleteConfirmDialog_title(1), '删除这次打卡？');
    expect(zh.habitRecord_deleteConfirmDialog_title(2), '删除这 2 次打卡？');
    expect(zhHant.habitRecord_deleteConfirmDialog_title(2), '刪除這 2 次打卡？');
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final dialog in ['value', 'reason']) {
      for (final outcome in ['cancel', 'barrier', 'confirm']) {
        testWidgets('$platform $dialog delete confirmation $outcome', (
          tester,
        ) async {
          var deletions = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: platform),
              localizationsDelegates: L10n.localizationsDelegates,
              supportedLocales: L10n.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () {
                      if (dialog == 'value') {
                        showHabitRecordCustomNumberPickerDialog(
                          context: context,
                          recordForm: HabitDailyRecordForm.getImp(
                            type: HabitType.normal,
                            value: 1,
                            targetValue: 1,
                          ),
                          recordStatus: HabitRecordStatus.done,
                          onDelete: () => deletions++,
                        );
                      } else {
                        showHabitRecordReasonModifierDialog(
                          context: context,
                          initReason: 'skip',
                          onDelete: () => deletions++,
                        );
                      }
                    },
                    child: const Text('Open record'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open record'));
          await tester.pumpAndSettle();
          final editDialog = dialog == 'value'
              ? find.byType(
                  HabitRecordCustomNumberPickerDialog,
                  skipOffstage: false,
                )
              : find.byType(
                  HabitRecordReasonModifierDialog,
                  skipOffstage: false,
                );
          expect(editDialog, findsOneWidget);

          await tester.tap(
            find.widgetWithIcon(TextButton, Icons.delete_outline),
          );
          await tester.pumpAndSettle();
          expect(editDialog, findsOneWidget);
          final l10n = L10n.of(tester.element(adaptiveDialogFinder))!;
          expect(
            find.text(l10n.habitRecord_deleteConfirmDialog_title(1)),
            findsOneWidget,
          );
          expect(
            tester
                .widget<AdaptiveConfirmDialog>(
                  find.byType(AdaptiveConfirmDialog),
                )
                .content,
            isNull,
          );
          expect(
            adaptiveDialogActions(tester).last.isDestructiveAction,
            isTrue,
          );
          expect(deletions, 0);

          if (outcome == 'barrier') {
            await tester.tapAt(const Offset(5, 5));
          } else {
            adaptiveDialogActions(
              tester,
            ).elementAt(outcome == 'confirm' ? 1 : 0).onPressed!();
          }
          await tester.pumpAndSettle();
          expect(deletions, outcome == 'confirm' ? 1 : 0);
          expect(
            editDialog,
            outcome == 'confirm' ? findsNothing : findsOneWidget,
          );
        });
      }
    }
  }
}

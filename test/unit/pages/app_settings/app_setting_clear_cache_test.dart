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
import 'package:mhabit/pages/app_settings/_widgets/app_setting_clear_cache.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../support/adaptive_dialog.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    testWidgets('$style clear cache preserves choice results', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: AdaptiveStyleScope(
            override: style,
            child: const Scaffold(body: Text('Settings')),
          ),
        ),
      );
      final context = tester.element(find.text('Settings'));
      final l10n = L10n.of(context)!;
      for (final choice in [true, false, null]) {
        final result = showAppSettingClearCacheDialog(context: context);
        await tester.pumpAndSettle();
        final finder = adaptiveDialogFinder;
        expect(AdaptiveStyle.of(tester.element(finder)), style);
        expect(
          find.text(l10n.appSetting_clearCacheDialog_titleText),
          findsOneWidget,
        );
        expect(
          find.text(l10n.appSetting_clearCacheDialog_subtitleText),
          findsOneWidget,
        );
        final actions = adaptiveDialogActions(tester);
        expect(actions.last.isDestructiveAction, isFalse);
        if (choice == null) {
          await tester.tapAt(const Offset(5, 5));
        } else {
          await tester.tap(
            find.text(
              choice
                  ? l10n.appSetting_clearCacheDialog_confirmText
                  : l10n.appSetting_clearCacheDialog_cancelText,
            ),
          );
        }
        await tester.pumpAndSettle();
        expect(await result, choice);
        expect(find.text('Settings'), findsOneWidget);
      }
    });
  }
}

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

import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoCheckbox;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_settings/_widgets/app_setting_open_system_language_tile.dart';
import 'package:mhabit/providers/app_ui/app_caches.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../support/adaptive_dialog.dart';

class _Caches extends AppCachesViewModel {
  bool skip = false;
  int updates = 0;

  @override
  bool get appFlagSkipOpenSystemLanguageConfirm => skip;

  @override
  Future<bool> updateAppFlagSkipOpenSystemLanguageConfirm(bool value) async {
    skip = value;
    updates++;
    return true;
  }
}

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final choice in ['cancel', 'confirm', 'skip', 'barrier']) {
      testWidgets(
        '$style language settings $choice persists only explicit skip',
        (tester) async {
          final caches = _Caches();
          var opened = 0;
          const channel = MethodChannel('com.spencerccf.app_settings/methods');
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            channel,
            (call) async {
              expect(call.method, 'openSettings');
              opened++;
              return null;
            },
          );
          addTearDown(
            () => tester.binding.defaultBinaryMessenger
                .setMockMethodCallHandler(channel, null),
          );
          await tester.pumpWidget(
            Provider<AppCachesViewModel>.value(
              value: caches,
              child: MaterialApp(
                theme: ThemeData(platform: TargetPlatform.macOS),
                localizationsDelegates: L10n.localizationsDelegates,
                supportedLocales: L10n.supportedLocales,
                home: AdaptiveStyleScope(
                  override: style,
                  child: const Scaffold(
                    body: AppSettingOpenSystemLanguageTile(),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byType(ListTile));
          await tester.pumpAndSettle();
          expect(find.byType(AdaptiveConfirmDialog), findsOneWidget);
          if (choice != 'confirm') {
            final checkbox = find.byType(
              style == AdaptiveStyle.apple
                  ? CupertinoCheckbox
                  : CheckboxListTile,
            );
            await tester.ensureVisible(checkbox);
            await tester.tap(checkbox);
            await tester.pump();
          }
          final actions = adaptiveDialogActions(tester);
          if (choice == 'barrier') {
            await tester.tapAt(const Offset(5, 5));
          } else {
            final action = choice == 'cancel'
                ? actions.firstWhere((a) => a.label == 'Cancel')
                : actions.firstWhere(
                    (a) =>
                        a.label ==
                        L10n.of(
                          tester.element(adaptiveDialogFinder),
                        )!.confirmDialog_confirm_text('open'),
                  );
            action.onPressed!();
            action.onPressed!();
          }
          await tester.pumpAndSettle();
          expect(caches.skip, choice == 'skip');
          expect(caches.updates, choice == 'skip' ? 1 : 0);
          expect(opened, choice == 'skip' || choice == 'confirm' ? 1 : 0);
          await tester.tap(find.byType(ListTile));
          await tester.pumpAndSettle();
          expect(
            find.byType(AdaptiveConfirmDialog),
            choice == 'skip' ? findsNothing : findsOneWidget,
          );
          if (choice == 'skip') {
            expect(opened, 2);
          } else {
            await tester.ensureVisible(find.text('Cancel'));
            await tester.tap(find.text('Cancel'));
            await tester.pumpAndSettle();
          }
        },
        skip: !Platform.isMacOS,
      );
    }
  }
}

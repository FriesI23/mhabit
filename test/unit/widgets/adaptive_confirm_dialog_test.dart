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

import 'package:flutter/cupertino.dart' show CupertinoCheckbox;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../support/adaptive_dialog.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    testWidgets('$style single submission and cancellation results', (
      tester,
    ) async {
      Object? result;
      var completions = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            platform: style == AdaptiveStyle.apple
                ? TargetPlatform.iOS
                : TargetPlatform.android,
          ),
          home: AdaptiveStyleScope(
            override: style,
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  child: const Text('Open'),
                  onPressed: () async {
                    result = await showAdaptiveConfirmDialog(
                      context: context,
                      title: const Text('Question'),
                    );
                    completions++;
                  },
                ),
              ),
            ),
          ),
        ),
      );
      Future<void> open() async {
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
      }

      await open();
      expect(adaptiveDialogActions(tester).map((action) => action.label), [
        'Cancel',
        'Confirm',
      ]);
      final action = adaptiveDialogActions(
        tester,
      ).firstWhere((action) => action.label == 'Confirm').onPressed!;
      action();
      action();
      await tester.pumpAndSettle();
      expect(result, true);
      expect(completions, 1);
      expect(find.text('Open'), findsOneWidget);
      await open();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, false);
      await open();
      final staleAction = adaptiveDialogActions(
        tester,
      ).firstWhere((action) => action.label == 'Confirm').onPressed!;
      await tester.tapAt(const Offset(5, 5));
      staleAction();
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(completions, 3);
      staleAction();
      expect(find.text('Open'), findsOneWidget);
    });
  }

  for (final (style, platform) in [
    (AdaptiveStyle.material, TargetPlatform.android),
    (AdaptiveStyle.apple, TargetPlatform.macOS),
    (AdaptiveStyle.apple, TargetPlatform.iOS),
    (AdaptiveStyle.apple, TargetPlatform.android),
    (AdaptiveStyle.apple, TargetPlatform.windows),
    (AdaptiveStyle.material, TargetPlatform.iOS),
  ]) {
    final useSkipAction =
        style == AdaptiveStyle.apple &&
        (platform == TargetPlatform.iOS || platform == TargetPlatform.android);
    testWidgets(
      '$style $platform large text and resize keep optional confirmation reachable',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(360, 500);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
            ),
            home: AdaptiveStyleScope(
              override: style,
              child: const Scaffold(body: Text('Host')),
            ),
          ),
        );
        final context = tester.element(find.text('Host'));
        final skips = <bool>[];
        final result = showAdaptiveConfirmDialog(
          context: context,
          onSkipConfirmed: skips.add,
          title: const Text('Confirm this operation'),
          content: Text(
            List.filled(8, 'Explanation of the operation.').join(' '),
          ),
          confirmLabel: 'Continue',
        );
        await tester.pumpAndSettle();
        final state = tester.state(find.byType(AdaptiveConfirmDialog));
        final checkbox = find.byType(
          style == AdaptiveStyle.apple ? CupertinoCheckbox : CheckboxListTile,
        );
        if (!useSkipAction) {
          await tester.ensureVisible(checkbox);
          await tester.tap(checkbox);
          await tester.pump();
        }
        tester.view.physicalSize = const Size(800, 400);
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(AdaptiveConfirmDialog)), same(state));
        if (style == AdaptiveStyle.material) {
          expect(
            tester
                .widget<CheckboxListTile>(find.byType(CheckboxListTile))
                .value,
            isTrue,
          );
        }
        final label = useSkipAction
            ? L10n.of(context)!.confirmDialog_confirmAndSkip_text('Continue')
            : 'Continue';
        await tester.ensureVisible(find.text(label));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(await result, isTrue);
        expect(skips, [true]);
        expect(tester.takeException(), isNull);
      },
    );
    for (final choice in ['cancel', 'confirm', 'skip', 'barrier']) {
      testWidgets('$style $platform optional confirm $choice', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            home: AdaptiveStyleScope(
              override: style,
              child: const Scaffold(body: Text('Host')),
            ),
          ),
        );
        final context = tester.element(find.text('Host'));
        final skips = <bool>[];
        final result = showAdaptiveConfirmDialog(
          context: context,
          onSkipConfirmed: skips.add,
          title: const Text('Question'),
          confirmLabel: 'Delete',
          isDestructiveAction: true,
        );
        await tester.pumpAndSettle();
        final checkbox = find.byType(
          style == AdaptiveStyle.apple ? CupertinoCheckbox : CheckboxListTile,
        );
        expect(checkbox, useSkipAction ? findsNothing : findsOneWidget);
        final dialogActions = adaptiveDialogActions(tester);
        expect(dialogActions.length, useSkipAction ? 3 : 2);
        expect(
          dialogActions
              .where((action) => action.label != 'Cancel')
              .every((action) => action.isDestructiveAction),
          isTrue,
        );
        expect(dialogActions.last.isDefaultAction, isFalse);
        // Cancelling or dismissing a checked draft must discard the selection.
        if (!useSkipAction && choice != 'confirm') {
          await tester.tap(
            style == AdaptiveStyle.apple
                ? find.text(L10n.of(context)!.common_dontShowAgain)
                : checkbox,
          );
          await tester.pump();
        }
        final actions = adaptiveDialogActions(tester);
        final stale = actions.firstWhere((a) => a.label == 'Delete').onPressed!;
        if (choice == 'barrier') {
          await tester.tapAt(const Offset(5, 5));
          stale();
        } else {
          final label = choice == 'cancel'
              ? 'Cancel'
              : useSkipAction && choice == 'skip'
              ? L10n.of(context)!.confirmDialog_confirmAndSkip_text('Delete')
              : 'Delete';
          final submit = actions.firstWhere((a) => a.label == label).onPressed!;
          submit();
          submit();
        }
        await tester.pumpAndSettle();
        expect(await result, switch (choice) {
          'cancel' => false,
          'confirm' => true,
          'skip' => true,
          _ => null,
        });
        stale();
        expect(
          skips,
          choice == 'confirm'
              ? [false]
              : choice == 'skip'
              ? [true]
              : isEmpty,
        );
        expect(find.text('Host'), findsOneWidget);
        // A new dialog starts with a fresh draft.
        showAdaptiveConfirmDialog(context: context, onSkipConfirmed: skips.add);
        await tester.pumpAndSettle();
        if (style == AdaptiveStyle.material) {
          expect(
            tester
                .widget<CheckboxListTile>(find.byType(CheckboxListTile))
                .value,
            isFalse,
          );
        }
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      });
    }
  }
}

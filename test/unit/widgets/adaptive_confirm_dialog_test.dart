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

import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/cupertino.dart' show CupertinoCheckbox;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_settings/_widgets/app_setting_clear_cache.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../support/adaptive_dialog.dart';
import '../../support/adaptive_ui_theme.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final direction in TextDirection.values) {
      for (final clearCache in [false, true]) {
        testWidgets(
          '$style $direction clearCache=$clearCache confirmation follows right/lower pane',
          (tester) async {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = const Size(1000, 800);
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final features = ValueNotifier<List<DisplayFeature>>(const [
              DisplayFeature(
                bounds: Rect.fromLTWH(490, 0, 20, 800),
                type: DisplayFeatureType.hinge,
                state: DisplayFeatureState.postureHalfOpened,
              ),
            ]);
            addTearDown(features.dispose);
            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(platform: TargetPlatform.android),
                localizationsDelegates: L10n.localizationsDelegates,
                supportedLocales: L10n.supportedLocales,
                builder: (context, child) => ValueListenableBuilder(
                  valueListenable: features,
                  builder: (context, value, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(displayFeatures: value),
                    child: Directionality(
                      textDirection: direction,
                      child: child!,
                    ),
                  ),
                  child: TestAdaptiveUiTheme(
                    update: (theme) => theme.copyWith(style: style),
                    child: child!,
                  ),
                ),
                home: const Scaffold(body: Text('Host')),
              ),
            );
            final context = tester.element(find.text('Host'));
            final skips = <bool>[];
            final result = clearCache
                ? showAppSettingClearCacheDialog(context: context)
                : showAdaptiveConfirmDialog(
                    context: context,
                    title: const Text('Question'),
                    onSkipConfirmed: skips.add,
                  );
            await tester.pumpAndSettle();
            final dialog = find.byType(AdaptiveConfirmDialog);
            final state = tester.state(dialog);
            final title = find.text(
              clearCache
                  ? L10n.of(context)!.appSetting_clearCacheDialog_titleText
                  : 'Question',
            );
            expect(tester.getRect(title).left, greaterThanOrEqualTo(510));
            expect(tester.getRect(title).right, lessThanOrEqualTo(1000));
            if (!clearCache && style == AdaptiveStyle.material) {
              await tester.tap(find.byType(CheckboxListTile));
              await tester.pump();
            }

            // Rotate while the same route remains open.
            tester.view.physicalSize = const Size(800, 1000);
            features.value = const [
              DisplayFeature(
                bounds: Rect.fromLTWH(0, 490, 800, 20),
                type: DisplayFeatureType.fold,
                state: DisplayFeatureState.postureHalfOpened,
              ),
            ];
            await tester.pumpAndSettle();
            expect(tester.getRect(title).top, greaterThanOrEqualTo(510));
            expect(tester.getCenter(title).dx, closeTo(400, 1));
            expect(tester.state(dialog), same(state));

            // Growing the window must not leave the anchor in the upper pane.
            tester.view.physicalSize = const Size(1600, 2400);
            features.value = const [
              DisplayFeature(
                bounds: Rect.fromLTWH(0, 1190, 1600, 20),
                type: DisplayFeatureType.fold,
                state: DisplayFeatureState.postureHalfOpened,
              ),
            ];
            await tester.pumpAndSettle();
            expect(tester.getRect(title).top, greaterThanOrEqualTo(1210));
            expect(tester.getCenter(title).dx, closeTo(800, 1));
            expect(tester.state(dialog), same(state));

            // Fully open fold with no obstruction returns to the full window.
            tester.view.physicalSize = const Size(800, 1000);
            features.value = const [
              DisplayFeature(
                bounds: Rect.fromLTWH(0, 500, 800, 0),
                type: DisplayFeatureType.fold,
                state: DisplayFeatureState.postureFlat,
              ),
            ];
            await tester.pumpAndSettle();
            expect(tester.getRect(title).top, lessThan(500));
            expect(tester.getCenter(title).dx, closeTo(400, 1));
            expect(tester.state(dialog), same(state));

            // Switching to the cover display removes the fold partition.
            tester.view.physicalSize = const Size(430, 932);
            features.value = const [];
            await tester.pumpAndSettle();
            expect(tester.getRect(title).left, greaterThanOrEqualTo(0));
            expect(tester.getRect(title).right, lessThanOrEqualTo(430));
            expect(tester.getCenter(title).dx, closeTo(215, 1));
            expect(tester.state(dialog), same(state));
            if (!clearCache && style == AdaptiveStyle.material) {
              expect(
                tester
                    .widget<CheckboxListTile>(find.byType(CheckboxListTile))
                    .value,
                isTrue,
              );
            }
            adaptiveDialogActions(tester)
                .firstWhere(
                  (action) =>
                      action.label ==
                      (clearCache
                          ? L10n.of(
                              context,
                            )!.appSetting_clearCacheDialog_confirmText
                          : 'Confirm'),
                )
                .onPressed!();
            await tester.pumpAndSettle();
            expect(await result, isTrue);
            if (!clearCache) {
              expect(skips, [style == AdaptiveStyle.material]);
            }

            // Ordinary dialogs keep Flutter's direction-based default.
            final ordinary = showAdaptiveModalDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (_) => const AdaptiveDialog(title: Text('Ordinary')),
            );
            tester.view.physicalSize = const Size(1000, 800);
            features.value = const [
              DisplayFeature(
                bounds: Rect.fromLTWH(490, 0, 20, 800),
                type: DisplayFeatureType.hinge,
                state: DisplayFeatureState.postureHalfOpened,
              ),
            ];
            await tester.pumpAndSettle();
            final ordinaryRect = tester.getRect(find.text('Ordinary'));
            if (direction == TextDirection.ltr) {
              expect(ordinaryRect.right, lessThanOrEqualTo(490));
            } else {
              expect(ordinaryRect.left, greaterThanOrEqualTo(510));
            }
            features.value = const [
              DisplayFeature(
                bounds: Rect.fromLTWH(0, 390, 1000, 20),
                type: DisplayFeatureType.fold,
                state: DisplayFeatureState.postureHalfOpened,
              ),
            ];
            await tester.pumpAndSettle();
            expect(
              tester.getRect(find.text('Ordinary')).bottom,
              lessThanOrEqualTo(390),
            );
            await tester.tapAt(const Offset(5, 5));
            await tester.pumpAndSettle();
            await ordinary;
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

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
          home: TestAdaptiveUiTheme(
            update: (parentTheme) => parentTheme.copyWith(style: style),
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
            home: TestAdaptiveUiTheme(
              update: (parentTheme) => parentTheme.copyWith(style: style),
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
            home: TestAdaptiveUiTheme(
              update: (parentTheme) => parentTheme.copyWith(style: style),
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

// Copyright 2026 Fries_I23
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/pages/common/_widgets/exporter_confirm_dialog.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _app({
  required TargetPlatform platform,
  required ValueChanged<Set<ExporterConfirmResultType>?> onResult,
  int groups = 2,
  bool exportAll = false,
}) => MaterialApp(
  theme: ThemeData(platform: platform),
  home: Builder(
    builder: (context) => TextButton(
      onPressed: () async => onResult(
        await showExporterConfirmDialog(
          context: context,
          exportHabitsNumber: 3,
          exportGroupsNumber: groups,
          exportAll: exportAll,
        ),
      ),
      child: const Text('Open'),
    ),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final records in [true, false]) {
      for (final groups in [true, false]) {
        testWidgets('$platform returns records=$records groups=$groups', (
          tester,
        ) async {
          Set<ExporterConfirmResultType>? result;
          await tester.pumpWidget(
            _app(platform: platform, onResult: (value) => result = value),
          );
          await _open(tester);
          expect(find.text('Export habits?'), findsOneWidget);
          if (!records) {
            await tester.tap(find.text('include records'));
            await tester.pumpAndSettle();
          }
          if (!groups) {
            final tile = find.byKey(const ValueKey('export-groups'));
            await tester.tap(
              find.descendant(
                of: tile,
                matching: platform == TargetPlatform.android
                    ? find.byType(Switch)
                    : find.byType(CupertinoSwitch),
              ),
            );
            await tester.pumpAndSettle();
          }
          if (platform == TargetPlatform.android) {
            expect(find.byType(AlertDialog), findsNothing);
            expect(find.bySubtype<AdaptiveModal>(), findsOneWidget);
            expect(find.byType(SwitchListTile), findsNWidgets(2));
          } else {
            expect(
              find.byKey(const ValueKey('adaptive-modal-app-bar')),
              findsNothing,
            );
            final actions = find.byKey(
              const ValueKey('adaptive-modal-actions'),
            );
            expect(
              find.descendant(
                of: actions,
                matching: find.byType(CupertinoButton),
              ),
              findsNWidgets(2),
            );
            expect(
              tester.getTopLeft(actions).dy,
              greaterThan(
                tester.getBottomLeft(find.text('Include 2 groups')).dy,
              ),
            );
          }
          await tester.tap(find.text('export'));
          await tester.pumpAndSettle();
          expect(result, {
            ExporterConfirmResultType.habit,
            if (records) ExporterConfirmResultType.records,
            if (groups) ExporterConfirmResultType.groups,
          });
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('$platform cancels and resets options when reopened', (
      tester,
    ) async {
      final results = <Set<ExporterConfirmResultType>?>[];
      await tester.pumpWidget(_app(platform: platform, onResult: results.add));
      await _open(tester);
      await tester.tap(find.text('include records'));
      await tester.tap(find.text('cancel'));
      await tester.pumpAndSettle();
      expect(results, [null]);
      await _open(tester);
      await tester.tap(find.text('export'));
      await tester.pumpAndSettle();
      expect(results.last, ExporterConfirmResultType.values.toSet());
      await _open(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(results.last, isNull);
      expect(find.byType(ExporterConfirmDialog), findsNothing);
    });

    testWidgets(
      '$platform no-group export preserves existing result contract',
      (tester) async {
        Set<ExporterConfirmResultType>? result;
        await tester.pumpWidget(
          _app(
            platform: platform,
            groups: 0,
            exportAll: true,
            onResult: (value) => result = value,
          ),
        );
        await _open(tester);
        expect(find.text('Export all habits?'), findsOneWidget);
        expect(find.byKey(const ValueKey('export-groups')), findsNothing);
        await tester.tap(find.text('export'));
        await tester.pumpAndSettle();
        expect(result, ExporterConfirmResultType.values.toSet());
      },
    );

    {
      testWidgets('$platform stays a constrained dialog after resize', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 1000);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_app(platform: platform, onResult: (_) {}));
        await _open(tester);
        final modal = find.bySubtype<AdaptiveModal>();
        expect(tester.getSize(modal).height, lessThan(560));
        expect(tester.getSize(modal).width, inInclusiveRange(320, 560));
        for (final size in [
          const Size(320, 800),
          const Size(900, 320),
          const Size(1000, 1000),
        ]) {
          tester.view.physicalSize = size;
          await tester.pumpAndSettle();
          expect(
            find.byType(
              platform == TargetPlatform.android
                  ? Dialog
                  : CupertinoPopupSurface,
            ),
            findsOneWidget,
          );
          expect(tester.getSize(modal).width, lessThanOrEqualTo(size.width));
          expect(tester.takeException(), isNull);
        }
      });
    }
  }
}

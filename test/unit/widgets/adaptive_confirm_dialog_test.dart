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
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    testWidgets('$style single submission and cancellation results', (
      tester,
    ) async {
      Object? result;
      var completions = 0;
      await tester.pumpWidget(
        MaterialApp(
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
      final action = tester
          .widget<AdaptiveDialog>(find.byType(AdaptiveDialog))
          .actions
          .last
          .onPressed!;
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
      final staleAction = tester
          .widget<AdaptiveDialog>(find.byType(AdaptiveDialog))
          .actions
          .last
          .onPressed!;
      await tester.tapAt(const Offset(5, 5));
      staleAction();
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(completions, 3);
      staleAction();
      expect(find.text('Open'), findsOneWidget);
    });
  }
}

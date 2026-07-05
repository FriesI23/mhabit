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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/thirdparty_import.dart';
import 'package:mhabit/pages/app_settings/_widgets/thirdparty_import_provider_dialog.dart';

void main() {
  group('showThirdPartyImportProviderDialog', () {
    testWidgets('shows all ThirdPartyProvider values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      // Trigger the dialog
      unawaited(
        showThirdPartyImportProviderDialog(
          tester.element(find.byType(SizedBox)),
        ),
      );
      await tester.pumpAndSettle();

      // Each provider should appear in the dialog
      for (final provider in ThirdPartyProvider.values) {
        expect(find.text(provider.displayName), findsOneWidget);
      }
    });

    testWidgets('returns selected provider on tap', (tester) async {
      ThirdPartyProvider? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showThirdPartyImportProviderDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap the Loop Habit Tracker option
      await tester.tap(find.text('Loop Habit Tracker'));
      await tester.pumpAndSettle();

      expect(result, ThirdPartyProvider.loopHabitTracker);
    });

    testWidgets('returns null when dismissed by system back', (tester) async {
      ThirdPartyProvider? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showThirdPartyImportProviderDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Dismiss by popping the route
      final nav = Navigator.of(tester.element(find.text('Loop Habit Tracker')));
      nav.pop();
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('each provider has an icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      unawaited(
        showThirdPartyImportProviderDialog(
          tester.element(find.byType(SizedBox)),
        ),
      );
      await tester.pumpAndSettle();

      // Each provider tile should have a CircleAvatar leading widget
      expect(
        find.byType(CircleAvatar),
        findsNWidgets(ThirdPartyProvider.values.length),
      );
    });
  });
}

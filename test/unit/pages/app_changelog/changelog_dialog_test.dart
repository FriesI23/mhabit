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
import 'package:mhabit/pages/app_changelog/changelog_dialog.dart';
import 'package:mhabit/widgets/_widgets/markdown_block.dart';

const _currentVersionSection = '- item 1\n- item 2';
const _fullChangelog = '## 1.0.0+1\n- old item\n';
const _version = '1.2.3+45';

Widget _buildTestApp({
  String currentVersionSection = _currentVersionSection,
  String fullChangelog = _fullChangelog,
  String version = _version,
}) {
  return MaterialApp(
    localizationsDelegates: L10n.localizationsDelegates,
    supportedLocales: L10n.supportedLocales,
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () => showChangelogDialog(
          context: context,
          currentVersionSection: currentVersionSection,
          fullChangelog: fullChangelog,
          version: version,
        ),
        child: const Text('Show'),
      ),
    ),
  );
}

Future<void> _openDialog(WidgetTester tester) async {
  await tester.tap(find.text('Show'));
  await tester.pumpAndSettle();
}

void main() {
  group('showChangelogDialog', () {
    // -----------------------------------------------------------------------
    // 1: shows current version section by default
    // -----------------------------------------------------------------------
    testWidgets('shows current version section by default', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);

      final block = find.byWidgetPredicate(
        (w) => w is ThematicMarkdownBlock && w.data == _currentVersionSection,
      );
      expect(block, findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 2: "View Full Changelog" button visible initially
    // -----------------------------------------------------------------------
    testWidgets('"View Full Changelog" button visible initially', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);

      expect(find.text('View Full Changelog'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 3: tapping "View Full Changelog" switches content and hides button
    // -----------------------------------------------------------------------
    testWidgets(
      'tapping "View Full Changelog" switches content and hides button',
      (tester) async {
        await tester.pumpWidget(_buildTestApp());
        await _openDialog(tester);

        await tester.tap(find.text('View Full Changelog'));
        await tester.pumpAndSettle();

        // Content should now show parsed section body (lazy list item)
        final block = find.byWidgetPredicate(
          (w) => w is ThematicMarkdownBlock && w.data == '- old item',
        );
        expect(block, findsOneWidget);
        // Original current-version content should be gone
        final oldBlock = find.byWidgetPredicate(
          (w) => w is ThematicMarkdownBlock && w.data == _currentVersionSection,
        );
        expect(oldBlock, findsNothing);
        expect(find.text('View Full Changelog'), findsNothing);
      },
    );

    // -----------------------------------------------------------------------
    // 4: re-opening dialog resets to current version
    // -----------------------------------------------------------------------
    testWidgets('re-opening dialog resets to current version', (tester) async {
      // Use large screen for reliable AlertDialog close button
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);

      // Switch to full changelog
      await tester.tap(find.text('View Full Changelog'));
      await tester.pumpAndSettle();
      expect(find.text('View Full Changelog'), findsNothing);

      // Close dialog via AlertDialog close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Re-open
      await _openDialog(tester);

      // Should show current version again
      final block = find.byWidgetPredicate(
        (w) => w is ThematicMarkdownBlock && w.data == _currentVersionSection,
      );
      expect(block, findsOneWidget);
      expect(find.text('View Full Changelog'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 5: modal bottom sheet on small screen (width < 600px)
    // -----------------------------------------------------------------------
    testWidgets('modal bottom sheet on small screen (width < 600px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);

      // Bottom sheet content should be visible
      expect(find.text('Changelog'), findsOneWidget);
      expect(find.text('v$_version'), findsOneWidget);
      // Bottom sheet actions should include the close button
      expect(find.text('Close'), findsOneWidget);
      // Fullscreen close icon should not be present
      expect(find.byIcon(Icons.close), findsNothing);
    });

    // -----------------------------------------------------------------------
    // 6: AlertDialog on large screen (width >= 600px)
    // -----------------------------------------------------------------------
    testWidgets('AlertDialog on large screen (width >= 600px)', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);

      // AlertDialog has actions with a Close button
      expect(find.text('Close'), findsOneWidget);
      // Fullscreen close icon should not be present
      expect(find.byIcon(Icons.close), findsNothing);
    });

    // -----------------------------------------------------------------------
    // 7: close button dismisses dialog
    // -----------------------------------------------------------------------
    testWidgets('close button dismisses dialog', (tester) async {
      // Use large screen to test AlertDialog close
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Dialog content should be gone
      expect(find.text('Changelog'), findsNothing);
    });
  });
}

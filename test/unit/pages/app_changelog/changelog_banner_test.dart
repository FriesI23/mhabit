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
import 'package:mhabit/pages/habits_display/_widgets/changelog_banner_sliver.dart';

// ---------------------------------------------------------------------------
// Test constants
// ---------------------------------------------------------------------------

const _testVersion = '1.0.0+1';
const _testContent = '- item a\n- item b';
const _fullChangelog = '## 1.0.0+1\n- item a\n- item b\n';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a minimal widget tree with [ChangelogBanner] ancestor and a
/// [ChangelogBannerSliver] inside a [CustomScrollView] so the private
/// `_ChangelogBanner` widget is in the tree and can animate.
///
/// Tapping the trigger button calls [ChangelogBannerController.show]
/// directly, bypassing asset loading.
Widget _buildTestApp({
  String version = _testVersion,
  String content = _testContent,
  String fullChangelog = _fullChangelog,
}) {
  return MaterialApp(
    localizationsDelegates: L10n.localizationsDelegates,
    supportedLocales: L10n.supportedLocales,
    home: ChangelogBanner(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const ChangelogBannerSliver(),
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () => ChangelogBanner.of(context).controller.show(
                    changelogContent: content,
                    fullChangelog: fullChangelog,
                    version: version,
                  ),
                  child: const Text('Trigger Banner'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Builds a widget tree with [ChangelogBanner] + [ChangelogBannerSliver]
/// but without calling [ChangelogBannerController.show] — used to test
/// the idle / collapsed state.
Widget _buildIdleApp() {
  return const MaterialApp(
    localizationsDelegates: L10n.localizationsDelegates,
    supportedLocales: L10n.supportedLocales,
    home: ChangelogBanner(
      child: Scaffold(
        body: CustomScrollView(slivers: [ChangelogBannerSliver()]),
      ),
    ),
  );
}

Future<void> _triggerBanner(WidgetTester tester) async {
  await tester.tap(find.text('Trigger Banner'));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// ChangelogBannerController — pure unit tests
// ---------------------------------------------------------------------------

void main() {
  group('ChangelogBannerController', () {
    late ChangelogBannerController controller;

    setUp(() => controller = ChangelogBannerController());
    tearDown(() => controller.dispose());

    test('initial isShowing is false', () {
      expect(controller.isShowing, false);
    });

    test('initial version is empty', () {
      expect(controller.version, '');
    });

    test('show() sets isShowing to true', () {
      controller.show(
        changelogContent: _testContent,
        fullChangelog: _fullChangelog,
        version: _testVersion,
      );
      expect(controller.isShowing, true);
    });

    test('show() sets version', () {
      controller.show(
        changelogContent: _testContent,
        fullChangelog: _fullChangelog,
        version: _testVersion,
      );
      expect(controller.version, _testVersion);
    });

    test('show() sets changelogContent', () {
      controller.show(
        changelogContent: _testContent,
        fullChangelog: _fullChangelog,
        version: _testVersion,
      );
      expect(controller.changelogContent, _testContent);
    });

    test('show() sets fullChangelog', () {
      controller.show(
        changelogContent: _testContent,
        fullChangelog: _fullChangelog,
        version: _testVersion,
      );
      expect(controller.fullChangelog, _fullChangelog);
    });

    test('show() invokes notifyListeners', () {
      var notified = false;
      controller.addListener(() => notified = true);
      controller.show(
        changelogContent: _testContent,
        fullChangelog: _fullChangelog,
        version: _testVersion,
      );
      expect(notified, true);
    });

    test('dismiss() sets isShowing to false', () {
      controller.show(
        changelogContent: _testContent,
        fullChangelog: _fullChangelog,
        version: _testVersion,
      );
      controller.dismiss();
      expect(controller.isShowing, false);
    });

    test('dismiss() when not showing is no-op', () {
      // Should not throw.
      controller.dismiss();
      expect(controller.isShowing, false);
    });

    test('dismiss() invokes onDismiss callback', () {
      var dismissed = false;
      controller.show(
        changelogContent: _testContent,
        fullChangelog: _fullChangelog,
        version: _testVersion,
        onDismiss: () => dismissed = true,
      );
      controller.dismiss();
      expect(dismissed, true);
    });

    test('dismiss() clears onDismiss after calling it', () {
      var callCount = 0;
      controller.show(
        changelogContent: _testContent,
        fullChangelog: _fullChangelog,
        version: _testVersion,
        onDismiss: () => callCount++,
      );
      controller.dismiss();
      controller.dismiss(); // second dismiss should NOT invoke callback again
      expect(callCount, 1);
    });

    test('dismissibleKey changes on each show()', () {
      controller.show(
        changelogContent: _testContent,
        fullChangelog: _fullChangelog,
        version: _testVersion,
      );
      final key1 = controller.dismissibleKey;
      controller.dismiss();
      controller.show(
        changelogContent: _testContent,
        fullChangelog: _fullChangelog,
        version: _testVersion,
      );
      final key2 = controller.dismissibleKey;
      expect(key1, isNot(key2));
    });
  });

  // -------------------------------------------------------------------------
  // ChangelogBanner InheritedWidget integration tests
  // -------------------------------------------------------------------------

  group('ChangelogBanner widget tree', () {
    testWidgets('ChangelogBanner.of throws when no ancestor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => ChangelogBanner.of(context),
              child: const Text('Bad'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Bad'));
      // Expect assertion error from ChangelogBanner.of
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('ChangelogBanner.of returns state when ancestor exists', (
      tester,
    ) async {
      ChangelogBannerState? captured;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: ChangelogBanner(
            child: Builder(
              builder: (context) {
                captured = ChangelogBanner.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(captured, isNotNull);
      expect(captured, isA<ChangelogBannerState>());
    });
  });

  // -------------------------------------------------------------------------
  // ChangelogBannerSliver widget tests
  // -------------------------------------------------------------------------

  group('ChangelogBannerSliver', () {
    testWidgets('banner is not visible in idle state', (tester) async {
      await tester.pumpWidget(_buildIdleApp());
      // MaterialBanner should not be present when controller is not showing
      expect(find.byType(MaterialBanner), findsNothing);
    });

    testWidgets('banner appears with VIEW and CLOSE buttons', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await _triggerBanner(tester);

      expect(find.text('VIEW'), findsOneWidget);
      expect(find.text('CLOSE'), findsOneWidget);
    });

    testWidgets('tapping CLOSE dismisses banner', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await _triggerBanner(tester);

      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();

      // MaterialBanner should animate out
      expect(find.byType(MaterialBanner), findsNothing);
    });

    testWidgets('banner has celebration icon', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await _triggerBanner(tester);

      expect(find.byIcon(Icons.celebration_outlined), findsOneWidget);
    });

    testWidgets('banner title includes version', (tester) async {
      await tester.pumpWidget(_buildTestApp(version: '2.5.0+99'));
      await _triggerBanner(tester);

      expect(find.text("What's New in v2.5.0+99"), findsOneWidget);
    });
  });
}

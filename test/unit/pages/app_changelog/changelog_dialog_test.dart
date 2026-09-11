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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_changelog/changelog_dialog.dart';
import 'package:mhabit/widgets/_widgets/markdown_block.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

const _currentVersionSection = '- item 1\n- item 2';
const _fullChangelog = '## 1.0.0+1\n- old item\n';
const _version = '1.2.3+45';

Widget _buildTestApp({
  String currentVersionSection = _currentVersionSection,
  String fullChangelog = _fullChangelog,
  String version = _version,
  TargetPlatform platform = TargetPlatform.android,
  AdaptiveStyle? adaptiveStyleOverride,
  EdgeInsets horizontalAvoidance = EdgeInsets.zero,
  EdgeInsets verticalAvoidance = EdgeInsets.zero,
}) {
  Widget home = Builder(
    builder: (context) => TextButton(
      onPressed: () => showChangelogDialog(
        context: context,
        currentVersionSection: currentVersionSection,
        fullChangelog: fullChangelog,
        version: version,
      ),
      child: const Text('Show'),
    ),
  );
  if (adaptiveStyleOverride case final style?) {
    home = AdaptiveStyleScope(override: style, child: home);
  }
  home = AdaptiveWindowControlLayoutScope(
    horizontalAvoidance: horizontalAvoidance,
    verticalAvoidance: verticalAvoidance,
    owner: WindowControlLayoutOwner.appBar,
    child: home,
  );
  return MaterialApp(
    theme: ThemeData(platform: platform),
    localizationsDelegates: L10n.localizationsDelegates,
    supportedLocales: L10n.supportedLocales,
    home: home,
  );
}

Future<void> _openDialog(WidgetTester tester) async {
  await tester.tap(find.text('Show'));
  await tester.pumpAndSettle();
}

Finder _findCupertinoBackChevron() => find.byIcon(CupertinoIcons.back);

void main() {
  group('showChangelogDialog', () {
    testWidgets('shows current version section by default', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);

      final block = find.byWidgetPredicate(
        (w) => w is ThematicMarkdownBlock && w.data == _currentVersionSection,
      );
      expect(block, findsOneWidget);
    });

    testWidgets('"View Full Changelog" button visible initially', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);

      expect(find.text('View Full Changelog'), findsOneWidget);
    });

    testWidgets(
      'tapping "View Full Changelog" switches content and hides button',
      (tester) async {
        await tester.pumpWidget(_buildTestApp());
        await _openDialog(tester);

        await tester.tap(find.text('View Full Changelog'));
        await tester.pumpAndSettle();

        final block = find.byWidgetPredicate(
          (w) => w is ThematicMarkdownBlock && w.data == '- old item',
        );
        expect(block, findsOneWidget);
        final oldBlock = find.byWidgetPredicate(
          (w) => w is ThematicMarkdownBlock && w.data == _currentVersionSection,
        );
        expect(oldBlock, findsNothing);
        expect(find.text('View Full Changelog'), findsNothing);
      },
    );

    testWidgets('Apple renders view full as content navigation', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(platform: TargetPlatform.iOS));
      await _openDialog(tester);

      expect(
        find.byKey(const ValueKey('changelog-apple-view-full')),
        findsOneWidget,
      );
      expect(find.byType(CupertinoButton), findsWidgets);
      expect(find.byType(FilledButton), findsNothing);
      final actionArea = tester.getRect(
        find.byKey(const ValueKey('adaptive-modal-actions')),
      );
      expect(
        actionArea.contains(tester.getCenter(find.text('View Full Changelog'))),
        isTrue,
      );
      expect(
        tester.getCenter(find.text('Changelog')).dx,
        tester.getCenter(find.byKey(const ValueKey('changelog-version'))).dx,
      );
    });

    testWidgets('Apple full changelog uses back without dismissing modal', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(platform: TargetPlatform.iOS));
      await _openDialog(tester);

      expect(find.byType(CupertinoPageScaffold), findsNothing);
      final dialogRect = tester.getRect(find.byType(CupertinoPopupSurface));
      expect(dialogRect.width, lessThanOrEqualTo(560));
      expect(dialogRect.height, lessThan(tester.view.physicalSize.height));

      await tester.tap(find.text('View Full Changelog'));
      await tester.pumpAndSettle();

      expect(_findCupertinoBackChevron(), findsOneWidget);
      final toolbar = tester.getRect(
        find.byKey(const ValueKey('adaptive-modal-app-bar')),
      );
      final backX = tester.getCenter(_findCupertinoBackChevron()).dx;
      final closeX = tester.getCenter(find.byIcon(CupertinoIcons.xmark)).dx;
      expect(backX, lessThan(toolbar.center.dx));
      expect(closeX, greaterThan(toolbar.center.dx));
      expect(closeX, greaterThan(backX));

      await tester.tap(_findCupertinoBackChevron());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 151));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(
        find.byKey(const ValueKey('adaptive-cupertino-modal-route-clip')),
        findsNWidgets(2),
      );
      final previousRouteClip = find.ancestor(
        of: find.text('View Full Changelog'),
        matching: find.byKey(
          const ValueKey('adaptive-cupertino-modal-route-clip'),
        ),
      );
      final outgoingRouteClip = find.ancestor(
        of: _findCupertinoBackChevron(),
        matching: find.byKey(
          const ValueKey('adaptive-cupertino-modal-route-clip'),
        ),
      );
      final previousRouteBox = tester.renderObject<RenderBox>(
        previousRouteClip,
      );
      final previousClip = tester
          .widget<ClipRect>(previousRouteClip)
          .clipper!
          .getClip(previousRouteBox.size);
      final outgoingRouteBox = tester.renderObject<RenderBox>(
        outgoingRouteClip,
      );
      expect(
        previousRouteBox.localToGlobal(previousClip.topRight).dx,
        closeTo(outgoingRouteBox.localToGlobal(Offset.zero).dx, 0.01),
      );
      await tester.pumpAndSettle();

      expect(find.text('Changelog'), findsOneWidget);
      expect(find.text('View Full Changelog'), findsOneWidget);
      expect(_findCupertinoBackChevron(), findsNothing);
    });

    testWidgets('Apple adaptive sheet clips covered inner route content', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(platform: TargetPlatform.iOS));
      await _openDialog(tester);
      expect(
        find.byKey(const ValueKey('adaptive-cupertino-modal-route-clip')),
        findsOneWidget,
      );

      final appBar = find.byKey(const ValueKey('adaptive-modal-app-bar'));
      expect(
        tester
            .widget<CupertinoNavigationBar>(
              find.descendant(
                of: appBar,
                matching: find.byType(CupertinoNavigationBar),
              ),
            )
            .transitionBetweenRoutes,
        isFalse,
      );

      await tester.tap(find.text('View Full Changelog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      final innerRoute = ModalRoute.of(
        tester.element(_findCupertinoBackChevron()),
      );
      expect(innerRoute, isA<CupertinoAdaptiveModalPageRoute<void>>());
      expect(innerRoute!.allowSnapshotting, isFalse);
      expect(innerRoute.barrierColor, isNull);

      final clips = tester
          .widgetList<ClipRect>(
            find.byKey(const ValueKey('adaptive-cupertino-modal-route-clip')),
          )
          .map((widget) => widget.clipper!.getClip(const Size(400, 800)))
          .toList();
      expect(clips, hasLength(2));
      expect(clips.any((clip) => clip.width < 400), isTrue);
      expect(clips.any((clip) => clip.width == 400), isTrue);
      expect(find.byType(Visibility), findsNothing);
      await tester.pumpAndSettle();

      await tester.tap(_findCupertinoBackChevron());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 151));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      final previousRouteClip = find.ancestor(
        of: find.text('View Full Changelog'),
        matching: find.byKey(
          const ValueKey('adaptive-cupertino-modal-route-clip'),
        ),
      );
      final outgoingRouteClip = find.ancestor(
        of: _findCupertinoBackChevron(),
        matching: find.byKey(
          const ValueKey('adaptive-cupertino-modal-route-clip'),
        ),
      );
      final previousRouteBox = tester.renderObject<RenderBox>(
        previousRouteClip,
      );
      final previousClip = tester
          .widget<ClipRect>(previousRouteClip)
          .clipper!
          .getClip(previousRouteBox.size);
      final outgoingRouteBox = tester.renderObject<RenderBox>(
        outgoingRouteClip,
      );
      expect(
        previousRouteBox.localToGlobal(previousClip.topRight).dx,
        closeTo(outgoingRouteBox.localToGlobal(Offset.zero).dx, 0.01),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Apple long markdown wraps without layout overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(700, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestApp(
          platform: TargetPlatform.iOS,
          fullChangelog: '''
## 1.0.0+1
- Feature: add resizable side navigation for wider layouts
- Feature: complete the adaptive interface migration across navigation, settings, page headers, search, selection, and habit actions
''',
        ),
      );
      await _openDialog(tester);
      expect(find.byType(CupertinoPopupSurface), findsOneWidget);
      await tester.tap(find.text('View Full Changelog'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('full page and its navigator survive dialog to sheet resize', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(platform: TargetPlatform.iOS));
      await _openDialog(tester);
      expect(find.byType(CupertinoPopupSurface), findsOneWidget);
      expect(
        find.byKey(const ValueKey('adaptive-cupertino-sheet-surface')),
        findsNothing,
      );

      await tester.tap(find.text('View Full Changelog'));
      await tester.pumpAndSettle();
      expect(_findCupertinoBackChevron(), findsOneWidget);

      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoPopupSurface), findsOneWidget);
      expect(
        find.byKey(const ValueKey('adaptive-cupertino-sheet-surface')),
        findsOneWidget,
      );
      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(_findCupertinoBackChevron(), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ThematicMarkdownBlock && widget.data == '- old item',
        ),
        findsOneWidget,
      );
    });

    testWidgets('system back pops full page before the modal route', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(platform: TargetPlatform.iOS));
      await _openDialog(tester);
      await tester.tap(find.text('View Full Changelog'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Changelog'), findsOneWidget);
      expect(find.text('View Full Changelog'), findsOneWidget);
      expect(_findCupertinoBackChevron(), findsNothing);
    });

    for (final style in AdaptiveStyle.values) {
      testWidgets(
        '$style nested back keeps the desktop scrollbar controller single-owner',
        (tester) async {
          tester.view.physicalSize = const Size(400, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(
            _buildTestApp(
              platform: TargetPlatform.macOS,
              adaptiveStyleOverride: style,
              fullChangelog: List.generate(
                80,
                (index) => '## 1.0.$index+$index\n- old item $index',
              ).join('\n'),
            ),
          );
          await _openDialog(tester);
          await tester.tap(find.text('View Full Changelog'));
          await tester.pumpAndSettle();

          final back = switch (style) {
            AdaptiveStyle.apple => _findCupertinoBackChevron(),
            AdaptiveStyle.material => find.byType(AdaptiveBackButton),
          };
          await tester.tap(back);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));
          final controllers = tester
              .widgetList<SingleChildScrollView>(
                find.byKey(const ValueKey('adaptive-modal-scroll-body')),
              )
              .map((scrollView) => scrollView.controller)
              .toList();
          expect(controllers.toSet(), hasLength(controllers.length));
          expect(tester.takeException(), isNull);
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text('View Full Changelog'), findsOneWidget);
        },
      );
    }

    testWidgets('sheet collapse closes the whole nested changelog flow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(platform: TargetPlatform.iOS));
      await _openDialog(tester);
      await tester.tap(find.text('View Full Changelog'));
      await tester.pumpAndSettle();

      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();
      final sheet = tester.widget<DraggableScrollableSheet>(
        find.byType(DraggableScrollableSheet),
      );
      final sheetContext = tester.element(
        find.byType(DraggableScrollableSheet),
      );
      DraggableScrollableNotification(
        extent: sheet.minChildSize,
        minExtent: sheet.minChildSize,
        maxExtent: sheet.maxChildSize,
        initialExtent: sheet.initialChildSize,
        context: sheetContext,
      ).dispatch(sheetContext);
      await tester.pumpAndSettle();

      expect(find.text('Changelog'), findsNothing);
      expect(find.text('Show'), findsOneWidget);
    });

    testWidgets('barrier tap closes the whole nested changelog flow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(platform: TargetPlatform.iOS));
      await _openDialog(tester);
      await tester.tap(find.text('View Full Changelog'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();

      expect(find.text('Changelog'), findsNothing);
      expect(find.text('Show'), findsOneWidget);
    });

    testWidgets('re-opening dialog resets to current version', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);

      await tester.tap(find.text('View Full Changelog'));
      await tester.pumpAndSettle();
      expect(find.text('View Full Changelog'), findsNothing);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      await _openDialog(tester);

      final block = find.byWidgetPredicate(
        (w) => w is ThematicMarkdownBlock && w.data == _currentVersionSection,
      );
      expect(block, findsOneWidget);
      expect(find.text('View Full Changelog'), findsOneWidget);
    });

    testWidgets('sheet on a compact window', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);

      expect(find.text('Changelog'), findsOneWidget);
      expect(find.text('v$_version'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byType(AdaptiveAppBar), findsOneWidget);
      expect(find.byType(SliverAppBar), findsNothing);

      final actionArea = tester.getRect(
        find.byKey(const ValueKey('adaptive-modal-actions')),
      );
      expect(
        actionArea.contains(tester.getCenter(find.text('View Full Changelog'))),
        isTrue,
      );
      expect(tester.getCenter(find.text('Close')).dx, greaterThan(200));
      final actionBar = tester.getRect(
        find.descendant(
          of: find.byKey(const ValueKey('adaptive-modal-actions')),
          matching: find.byType(OverflowBar),
        ),
      );
      final frame = tester.getRect(
        find.byKey(const ValueKey('adaptive-modal-constraints')),
      );
      expect(frame.bottom - actionBar.bottom, 8);
    });

    testWidgets('desktop platform also uses a sheet on a compact window', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp(platform: TargetPlatform.windows));
      await _openDialog(tester);

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets(
      'compact desktop transition keeps the sheet controller single-owner',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          _buildTestApp(platform: TargetPlatform.windows),
        );
        await _openDialog(tester);

        await tester.tap(find.text('View Full Changelog'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('View Full Changelog'), findsNothing);
      },
    );

    testWidgets('dialog when both window axes are medium or larger', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);

      expect(find.text('Close'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.clipBehavior, Clip.antiAlias);
      expect(
        (dialog.shape! as RoundedRectangleBorder).borderRadius,
        const BorderRadius.all(Radius.circular(28)),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SliverAppBar), findsNothing);
      final actionArea = tester.getRect(
        find.byKey(const ValueKey('adaptive-modal-actions')),
      );
      final dialogRect = tester.getRect(find.byType(Dialog));
      expect(actionArea.bottom, lessThanOrEqualTo(dialogRect.bottom));
      final actionBar = tester.getRect(
        find.descendant(
          of: find.byKey(const ValueKey('adaptive-modal-actions')),
          matching: find.byType(OverflowBar),
        ),
      );
      final frame = tester.getRect(
        find.byKey(const ValueKey('adaptive-modal-constraints')),
      );
      expect(frame.bottom - actionBar.bottom, 24);
    });

    testWidgets('Material full changelog puts back in app bar leading', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);
      await tester.tap(find.text('View Full Changelog'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(AdaptiveBackButton),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('adaptive-modal-actions')),
          matching: find.byType(AdaptiveBackButton),
        ),
        findsNothing,
      );
    });

    testWidgets(
      'Material restores the previous app bar geometry after nested back',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          _buildTestApp(
            platform: TargetPlatform.iOS,
            adaptiveStyleOverride: AdaptiveStyle.material,
            horizontalAvoidance: const EdgeInsets.only(left: 100),
            verticalAvoidance: const EdgeInsets.only(top: 1200),
          ),
        );
        await _openDialog(tester);
        final initialTitleRect = tester.getRect(find.text('Changelog'));

        await tester.tap(find.text('View Full Changelog'));
        await tester.pumpAndSettle();
        final back = find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(AdaptiveBackButton),
        );
        expect(back, findsOneWidget);

        await tester.tap(back);
        await tester.pumpAndSettle();

        expect(find.text('View Full Changelog'), findsOneWidget);
        expect(tester.getRect(find.text('Changelog')), initialTitleRect);
      },
    );

    testWidgets('close button dismisses dialog', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(_buildTestApp());
      await _openDialog(tester);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Changelog'), findsNothing);
    });
  });
}

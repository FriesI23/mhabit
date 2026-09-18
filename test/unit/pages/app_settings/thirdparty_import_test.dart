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
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/thirdparty_import.dart';
import 'package:mhabit/pages/app_settings/_widgets/thirdparty_import_provider_dialog.dart';
import 'package:mhabit/providers/workflow/thirdparty_file_importer.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_adaptive_modal.dart';
import 'package:mhabit_adaptive_ui/src/material/material_adaptive_modal.dart';

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'source selection and independent version link $platform $brightness',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(320, 700);
          addTearDown(tester.view.reset);
          const channel = MethodChannel('plugins.flutter.io/url_launcher');
          final calls = <MethodCall>[];
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            channel,
            (call) async {
              calls.add(call);
              return true;
            },
          );
          addTearDown(
            () => tester.binding.defaultBinaryMessenger
                .setMockMethodCallHandler(channel, null),
          );
          ThirdPartyProvider? result;
          var completions = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: platform, brightness: brightness),
              locale: const Locale('de'),
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
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () async {
                      result = await showThirdPartyImportProviderDialog(
                        context,
                      );
                      completions++;
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          void expectDialog() {
            final presentation = platform == TargetPlatform.android
                ? tester
                      .widget<MaterialAdaptiveModal>(
                        find.byType(MaterialAdaptiveModal),
                      )
                      .presentation
                : tester
                      .widget<CupertinoAdaptiveModal>(
                        find.byType(CupertinoAdaptiveModal),
                      )
                      .presentation;
            expect(presentation, AdaptiveModalPresentation.dialog);
          }

          expectDialog();
          expect(
            find.byKey(const ValueKey('adaptive-modal-app-bar')),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('adaptive-modal-implied-close')),
            findsNothing,
          );
          expect(find.bySubtype<AdaptiveModal>(), findsOneWidget);
          expect(tester.takeException(), isNull);
          final version = getThirdPartyImporterVersion(
            ThirdPartyProvider.loopHabitTracker,
          );
          final link = find.text('v${version.version}');
          await Scrollable.ensureVisible(tester.element(link), alignment: 0.5);
          await tester.pumpAndSettle();
          await tester.tap(link);
          await tester.pumpAndSettle();
          expect(calls.single.arguments['url'], version.releaseUrl.toString());
          expect(completions, 0);
          expect(find.bySubtype<AdaptiveModal>(), findsOneWidget);
          for (final size in [
            const Size(1000, 900),
            const Size(900, 500),
            const Size(320, 700),
          ]) {
            tester.view.physicalSize = size;
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(completions, 0);
            expectDialog();
          }
          final title = find.text('Loop Habit Tracker');
          await Scrollable.ensureVisible(tester.element(title), alignment: 0.5);
          await tester.pumpAndSettle();
          await tester.tap(title);
          await tester.pumpAndSettle();
          expect(result, ThirdPartyProvider.loopHabitTracker);
          expect(completions, 1);
          expect(calls, hasLength(1));
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          await tester.tapAt(const Offset(5, 5));
          await tester.pumpAndSettle();
          expect(result, isNull);
          expect(completions, 2);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('source dialog fits normal text width $platform', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 900);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showThirdPartyImportProviderDialog(context),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final width = tester
          .getSize(find.byKey(const ValueKey('adaptive-modal-constraints')))
          .width;
      expect(width, isNot(560));
      expect(width, lessThan(900));
      expect(width, greaterThan(200));
      expect(tester.takeException(), isNull);
    });
  }
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

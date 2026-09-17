import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_sync_options.dart';
import 'package:mhabit/pages/app_sync/_widgets/app_sync_fetch_interval.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final largeText in [false, true]) {
      testWidgets(
        '$platform interval results and resizing, large text $largeText',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(1000, 1000);
          addTearDown(tester.view.reset);
          AppSyncFetchInterval? selected = AppSyncFetchInterval.minute30;
          AppSyncFetchInterval? result;
          var completions = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                platform: platform,
                brightness: largeText ? Brightness.dark : Brightness.light,
              ),
              locale: const Locale('de'),
              localizationsDelegates: L10n.localizationsDelegates,
              supportedLocales: L10n.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(largeText ? 2 : 1)),
                child: Directionality(
                  textDirection: largeText
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: child!,
                ),
              ),
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () async {
                      result = await showAppSyncFetchIntervalSwitchDialog(
                        context: context,
                        select: selected,
                      );
                      completions++;
                    },
                    child: const Text('Open'),
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
          expect(find.byType(SimpleDialog), findsNothing);
          expect(
            find.byType(AdaptiveListTile),
            findsNWidgets(AppSyncFetchInterval.values.length),
          );
          expect(
            tester.getSize(find.byType(AdaptiveModal)).height,
            lessThan(720),
          );
          final dialog = find.byType(AppSyncFetchIntervalSwitchDialog);
          for (final interval in AppSyncFetchInterval.values) {
            final option = find.descendant(
              of: dialog,
              matching: find.byKey(ValueKey(interval.index)),
            );
            expect(
              tester.widget<Semantics>(option).properties.selected,
              interval == selected,
            );
          }
          for (final size in [
            const Size(320, 700),
            const Size(900, 400),
            const Size(1000, 1000),
          ]) {
            tester.view.physicalSize = size;
            await tester.pumpAndSettle();
            expect(dialog, findsOneWidget);
            expect(completions, 0);
            expect(tester.takeException(), isNull);
          }
          for (final interval in AppSyncFetchInterval.values) {
            if (interval.index > 0) await open();
            final option = find.descendant(
              of: dialog,
              matching: find.byKey(ValueKey(interval.index)),
            );
            await Scrollable.ensureVisible(
              tester.element(option),
              alignment: 0.5,
            );
            await tester.pumpAndSettle();
            await tester.tap(option);
            await tester.pumpAndSettle();
            expect(result, interval);
            expect(completions, interval.index + 1);
          }
          selected = null;
          await open();
          expect(find.byIcon(Icons.check), findsNothing);
          expect(find.byIcon(CupertinoIcons.check_mark), findsNothing);
          await tester.tap(
            find.byKey(const ValueKey('adaptive-modal-implied-close')),
          );
          await tester.pumpAndSettle();
          expect(result, isNull);
          expect(completions, AppSyncFetchInterval.values.length + 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/common/utils.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_settings/_widgets/app_setting_first_day.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final size in [const Size(320, 700), const Size(900, 500)]) {
      testWidgets('$platform first day selection and cancellation at $size', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);
        int? selected = DateTime.sunday;
        int? result;
        var completions = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              platform: platform,
              brightness: size.width < 600 ? Brightness.light : Brightness.dark,
            ),
            locale: const Locale('de'),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: Directionality(
                textDirection: size.width < 600
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              ),
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showAppSettingFirstDaySelectDialog(
                      context: context,
                      firstDay: selected,
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
        expect(find.byType(AdaptiveListTile), findsNWidgets(7));
        final l10n = L10n.of(
          tester.element(find.byType(AppSettingFirstDaySelectDialog)),
        )!;
        final defaultLabel =
            intl.DateFormat.EEEE(
              l10n.localeName,
            ).format(getProtoDateWithFirstDay(defaultFirstDay)) +
            l10n.appSetting_firstDayOfWeekDialog_defaultText;
        expect(find.text(defaultLabel), findsOneWidget);
        for (var day = 1; day <= 7; day++) {
          final option = find.byKey(ValueKey('first-day-option-$day'));
          expect(
            tester.widget<Semantics>(option).properties.selected,
            day == selected,
          );
        }
        expect(
          find.byIcon(
            platform == TargetPlatform.android
                ? Icons.check
                : CupertinoIcons.check_mark,
          ),
          findsOneWidget,
        );
        tester.view.physicalSize = size.width < 600
            ? const Size(900, 500)
            : const Size(320, 700);
        await tester.pumpAndSettle();
        expect(completions, 0);
        // Verify every weekday's captured callback returns its own value.
        for (var day = 1; day <= 7; day++) {
          if (day > 1) await open();
          final option = find.byKey(ValueKey('first-day-option-$day'));
          await Scrollable.ensureVisible(
            tester.element(option),
            alignment: 0.5,
          );
          await tester.pumpAndSettle();
          expect(option.hitTestable(), findsOneWidget);
          await tester.tap(option);
          await tester.pumpAndSettle();
          expect(result, day);
          expect(completions, day);
          expect(tester.takeException(), isNull);
        }
        selected = null;
        await open();
        expect(find.byIcon(Icons.check), findsNothing);
        expect(find.byIcon(CupertinoIcons.check_mark), findsNothing);
        await tester.tap(
          platform == TargetPlatform.android
              ? find.byType(CloseButton)
              : find.byKey(const ValueKey('adaptive-modal-implied-close')),
        );
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(completions, 8);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

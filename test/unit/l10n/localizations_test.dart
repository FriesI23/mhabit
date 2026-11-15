import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/entries/common/app_root_view.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/custom_date_format.dart';

void main() {
  setUpAll(initializeDateFormatting);

  test(
    'Esperanto loads its component and intl data after startup initialization',
    () async {
      const locale = Locale('eo');
      for (final delegate in appLocalizationsDelegates) {
        if (delegate.isSupported(locale)) await delegate.load(locale);
      }
      final l10n = lookupL10n(locale);
      final date = DateTime(2026, 11, 13, 14, 25, 36);
      expect(l10n.localeName, 'eo');
      expect(l10n.appSync_nowTile_syncingText_withPrt(0.75), 'Syncing: 75,00%');
      expect(NumberFormat.compact(locale: 'eo').format(12345), contains('mil'));
      expect(l10n.calendarPicker_clip_after7Days(date), 'Next ven.');
      for (final pattern in [
        'yyyy-MM-dd HH:mm:ss',
        'MM/dd',
        'E',
        'EEEE',
        'MMM',
        'y',
        'dd',
        'yMd',
        'yMMMMd',
        'yM',
        'yMMM',
        'yMMMd',
      ]) {
        expect(
          DateFormat(pattern, 'eo').format(date),
          isNotEmpty,
          reason: pattern,
        );
      }
      expect(
        DateFormat(
          'yyyy-MM-dd HH:mm:ss',
          'eo',
        ).parseStrict('2026-11-13 14:25:36'),
        date,
      );
      expect(DateFormat.yMMMMd('eo').format(date), '13-a de novembro 2026');
      expect(DateFormat('yyyy-MM-dd').format(date), '2026-11-13');
      for (final language in ['eo', 'cy', 'en', 'eo']) {
        for (final delegate in appLocalizationsDelegates) {
          final locale = Locale(language);
          if (delegate.isSupported(locale)) await delegate.load(locale);
        }
      }
      expect(DateFormat.MMMM('cy').format(date), 'Tachwedd');
      expect(DateFormat.MMMM('eo').format(date), 'novembro');
      expect(DateFormat.MMMM('en').format(date), 'November');
    },
  );

  test('selectable app locales have component and date support', () async {
    const dateConfig = CustomDateYmdHmsConfig.withDefault();
    for (final locale in appSupportedLocales) {
      final loadedTypes = <Type>{};
      // WidgetsApp appends its default Widgets delegate at runtime.
      for (final delegate in [
        ...appLocalizationsDelegates,
        DefaultWidgetsLocalizations.delegate,
      ]) {
        if (!delegate.isSupported(locale) || !loadedTypes.add(delegate.type)) {
          continue;
        }
        await delegate.load(locale);
      }
      expect(
        loadedTypes,
        containsAll([
          L10n,
          MaterialLocalizations,
          CupertinoLocalizations,
          WidgetsLocalizations,
        ]),
        reason: '$locale',
      );
      final localeName = lookupL10n(locale).localeName;
      expect(
        dateConfig
            .getYMDBatchCheckinFormatter(localeName)
            .format(DateTime(2026, 11, 13)),
        isNotEmpty,
        reason: localeName,
      );
    }
  });

  test('new ARB locales retain native names and English message fallback', () {
    final english = lookupL10n(const Locale('en'));
    for (final entry in {'cy': 'Cymraeg', 'eo': 'Esperanto'}.entries) {
      final locale = Locale(entry.key);
      expect(L10n.delegate.isSupported(locale), isTrue);
      final l10n = lookupL10n(locale);
      expect(l10n.localeScriptName, entry.value);
      expect(l10n.confirmDialog_cancel_text, english.confirmDialog_cancel_text);
      expect(
        l10n.habitDisplay_exportHabitsSuccSnackbarText(2),
        english.habitDisplay_exportHabitsSuccSnackbarText(2),
      );
    }
    expect(appSupportedLocales, contains(const Locale('eo')));
  });

  for (final locale in [const Locale('cy'), const Locale('eo')]) {
    for (final cupertino in [false, true]) {
      testWidgets(
        '$locale loads ${cupertino ? 'Cupertino' : 'Material'} date picker',
        (tester) async {
          final date = DateTime(2026, 11, 13);
          final picker = SizedBox(
            height: 350,
            child: cupertino
                ? CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: date,
                    onDateTimeChanged: (_) {},
                  )
                : CalendarDatePicker(
                    initialDate: date,
                    firstDate: DateTime(2026),
                    lastDate: DateTime(2027),
                    onDateChanged: (_) {},
                  ),
          );
          await tester.pumpWidget(
            AppRootView.withDefault(
              language: locale,
              child: Scaffold(body: picker),
            ),
          );
          await tester.pumpAndSettle();
          final context = tester.element(find.byWidget(picker));
          expect(Localizations.localeOf(context), locale);
          expect(L10n.of(context)!.localeName, locale.languageCode);
          expect(
            L10n.of(context)!.localeScriptName,
            locale.languageCode == 'cy' ? 'Cymraeg' : 'Esperanto',
          );
          expect(Directionality.of(context), TextDirection.ltr);
          expect(
            MaterialLocalizations.of(context).cancelButtonLabel,
            locale.languageCode == 'cy' ? 'Canslo' : 'Ne',
          );
          expect(
            CupertinoLocalizations.of(context).datePickerMonth(11),
            locale.languageCode == 'cy' ? 'Tachwedd' : 'Novembro',
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

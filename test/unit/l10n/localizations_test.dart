import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:material_ui/material_ui.dart';
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
      expect(appSupportedLocales, contains(locale));
      expect(l10n.localeName, 'eo');
      final percent = NumberFormat.decimalPercentPattern(
        locale: 'eo',
        decimalDigits: 2,
      );
      expect(percent.locale, 'eo');
      expect(percent.parse(percent.format(0.75)), 0.75);
      expect(NumberFormat.compact(locale: 'eo').format(12345), isNotEmpty);
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
      expect(DateFormat('yyyy-MM-dd').format(date), '2026-11-13');
      for (final language in ['eo', 'cy', 'en', 'eo']) {
        for (final delegate in appLocalizationsDelegates) {
          final locale = Locale(language);
          if (delegate.isSupported(locale)) await delegate.load(locale);
        }
      }
      for (final language in ['cy', 'eo', 'en']) {
        final formatter = DateFormat.MMMM(language);
        expect(formatter.locale, language);
        expect(formatter.format(date), isNotEmpty);
      }
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
          expect(Directionality.of(context), TextDirection.ltr);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

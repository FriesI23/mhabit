import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_settings/_widgets/app_language_changer.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final size in [const Size(320, 700), const Size(900, 500)]) {
      testWidgets('$platform language results and resize at $size', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.reset);
        AppLanguageChangerDialogResult? result;
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
                    result = await showAppLanguageChangerDialog(
                      context: context,
                      selectedLocale: const Locale('en'),
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
        expect(find.byType(AdaptiveModal), findsOneWidget);
        expect(
          find.byType(AdaptiveListTile),
          findsNWidgets(appSupportedLocales.length + 1),
        );
        expect(
          find.byIcon(
            platform == TargetPlatform.android
                ? Icons.check
                : CupertinoIcons.check_mark,
          ),
          findsOneWidget,
        );
        final english = find.byKey(const ValueKey('language-option-en'));
        expect(tester.widget<Semantics>(english).properties.selected, isTrue);
        final locales = appSupportedLocales.toList()
          ..sort((a, b) => a.toString().compareTo(b.toString()));
        final last = find.byKey(ValueKey('language-option-${locales.last}'));
        await Scrollable.ensureVisible(tester.element(last), alignment: 0.5);
        await tester.pumpAndSettle();
        expect(last.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        tester.view.physicalSize = size.width < 600
            ? const Size(900, 500)
            : const Size(320, 700);
        await tester.pumpAndSettle();
        expect(find.byType(AppLanguageChangerDialog), findsOneWidget);
        expect(completions, 0);
        await Scrollable.ensureVisible(tester.element(english), alignment: 0.5);
        await tester.pumpAndSettle();
        await tester.tap(english);
        await tester.pumpAndSettle();
        expect(result?.choosenLanguage, const Locale('en'));
        expect(completions, 1);
        await open();
        final system = find.byKey(const ValueKey('language-option-system'));
        await Scrollable.ensureVisible(tester.element(system), alignment: 0.5);
        await tester.pumpAndSettle();
        await tester.tap(system);
        await tester.pumpAndSettle();
        expect(result, isNotNull);
        expect(result!.choosenLanguage, isNull);
        expect(completions, 2);
        await open();
        await tester.tap(
          platform == TargetPlatform.android
              ? find.byType(CloseButton)
              : find.byKey(const ValueKey('adaptive-modal-implied-close')),
        );
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(completions, 3);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host(
  Widget button, {
  TargetPlatform? platform,
  Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
}) => MaterialApp(
  theme: platform == null ? null : ThemeData(platform: platform),
  localizationsDelegates: localizationsDelegates,
  home: Scaffold(appBar: AppBar(leading: button)),
);

class _TestCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const _TestCupertinoLocalizations();

  @override
  String get backButtonLabel => 'Cupertino back';
}

class _TestCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _TestCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture(const _TestCupertinoLocalizations());

  @override
  bool shouldReload(_TestCupertinoLocalizationsDelegate old) => false;
}

void main() {
  testWidgets('default constructor dispatches from adaptive style', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const AdaptiveBackButton()));
    expect(find.byType(BackButton), findsOneWidget);

    await tester.pumpWidget(
      _host(
        const AdaptiveBackButton(key: ValueKey('apple-back')),
        platform: TargetPlatform.iOS,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoButton), findsOneWidget);
    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.byType(CupertinoButton),
        matching: find.byType(Icon),
      ),
    );
    expect(icon.icon, CupertinoIcons.back);
  });

  testWidgets('close type keeps platform-specific presentation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AdaptiveBackButton.material(type: AdaptiveBackButtonType.close),
      ),
    );
    expect(find.byType(CloseButton), findsOneWidget);

    await tester.pumpWidget(
      _host(const AdaptiveBackButton.apple(type: AdaptiveBackButtonType.close)),
    );
    expect(find.byIcon(CupertinoIcons.xmark), findsOneWidget);
    expect(find.byType(CupertinoButton), findsOneWidget);
  });

  testWidgets('custom callback is invoked without popping the route', (
    tester,
  ) async {
    var invocationCount = 0;
    await tester.pumpWidget(
      _host(AdaptiveBackButton(onPressed: () => invocationCount += 1)),
    );

    await tester.tap(find.byType(BackButton));

    expect(invocationCount, 1);
  });

  testWidgets('Apple button keeps a 44 point interaction target', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const AdaptiveBackButton.apple()));

    expect(
      tester.getSize(find.byType(CupertinoButton)).height,
      greaterThanOrEqualTo(44),
    );
  });

  testWidgets('Apple back tooltip uses Cupertino localizations', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AdaptiveBackButton.apple(),
        localizationsDelegates: const [_TestCupertinoLocalizationsDelegate()],
      ),
    );

    expect(
      tester.widget<Tooltip>(find.byType(Tooltip)).message,
      'Cupertino back',
    );
  });
}

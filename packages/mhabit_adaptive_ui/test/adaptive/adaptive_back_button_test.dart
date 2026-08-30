import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host(Widget button, {TargetPlatform? platform}) => MaterialApp(
  theme: platform == null ? null : ThemeData(platform: platform),
  home: Scaffold(appBar: AppBar(leading: button)),
);

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
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host(Widget button, {TargetPlatform? platform}) => MaterialApp(
  theme: platform == null ? null : ThemeData(platform: platform),
  home: Scaffold(appBar: AppBar(leading: button)),
);

void main() {
  testWidgets('legacy default follows the adaptive package behavior', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const PageBackButton(), platform: TargetPlatform.iOS),
    );

    expect(find.byType(PageBackButton), findsOneWidget);
    expect(find.byType(AdaptiveBackButton), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
    expect(find.byType(CupertinoButton), findsOneWidget);
  });

  testWidgets('legacy close reason maps to the package API', (tester) async {
    await tester.pumpWidget(
      _host(
        const PageBackButton(reason: PageBackReason.close),
        platform: TargetPlatform.iOS,
      ),
    );

    final adaptive = tester.widget<AdaptiveBackButton>(
      find.byType(AdaptiveBackButton),
    );
    expect(adaptive.type, AdaptiveBackButtonType.close);
    expect(find.byIcon(CupertinoIcons.xmark), findsOneWidget);
    expect(find.byType(CupertinoButton), findsOneWidget);
  });
}

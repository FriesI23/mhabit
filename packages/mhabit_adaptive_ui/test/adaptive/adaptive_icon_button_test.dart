import 'package:flutter/cupertino.dart' show CupertinoButton;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host({required TargetPlatform platform, required Widget child}) =>
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('uses Material IconButton on Material platforms', (tester) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.android,
        child: AdaptiveIconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () {},
        ),
      ),
    );

    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byType(CupertinoButton), findsNothing);
  });

  testWidgets('uses standard CupertinoButton on Apple platforms', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        child: AdaptiveIconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () {},
        ),
      ),
    );

    final button = tester.widget<CupertinoButton>(find.byType(CupertinoButton));
    expect(find.byType(IconButton), findsNothing);
    expect(button.minimumSize, const Size.square(44));
    expect(button.color, isNull);
  });

  testWidgets('forced constructors override the platform', (tester) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.android,
        child: AdaptiveIconButton.apple(
          icon: const Icon(Icons.settings),
          onPressed: () {},
        ),
      ),
    );
    expect(find.byType(CupertinoButton), findsOneWidget);

    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        child: AdaptiveIconButton.material(
          icon: const Icon(Icons.settings),
          onPressed: () {},
        ),
      ),
    );
    expect(find.byType(IconButton), findsOneWidget);
  });
}

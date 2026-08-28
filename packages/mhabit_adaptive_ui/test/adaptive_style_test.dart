import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _styleLabel({
  required TargetPlatform platform,
  AdaptiveStyle? override,
  Widget? child,
}) => MaterialApp(
  theme: ThemeData(platform: platform),
  home: AdaptiveStyleScope(
    override: override,
    child:
        child ??
        Builder(
          builder: (context) => Text(
            AdaptiveStyle.of(context).name,
            textDirection: TextDirection.ltr,
          ),
        ),
  ),
);

void main() {
  group('AdaptiveStyleScope', () {
    testWidgets('falls back to the theme platform when override is null', (
      tester,
    ) async {
      await tester.pumpWidget(_styleLabel(platform: TargetPlatform.macOS));
      expect(find.text('apple'), findsOneWidget);

      await tester.pumpWidget(_styleLabel(platform: TargetPlatform.android));
      await tester.pumpAndSettle();
      expect(find.text('material'), findsOneWidget);
    });

    testWidgets('overrides material and Apple platform defaults', (
      tester,
    ) async {
      await tester.pumpWidget(
        _styleLabel(
          platform: TargetPlatform.macOS,
          override: AdaptiveStyle.material,
        ),
      );
      expect(find.text('material'), findsOneWidget);

      await tester.pumpWidget(
        _styleLabel(
          platform: TargetPlatform.android,
          override: AdaptiveStyle.apple,
        ),
      );
      expect(find.text('apple'), findsOneWidget);
    });

    testWidgets('updates adaptive consumers at runtime', (tester) async {
      final style = ValueNotifier<AdaptiveStyle?>(null);
      addTearDown(style.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: ValueListenableBuilder<AdaptiveStyle?>(
            valueListenable: style,
            builder: (context, value, child) => AdaptiveStyleScope(
              override: value,
              child: Builder(
                builder: (context) => Text(AdaptiveStyle.of(context).name),
              ),
            ),
          ),
        ),
      );
      expect(find.text('apple'), findsOneWidget);

      style.value = AdaptiveStyle.material;
      await tester.pump();
      expect(find.text('material'), findsOneWidget);

      style.value = null;
      await tester.pump();
      expect(find.text('apple'), findsOneWidget);
    });

    testWidgets('explicit widget style has priority over the scope', (
      tester,
    ) async {
      await tester.pumpWidget(
        _styleLabel(
          platform: TargetPlatform.android,
          override: AdaptiveStyle.apple,
          child: AdaptiveIconButton.material(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byType(CupertinoButton), findsNothing);

      await tester.pumpWidget(
        _styleLabel(
          platform: TargetPlatform.macOS,
          override: AdaptiveStyle.material,
          child: AdaptiveIconButton.apple(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(CupertinoButton), findsOneWidget);
      expect(find.byType(IconButton), findsNothing);
    });
  });
}

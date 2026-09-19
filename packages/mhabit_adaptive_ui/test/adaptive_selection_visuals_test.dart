import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final brightness in Brightness.values) {
      testWidgets('$style $brightness transparent section and checkmark', (
        tester,
      ) async {
        const host = Color(0xff123456);
        final scheme = ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: brightness,
        );
        var taps = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(colorScheme: scheme),
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: RepaintBoundary(
                  key: const ValueKey('capture'),
                  child: ColoredBox(
                    color: host,
                    child: SizedBox(
                      width: 400,
                      height: 200,
                      child: AdaptiveStyleScope(
                        override: style,
                        child: AdaptiveListSection(
                          appleTransparent: true,
                          padding: EdgeInsets.zero,
                          children: [
                            AdaptiveListTile(
                              key: const ValueKey('row'),
                              title: const Text('Option'),
                              trailing: const AdaptiveCheckmark(),
                              onTap: () => taps++,
                            ),
                            const AdaptiveListTile(title: Text('Second')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('capture')),
        );
        final row = tester.getRect(find.byKey(const ValueKey('row')));
        final image = await tester.runAsync(
          () => boundary.toImage(pixelRatio: 1),
        );
        final pixels = await tester.runAsync(() => image!.toByteData());
        final offset = (5 * image!.width + 30) * 4;
        final color = Color.fromARGB(
          pixels!.getUint8(offset + 3),
          pixels.getUint8(offset),
          pixels.getUint8(offset + 1),
          pixels.getUint8(offset + 2),
        );
        image.dispose();
        expect(
          color,
          style == AdaptiveStyle.apple ? host : scheme.surfaceContainerHigh,
        );
        expect(row.height, greaterThan(40));
        final icon = tester.widget<Icon>(
          find.descendant(
            of: find.byType(AdaptiveCheckmark),
            matching: find.byType(Icon),
          ),
        );
        expect(
          icon.icon,
          style == AdaptiveStyle.apple
              ? CupertinoIcons.check_mark
              : Icons.check,
        );
        if (style == AdaptiveStyle.apple) {
          expect(
            icon.color,
            CupertinoTheme.of(
              tester.element(find.byType(AdaptiveCheckmark)),
            ).primaryColor,
          );
        }
        expect(find.byType(CupertinoButton), findsNothing);
        expect(find.byType(IconButton), findsNothing);
        await tester.tap(find.byType(AdaptiveCheckmark));
        await tester.pumpAndSettle();
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('forced checkmarks ignore surrounding style', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AdaptiveStyleScope(
            override: AdaptiveStyle.material,
            child: Row(
              children: [
                AdaptiveCheckmark.apple(),
                AdaptiveCheckmark.material(),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

ShapeDecoration _paintedDecoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(
                of: find.byType(AdaptiveCupertinoFocusDecoration),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration
        as ShapeDecoration;

void main() {
  testWidgets('composes renderer geometry without changing layout or taps', (
    tester,
  ) async {
    final visible = ValueNotifier(true);
    addTearDown(visible.dispose);
    var taps = 0;
    const childKey = ValueKey('control');
    const gradient = LinearGradient(colors: [Colors.red, Colors.blue]);
    const shadows = [BoxShadow(blurRadius: 3)];
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      side: BorderSide(color: Colors.green),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const [
            AppAdaptiveUiThemeData(
              cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(
                haloWidth: 6,
              ),
            ),
          ],
        ),
        home: Center(
          child: ValueListenableBuilder(
            valueListenable: visible,
            builder: (_, value, child) => AdaptiveCupertinoFocusDecoration(
              visible: value,
              decoration: const ShapeDecoration(
                gradient: gradient,
                shadows: shadows,
                shape: shape,
              ),
              child: child!,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => taps++,
              child: const SizedBox(key: childKey, width: 80, height: 40),
            ),
          ),
        ),
      ),
    );
    final rect = tester.getRect(find.byKey(childKey));
    var decoration = _paintedDecoration(tester);
    final border = decoration.shape as RoundedRectangleBorder;
    expect(border.borderRadius, shape.borderRadius);
    expect(border.side.width, 6);
    expect(border.side.strokeAlign, BorderSide.strokeAlignOutside);
    expect(decoration.gradient, same(gradient));
    expect(decoration.shadows, same(shadows));
    expect(
      find.descendant(
        of: find.byType(AdaptiveCupertinoFocusDecoration),
        matching: find.byType(Focus),
      ),
      findsNothing,
    );
    await tester.tap(find.byKey(childKey));
    expect(taps, 1);
    visible.value = false;
    await tester.pump();
    decoration = _paintedDecoration(tester);
    expect((decoration.shape as OutlinedBorder).side, BorderSide.none);
    expect(tester.getRect(find.byKey(childKey)), rect);
    expect(decoration.gradient, same(gradient));
  });

  testWidgets(
    'resolves live local colors and theme widths without replacing content',
    (tester) async {
      final dark = ValueNotifier(false);
      addTearDown(dark.dispose);
      final input = TextEditingController(text: 'retained');
      final focus = FocusNode();
      addTearDown(input.dispose);
      addTearDown(focus.dispose);
      const localColor = CupertinoDynamicColor.withBrightness(
        color: Colors.red,
        darkColor: Colors.blue,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              AppAdaptiveUiThemeData(
                cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(
                  haloColor: Colors.green,
                  haloWidth: 1,
                ),
              ),
            ],
          ),
          home: Scaffold(
            body: ValueListenableBuilder(
              valueListenable: dark,
              builder: (_, value, child) => CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: value ? Brightness.dark : Brightness.light,
                ),
                child: AppAdaptiveUiTheme(
                  data: AppAdaptiveUiThemeData(
                    cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(
                      haloColor: localColor,
                      haloWidth: value ? 8 : 4,
                    ),
                  ),
                  child: child!,
                ),
              ),
              child: AdaptiveCupertinoFocusDecoration(
                visible: true,
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(),
                ),
                child: TextField(controller: input, focusNode: focus),
              ),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      final before = (_paintedDecoration(tester).shape as OutlinedBorder).side;
      expect(before.width, 4);
      final element = tester.element(
        find.byType(AdaptiveCupertinoFocusDecoration),
      );
      dark.value = true;
      await tester.pumpAndSettle();
      final after = (_paintedDecoration(tester).shape as OutlinedBorder).side;
      expect(after.width, 8);
      expect(after.color, isNot(before.color));
      expect(
        tester.element(find.byType(AdaptiveCupertinoFocusDecoration)),
        same(element),
      );
      expect(input.text, 'retained');
      expect(focus.hasFocus, isTrue);
    },
  );
}

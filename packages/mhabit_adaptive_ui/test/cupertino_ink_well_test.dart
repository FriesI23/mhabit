import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  testWidgets('child retains pressed background and one tap owner', (
    tester,
  ) async {
    var taps = 0;
    void activate() => taps++;
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: CupertinoInkWell(
            onActivate: activate,
            child: CupertinoListTile(
              title: const Text('Action'),
              backgroundColorActivated: CupertinoColors.systemRed,
              onTap: activate,
            ),
          ),
        ),
      ),
    );
    expect(find.byType(CupertinoButton), findsNothing);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Action')),
    );
    await tester.pump(const Duration(milliseconds: 200));
    final boxes = find.descendant(
      of: find.byType(CupertinoListTile),
      matching: find.byType(ColoredBox),
    );
    expect(
      tester.widgetList<ColoredBox>(boxes).map((box) => box.color),
      contains(CupertinoColors.systemRed),
    );
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(taps, 0);
    expect(
      tester.widgetList<ColoredBox>(boxes).map((box) => box.color),
      isNot(contains(CupertinoColors.systemRed)),
    );
    await tester.tap(find.text('Action'));
    await tester.pumpAndSettle();
    expect(taps, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(taps, 3);
  });

  testWidgets('owns supplemental long press feedback without a tap action', (
    tester,
  ) async {
    var longPresses = 0;
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: CupertinoInkWell(
            onLongPress: () => longPresses++,
            pressedColor: CupertinoColors.systemRed,
            child: const SizedBox(
              width: 200,
              height: 60,
              child: Center(child: Text('Action')),
            ),
          ),
        ),
      ),
    );
    final pressedBackground = find.descendant(
      of: find.byType(CupertinoInkWell),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == CupertinoColors.systemRed,
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Action')),
    );
    await tester.pump();
    expect(pressedBackground, findsOneWidget);
    expect(longPresses, 0);
    await tester.pump(const Duration(milliseconds: 600));
    expect(pressedBackground, findsOneWidget);
    expect(longPresses, 1);
    await gesture.up();
    await tester.pump();
    expect(pressedBackground, findsNothing);
    expect(longPresses, 1);
  });
}

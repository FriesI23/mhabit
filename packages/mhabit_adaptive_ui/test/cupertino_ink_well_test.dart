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
}

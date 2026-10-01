import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host({
  required Widget child,
  Color neutralForegroundColor = const Color(0xFF57525F),
}) => MaterialApp(
  theme: ThemeData(
    platform: TargetPlatform.iOS,
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: CupertinoColors.systemPurple,
    ),
    extensions: [
      AdaptiveCupertinoButtonThemeData(
        neutralForegroundColor: neutralForegroundColor,
      ),
    ],
  ),
  home: Center(child: child),
);

void main() {
  testWidgets('uses the neutral foreground without changing disabled color', (
    tester,
  ) async {
    const neutral = Color(0xFF57525F);

    await tester.pumpWidget(
      _host(
        neutralForegroundColor: neutral,
        child: NeutralCupertinoButton(
          onPressed: () {},
          child: const Icon(CupertinoIcons.add),
        ),
      ),
    );

    var iconContext = tester.element(find.byIcon(CupertinoIcons.add));
    expect(IconTheme.of(iconContext).color, neutral);

    await tester.pumpWidget(
      _host(
        neutralForegroundColor: neutral,
        child: const NeutralCupertinoButton(
          onPressed: null,
          child: Icon(CupertinoIcons.add),
        ),
      ),
    );

    iconContext = tester.element(find.byIcon(CupertinoIcons.add));
    expect(
      IconTheme.of(iconContext).color,
      CupertinoDynamicColor.resolve(CupertinoColors.tertiaryLabel, iconContext),
    );
  });

  testWidgets('preserves an explicit foreground override', (tester) async {
    const foreground = CupertinoColors.systemGreen;
    await tester.pumpWidget(
      _host(
        child: NeutralCupertinoButton(
          foregroundColor: foreground,
          onPressed: () {},
          child: const Icon(CupertinoIcons.add),
        ),
      ),
    );

    final iconContext = tester.element(find.byIcon(CupertinoIcons.add));
    expect(IconTheme.of(iconContext).color, foreground);
  });
}

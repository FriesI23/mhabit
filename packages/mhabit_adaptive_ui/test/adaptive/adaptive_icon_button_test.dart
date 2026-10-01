import 'package:flutter/cupertino.dart'
    show
        CupertinoButton,
        CupertinoColors,
        CupertinoDynamicColor,
        CupertinoThemeData;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host({
  required TargetPlatform platform,
  required Widget child,
  AdaptiveCupertinoFocusThemeData? focusTheme,
  Color? neutralForegroundColor,
  Brightness brightness = Brightness.light,
}) => MaterialApp(
  theme: ThemeData(
    platform: platform,
    brightness: brightness,
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: brightness,
      primaryColor: CupertinoColors.systemPurple,
    ),
    extensions: [
      focusTheme ?? const AdaptiveCupertinoFocusThemeData(),
      if (neutralForegroundColor != null)
        AdaptiveCupertinoButtonThemeData(
          neutralForegroundColor: neutralForegroundColor,
        ),
    ],
  ),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Apple button uses label in ${brightness.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          platform: TargetPlatform.iOS,
          brightness: brightness,
          child: AdaptiveIconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ),
      );

      final button = tester.widget<CupertinoButton>(
        find.byType(CupertinoButton),
      );
      final iconContext = tester.element(find.byIcon(Icons.settings));
      expect(button.foregroundColor, isNull);
      expect(
        IconTheme.of(iconContext).color,
        CupertinoDynamicColor.resolve(CupertinoColors.label, iconContext),
      );
    });
  }

  testWidgets('Apple button uses the configured blended foreground', (
    tester,
  ) async {
    const blended = Color(0xFF57525F);
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        neutralForegroundColor: blended,
        child: AdaptiveIconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {},
        ),
      ),
    );

    final iconContext = tester.element(find.byIcon(Icons.settings));
    expect(IconTheme.of(iconContext).color, blended);
  });

  testWidgets('Apple button preserves disabled and explicit icon colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        child: const AdaptiveIconButton(
          icon: Icon(Icons.settings),
          onPressed: null,
        ),
      ),
    );

    var button = tester.widget<CupertinoButton>(find.byType(CupertinoButton));
    var iconContext = tester.element(find.byIcon(Icons.settings));
    expect(button.foregroundColor, isNull);
    expect(
      IconTheme.of(iconContext).color,
      CupertinoDynamicColor.resolve(CupertinoColors.tertiaryLabel, iconContext),
    );

    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        child: AdaptiveIconButton(
          icon: const Icon(Icons.settings, color: Colors.green),
          onPressed: () {},
        ),
      ),
    );

    button = tester.widget<CupertinoButton>(find.byType(CupertinoButton));
    iconContext = tester.element(find.byIcon(Icons.settings));
    expect(button.foregroundColor, isNull);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.settings)).color,
      Colors.green,
    );
    expect(
      IconTheme.of(iconContext).color,
      CupertinoDynamicColor.resolve(CupertinoColors.label, iconContext),
    );
  });

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

  testWidgets('uses the shared Cupertino focus halo on Apple platforms', (
    tester,
  ) async {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        focusTheme: const AdaptiveCupertinoFocusThemeData(haloWidth: 6),
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
    expect(button.focusColor, CupertinoColors.transparent);
    expect(find.byType(Tooltip), findsOneWidget);
    expect(find.byType(RawTooltip), findsOneWidget);

    Focus.of(tester.element(find.byIcon(Icons.settings))).requestFocus();
    await tester.pump();
    final halo = tester
        .widgetList<DecoratedBox>(
          find.ancestor(
            of: find.byType(CupertinoButton),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => box.decoration)
        .whereType<ShapeDecoration>()
        .map((decoration) => decoration.shape)
        .whereType<OutlinedBorder>()
        .singleWhere((shape) => shape.side.width == 6);
    expect(halo.side.strokeAlign, BorderSide.strokeAlignOutside);
  });

  testWidgets('Apple tooltip uses Material presentation on mouse hover', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.macOS,
        child: AdaptiveIconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () {},
        ),
      ),
    );

    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: Offset.zero);
    await pointer.moveTo(tester.getCenter(find.byType(CupertinoButton)));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    await pointer.removePointer();
    await tester.pumpAndSettle();
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

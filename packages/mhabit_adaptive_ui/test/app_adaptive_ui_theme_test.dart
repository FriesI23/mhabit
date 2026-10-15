import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host({
  required Widget child,
  AppAdaptiveUiThemeData data = const AppAdaptiveUiThemeData(),
  TargetPlatform platform = TargetPlatform.android,
}) => MaterialApp(
  theme: ThemeData(platform: platform, extensions: [data]),
  home: child,
);

void main() {
  test(
    'copyWith preserves components and explicitly clears automatic choices',
    () {
      const data = AppAdaptiveUiThemeData(
        style: AdaptiveStyle.apple,
        breakpoints: CustomBreakpoints(width: [400]),
        listTheme: AdaptiveListThemeData(iconColor: Colors.green),
        appBarTheme: AdaptiveAppBarThemeData(
          materialFixedScrollBackground: true,
        ),
        cupertinoButtonTheme: AdaptiveCupertinoButtonThemeData(
          neutralForegroundColor: Colors.red,
        ),
        cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(haloWidth: 6),
      );
      expect(data.copyWith(), data);
      expect(data.copyWith().hashCode, data.hashCode);
      final reset = data.copyWith(style: null, breakpoints: null);
      expect(reset.style, isNull);
      expect(reset.breakpoints, isNull);
      expect(reset.listTheme, same(data.listTheme));
      expect(reset.appBarTheme, same(data.appBarTheme));
      expect(reset.cupertinoButtonTheme, same(data.cupertinoButtonTheme));
      expect(reset.cupertinoFocusTheme, same(data.cupertinoFocusTheme));
      expect(
        data
            .copyWith(
              listTheme: const AdaptiveListThemeData(surfaceColor: Colors.blue),
            )
            .listTheme
            .iconColor,
        isNull,
      );
    },
  );

  test(
    'lerp delegates to components and switches discrete choices at midpoint',
    () {
      const dynamicColor = CupertinoColors.secondarySystemBackground;
      const a = AppAdaptiveUiThemeData(
        style: AdaptiveStyle.apple,
        listTheme: AdaptiveListThemeData(surfaceColor: dynamicColor),
        cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(haloWidth: 2),
        cupertinoButtonTheme: AdaptiveCupertinoButtonThemeData(
          neutralForegroundColor: Colors.black,
        ),
      );
      const b = AppAdaptiveUiThemeData(
        breakpoints: CustomBreakpoints(width: [400]),
        appBarTheme: AdaptiveAppBarThemeData(
          materialFixedScrollBackground: true,
        ),
        listTheme: AdaptiveListThemeData(surfaceColor: Colors.red),
        cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(haloWidth: 6),
        cupertinoButtonTheme: AdaptiveCupertinoButtonThemeData(
          neutralForegroundColor: Colors.white,
        ),
      );
      final before = a.lerp(b, 0.25);
      final middle = a.lerp(b, 0.5);
      expect(before.style, AdaptiveStyle.apple);
      expect(before.breakpoints, isNull);
      expect(before.listTheme.surfaceColor, same(dynamicColor));
      expect(before.appBarTheme.materialFixedScrollBackground, isFalse);
      expect(middle.style, isNull);
      expect(middle.breakpoints, same(b.breakpoints));
      expect(middle.listTheme, b.listTheme);
      expect(middle.appBarTheme.materialFixedScrollBackground, isTrue);
      expect(middle.cupertinoFocusTheme.haloWidth, 4);
      expect(
        middle.cupertinoButtonTheme.neutralForegroundColor,
        Color.lerp(Colors.black, Colors.white, 0.5),
      );
      expect(a.lerp(null, 0.5), same(a));
    },
  );

  testWidgets('empty configuration follows platform and component defaults', (
    tester,
  ) async {
    late AppAdaptiveUiThemeData data;
    late AdaptiveStyle style;
    late Breakpoints breakpoints;
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.macOS,
        child: Builder(
          builder: (context) {
            data = AppAdaptiveUiTheme.of(context);
            style = AdaptiveStyle.of(context);
            breakpoints = Breakpoints.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(data, const AppAdaptiveUiThemeData());
    expect(style, AdaptiveStyle.apple);
    expect(breakpoints, isA<AppleBreakpoints>());
    expect(data.appBarTheme.materialFixedScrollBackground, isFalse);
    expect(data.cupertinoFocusTheme.haloWidth, 3.5);
    expect(data.cupertinoFocusTheme.haloPaintOutset, 4);
  });

  testWidgets(
    'nearest local theme replaces data; copyWith retains global fields',
    (tester) async {
      const global = AppAdaptiveUiThemeData(
        style: AdaptiveStyle.apple,
        listTheme: AdaptiveListThemeData(iconColor: Colors.green),
        cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(haloWidth: 7),
      );
      final seen = <String, AppAdaptiveUiThemeData>{};
      Widget record(String key) => Builder(
        builder: (context) {
          seen[key] = AppAdaptiveUiTheme.of(context);
          return const SizedBox();
        },
      );
      await tester.pumpWidget(
        _host(
          data: global,
          child: Builder(
            builder: (context) => Column(
              children: [
                record('global'),
                AppAdaptiveUiTheme(
                  data: const AppAdaptiveUiThemeData(),
                  child: record('replacement'),
                ),
                AppAdaptiveUiTheme(
                  data: AppAdaptiveUiTheme.of(
                    context,
                  ).copyWith(style: AdaptiveStyle.material),
                  child: record('derived'),
                ),
              ],
            ),
          ),
        ),
      );
      expect(seen['global'], global);
      expect(seen['replacement'], const AppAdaptiveUiThemeData());
      expect(seen['derived']!.style, AdaptiveStyle.material);
      expect(seen['derived']!.listTheme, global.listTheme);
      expect(seen['derived']!.cupertinoFocusTheme, global.cupertinoFocusTheme);
    },
  );

  testWidgets('extension and local updates retain input and focus state', (
    tester,
  ) async {
    final config = ValueNotifier(
      const AppAdaptiveUiThemeData(style: AdaptiveStyle.apple),
    );
    final localStyle = ValueNotifier<AdaptiveStyle?>(AdaptiveStyle.material);
    final controller = TextEditingController(text: 'retained');
    final focus = FocusNode();
    addTearDown(config.dispose);
    addTearDown(localStyle.dispose);
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      ValueListenableBuilder(
        valueListenable: config,
        builder: (_, data, child) => _host(
          data: data,
          child: ValueListenableBuilder(
            valueListenable: localStyle,
            builder: (context, style, child) => AppAdaptiveUiTheme(
              data: AppAdaptiveUiTheme.of(context).copyWith(style: style),
              child: child!,
            ),
            child: Scaffold(
              body: Column(
                children: [
                  TextField(controller: controller, focusNode: focus),
                  Builder(
                    builder: (context) => Text(
                      '${AdaptiveStyle.of(context).name}:${AppAdaptiveUiTheme.of(context).cupertinoFocusTheme.haloWidth}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    expect(find.text('material:3.5'), findsOneWidget);
    config.value = config.value.copyWith(
      cupertinoFocusTheme: const AdaptiveCupertinoFocusThemeData(haloWidth: 6),
    );
    localStyle.value = null;
    await tester.pumpAndSettle();
    expect(find.text('material:6.0'), findsOneWidget);
    expect(controller.text, 'retained');
    expect(focus.hasFocus, isTrue);
  });

  for (final sheet in [false, true]) {
    for (final root in [false, true]) {
      testWidgets(
        '${sheet ? 'sheet' : 'dialog'} captures local theme with root=$root',
        (tester) async {
          const customBreakpoints = CustomBreakpoints(
            width: [1000],
            height: [1000],
          );
          late AppAdaptiveUiThemeData routeTheme;
          late AdaptiveListThemeData listTheme;
          await tester.pumpWidget(
            _host(
              data: const AppAdaptiveUiThemeData(style: AdaptiveStyle.material),
              child: Navigator(
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (context) => AppAdaptiveUiTheme(
                    data: AppAdaptiveUiTheme.of(context).copyWith(
                      breakpoints: customBreakpoints,
                      cupertinoFocusTheme:
                          const AdaptiveCupertinoFocusThemeData(haloWidth: 8),
                    ),
                    child: AdaptiveListTheme(
                      data: const AdaptiveListThemeData(
                        iconColor: Colors.orange,
                      ),
                      child: Builder(
                        builder: (context) => Scaffold(
                          body: TextButton(
                            onPressed: () {
                              Widget content(BuildContext context) {
                                routeTheme = AppAdaptiveUiTheme.of(context);
                                listTheme = AdaptiveListTheme.of(context);
                                return const Text('captured');
                              }

                              if (sheet) {
                                showAdaptiveSheet<void>(
                                  context: context,
                                  useRootNavigator: root,
                                  builder: content,
                                );
                              } else {
                                showAdaptiveModalDialog<void>(
                                  context: context,
                                  useRootNavigator: root,
                                  barrierDismissible: true,
                                  builder: content,
                                );
                              }
                            },
                            child: const Text('open'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          expect(find.text('captured'), findsOneWidget);
          expect(routeTheme.cupertinoFocusTheme.haloWidth, 8);
          expect(routeTheme.breakpoints, same(customBreakpoints));
          expect(listTheme.iconColor, Colors.orange);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('forced sheet style chooses its own default breakpoints', (
    tester,
  ) async {
    late Breakpoints breakpoints;
    late AdaptiveStyle style;
    await tester.pumpWidget(
      _host(
        data: const AppAdaptiveUiThemeData(style: AdaptiveStyle.material),
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAdaptiveSheet<void>(
              context: context,
              styleOverride: AdaptiveStyle.apple,
              builder: (context) {
                breakpoints = Breakpoints.of(context);
                style = AdaptiveStyle.of(context);
                return const Text('forced');
              },
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(style, AdaptiveStyle.apple);
    expect(breakpoints, isA<AppleBreakpoints>());
  });
  testWidgets('missing extension returns empty configuration', (tester) async {
    late AppAdaptiveUiThemeData data;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            data = AppAdaptiveUiTheme.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(data, const AppAdaptiveUiThemeData());
  });

  for (final sheet in [false, true]) {
    testWidgets(
      '${sheet ? "sheet" : "dialog"} keeps root theme updates while pinning style',
      (tester) async {
        final dark = ValueNotifier(false);
        addTearDown(dark.dispose);
        final input = TextEditingController(text: 'route text');
        final focus = FocusNode();
        addTearDown(input.dispose);
        addTearDown(focus.dispose);
        await tester.pumpWidget(
          ValueListenableBuilder(
            valueListenable: dark,
            builder: (_, isDark, child) => MaterialApp(
              theme: ThemeData(
                brightness: isDark ? Brightness.dark : Brightness.light,
                extensions: [
                  AppAdaptiveUiThemeData(
                    style: isDark
                        ? AdaptiveStyle.apple
                        : AdaptiveStyle.material,
                    cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(
                      haloWidth: isDark ? 8 : 4,
                    ),
                  ),
                ],
              ),
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () {
                    Widget content(BuildContext context) => Material(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${Theme.of(context).brightness.name}:${AdaptiveStyle.of(context).name}:${AppAdaptiveUiTheme.of(context).cupertinoFocusTheme.haloWidth}',
                          ),
                          TextField(controller: input, focusNode: focus),
                        ],
                      ),
                    );
                    if (sheet) {
                      showAdaptiveSheet<void>(
                        context: context,
                        builder: content,
                      );
                    } else {
                      showAdaptiveModalDialog<void>(
                        context: context,
                        barrierDismissible: true,
                        builder: content,
                      );
                    }
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.text('light:material:4.0'), findsOneWidget);
        focus.requestFocus();
        await tester.pump();
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        dark.value = true;
        await tester.pumpAndSettle();
        expect(find.text('dark:material:8.0'), findsOneWidget);
        expect(input.text, 'route text');
        expect(focus.hasFocus, isTrue);
        expect(
          tester.state<NavigatorState>(find.byType(Navigator)),
          same(navigator),
        );
      },
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final fromList in [false, true]) {
      for (final nested in [false, true]) {
        testWidgets(
          '$style list=$fromList nested=$nested keeps live root modal themes',
          (tester) async {
            final dark = ValueNotifier(false);
            addTearDown(dark.dispose);
            Widget content(BuildContext context) => Text(
              '${Theme.of(context).brightness.name}:'
              '${CupertinoTheme.of(context).brightness?.name}:'
              '${AppAdaptiveUiTheme.of(context).cupertinoFocusTheme.haloWidth}',
            );
            void open(BuildContext context) {
              showAdaptiveSheet<void>(
                context: context,
                builder: nested
                    ? (context) => TextButton(
                        onPressed: () => showAdaptiveSheet<void>(
                          context: context,
                          builder: content,
                        ),
                        child: const Text('nested'),
                      )
                    : content,
              );
            }

            final button = Builder(
              builder: (context) => TextButton(
                onPressed: () => open(context),
                child: const Text('open'),
              ),
            );
            await tester.pumpWidget(
              ValueListenableBuilder(
                valueListenable: dark,
                builder: (_, isDark, child) => MaterialApp(
                  theme: ThemeData(
                    platform: style == AdaptiveStyle.apple
                        ? TargetPlatform.macOS
                        : TargetPlatform.android,
                    brightness: isDark ? Brightness.dark : Brightness.light,
                    extensions: [
                      AppAdaptiveUiThemeData(
                        cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(
                          haloWidth: isDark ? 8 : 4,
                        ),
                      ),
                    ],
                  ),
                  // Like Sidebar, the page derives its Cupertino surface from
                  // the current root theme. It is not an explicit modal theme.
                  home: Builder(
                    builder: (context) => CupertinoTheme(
                      data: CupertinoTheme.of(context).copyWith(
                        scaffoldBackgroundColor: CupertinoTheme.of(
                          context,
                        ).scaffoldBackgroundColor,
                      ),
                      child: Scaffold(
                        body: fromList
                            ? AdaptiveListSection(children: [button])
                            : button,
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.tap(find.text('open'));
            await tester.pumpAndSettle();
            if (nested) {
              await tester.tap(find.text('nested'));
              await tester.pumpAndSettle();
            }
            expect(find.text('light:light:4.0'), findsOneWidget);
            dark.value = true;
            await tester.pumpAndSettle();
            expect(find.text('dark:dark:8.0'), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  for (final localInside in [false, true]) {
    testWidgets('nearest theme wins: local inside=$localInside', (
      tester,
    ) async {
      const local = AppAdaptiveUiThemeData(
        style: AdaptiveStyle.material,
        cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(haloWidth: 9),
      );
      late AppAdaptiveUiThemeData seen;
      final record = Builder(
        builder: (context) {
          seen = AppAdaptiveUiTheme.of(context);
          return const SizedBox();
        },
      );
      final child = localInside
          ? AdaptiveListSection.apple(
              children: [AppAdaptiveUiTheme(data: local, child: record)],
            )
          : AppAdaptiveUiTheme(
              data: local,
              child: AdaptiveListSection.apple(children: [record]),
            );
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
      expect(
        seen.style,
        localInside ? AdaptiveStyle.material : AdaptiveStyle.apple,
      );
      expect(seen.cupertinoFocusTheme.haloWidth, 9);
    });
  }

  testWidgets('a nearer local theme shields consumers from outer updates', (
    tester,
  ) async {
    final outer = ValueNotifier(const AppAdaptiveUiThemeData());
    addTearDown(outer.dispose);
    var consumerBuilds = 0;
    final section = AdaptiveListSection.apple(
      children: [
        AppAdaptiveUiTheme(
          data: const AppAdaptiveUiThemeData(
            cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(haloWidth: 9),
          ),
          child: Builder(
            builder: (context) {
              consumerBuilds++;
              return Text(
                '${AppAdaptiveUiTheme.of(context).cupertinoFocusTheme.haloWidth}',
              );
            },
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: outer,
            child: section,
            builder: (_, data, child) =>
                AppAdaptiveUiTheme(data: data, child: child!),
          ),
        ),
      ),
    );
    final initialBuilds = consumerBuilds;
    outer.value = outer.value.copyWith(
      cupertinoFocusTheme: const AdaptiveCupertinoFocusThemeData(haloWidth: 8),
    );
    await tester.pumpAndSettle();
    expect(find.text('9.0'), findsOneWidget);
    expect(consumerBuilds, initialBuilds);
    expect(tester.takeException(), isNull);
  });

  for (final native in [false, true]) {
    for (final explicit in [false, true]) {
      testWidgets(
        'dialog native=$native explicit=$explicit captures only explicit data',
        (tester) async {
          final dark = ValueNotifier(false);
          addTearDown(dark.dispose);
          const local = AppAdaptiveUiThemeData(
            cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(haloWidth: 9),
          );
          final section = AdaptiveListSection.apple(
            children: [
              Builder(
                builder: (context) => TextButton(
                  onPressed: () {
                    Widget content(BuildContext context) => Text(
                      '${AppAdaptiveUiTheme.of(context).cupertinoFocusTheme.haloWidth}',
                    );
                    if (native) {
                      showDialog<void>(context: context, builder: content);
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
            ],
          );
          await tester.pumpWidget(
            ValueListenableBuilder(
              valueListenable: dark,
              builder: (_, value, child) => MaterialApp(
                theme: ThemeData(
                  brightness: value ? Brightness.dark : Brightness.light,
                  extensions: [
                    AppAdaptiveUiThemeData(
                      cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(
                        haloWidth: value ? 8 : 4,
                      ),
                    ),
                  ],
                ),
                home: Scaffold(
                  body: explicit
                      ? AppAdaptiveUiTheme(data: local, child: section)
                      : section,
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          expect(find.text(explicit ? '9.0' : '4.0'), findsOneWidget);
          dark.value = true;
          await tester.pumpAndSettle();
          expect(find.text(explicit ? '9.0' : '8.0'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Navigator context does not capture themes above itself', (
    tester,
  ) async {
    final data = ValueNotifier(const AppAdaptiveUiThemeData());
    addTearDown(data.dispose);
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        builder: (_, child) => ValueListenableBuilder(
          valueListenable: data,
          child: child,
          builder: (_, value, child) =>
              AppAdaptiveUiTheme(data: value, child: child!),
        ),
        home: const Scaffold(),
      ),
    );
    showAdaptiveSheet<void>(
      context: navigator.currentContext!,
      builder: (context) => Text(
        '${AppAdaptiveUiTheme.of(context).cupertinoFocusTheme.haloWidth}',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3.5'), findsOneWidget);
    data.value = data.value.copyWith(
      cupertinoFocusTheme: const AdaptiveCupertinoFocusThemeData(haloWidth: 8),
    );
    await tester.pumpAndSettle();
    expect(find.text('8.0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final local in [false, true]) {
    testWidgets('captures local nodes, not shared theme data: local=$local', (
      tester,
    ) async {
      const initial = AppAdaptiveUiThemeData(
        cupertinoFocusTheme: AdaptiveCupertinoFocusThemeData(haloWidth: 4),
      );
      const initialList = AdaptiveListThemeData(iconColor: Colors.red);
      final data = ValueNotifier(initial);
      addTearDown(data.dispose);
      final button = Builder(
        builder: (context) => TextButton(
          onPressed: () => showAdaptiveSheet<void>(
            context: context,
            builder: (context) => Text(
              '${AppAdaptiveUiTheme.of(context).cupertinoFocusTheme.haloWidth}:'
              '${AdaptiveListTheme.of(context).iconColor == Colors.red}',
            ),
          ),
          child: const Text('open'),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (_, child) => ValueListenableBuilder(
            valueListenable: data,
            child: child,
            builder: (_, value, child) => AppAdaptiveUiTheme(
              data: value,
              child: AdaptiveListTheme(
                data: identical(value, initial)
                    ? initialList
                    : const AdaptiveListThemeData(iconColor: Colors.blue),
                child: child!,
              ),
            ),
          ),
          home: Scaffold(
            // These local nodes intentionally reuse the root data objects.
            // Identity must be compared on the nodes, not their data.
            body: local
                ? AppAdaptiveUiTheme(
                    data: initial,
                    child: AdaptiveListTheme(data: initialList, child: button),
                  )
                : button,
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('4.0:true'), findsOneWidget);
      data.value = initial.copyWith(
        cupertinoFocusTheme: const AdaptiveCupertinoFocusThemeData(
          haloWidth: 8,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(local ? '4.0:true' : '8.0:false'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

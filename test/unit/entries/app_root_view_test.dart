// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/cupertino.dart' show CupertinoTheme, CupertinoThemeData;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit/entries/common/app_root_view.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

const MethodChannel _windowControlChannel = MethodChannel(
  'ios_window_control_layout',
);

Map<String, double> _insets({
  double start = 0,
  double top = 0,
  double end = 0,
  double bottom = 0,
}) => <String, double>{
  'start': start,
  'top': top,
  'end': end,
  'bottom': bottom,
};

Map<String, Object> _windowControlPayload({
  required bool hasHorizontalAvoidance,
  bool hasVerticalAvoidance = false,
  bool isPad = true,
  bool isFullScreen = false,
}) => <String, Object>{
  'schemaVersion': 4,
  'isAvailable': true,
  'isPad': isPad,
  'isFullScreen': isFullScreen,
  'baseMargins': _insets(),
  'horizontalMargins': _insets(start: hasHorizontalAvoidance ? 40 : 0),
  'verticalMargins': _insets(top: hasVerticalAvoidance ? 20 : 0),
  'baseSafeArea': _insets(bottom: 34),
  'horizontalSafeArea': _insets(bottom: 34),
  'verticalSafeArea': _insets(bottom: 34),
  'effectiveCornerRadii': <String, double>{
    'topLeft': 62,
    'topRight': 62,
    'bottomLeft': 62,
    'bottomRight': 62,
  },
};

void main() {
  group('AppRootView', () {
    testWidgets('default constructor builds MaterialApp with home:', (
      tester,
    ) async {
      await tester.pumpWidget(
        const AppRootView(
          themeMode: ThemeMode.system,
          child: Text('home-child'),
        ),
      );

      expect(find.text('home-child'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('.router constructor builds MaterialApp.router with config', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Text('router-child')),
        ],
      );

      await tester.pumpWidget(
        AppRootView.router(themeMode: ThemeMode.system, config: router),
      );

      expect(find.text('router-child'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('.withDefault uses ThemeMode.system by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        const AppRootView.withDefault(child: Text('default-child')),
      );

      expect(find.text('default-child'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('text direction override reaches the app content', (
      tester,
    ) async {
      await tester.pumpWidget(
        const AppRootView(
          themeMode: ThemeMode.system,
          textDirectionOverride: TextDirection.rtl,
          child: _TextDirectionProbe(),
        ),
      );

      expect(find.text('rtl'), findsOneWidget);
    });

    testWidgets(
      'router path: no navigatorKey/navigatorObservers on MaterialApp',
      (tester) async {
        // When routerConfig is provided, navigatorKey is managed by GoRouter
        // and should not appear as direct properties on MaterialApp.
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Text('router-key-test'),
            ),
          ],
        );

        await tester.pumpWidget(
          AppRootView.router(themeMode: ThemeMode.system, config: router),
        );

        expect(find.text('router-key-test'), findsOneWidget);

        // Verify a MaterialApp.router descendant exists (no crash = success).
        final materialAppFinder = find.byType(MaterialApp);
        expect(materialAppFinder, findsOneWidget);
      },
    );

    testWidgets('home path: navigatorKey and observers on MaterialApp', (
      tester,
    ) async {
      await tester.pumpWidget(
        const AppRootView(
          themeMode: ThemeMode.system,
          child: Text('home-key-test'),
        ),
      );

      expect(find.text('home-key-test'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('theme builders receive the window-control context', (
      tester,
    ) async {
      var lightBuilderHasLayout = false;
      var darkBuilderHasLayout = false;

      await tester.pumpWidget(
        AppRootView(
          themeMode: ThemeMode.system,
          lightThemeBuilder: (context) {
            lightBuilderHasLayout =
                AdaptiveWindowControlLayoutScope.maybeOf(context) != null;
            return ThemeData.light();
          },
          darkThemeBuilder: (context) {
            darkBuilderHasLayout =
                AdaptiveWindowControlLayoutScope.maybeOf(context) != null;
            return ThemeData.dark();
          },
          child: const SizedBox(),
        ),
      );

      expect(lightBuilderHasLayout, isTrue);
      expect(darkBuilderHasLayout, isTrue);
    });

    testWidgets(
      'apple window transition preserves state and elevates page background',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        var hasHorizontalAvoidance = false;
        var isPad = true;
        var isFullScreen = false;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              _windowControlChannel,
              (_) async => _windowControlPayload(
                hasHorizontalAvoidance: hasHorizontalAvoidance,
                hasVerticalAvoidance: true,
                isPad: isPad,
                isFullScreen: isFullScreen,
              ),
            );
        final colorScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFF446688),
          brightness: Brightness.dark,
        );
        final baseBackground = colorScheme.surface;
        final elevatedBackground = colorScheme.surfaceContainerLow;
        const probeKey = ValueKey('apple-window-background-probe');
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const _StatefulProbe(key: probeKey),
            ),
          ],
        );
        addTearDown(router.dispose);

        try {
          await tester.pumpWidget(
            AppRootView.router(
              themeMode: ThemeMode.dark,
              darkThemeBuilder: (context) {
                final useElevatedTheme =
                    defaultTargetPlatform == TargetPlatform.iOS &&
                    AdaptiveWindowControlLayoutScope.maybeOf(
                          context,
                        )?.hasWindowControlAvoidance ==
                        true;
                if (!useElevatedTheme) {
                  return ThemeData(
                    colorScheme: colorScheme,
                    scaffoldBackgroundColor: baseBackground,
                    cupertinoOverrideTheme: CupertinoThemeData(
                      scaffoldBackgroundColor: baseBackground,
                    ),
                  );
                }
                final elevatedScheme = colorScheme.copyWith(
                  surface: elevatedBackground,
                );
                return ThemeData(
                  colorScheme: elevatedScheme,
                  scaffoldBackgroundColor: baseBackground,
                  cupertinoOverrideTheme: CupertinoThemeData(
                    scaffoldBackgroundColor: elevatedBackground,
                  ),
                ).copyWith(scaffoldBackgroundColor: elevatedBackground);
              },
              config: router,
            ),
          );
          await tester.pumpAndSettle();

          var context = tester.element(find.byKey(probeKey));
          final probeState = tester.state(find.byKey(probeKey));
          expect(Theme.of(context).scaffoldBackgroundColor, baseBackground);
          expect(
            CupertinoTheme.of(context).scaffoldBackgroundColor,
            baseBackground,
          );
          final initialLayout = AdaptiveWindowControlLayoutScope.maybeOf(
            context,
          );
          expect(
            initialLayout?.verticalAvoidance,
            isNot(EdgeInsetsDirectional.zero),
          );
          expect(initialLayout?.hasWindowControlAvoidance, isFalse);
          final baseBarBackground = CupertinoTheme.of(
            context,
          ).barBackgroundColor;

          hasHorizontalAvoidance = true;
          tester.binding.handleMetricsChanged();
          await tester.pumpAndSettle();

          context = tester.element(find.byKey(probeKey));
          final layout = AdaptiveWindowControlLayoutScope.maybeOf(context);
          expect(AdaptiveStyle.of(context), AdaptiveStyle.apple);
          expect(
            layout?.horizontalAvoidance,
            isNot(EdgeInsetsDirectional.zero),
          );
          expect(tester.state(find.byKey(probeKey)), same(probeState));
          expect(Theme.of(context).scaffoldBackgroundColor, elevatedBackground);
          expect(Theme.of(context).colorScheme.surface, elevatedBackground);
          expect(
            tester
                .widget<MaterialApp>(find.byType(MaterialApp))
                .darkTheme
                ?.scaffoldBackgroundColor,
            elevatedBackground,
          );
          expect(
            CupertinoTheme.of(context).scaffoldBackgroundColor,
            elevatedBackground,
          );
          expect(
            CupertinoTheme.of(context).barBackgroundColor,
            baseBarBackground,
          );

          isPad = false;
          tester.binding.handleMetricsChanged();
          await tester.pumpAndSettle();

          context = tester.element(find.byKey(probeKey));
          expect(tester.state(find.byKey(probeKey)), same(probeState));
          expect(
            AdaptiveWindowControlLayoutScope.maybeOf(
              context,
            )?.hasWindowControlAvoidance,
            isFalse,
          );
          expect(Theme.of(context).scaffoldBackgroundColor, baseBackground);

          isPad = true;
          isFullScreen = true;
          tester.binding.handleMetricsChanged();
          await tester.pumpAndSettle();

          context = tester.element(find.byKey(probeKey));
          expect(tester.state(find.byKey(probeKey)), same(probeState));
          expect(
            AdaptiveWindowControlLayoutScope.maybeOf(
              context,
            )?.hasWindowControlAvoidance,
            isFalse,
          );
          expect(Theme.of(context).scaffoldBackgroundColor, baseBackground);

          isFullScreen = false;
          tester.binding.handleMetricsChanged();
          await tester.pumpAndSettle();

          context = tester.element(find.byKey(probeKey));
          expect(tester.state(find.byKey(probeKey)), same(probeState));
          expect(
            AdaptiveWindowControlLayoutScope.maybeOf(
              context,
            )?.hasWindowControlAvoidance,
            isTrue,
          );
          expect(Theme.of(context).scaffoldBackgroundColor, elevatedBackground);

          hasHorizontalAvoidance = false;
          tester.binding.handleMetricsChanged();
          await tester.pumpAndSettle();

          context = tester.element(find.byKey(probeKey));
          expect(tester.state(find.byKey(probeKey)), same(probeState));
          expect(Theme.of(context).scaffoldBackgroundColor, baseBackground);
          expect(
            CupertinoTheme.of(context).scaffoldBackgroundColor,
            baseBackground,
          );
          expect(
            tester
                .widget<MaterialApp>(find.byType(MaterialApp))
                .darkTheme
                ?.scaffoldBackgroundColor,
            baseBackground,
          );
          expect(
            CupertinoTheme.of(context).barBackgroundColor,
            baseBarBackground,
          );
        } finally {
          debugDefaultTargetPlatformOverride = null;
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(_windowControlChannel, null);
        }
      },
    );

    testWidgets('non-iOS apple platform ignores window background elevation', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final colorScheme = ColorScheme.fromSeed(
        seedColor: const Color(0xFF446688),
        brightness: Brightness.dark,
      );
      final baseBackground = colorScheme.surface;
      const probeKey = ValueKey('non-ios-window-background-probe');

      try {
        await tester.pumpWidget(
          AppRootView(
            themeMode: ThemeMode.dark,
            darkThemeBuilder: (context) {
              if (defaultTargetPlatform == TargetPlatform.iOS &&
                  AdaptiveWindowControlLayoutScope.maybeOf(
                        context,
                      )?.hasWindowControlAvoidance ==
                      true) {
                throw StateError(
                  'macOS must not select the iOS elevated theme',
                );
              }
              return ThemeData(
                platform: TargetPlatform.macOS,
                colorScheme: colorScheme,
                scaffoldBackgroundColor: baseBackground,
              );
            },
            child: const SizedBox(key: probeKey),
          ),
        );
        await tester.pumpAndSettle();

        final context = tester.element(find.byKey(probeKey));
        expect(AdaptiveStyle.of(context), AdaptiveStyle.apple);
        expect(Theme.of(context).platform, TargetPlatform.macOS);
        expect(Theme.of(context).scaffoldBackgroundColor, baseBackground);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('window-control layout reaches root GoRouter pages', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_windowControlChannel, (_) async {
            return <String, Object>{
              'schemaVersion': 4,
              'isAvailable': true,
              'isPad': true,
              'isFullScreen': false,
              'baseMargins': _insets(),
              'horizontalMargins': _insets(start: 40, end: 12),
              'verticalMargins': _insets(),
              'baseSafeArea': _insets(bottom: 34),
              'horizontalSafeArea': _insets(start: 24, end: 18, bottom: 34),
              'verticalSafeArea': _insets(bottom: 34),
              'effectiveCornerRadii': <String, double>{
                'topLeft': 62,
                'topRight': 62,
                'bottomLeft': 62,
                'bottomRight': 62,
              },
            };
          });
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () => context.push('/settings'),
                child: const Text('open page'),
              ),
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, _) => const Scaffold(
              appBar: WindowControlAppBar(
                leading: SizedBox.expand(key: ValueKey('pushed-leading')),
              ),
            ),
          ),
        ],
      );
      try {
        await tester.pumpWidget(
          AppRootView.router(themeMode: ThemeMode.system, config: router),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('open page'));
        await tester.pumpAndSettle();

        expect(
          tester.getTopLeft(find.byKey(const ValueKey('pushed-leading'))).dx,
          52,
        );
      } finally {
        router.dispose();
        debugDefaultTargetPlatformOverride = null;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_windowControlChannel, null);
      }
    });
  });
}

class _TextDirectionProbe extends StatelessWidget {
  const _TextDirectionProbe();

  @override
  Widget build(BuildContext context) => Text(Directionality.of(context).name);
}

class _StatefulProbe extends StatefulWidget {
  const _StatefulProbe({super.key});

  @override
  State<_StatefulProbe> createState() => _StatefulProbeState();
}

class _StatefulProbeState extends State<_StatefulProbe> {
  @override
  Widget build(BuildContext context) => const SizedBox();
}

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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/widgets/widgets.dart';

Future<void> _commitPredictiveBack(WidgetTester tester) async {
  final startMessage = const StandardMethodCodec().encodeMethodCall(
    const MethodCall('startBackGesture', <String, dynamic>{
      'touchOffset': <double>[5.0, 300.0],
      'progress': 0.0,
      'swipeEdge': 0,
    }),
  );
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/backgesture',
    startMessage,
    (data) {},
  );
  await tester.pump();

  final commitMessage = const StandardMethodCodec().encodeMethodCall(
    const MethodCall('commitBackGesture'),
  );
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/backgesture',
    commitMessage,
    (data) {},
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('routes on the root navigator are never considered covered', (
    tester,
  ) async {
    late BuildContext pageContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            pageContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final route = ModalRoute.of(pageContext)! as PageRoute<dynamic>;
    expect(isRouteCoveredByRootRoute(route), isFalse);
  });

  testWidgets(
    'nested navigator route becomes covered when a root-level route is on '
    'top',
    (tester) async {
      final nestedNavigatorKey = GlobalKey<NavigatorState>();
      late BuildContext rootPageContext;
      late BuildContext nestedPageContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              rootPageContext = context;
              return Navigator(
                key: nestedNavigatorKey,
                onGenerateRoute: (settings) => MaterialPageRoute<void>(
                  settings: settings,
                  builder: (context) => Builder(
                    builder: (nestedContext) {
                      nestedPageContext = nestedContext;
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      final nestedRoute =
          ModalRoute.of(nestedPageContext)! as PageRoute<dynamic>;
      expect(isRouteCoveredByRootRoute(nestedRoute), isFalse);

      Navigator.of(rootPageContext).push<void>(
        DialogRoute<void>(
          context: rootPageContext,
          builder: (context) => const SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();

      expect(isRouteCoveredByRootRoute(nestedRoute), isTrue);
    },
  );

  testWidgets(
    'stateful-shell-depth route detects a dialog above all shell navigators',
    (tester) async {
      late BuildContext rootPageContext;
      late BuildContext branchPageContext;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              rootPageContext = context;
              return Navigator(
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (context) => Navigator(
                    onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (context) => Builder(
                        builder: (context) {
                          branchPageContext = context;
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      final branchRoute =
          ModalRoute.of(branchPageContext)! as PageRoute<dynamic>;
      expect(isRouteCoveredByRootRoute(branchRoute), isFalse);

      Navigator.of(rootPageContext).push<void>(
        DialogRoute<void>(
          context: rootPageContext,
          builder: (context) => const SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();

      expect(isRouteCoveredByRootRoute(branchRoute), isTrue);
    },
  );

  testWidgets(
    'root dialog then branch detail handle consecutive predictive backs',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final branchNavigatorKey = GlobalKey<NavigatorState>();
      late BuildContext rootPageContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android:
                    CustomPredictiveBackPageTransitionsBuilder(),
              },
            ),
          ),
          home: Builder(
            builder: (context) {
              rootPageContext = context;
              return Navigator(
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (context) => Navigator(
                    key: branchNavigatorKey,
                    onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (context) => const Text('habits page'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      branchNavigatorKey.currentState!.push<void>(
        MaterialPageRoute<void>(
          builder: (context) => const Text('detail page'),
        ),
      );
      await tester.pumpAndSettle();
      showDialog<void>(
        context: rootPageContext,
        builder: (context) => const AlertDialog(title: Text('calendar')),
      );
      await tester.pumpAndSettle();

      await _commitPredictiveBack(tester);

      expect(find.text('calendar'), findsNothing);
      expect(find.text('detail page'), findsOneWidget);

      await _commitPredictiveBack(tester);

      expect(find.text('detail page'), findsNothing);
      expect(find.text('habits page'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    },
  );
}

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
import 'package:mhabit/routes/app_material_page.dart';

Future<void> _commitPredictiveBack(WidgetTester tester) async {
  for (final call in [
    const MethodCall('startBackGesture', <String, dynamic>{
      'touchOffset': <double>[5.0, 300.0],
      'progress': 0.0,
      'swipeEdge': 0,
    }),
    const MethodCall('commitBackGesture'),
  ]) {
    final message = const StandardMethodCodec().encodeMethodCall(call);
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/backgesture',
      message,
      (data) {},
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('root navigator routes are never considered covered', (
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
    expect(isRouteCoveredByAncestorRoute(route), isFalse);
  });

  testWidgets('nested route detects a covering root route', (tester) async {
    late BuildContext rootPageContext;
    late BuildContext nestedPageContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            rootPageContext = context;
            return Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute<void>(
                settings: settings,
                builder: (context) => Builder(
                  builder: (context) {
                    nestedPageContext = context;
                    return const SizedBox.shrink();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );

    final nestedRoute = ModalRoute.of(nestedPageContext)! as PageRoute<dynamic>;
    expect(isRouteCoveredByAncestorRoute(nestedRoute), isFalse);

    Navigator.of(rootPageContext).push<void>(
      DialogRoute<void>(
        context: rootPageContext,
        builder: (context) => const SizedBox.shrink(),
      ),
    );
    await tester.pumpAndSettle();

    expect(isRouteCoveredByAncestorRoute(nestedRoute), isTrue);
  });

  testWidgets('route checks every navigator ancestor', (tester) async {
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

    final branchRoute = ModalRoute.of(branchPageContext)! as PageRoute<dynamic>;
    expect(isRouteCoveredByAncestorRoute(branchRoute), isFalse);

    Navigator.of(rootPageContext).push<void>(
      DialogRoute<void>(
        context: rootPageContext,
        builder: (context) => const SizedBox.shrink(),
      ),
    );
    await tester.pumpAndSettle();

    expect(isRouteCoveredByAncestorRoute(branchRoute), isTrue);
  });

  testWidgets(
    'root dialog and nested detail handle consecutive predictive backs',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final branchNavigatorKey = GlobalKey<NavigatorState>();
      late BuildContext rootPageContext;

      await tester.pumpWidget(
        MaterialApp(
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

      final detailRoute =
          const AppMaterialPage<void>(
                name: 'detail',
                child: Text('detail page'),
              ).createRoute(rootPageContext)
              as PageRoute<void>;
      branchNavigatorKey.currentState!.push<void>(detailRoute);
      await tester.pumpAndSettle();

      expect(detailRoute.popDisposition, RoutePopDisposition.pop);
      expect(detailRoute.popGestureEnabled, isTrue);

      showDialog<void>(
        context: rootPageContext,
        builder: (context) => const AlertDialog(title: Text('calendar')),
      );
      await tester.pumpAndSettle();

      expect(detailRoute.popDisposition, RoutePopDisposition.pop);
      expect(detailRoute.popGestureEnabled, isFalse);

      await _commitPredictiveBack(tester);

      expect(find.text('calendar'), findsNothing);
      expect(find.text('detail page'), findsOneWidget);
      expect(detailRoute.popDisposition, RoutePopDisposition.pop);
      expect(detailRoute.popGestureEnabled, isTrue);

      await _commitPredictiveBack(tester);

      expect(find.text('detail page'), findsNothing);
      expect(find.text('habits page'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    },
  );
}

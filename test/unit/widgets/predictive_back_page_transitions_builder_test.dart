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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/widgets/widgets.dart';

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
}

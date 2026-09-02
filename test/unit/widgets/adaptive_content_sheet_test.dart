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

final class _RouteCountingObserver extends NavigatorObserver {
  int popupPushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PopupRoute<dynamic>) popupPushes += 1;
  }
}

Widget _buildNestedNavigatorApp({
  required NavigatorObserver rootObserver,
  required NavigatorObserver branchObserver,
  required bool forceDialog,
  bool? useRootNavigator,
}) {
  return MaterialApp(
    navigatorObservers: [rootObserver],
    home: Navigator(
      observers: [branchObserver],
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => useRootNavigator == null
                ? showAdaptiveContentSheet<void>(
                    context: context,
                    contentBuilder: (_) => const Text('Content'),
                    forceDialog: forceDialog,
                    forceSheet: !forceDialog,
                  )
                : showAdaptiveContentSheet<void>(
                    context: context,
                    contentBuilder: (_) => const Text('Content'),
                    forceDialog: forceDialog,
                    forceSheet: !forceDialog,
                    useRootNavigator: useRootNavigator,
                  ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  for (final forceDialog in [false, true]) {
    final mode = forceDialog ? 'dialog' : 'sheet';

    testWidgets('$mode uses the root navigator by default', (tester) async {
      final rootObserver = _RouteCountingObserver();
      final branchObserver = _RouteCountingObserver();

      await tester.pumpWidget(
        _buildNestedNavigatorApp(
          rootObserver: rootObserver,
          branchObserver: branchObserver,
          forceDialog: forceDialog,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(rootObserver.popupPushes, 1);
      expect(branchObserver.popupPushes, 0);
    });

    testWidgets('$mode can use the nearest navigator explicitly', (
      tester,
    ) async {
      final rootObserver = _RouteCountingObserver();
      final branchObserver = _RouteCountingObserver();

      await tester.pumpWidget(
        _buildNestedNavigatorApp(
          rootObserver: rootObserver,
          branchObserver: branchObserver,
          forceDialog: forceDialog,
          useRootNavigator: false,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(rootObserver.popupPushes, 0);
      expect(branchObserver.popupPushes, 1);
    });
  }
}

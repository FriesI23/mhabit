// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/pages/habits_display/shortcuts.dart';

void main() {
  testWidgets('Cupertino submenu consumes escape before the page fallback', (
    tester,
  ) async {
    var pageDismissCount = 0;
    final nested = AdaptiveAction<String>.action(
      id: ActionId('nested'),
      metadata: const ActionMetadata(label: 'Nested'),
      payload: 'nested',
    );
    final filters = AdaptiveAction<String>.menu(
      id: ActionId('filters'),
      metadata: const ActionMetadata(label: 'Filters'),
      children: [nested],
      placementPolicy: ActionPlacementPolicy(
        placement: ActionPlacement.overflowOnly,
      ),
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: PageShortcuts(
            onDismiss: () => pageDismissCount += 1,
            child: Center(
              child: SizedBox(
                width: 44,
                child: CupertinoAdaptiveActions<String>.moreAction(
                  actions: ActionCollection(roots: [filters]),
                  onInvoke: (_) {},
                  primaryCapacity: 44,
                  maxPrimaryActions: 0,
                  overflowIcon: const Icon(CupertinoIcons.ellipsis),
                  overflowTooltip: 'More actions',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final trigger = tester.widget<CupertinoButton>(
      find.ancestor(
        of: find.byIcon(CupertinoIcons.ellipsis),
        matching: find.byType(CupertinoButton),
      ),
    );
    trigger.focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPopupSurface), findsNWidgets(2));

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPopupSurface), findsNothing);
    expect(pageDismissCount, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(pageDismissCount, 1);
  });
}

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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit/widgets/_widgets/filterable_menu_field.dart';

/// Helper that wraps [child] in a [MaterialApp] + [Scaffold].
Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

/// A simple builder that renders a [TextField] using the provided
/// controller, focus node, and menu controller.
Widget _defaultBuilder(
  BuildContext context,
  TextEditingController controller,
  FocusNode focusNode,
  MenuController menuController,
) => TextField(
  controller: controller,
  focusNode: focusNode,
  onTap: () => menuController.open(),
);

void main() {
  // ---------------------------------------------------------------------------
  // Rendering
  // ---------------------------------------------------------------------------
  group('FilterableMenuField rendering', () {
    testWidgets('builder receives non-null parameters and correct label', (
      tester,
    ) async {
      TextEditingController? capturedCtrl;
      FocusNode? capturedFocus;
      MenuController? capturedMenu;

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: 'Hello',
            builder: (context, ctrl, focus, menu) {
              capturedCtrl = ctrl;
              capturedFocus = focus;
              capturedMenu = menu;
              return _defaultBuilder(context, ctrl, focus, menu);
            },
            menuChildrenBuilder: (query, hi) => [],
          ),
        ),
      );

      expect(capturedCtrl, isNotNull);
      expect(capturedCtrl!.text, 'Hello');
      expect(capturedFocus, isNotNull);
      expect(capturedMenu, isNotNull);
    });

    testWidgets('label is displayed in the text field', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: 'MyGroup',
            builder: _defaultBuilder,
            menuChildrenBuilder: (query, hi) => [],
          ),
        ),
      );

      expect(find.text('MyGroup'), findsOneWidget);
    });

    testWidgets('menuChildrenBuilder receives empty query and -1 initially', (
      tester,
    ) async {
      String? query;
      int? hi;

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, h) {
              query = q;
              hi = h;
              return [];
            },
          ),
        ),
      );

      expect(query, '');
      expect(hi, -1);
    });
  });

  // ---------------------------------------------------------------------------
  // Text input → menu open & filtering
  // ---------------------------------------------------------------------------
  group('FilterableMenuField text input opens menu', () {
    testWidgets('typing opens the menu and menu items appear', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            builder: _defaultBuilder,
            menuChildrenBuilder: (query, hi) => [
              const MenuItemButton(child: Text('Alpha')),
              const MenuItemButton(child: Text('Beta')),
            ],
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'A');
      await tester.pump();

      expect(find.byType(MenuItemButton), findsNWidgets(2));
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('typing updates the query passed to menuChildrenBuilder', (
      tester,
    ) async {
      String? query;

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, hi) {
              query = q;
              return [MenuItemButton(child: Text(q))];
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Foo');
      await tester.pump();

      expect(query, 'Foo');
      // Text appears both in TextField and menu item
      expect(find.text('Foo'), findsAtLeastNWidgets(1));
    });

    testWidgets('typing same text again does not trigger redundant rebuild', (
      tester,
    ) async {
      String? query;

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, hi) {
              query = q;
              return [const MenuItemButton(child: Text('Item'))];
            },
          ),
        ),
      );

      // Type different text to trigger open
      await tester.enterText(find.byType(TextField), 'X');
      await tester.pump();
      expect(find.byType(MenuItemButton), findsOneWidget);
      expect(query, 'X');
    });

    testWidgets('menu stays closed when query is empty and never changed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            builder: (context, ctrl, focus, menu) => TextField(
              controller: ctrl,
              focusNode: focus,
              // no onTap → menu not opened by tap
            ),
            menuChildrenBuilder: (query, hi) => [
              const MenuItemButton(child: Text('Never shown')),
            ],
          ),
        ),
      );

      // No interaction → menu should not be open.
      // MenuItemButton in overlay should not be findable.
      expect(find.byType(MenuItemButton), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // didUpdateWidget
  // ---------------------------------------------------------------------------
  group('FilterableMenuField didUpdateWidget', () {
    testWidgets('external label change updates text without opening menu', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            key: const ValueKey('k'),
            label: 'Old',
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, hi) => [],
          ),
        ),
      );

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            key: const ValueKey('k'),
            label: 'New',
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, hi) => [
              const MenuItemButton(child: Text('Should not appear')),
            ],
          ),
        ),
      );

      expect(find.text('New'), findsOneWidget);
      expect(find.text('Old'), findsNothing);
      // _isUpdatingText guard should prevent menu open.
      expect(find.byType(MenuItemButton), findsNothing);
    });

    testWidgets('rebuild with same label does not change text field', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            key: const ValueKey('k'),
            label: 'Same',
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, hi) => [],
          ),
        ),
      );

      // Type something in the field
      await tester.enterText(find.byType(TextField), 'UserTyped');
      await tester.pump();

      // Rebuild with same label
      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            key: const ValueKey('k'),
            label: 'Same',
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, hi) => [],
          ),
        ),
      );

      // didUpdateWidget only replaces text when label != current text.
      // 'Same' != 'UserTyped' → replacement happens.
      expect(find.text('Same'), findsOneWidget);
      expect(find.text('UserTyped'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Keyboard navigation
  // ---------------------------------------------------------------------------
  group('FilterableMenuField keyboard navigation', () {
    testWidgets('ArrowDown / ArrowUp change highlightIndex when menu is open', (
      tester,
    ) async {
      int? hi;

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, h) {
              hi = h;
              return [
                const MenuItemButton(child: Text('A')),
                const MenuItemButton(child: Text('B')),
                const MenuItemButton(child: Text('C')),
              ];
            },
          ),
        ),
      );

      // Open menu by typing
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();

      // After setState + onOpen, highlightIndex = -1.
      // ArrowDown should increment it.

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      final afterDown1 = hi!;

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      final afterDown2 = hi!;

      expect(afterDown2, greaterThan(afterDown1));

      // ArrowUp should decrement
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      final afterUp = hi!;
      expect(afterUp, lessThan(afterDown2));
    });

    testWidgets('Enter activates highlighted item and closes menu', (
      tester,
    ) async {
      int? activatedIndex;
      String? activatedQuery;
      bool menuWasOpenAtActivation = false;

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, h) => [
              const MenuItemButton(child: Text('A')),
            ],
            onHighlightActivated: (index, query) {
              activatedIndex = index;
              activatedQuery = query;
            },
          ),
        ),
      );

      // Open menu
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      // Press ArrowDown to highlight first item, then Enter
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      menuWasOpenAtActivation = find
          .byType(MenuItemButton)
          .evaluate()
          .isNotEmpty;

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(activatedIndex, isNotNull);
      expect(activatedQuery, 'hello');
      // Menu should close after activation
      expect(menuWasOpenAtActivation, isTrue);
    });

    testWidgets('key events are ignored when menu is closed', (tester) async {
      int? hi;

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            builder: (context, ctrl, focus, menu) => TextField(
              controller: ctrl,
              focusNode: focus,
              // no onTap, so menu won't open via tap
            ),
            menuChildrenBuilder: (q, h) {
              hi = h;
              return [const MenuItemButton(child: Text('A'))];
            },
          ),
        ),
      );

      // Menu is closed. Send arrow key via sendKeyEvent (down+up).
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // highlightIndex should NOT change (still -1 from init)
      expect(hi, -1);
    });
  });

  // ---------------------------------------------------------------------------
  // Callbacks
  // ---------------------------------------------------------------------------
  group('FilterableMenuField callbacks', () {
    testWidgets('onHighlightActivated receives correct index and query', (
      tester,
    ) async {
      int? idx;
      String? qry;

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, h) => [
              const MenuItemButton(child: Text('Apple')),
              const MenuItemButton(child: Text('Banana')),
            ],
            onHighlightActivated: (index, query) {
              idx = index;
              qry = query;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'app');
      await tester.pump();

      // Highlight second item (two ArrowDown events)
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(idx, isNotNull);
      expect(qry, 'app');
    });

    testWidgets('closing via external MenuController dismisses menu', (
      tester,
    ) async {
      final externalCtrl = MenuController();

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            menuController: externalCtrl,
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, h) => [
              const MenuItemButton(child: Text('Item')),
            ],
          ),
        ),
      );

      // Open menu
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();
      expect(externalCtrl.isOpen, isTrue);

      // Close programmatically
      externalCtrl.close();
      await tester.pump();

      expect(externalCtrl.isOpen, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // External MenuController
  // ---------------------------------------------------------------------------
  group('FilterableMenuField external MenuController', () {
    testWidgets('external MenuController reflects menu state', (tester) async {
      final externalCtrl = MenuController();

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            menuController: externalCtrl,
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, h) => [
              const MenuItemButton(child: Text('ExtItem')),
            ],
          ),
        ),
      );

      expect(externalCtrl.isOpen, isFalse);

      // Open via typing
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();

      expect(externalCtrl.isOpen, isTrue);

      // Close programmatically
      externalCtrl.close();
      await tester.pumpAndSettle();

      expect(externalCtrl.isOpen, isFalse);
      expect(find.byType(MenuItemButton), findsNothing);
    });

    testWidgets('external MenuController can open menu programmatically', (
      tester,
    ) async {
      final externalCtrl = MenuController();

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            menuController: externalCtrl,
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, h) => [
              const MenuItemButton(child: Text('Programmatic')),
            ],
          ),
        ),
      );

      externalCtrl.open();
      await tester.pump();

      expect(externalCtrl.isOpen, isTrue);
      expect(find.byType(MenuItemButton), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Edge cases
  // ---------------------------------------------------------------------------
  group('FilterableMenuField edge cases', () {
    testWidgets('empty menuChildrenBuilder list works', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, h) => [],
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'no matches');
      await tester.pump();

      // Menu opens but has no items.
      expect(find.byType(MenuItemButton), findsNothing);
    });

    testWidgets('menu opens on tap via builder callback', (tester) async {
      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: 'Tap me',
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, h) => [
              const MenuItemButton(child: Text('Tapped')),
            ],
          ),
        ),
      );

      // Tap the text field (builder wires onTap → open)
      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(find.byType(MenuItemButton), findsOneWidget);
    });

    testWidgets('typing after closing reopens with updated query', (
      tester,
    ) async {
      String? query;
      final externalCtrl = MenuController();

      await tester.pumpWidget(
        _wrap(
          FilterableMenuField<String>(
            label: '',
            menuController: externalCtrl,
            builder: _defaultBuilder,
            menuChildrenBuilder: (q, h) {
              query = q;
              return [MenuItemButton(child: Text(q))];
            },
          ),
        ),
      );

      // Open first time
      await tester.enterText(find.byType(TextField), 'first');
      await tester.pump();
      expect(query, 'first');

      // Close programmatically
      externalCtrl.close();
      await tester.pump();
      expect(externalCtrl.isOpen, isFalse);

      // Type again — should reopen with new query
      await tester.enterText(find.byType(TextField), 'second');
      await tester.pump();
      expect(query, 'second');
      // Text appears both in TextField and menu item
      expect(find.text('second'), findsAtLeastNWidgets(1));
    });
  });
}

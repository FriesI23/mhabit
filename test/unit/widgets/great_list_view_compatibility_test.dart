// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter_test/flutter_test.dart';
import 'package:great_list_view_plus/great_list_view_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mhabit/pages/habits_display/styles.dart';
import 'package:worker_manager/worker_manager.dart';

bool _sameItem(int a, int b) => a == b;

const _comparator = AnimatedListDiffListComparator<int>(
  sameItem: _sameItem,
  sameContent: _sameItem,
);

void main() {
  for (final fixedExtent in [false, true]) {
    final layout = fixedExtent ? 'fixed' : 'variable';
    testWidgets('$layout list splits and deletes an active moving range', (
      tester,
    ) async {
      final key = GlobalKey<_ListHarnessState>();
      await tester.pumpWidget(_ListHarness(key: key, fixedExtent: fixedExtent));
      final state = key.currentState!;

      state.move(1, 5, 4);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(state.movingItems, isNotEmpty);

      // Move the middle of the active range, retaining both side intervals.
      state.move(5, 2, 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      state.remove(1, 2);
      await _settleList(tester);

      _expectOrder(tester, [0, 6, 7, 8, 1, 4, 5, 9]);
      expect(find.text('Habit 2'), findsNothing);
      expect(find.text('Habit 3'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$layout list cancels a drag without changing its order', (
      tester,
    ) async {
      final key = GlobalKey<_ListHarnessState>();
      await tester.pumpWidget(_ListHarness(key: key, fixedExtent: fixedExtent));
      final state = key.currentState!;
      final row = tester.element(find.byKey(const ValueKey('habit-1')));
      expect(state.controller.notifyStartReorder(row, 10, 10), isTrue);
      await tester.pump();
      state.controller.notifyUpdateReorder(10, 150);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(state.draggingItems, contains(1));

      state.controller.notifyStopReorder(true);
      await _settleList(tester);

      expect(state.items, orderedEquals(List.generate(10, (index) => index)));
      _expectOrder(tester, state.items);
      expect(tester.takeException(), isNull);
    });
  }

  test('large list diffs start on demand and discard stale updates', () async {
    addTearDown(workerManager.dispose);
    final controller = _DiffNotifications();
    final initial = List.generate(250, (index) => index);
    final dispatcher = AnimatedListDiffListDispatcher<int>(
      controller: controller,
      currentList: initial,
      comparator: _comparator,
      itemBuilder: (context, value, data) => Text('Habit $value'),
    );
    // The default 500-item total starts background work without app startup
    // initialization; only the newest result may notify the mounted consumer.
    final superseded = dispatcher.dispatchNewList([...initial, 998]);
    expect(dispatcher.hasPendingTask, isTrue);
    final latest = [...initial, 999];
    await Future.wait([superseded, dispatcher.dispatchNewList(latest)])
        .timeout(const Duration(seconds: 15));
    expect(dispatcher.currentList, orderedEquals(latest));
    expect(dispatcher.hasPendingTask, isFalse);
    expect(controller.notifications, ['insert:250:1']);

    controller.notifications.clear();
    final discarded = [...latest, 1000];
    final pending = dispatcher.dispatchNewList(discarded);
    expect(dispatcher.discard(), same(discarded));
    await pending.timeout(const Duration(seconds: 15));
    expect(dispatcher.currentList, orderedEquals(latest));
    expect(dispatcher.hasPendingTask, isFalse);
    expect(controller.notifications, isEmpty);

    final resumed = [...latest, 1001];
    await dispatcher
        .dispatchNewList(resumed)
        .timeout(const Duration(seconds: 15));
    expect(dispatcher.currentList, orderedEquals(resumed));
    expect(controller.notifications, ['insert:251:1']);
  });
}

Future<void> _settleList(WidgetTester tester) async {
  // Variable extents have measurement frames without a ticker between the
  // dismissal, resize and incoming phases; pump through the complete sequence.
  for (var frame = 0; frame < 25; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

void _expectOrder(WidgetTester tester, List<int> expected) {
  var previousBottom = double.negativeInfinity;
  for (final id in expected) {
    final finder = find.byKey(ValueKey('habit-$id'));
    expect(finder, findsOneWidget);
    final rect = tester.getRect(finder);
    expect(rect.top, greaterThanOrEqualTo(previousBottom - 0.01));
    expect(rect.height, 40);
    previousBottom = rect.bottom;
  }
}

class _ListHarness extends StatefulWidget {
  const _ListHarness({super.key, required this.fixedExtent});

  final bool fixedExtent;

  @override
  State<_ListHarness> createState() => _ListHarnessState();
}

class _ListHarnessState extends State<_ListHarness> {
  final controller = AnimatedListController();
  final items = List.generate(10, (index) => index);
  final movingItems = <int>{};
  final draggingItems = <int>{};

  Widget _row(int id, AnimatedWidgetBuilderData data) {
    if (data.moving) movingItems.add(id);
    if (data.dragging) draggingItems.add(id);
    return SizedBox(
      key: data.measuring ? null : ValueKey('habit-$id'),
      height: 40,
      child: Text('Habit $id'),
    );
  }

  void move(int from, int count, int to) {
    setState(() {
      final moved = items.sublist(from, from + count);
      items.removeRange(from, from + count);
      items.insertAll(to, moved);
    });
    controller.notifyMovedRange(from, count, to);
  }

  void remove(int from, int count) {
    final removed = items.sublist(from, from + count);
    setState(() => items.removeRange(from, from + count));
    controller.notifyRemovedRange(
      from,
      count,
      (context, index, data) => _row(removed[index], data),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: AnimatedListView(
        listController: controller,
        initialItemCount: items.length,
        itemExtent: widget.fixedExtent ? 40 : null,
        itemBuilder: (context, index, data) => _row(items[index], data),
        animator: kHabitContentListAnimator,
        reorderModel: AutomaticAnimatedListReorderModel(items),
        padding: EdgeInsets.zero,
      ),
    ),
  );
}

class _DiffNotifications extends AnimatedListController {
  final notifications = <String>[];

  @override
  void batch(VoidCallback callback) => callback();

  @override
  void notifyInsertedRange(int from, int count) =>
      notifications.add('insert:$from:$count');

  @override
  void notifyRemovedRange(
    int from,
    int count,
    AnimatedWidgetBuilder removeItemBuilder,
  ) => notifications.add('remove:$from:$count');
}

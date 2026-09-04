import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

ActionCollection<String> _collection() => ActionCollection<String>(
  roots: [
    AdaptiveAction<String>.action(
      id: ActionId('edit'),
      metadata: const ActionMetadata(label: 'Edit', iconKey: 'edit'),
      payload: 'edit',
    ),
    AdaptiveAction<String>.action(
      id: ActionId('delete'),
      metadata: const ActionMetadata(
        label: 'Delete',
        iconKey: 'delete',
        isDestructive: true,
      ),
      payload: 'delete',
      placementPolicy: ActionPlacementPolicy(
        placement: ActionPlacement.overflowOnly,
      ),
    ),
  ],
);

Widget _app(Widget child) => MaterialApp(
  theme: ThemeData(platform: TargetPlatform.iOS),
  home: Scaffold(body: CustomScrollView(slivers: [child])),
);

void main() {
  testWidgets('keeps Select All and Done fixed around typed actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? invoked;

    await tester.pumpWidget(
      _app(
        CupertinoSliverSelectAppBar<String>(
          title: const Text('Selected 2'),
          selectAllLabel: 'Select All',
          doneLabel: 'Done',
          onSelectAll: () {},
          onDone: () {},
          collection: _collection(),
          onInvoke: (_, value) => invoked = value,
          actions: CupertinoAppBarActionsConfig(
            iconBuilder: (_, action) => Icon(
              action.id.value == 'edit'
                  ? CupertinoIcons.pencil
                  : CupertinoIcons.delete,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Select All'), findsOneWidget);
    expect(find.byKey(const ValueKey('cupertino-select-done')), findsOneWidget);
    expect(find.byType(AdaptiveAppBarActions<String>), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.pencil));
    await tester.pump();
    expect(invoked, 'edit');
  });

  testWidgets('compact bottom toolbar uses the same collection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: Scaffold(
          bottomNavigationBar: CupertinoSelectBottomToolbar<String>(
            collection: _collection(),
            onInvoke: (_, _) {},
            actions: CupertinoAppBarActionsConfig(
              iconBuilder: (_, action) => Icon(
                action.id.value == 'edit'
                    ? CupertinoIcons.pencil
                    : CupertinoIcons.delete,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('cupertino-select-bottom-toolbar')),
      findsOneWidget,
    );
    expect(find.byType(AdaptiveAppBarActions<String>), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long fixed labels retain 44pt reachable edge targets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        CupertinoSliverSelectAppBar<String>(
          title: const Text('123456789 habits selected'),
          selectAllLabel: 'Select every habit in this translation',
          doneLabel: 'Finish this selection operation',
          onSelectAll: () {},
          onDone: () {},
          collection: _collection(),
          onInvoke: (_, _) {},
        ),
      ),
    );

    final selectAll = find.byKey(const ValueKey('cupertino-select-all-top'));
    final done = find.byKey(const ValueKey('cupertino-select-done'));
    expect(tester.getSize(selectAll).height, greaterThanOrEqualTo(44));
    expect(tester.getSize(done).height, greaterThanOrEqualTo(44));
    expect(tester.getRect(selectAll).left, greaterThanOrEqualTo(0));
    expect(tester.getRect(done).right, lessThanOrEqualTo(320));
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom toolbar adds the safe area and retains overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: Scaffold(
          bottomNavigationBar: CupertinoSelectBottomToolbar<String>(
            collection: _collection(),
            onInvoke: (_, _) {},
            actions: CupertinoAppBarActionsConfig(
              iconBuilder: (_, action) => Icon(
                action.id.value == 'edit'
                    ? CupertinoIcons.pencil
                    : CupertinoIcons.delete,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('cupertino-select-bottom-toolbar')),
          )
          .height,
      68,
    );
    expect(find.byIcon(CupertinoIcons.ellipsis), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

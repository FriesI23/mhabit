import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void _setSurfaceSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

Widget _sliverHost(
  Widget sliver, {
  TextDirection direction = TextDirection.ltr,
}) => CupertinoApp(
  home: Directionality(
    textDirection: direction,
    child: CustomScrollView(slivers: [sliver]),
  ),
);

void main() {
  testWidgets('compact top fixes Select All and Done around the title', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(390, 800));
    await tester.pumpWidget(
      _sliverHost(
        CupertinoSliverSelectAppBar(
          title: const Text('3'),
          selectAllLabel: 'Select All',
          doneLabel: 'Done',
          onSelectAll: () {},
          onDone: () {},
          actions: [
            CupertinoSelectAction(
              id: 'delete',
              label: 'Delete',
              icon: const Icon(CupertinoIcons.delete),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.byKey(const ValueKey('cupertino-select-done')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('cupertino-select-all-top')),
      findsOneWidget,
    );
    expect(
      tester
          .getCenter(find.byKey(const ValueKey('cupertino-select-all-top')))
          .dx,
      lessThan(tester.getCenter(find.text('3')).dx),
    );
    expect(find.byIcon(CupertinoIcons.delete), findsNothing);
    expect(
      tester.getSize(find.byType(CupertinoNavigationBar)).height,
      CupertinoSliverSelectAppBar.toolbarHeight,
    );
  });

  testWidgets(
    'medium overflows uncommon commands and large expands labels when space allows',
    (tester) async {
      Widget build() => _sliverHost(
        CupertinoSliverSelectAppBar(
          title: const Text('Selected 3'),
          selectAllLabel: 'Select All',
          doneLabel: 'Done',
          onSelectAll: () {},
          onDone: () {},
          actions: [
            CupertinoSelectAction(
              id: 'export',
              label: 'Export',
              icon: const Icon(CupertinoIcons.share),
              onPressed: () {},
            ),
            CupertinoSelectAction(
              id: 'group',
              label: 'Modify Group',
              icon: const Icon(CupertinoIcons.folder),
              onPressed: () {},
              overflowBelowLarge: true,
              presentation: CupertinoSelectActionPresentation.iconAndLabel,
            ),
            CupertinoSelectAction(
              id: 'status',
              label: 'Check In',
              icon: const Icon(CupertinoIcons.square_list),
              onPressed: () {},
              retentionPriority: 1000,
              presentation: CupertinoSelectActionPresentation.iconAndLabel,
            ),
          ],
        ),
      );

      _setSurfaceSize(tester, const Size(800, 800));
      await tester.pumpWidget(build());
      expect(find.byIcon(CupertinoIcons.share), findsNothing);
      expect(find.byIcon(CupertinoIcons.folder), findsNothing);
      expect(find.text('Modify Group'), findsNothing);
      expect(find.text('Check In'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.square_list), findsOneWidget);

      tester.view.physicalSize = const Size(2000, 800);
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();
      expect(find.text('Export'), findsNothing);
      expect(find.byIcon(CupertinoIcons.folder), findsOneWidget);
      expect(find.text('Modify Group'), findsOneWidget);
      expect(find.text('Check In'), findsOneWidget);
    },
  );

  testWidgets('selection title keeps its region before actions', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(600, 800));
    await tester.pumpWidget(
      _sliverHost(
        CupertinoSliverSelectAppBar(
          title: const Text(
            '123456789 Habits Selected With A Very Long Localized Title',
          ),
          selectAllLabel: 'Select All',
          doneLabel: 'Done',
          onSelectAll: () {},
          onDone: () {},
          actions: [
            CupertinoSelectAction(
              id: 'export',
              label: 'Export',
              icon: const Icon(CupertinoIcons.share),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    final title = find.text(
      '123456789 Habits Selected With A Very Long Localized Title',
    );
    expect(
      tester.getRect(title).right,
      lessThanOrEqualTo(tester.getRect(find.byIcon(CupertinoIcons.share)).left),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('selection toolbar mirrors fixed edges in RTL', (tester) async {
    _setSurfaceSize(tester, const Size(800, 800));
    await tester.pumpWidget(
      _sliverHost(
        CupertinoSliverSelectAppBar(
          title: const Text('Selected 3'),
          selectAllLabel: 'Select All',
          doneLabel: 'Done',
          onSelectAll: () {},
          onDone: () {},
        ),
        direction: TextDirection.rtl,
      ),
    );

    final titleCenter = tester.getCenter(find.text('Selected 3')).dx;
    expect(
      tester
          .getCenter(find.byKey(const ValueKey('cupertino-select-all-top')))
          .dx,
      greaterThan(titleCenter),
    );
    expect(
      tester.getCenter(find.byKey(const ValueKey('cupertino-select-done'))).dx,
      lessThan(titleCenter),
    );
  });

  testWidgets('medium top fixes Select All and Done around adaptive actions', (
    tester,
  ) async {
    _setSurfaceSize(tester, const Size(800, 800));
    await tester.pumpWidget(
      _sliverHost(
        CupertinoSliverSelectAppBar(
          title: const Text('2'),
          selectAllLabel: 'Select All',
          doneLabel: 'Done',
          onSelectAll: () {},
          onDone: () {},
          actions: [
            CupertinoSelectAction(
              id: 'export',
              label: 'Export',
              icon: const Icon(CupertinoIcons.share),
              onPressed: () {},
            ),
            CupertinoSelectAction(
              id: 'delete',
              label: 'Delete',
              icon: const Icon(CupertinoIcons.delete),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('cupertino-select-all-top')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('cupertino-select-done')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('cupertino-select-adaptive-actions')),
      findsOneWidget,
    );
    expect(find.byIcon(CupertinoIcons.share), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.delete), findsOneWidget);
    expect(
      tester.getRect(find.byKey(const ValueKey('cupertino-select-done'))).left -
          tester.getRect(find.byIcon(CupertinoIcons.delete)).right,
      lessThan(20),
    );
  });

  testWidgets(
    'view entry forces Select into compact More and promotes it later',
    (tester) async {
      Widget build() => _sliverHost(
        CupertinoSliverSelectAppBar.view(
          title: const Text('Habits'),
          actions: [
            CupertinoSelectAction(
              id: 'select',
              label: 'Select',
              icon: const Icon(CupertinoIcons.check_mark_circled),
              onPressed: () {},
              overflowOnly: true,
              primaryBuilder: (context, onPressed) => CupertinoButton(
                onPressed: onPressed,
                child: const Text('Select'),
              ),
            ),
            CupertinoSelectAction(
              id: 'settings',
              label: 'Settings',
              icon: const Icon(CupertinoIcons.settings),
              onPressed: () {},
            ),
          ],
        ),
      );

      _setSurfaceSize(tester, const Size(390, 800));
      await tester.pumpWidget(build());
      expect(find.text('Select'), findsNothing);

      tester.view.physicalSize = const Size(800, 800);
      await tester.pumpWidget(
        _sliverHost(
          CupertinoSliverSelectAppBar.view(
            title: const Text('Habits'),
            actions: [
              CupertinoSelectAction(
                id: 'select',
                label: 'Select',
                icon: const Icon(CupertinoIcons.check_mark_circled),
                onPressed: () {},
                primaryBuilder: (context, onPressed) => CupertinoButton(
                  onPressed: onPressed,
                  child: const Text('Select'),
                ),
              ),
            ],
          ),
        ),
      );
      expect(find.text('Select'), findsOneWidget);
    },
  );

  testWidgets('bottom toolbar uses 44 content plus safe area', (tester) async {
    _setSurfaceSize(tester, const Size(390, 800));
    tester.view.padding = const FakeViewPadding(bottom: 24);
    addTearDown(() => tester.view.resetPadding());

    await tester.pumpWidget(
      CupertinoApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: CupertinoSelectBottomToolbar(
              actions: [
                CupertinoSelectAction(
                  id: 'delete',
                  label: 'Delete',
                  icon: const Icon(CupertinoIcons.delete),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final toolbar = find.byKey(
      const ValueKey('cupertino-select-bottom-toolbar'),
    );
    expect(tester.getSize(toolbar).height, 68);
    expect(find.byType(BackdropFilter), findsOneWidget);
    final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
    expect(filter.filter, isA<ImageFilter>());
    expect(
      find.byKey(const ValueKey('cupertino-select-all-bottom')),
      findsNothing,
    );
  });
}

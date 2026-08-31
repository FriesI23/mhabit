import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show MaterialApp, Scaffold, TargetPlatform, ThemeData;
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host(
  CupertinoSliverSearchBar searchBar, {
  TextDirection textDirection = TextDirection.ltr,
  double? contentWidth,
  EdgeInsetsDirectional appBarAvoidance = EdgeInsetsDirectional.zero,
  Color? pageBackground,
  Brightness brightness = Brightness.light,
}) {
  final content = Directionality(
    textDirection: textDirection,
    child: AdaptiveWindowControlLayoutScope(
      horizontalAvoidance: appBarAvoidance,
      verticalAvoidance: EdgeInsetsDirectional.zero,
      owner: WindowControlLayoutOwner.appBar,
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: contentWidth,
            child: CustomScrollView(slivers: [searchBar]),
          ),
        ),
      ),
    ),
  );
  return MaterialApp(
    theme: ThemeData(platform: TargetPlatform.iOS, brightness: brightness),
    home: pageBackground == null
        ? content
        : CupertinoPageScaffoldBackgroundColor(
            color: pageBackground,
            child: content,
          ),
  );
}

void main() {
  late TextEditingController controller;
  late FocusNode focusNode;
  late List<String> changes;
  late List<String> submissions;
  late int activations;
  late int dismissals;
  late int outsideTaps;
  late int filterInvocations;
  late int settingsInvocations;
  late int statisticsInvocations;

  setUp(() {
    controller = TextEditingController();
    focusNode = FocusNode();
    changes = [];
    submissions = [];
    activations = 0;
    dismissals = 0;
    outsideTaps = 0;
    filterInvocations = 0;
    settingsInvocations = 0;
    statisticsInvocations = 0;
  });

  tearDown(() {
    controller.dispose();
    focusNode.dispose();
  });

  CupertinoSliverSearchBar buildBar({
    bool isSearchActive = false,
    String? keyword,
    double maxSearchWidth = 240,
    String title = 'Habits',
    List<CupertinoSliverSearchBarAction>? actions,
    Widget? bottom,
    double bottomExtent = 0,
    bool pinned = true,
    AppBarAppleStyle? style,
  }) => CupertinoSliverSearchBar(
    title: Text(title),
    leading: const Icon(CupertinoIcons.info, key: ValueKey('info')),
    actions:
        actions ??
        [
          CupertinoSliverSearchBarAction(
            id: 'statistics',
            label: 'Statistics',
            icon: const Icon(
              CupertinoIcons.chart_bar,
              key: ValueKey('statistics'),
            ),
            onPressed: () => statisticsInvocations++,
          ),
          CupertinoSliverSearchBarAction(
            id: 'filter',
            label: 'Filter',
            icon: const Icon(
              CupertinoIcons.slider_horizontal_3,
              key: ValueKey('filter'),
            ),
            onPressed: () => filterInvocations++,
            retentionPriority: 100,
          ),
          CupertinoSliverSearchBarAction(
            id: 'settings',
            label: 'Settings',
            icon: const Icon(
              CupertinoIcons.settings,
              key: ValueKey('settings'),
            ),
            onPressed: () => settingsInvocations++,
            retentionPriority: 50,
          ),
        ],
    controller: controller,
    focusNode: focusNode,
    isSearchActive: isSearchActive,
    keyword: keyword ?? controller.text,
    hintText: 'Search habits',
    maxSearchWidth: maxSearchWidth,
    bottom: bottom,
    bottomExtent: bottomExtent,
    pinned: pinned,
    style: style,
    onChanged: changes.add,
    onSubmitted: submissions.add,
    onSearchActivated: () {
      activations++;
    },
    onSearchDismissed: () {
      dismissals++;
      focusNode.unfocus();
    },
    onTapOutside: (_) {
      outsideTaps++;
      focusNode.unfocus();
    },
  );

  testWidgets(
    'compact keeps actions and expands from trailing toward leading',
    (tester) async {
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(buildBar()));

      expect(find.byKey(const ValueKey('activate-cupertino-search')), findsOne);
      expect(
        tester
            .widget<CupertinoButton>(
              find.byKey(const ValueKey('activate-cupertino-search')),
            )
            .color,
        isNull,
      );
      expect(find.byType(CupertinoSearchTextField), findsNothing);
      expect(find.byKey(const ValueKey('info')), findsOne);
      expect(find.byKey(const ValueKey('filter')), findsOne);
      expect(find.byKey(const ValueKey('settings')), findsOne);
      expect(find.byKey(const ValueKey('statistics')), findsOne);
      final idleSearchX = tester
          .getCenter(find.byKey(const ValueKey('activate-cupertino-search')))
          .dx;
      final idleTitleWidth = tester
          .getSize(find.byKey(const ValueKey('cupertino-search-title')))
          .width;
      expect(
        tester.getTopLeft(find.text('Habits')).dx -
            tester
                .getTopLeft(
                  find.byKey(const ValueKey('cupertino-search-title')),
                )
                .dx,
        greaterThanOrEqualTo(10),
      );
      expect(
        idleSearchX,
        greaterThan(tester.getCenter(find.byKey(const ValueKey('filter'))).dx),
      );

      await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
      await tester.pumpAndSettle();

      expect(activations, 1);
      expect(find.byType(CupertinoSearchTextField), findsOne);
      expect(focusNode.hasFocus, isTrue);
      expect(find.byKey(const ValueKey('info')), findsOne);
      expect(find.byKey(const ValueKey('filter')), findsOne);
      expect(find.byKey(const ValueKey('settings')), findsOne);
      expect(find.byKey(const ValueKey('statistics')), findsOne);
      expect(
        find.byKey(const ValueKey('cupertino-search-overflow-expanded')),
        findsNothing,
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('cupertino-search-title')))
            .width,
        lessThan(idleTitleWidth),
      );
    },
  );

  testWidgets('uses a fixed toolbar with no large title', (tester) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar()));

    expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(
      tester
          .widget<CupertinoNavigationBar>(find.byType(CupertinoNavigationBar))
          .border,
      isNull,
    );
    expect(tester.getSize(find.byType(CupertinoNavigationBar)).height, 44);
    final header = tester.widget<SliverPersistentHeader>(
      find.byType(SliverPersistentHeader),
    );
    expect(header.pinned, isTrue);
    expect(header.delegate.minExtent, 44);
    expect(header.delegate.maxExtent, 44);
    expect(
      tester
          .getCenter(find.byKey(const ValueKey('activate-cupertino-search')))
          .dy,
      22,
    );
  });

  testWidgets('resolves its nullable style at the public boundary', (
    tester,
  ) async {
    const color = Color(0xFF123456);
    await tester.pumpWidget(
      _host(
        buildBar(
          style: const AppBarAppleStyle(
            backgroundColor: color,
            automaticBackgroundVisibility: true,
          ),
        ),
      ),
    );

    final navigationBar = tester.widget<CupertinoNavigationBar>(
      find.byType(CupertinoNavigationBar),
    );
    expect(navigationBar.backgroundColor, color);
    expect(navigationBar.automaticBackgroundVisibility, isTrue);
  });

  testWidgets('caps phone safe padding at 32 and keeps wide layouts at 16', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(left: 24, right: 36);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar()));

    final searchRegion = find.byKey(
      const ValueKey('cupertino-expandable-search-region'),
    );
    expect(tester.getTopRight(searchRegion).dx, 500 - 32);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('info'))).dx,
      greaterThanOrEqualTo(32),
    );

    tester.view.physicalSize = const Size(1000, 800);
    await tester.pumpAndSettle();
    expect(tester.getTopRight(searchRegion).dx, 1000 - 16);
  });

  testWidgets('adds window-control avoidance to Cupertino toolbar padding', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(
        buildBar(),
        appBarAvoidance: const EdgeInsetsDirectional.only(start: 40, end: 12),
      ),
    );

    final searchRegion = find.byKey(
      const ValueKey('cupertino-expandable-search-region'),
    );
    expect(tester.getTopRight(searchRegion).dx, 800 - 16 - 12);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('info'))).dx,
      greaterThanOrEqualTo(16 + 40),
    );
    expect(
      tester.getCenter(find.byKey(const ValueKey('cupertino-search-title'))).dx,
      closeTo(400, 1),
    );
  });

  testWidgets('bottom shares the toolbar glass and extends its pinned extent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(
        buildBar(
          bottom: const ColoredBox(
            key: ValueKey('cupertino-search-bottom'),
            color: CupertinoColors.transparent,
          ),
          bottomExtent: 48,
        ),
      ),
    );

    final header = tester.widget<SliverPersistentHeader>(
      find.byType(SliverPersistentHeader),
    );
    expect(header.delegate.minExtent, 92);
    expect(header.delegate.maxExtent, 92);
    expect(tester.getSize(find.byType(CupertinoNavigationBar)).height, 92);
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey('cupertino-search-bottom')))
          .dy,
      44,
    );
    final navigationBar = tester.widget<CupertinoNavigationBar>(
      find.byType(CupertinoNavigationBar),
    );
    expect(navigationBar.enableBackgroundFilterBlur, isTrue);
    expect(navigationBar.automaticBackgroundVisibility, isTrue);
    expect(navigationBar.backgroundColor, CupertinoColors.transparent);
    expect(navigationBar.border, isNull);
    expect(
      tester
          .widgetList<BackdropFilter>(find.byType(BackdropFilter))
          .where((filter) => filter.enabled),
      hasLength(1),
    );
  });

  testWidgets('supports a primary cascading action menu', (tester) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var nestedInvocations = 0;
    await tester.pumpWidget(
      _host(
        buildBar(
          actions: [
            CupertinoSliverSearchBarAction(
              id: 'filter-menu',
              label: 'Filter',
              icon: const Icon(
                CupertinoIcons.slider_horizontal_3,
                key: ValueKey('filter-menu'),
              ),
              children: [
                const CupertinoSliverSearchBarMenuDivider(),
                CupertinoSliverSearchBarAction(
                  id: 'habit-type-menu',
                  label: 'Habit Type',
                  subtitle: 'Negative',
                  icon: const Icon(CupertinoIcons.square_grid_2x2),
                  children: [
                    CupertinoSliverSearchBarAction(
                      id: 'negative-filter',
                      label: 'Negative',
                      icon: const Icon(CupertinoIcons.check_mark),
                      onPressed: () => nestedInvocations++,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('filter-menu')));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoMenuDivider), findsOneWidget);
    expect(find.text('Habit Type'), findsOneWidget);
    final habitTypeItem = tester.widget<CupertinoMenuItem>(
      find.widgetWithText(CupertinoMenuItem, 'Habit Type'),
    );
    expect((habitTypeItem.subtitle! as Text).data, 'Negative');
    await tester.tap(find.text('Habit Type'));
    await tester.pumpAndSettle();
    final negativeItem = find.byWidgetPredicate(
      (widget) =>
          widget is CupertinoMenuItem &&
          widget.child is Text &&
          (widget.child as Text).data == 'Negative',
    );
    expect(negativeItem, findsOneWidget);
    await tester.tap(negativeItem);
    await tester.pumpAndSettle();
    expect(nestedInvocations, 1);
  });

  testWidgets('animates expansion and collapse over 300ms', (tester) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar()));
    final region = find.byKey(
      const ValueKey('cupertino-expandable-search-region'),
    );
    expect(tester.getSize(region).width, 44);
    final idleFilterX = tester
        .getCenter(find.byKey(const ValueKey('filter')))
        .dx;

    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.getSize(region).width, greaterThan(44));
    expect(tester.getSize(region).width, lessThan(240));
    final halfExpandedFilterX = tester
        .getCenter(find.byKey(const ValueKey('filter')))
        .dx;
    expect(halfExpandedFilterX, lessThan(idleFilterX));
    await tester.pumpAndSettle();
    expect(tester.getSize(region).width, 240);
    expect(
      tester.getCenter(find.byKey(const ValueKey('filter'))).dx,
      lessThan(halfExpandedFilterX),
    );

    focusNode.unfocus();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CupertinoSearchTextField), findsNothing);
    expect(find.byKey(const ValueKey('activate-cupertino-search')), findsOne);
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.getSize(region).width, greaterThan(44));
    expect(tester.getSize(region).width, lessThan(240));
    await tester.pumpAndSettle();
    expect(tester.getSize(region).width, 44);

    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('expanded More collapses empty Search before menu can open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(232, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar()));
    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();

    final expandedMore = find.byKey(
      const ValueKey('cupertino-search-overflow-expanded'),
    );
    expect(expandedMore, findsOne);
    expect(find.byIcon(CupertinoIcons.chevron_right_2), findsOne);
    await tester.tap(expandedMore);
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.byType(CupertinoPopupSurface), findsNothing);
    expect(find.byType(CupertinoSearchTextField), findsNothing);

    await tester.pumpAndSettle();

    expect(find.byType(CupertinoPopupSurface), findsNothing);
    expect(find.byType(CupertinoSearchTextField), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPopupSurface), findsOneWidget);
    await tester.tapAt(const Offset(10, 650));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('activate-cupertino-search')), findsOne);
  });

  testWidgets('menu to Search restores field focus and both More states work', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(232, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar()));
    final collapsedMore = find.byKey(
      const ValueKey('cupertino-search-overflow-collapsed'),
    );
    await tester.tap(collapsedMore);
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPopupSurface), findsOneWidget);
    expect(focusNode.hasFocus, isFalse);

    await tester.tap(
      find.byKey(const ValueKey('activate-cupertino-search')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPopupSurface), findsNothing);
    expect(find.byType(CupertinoSearchTextField), findsOneWidget);
    expect(focusNode.hasFocus, isTrue);

    final expandedMore = find.byKey(
      const ValueKey('cupertino-search-overflow-expanded'),
    );
    await tester.tap(expandedMore);
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPopupSurface), findsNothing);
    expect(find.byType(CupertinoSearchTextField), findsNothing);
    expect(focusNode.hasFocus, isFalse);

    await tester.tap(collapsedMore);
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPopupSurface), findsOneWidget);
    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets('filter leaves primary after Settings when width is exhausted', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(532, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar()));

    expect(find.byKey(const ValueKey('statistics')), findsOne);
    expect(find.byKey(const ValueKey('filter')), findsOne);
    expect(find.byKey(const ValueKey('settings')), findsOne);

    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('filter')), findsOne);
    expect(find.byKey(const ValueKey('settings')), findsOne);
    expect(find.byKey(const ValueKey('statistics')), findsOne);

    tester.view.physicalSize = const Size(432, 700);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('filter')), findsOne);
    expect(find.byKey(const ValueKey('settings')), findsNothing);
    expect(find.byKey(const ValueKey('statistics')), findsNothing);
    expect(
      find.byKey(const ValueKey('cupertino-search-overflow-expanded')),
      findsOne,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('cupertino-search-title')))
          .width,
      lessThanOrEqualTo(1),
    );

    tester.view.physicalSize = const Size(392, 700);
    controller.text = 'keeps-search-open';
    await tester.pumpWidget(_host(buildBar(isSearchActive: true)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('filter')), findsNothing);
    expect(find.byKey(const ValueKey('settings')), findsNothing);
    expect(
      find.byKey(const ValueKey('cupertino-search-overflow-expanded')),
      findsOne,
    );
    final moreButton = tester.widget<CupertinoButton>(
      find.ancestor(
        of: find.byKey(const ValueKey('cupertino-search-overflow-expanded')),
        matching: find.byType(CupertinoButton),
      ),
    );
    expect(focusNode.hasFocus, isTrue);
    moreButton.onPressed!();
    expect(focusNode.hasFocus, isTrue);
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPopupSurface), findsOne);
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    expect(filterInvocations, 1);
    expect(settingsInvocations, 0);
    expect(statisticsInvocations, 0);
  });

  testWidgets('forwards input submit clear and outside tap without Cancel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar()));
    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoSearchTextField), findsOne);
    expect(
      find.byKey(const ValueKey('dismiss-cupertino-search')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('clear-cupertino-search')).hitTestable(),
      findsNothing,
    );

    await tester.enterText(find.byType(CupertinoSearchTextField), 'alpha');
    await tester.pump();
    expect(
      find.byKey(const ValueKey('clear-cupertino-search')).hitTestable(),
      findsOne,
    );
    await tester.tap(
      find.byKey(const ValueKey('clear-cupertino-search')).hitTestable(),
    );
    await tester.pump();
    expect(changes, contains(''));

    await tester.enterText(find.byType(CupertinoSearchTextField), 'alpha');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    final tapRegion = tester.widget<TextFieldTapRegion>(
      find.ancestor(
        of: find.byType(CupertinoSearchTextField),
        matching: find.byType(TextFieldTapRegion),
      ),
    );
    tapRegion.onTapOutside!(const PointerDownEvent());

    expect(changes, contains('alpha'));
    expect(submissions, ['alpha']);
    expect(outsideTaps, 1);
    expect(dismissals, 0);
  });

  testWidgets('iOS touch outside the search field removes focus', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar()));

    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(100, 200));
    await tester.pumpAndSettle();

    expect(outsideTaps, 1);
    expect(focusNode.hasFocus, isFalse);
  });

  testWidgets('medium defaults to a button with a centered title', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar(isSearchActive: true)));

    expect(find.byKey(const ValueKey('activate-cupertino-search')), findsOne);
    expect(find.byType(CupertinoSearchTextField), findsNothing);
    expect(find.byKey(const ValueKey('filter')), findsOne);
    expect(
      tester.getCenter(find.byKey(const ValueKey('cupertino-search-title'))).dx,
      closeTo(400, 1),
    );
    expect(find.byKey(const ValueKey('statistics')), findsOne);
    expect(find.byKey(const ValueKey('settings')), findsOne);
    expect(
      find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
      findsNothing,
    );

    tester.view.physicalSize = const Size(600, 700);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('activate-cupertino-search')), findsOne);
    expect(find.byType(CupertinoSearchTextField), findsNothing);
    expect(
      tester.getCenter(find.byKey(const ValueKey('cupertino-search-title'))).dx,
      closeTo(300, 1),
    );
  });

  testWidgets('large field falls back when measured space is below 100', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar(), contentWidth: 250));

    expect(find.byKey(const ValueKey('activate-cupertino-search')), findsOne);
    expect(find.byType(CupertinoSearchTextField), findsNothing);
    expect(find.byKey(const ValueKey('cupertino-search-title')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoSearchTextField), findsOne);
    expect(
      find.byKey(const ValueKey('cupertino-search-overflow-expanded')),
      findsOne,
    );
  });

  testWidgets('compact title is single-line ellipsis then hides at threshold', (
    tester,
  ) async {
    const longTitle = 'A very long application title that must not wrap';
    tester.view.physicalSize = const Size(500, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar(title: longTitle)));

    final titleStyle = tester.widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text(longTitle),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    expect(titleStyle.maxLines, 1);
    expect(titleStyle.softWrap, isFalse);
    expect(titleStyle.overflow, TextOverflow.ellipsis);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('cupertino-search-title')))
          .width,
      greaterThan(250),
    );
    expect(find.byKey(const ValueKey('filter')), findsNothing);
    expect(
      find.byKey(const ValueKey('cupertino-search-overflow-collapsed')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(400, 700);
    await tester.pumpAndSettle();
    expect(
      tester
          .getSize(find.byKey(const ValueKey('cupertino-search-title')))
          .width,
      0,
    );
  });

  testWidgets('large layout uses the 240 default and configured maximum', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar()));

    expect(find.byType(CupertinoSearchTextField), findsOne);
    expect(
      find.byKey(const ValueKey('activate-cupertino-search')),
      findsNothing,
    );
    expect(
      tester.getSize(find.byType(CupertinoSearchTextField)),
      const Size(240, 40),
    );
    expect(find.byKey(const ValueKey('cupertino-search-title')), findsNothing);

    await tester.pumpWidget(_host(buildBar(maxSearchWidth: 180)));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(CupertinoSearchTextField)).width, 180);
  });

  testWidgets('breakpoint strictly uses screen width, not sliver width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar(), contentWidth: 700));

    expect(
      find.byKey(const ValueKey('activate-cupertino-search')),
      findsNothing,
    );
    expect(find.byType(CupertinoSearchTextField), findsOne);
    expect(find.byKey(const ValueKey('cupertino-search-title')), findsNothing);
  });

  testWidgets('breakpoint round trip keeps controller focus and query', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(buildBar()));
    await tester.tap(find.byKey(const ValueKey('activate-cupertino-search')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoSearchTextField), 'kept');

    for (final size in const [
      Size(800, 700),
      Size(1000, 700),
      Size(500, 800),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(_host(buildBar(isSearchActive: true)));
      final field = tester.widget<CupertinoSearchTextField>(
        find.byType(CupertinoSearchTextField),
      );
      expect(field.controller, same(controller));
      expect(field.focusNode, same(focusNode));
      expect(controller.text, 'kept');
      expect(focusNode.hasFocus, isTrue);
    }
  });

  testWidgets('RTL keeps search at trailing and expands without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(200, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(buildBar(), textDirection: TextDirection.rtl),
    );

    final search = find.byKey(const ValueKey('activate-cupertino-search'));
    final more = find.byKey(
      const ValueKey('cupertino-search-overflow-collapsed'),
    );
    expect(tester.getCenter(search).dx, lessThan(tester.getCenter(more).dx));
    expect(more, findsOne);
    expect(find.byIcon(CupertinoIcons.chevron_right_2), findsOne);
    await tester.tap(search);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(CupertinoSearchTextField), findsOne);
    expect(
      find.byKey(const ValueKey('cupertino-search-overflow-expanded')),
      findsOne,
    );
    expect(find.byIcon(CupertinoIcons.chevron_left_2), findsOne);
  });
}

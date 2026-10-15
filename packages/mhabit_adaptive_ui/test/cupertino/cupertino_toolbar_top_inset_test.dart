import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_sliver_app_bar.dart';

import '../harness/adaptive_ui_theme.dart';

void main() {
  testWidgets('explicit zero disables the macOS toolbar default', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.macOS),
        home: const CustomScrollView(
          slivers: [
            CupertinoSliverAppBar(
              toolbarTopInset: 0,
              title: Text('Default'),
              height: 44,
              style: AppBarAppleStyle(),
            ),
            SliverToBoxAdapter(
              child: SizedBox(key: ValueKey('default-body'), height: 100),
            ),
          ],
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('default-body'))).dy,
      44,
    );
  });

  testWidgets('caller inset respects existing safe area without adding twice', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: 20)),
          child: CustomScrollView(
            slivers: [
              AdaptiveEditableSliverAppBar.apple(
                appleToolbarTopInset: 10,
                title: 'Editor',
                controller: controller,
                isCollapsed: true,
              ),
              const SliverToBoxAdapter(
                child: SizedBox(key: ValueKey('editor-body'), height: 100),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final row = tester.getRect(find.byType(NavigationToolbar).first);
    expect(row.top, 20);
    expect(row.height, 44);
    expect(tester.getSize(find.byType(CupertinoNavigationBar)).height, 64);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('editor-body'))).dy,
      greaterThan(row.bottom),
    );
    expect(tester.takeException(), isNull);
  });

  for (final inset in [0.0, 10.0, 18.0]) {
    for (final platform in [TargetPlatform.macOS, TargetPlatform.iOS]) {
      for (final direction in TextDirection.values) {
        for (final mode in ['ordinary', 'search', 'selection']) {
          testWidgets(
            '$platform inset=$inset $direction $mode keeps its row across resize',
            (tester) async {
              tester.view.devicePixelRatio = 1;
              tester.view.physicalSize = const Size(350, 520);
              addTearDown(tester.view.reset);
              final controller = TextEditingController();
              final focus = FocusNode();
              addTearDown(controller.dispose);
              addTearDown(focus.dispose);
              final collection = ActionCollection<String>(roots: []);
              final bar = switch (mode) {
                'search' => CupertinoSliverSearchBar<String>(
                  toolbarTopInset: inset,
                  title: const Text('Habits'),
                  collection: collection,
                  onInvoke: (_, _) {},
                  controller: controller,
                  focusNode: focus,
                  isSearchActive: false,
                  keyword: '',
                  onChanged: (_) {},
                  onSearchActivated: () {},
                  onSearchDismissed: () {},
                ),
                'selection' => CupertinoSliverSelectAppBar<String>(
                  toolbarTopInset: inset,
                  title: const Text('Selected 2'),
                  selectAllLabel: 'All',
                  doneLabel: 'Done',
                  onSelectAll: () {},
                  onDone: () {},
                  collection: collection,
                  onInvoke: (_, _) {},
                ),
                _ => CupertinoSliverAppBar(
                  toolbarTopInset: inset,
                  title: const Text('Habits'),
                  height: 44,
                  style: const AppBarAppleStyle(),
                ),
              };
              await tester.pumpWidget(
                MaterialApp(
                  theme: ThemeData(platform: platform),
                  home: TestAdaptiveUiTheme(
                    update: (parentTheme) =>
                        parentTheme.copyWith(style: AdaptiveStyle.apple),
                    child: Directionality(
                      textDirection: direction,
                      child: CustomScrollView(
                        slivers: [
                          bar,
                          const SliverToBoxAdapter(
                            child: SizedBox(key: ValueKey('body'), height: 100),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              for (final width in [350.0, 700.0, 350.0]) {
                tester.view.physicalSize = Size(width, 520);
                await tester.pumpAndSettle();
                expect(
                  tester.getTopLeft(find.byKey(const ValueKey('body'))).dy,
                  44 + inset,
                );
                final row = tester.getRect(
                  find.byType(NavigationToolbar).first,
                );
                expect(row.height, 44);
                expect(row.center.dy, 22 + inset);
                expect(tester.takeException(), isNull);
              }
            },
          );
        }
      }
    }
  }
  for (final platform in [TargetPlatform.macOS, TargetPlatform.iOS]) {
    testWidgets(
      '$platform modal reserves its toolbar without padding the body',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(350, 520);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            home: TestAdaptiveUiTheme(
              update: (parentTheme) =>
                  parentTheme.copyWith(style: AdaptiveStyle.apple),
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showAdaptiveSheet<void>(
                    context: context,
                    builder: (_) => const AdaptiveModal(
                      appleToolbarTopInset: 18,
                      title: Text('Modal'),
                      body: SizedBox(key: ValueKey('modal-body'), height: 100),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        for (final width in [350.0, 700.0, 350.0]) {
          tester.view.physicalSize = Size(width, 520);
          await tester.pumpAndSettle();
          final bar = tester.getRect(find.byType(CupertinoNavigationBar));
          expect(bar.height, 62);
          final body = find.byKey(const ValueKey('modal-body'));
          expect(tester.getTopLeft(body).dy, greaterThanOrEqualTo(bar.bottom));
          expect(MediaQuery.paddingOf(tester.element(body)).top, 0);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}

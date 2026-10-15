import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_sliver_app_bar.dart';

import '../harness/adaptive_ui_theme.dart';

void main() {
  for (final platform in TargetPlatform.values) {
    final desktop = switch (platform) {
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux => true,
      _ => false,
    };
    for (final direction in TextDirection.values) {
      for (final mode in ['ordinary', 'search', 'selection']) {
        testWidgets('$platform $direction $mode keeps its row across resize', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(350, 520);
          addTearDown(tester.view.reset);
          final controller = TextEditingController();
          final focus = FocusNode();
          addTearDown(controller.dispose);
          addTearDown(focus.dispose);
          final collection = ActionCollection<String>(roots: []);
          Widget buildBar(BuildContext context) {
            return switch (mode) {
              'search' => CupertinoSliverSearchBar<String>(
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
                title: const Text('Selected 2'),
                selectAllLabel: 'All',
                doneLabel: 'Done',
                onSelectAll: () {},
                onDone: () {},
                collection: collection,
                onInvoke: (_, _) {},
              ),
              _ => const CupertinoSliverAppBar(
                title: Text('Habits'),
                height: 44,
                style: AppBarAppleStyle(),
              ),
            };
          }

          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: platform),
              home: TestAdaptiveUiTheme(
                update: (parentTheme) =>
                    parentTheme.copyWith(style: AdaptiveStyle.apple),
                child: Directionality(
                  textDirection: direction,
                  child: Builder(
                    builder: (context) => CustomScrollView(
                      slivers: [
                        buildBar(context),
                        const SliverToBoxAdapter(
                          child: SizedBox(key: ValueKey('body'), height: 100),
                        ),
                      ],
                    ),
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
              desktop ? 54 : 44,
            );
            final row = tester.getRect(find.byType(NavigationToolbar).first);
            expect(row.height, 44);
            expect(row.center.dy, desktop ? 32 : 22);
            expect(tester.takeException(), isNull);
          }
        });
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
                    builder: (context) => const AdaptiveModal(
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
          expect(bar.height, platform == TargetPlatform.macOS ? 54 : 44);
          final body = find.byKey(const ValueKey('modal-body'));
          expect(tester.getTopLeft(body).dy, greaterThanOrEqualTo(bar.bottom));
          expect(MediaQuery.paddingOf(tester.element(body)).top, 0);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}

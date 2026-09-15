import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final count in [3, 4]) {
      testWidgets('Choice $platform count=$count', (tester) async {
        int? value;
        var calls = 0;
        var enabled = true;
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  void onChanged(int next) => setState(() {
                    value = next;
                    calls++;
                  });
                  return AdaptiveChoiceListTile<int>(
                    title: const Text('Choice'),
                    subtitle: const Text('Description'),
                    labels: {
                      0: 'First',
                      1: 'Second',
                      2: 'Third',
                      if (count == 4) 3: 'Fourth',
                    },
                    value: value,
                    onChanged: enabled ? onChanged : null,
                  );
                },
              ),
            ),
          ),
        );
        final menu = count > 3;
        final menuAnchor = platform == TargetPlatform.android
            ? find.byType(MenuAnchor)
            : find.byType(CupertinoMenuAnchor);
        expect(menuAnchor, menu ? findsOneWidget : findsNothing);
        if (menu) {
          await tester.tap(
            platform == TargetPlatform.android
                ? find.byType(TextButton)
                : find.byType(CupertinoButton),
          );
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Second').last);
        await tester.pumpAndSettle();
        expect(value, 1);
        expect(calls, 1);
        expect(find.text('Description'), findsOneWidget);
        update(() => enabled = false);
        await tester.pumpAndSettle();
        if (menu) {
          final onPressed = platform == TargetPlatform.android
              ? tester.widget<TextButton>(find.byType(TextButton)).onPressed
              : tester
                    .widget<CupertinoButton>(find.byType(CupertinoButton))
                    .onPressed;
          expect(onPressed, isNull);
        } else {
          await tester.tap(find.text('First'));
          await tester.pumpAndSettle();
          expect(calls, 1);
        }
        expect(
          find.byType(CupertinoSlidingSegmentedControl<int>),
          platform == TargetPlatform.iOS && !menu
              ? findsOneWidget
              : findsNothing,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Threshold and layouts remain independent', (tester) async {
    tester.view.physicalSize = const Size(320, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Future<void> pump(
      AdaptiveChoiceListTileConfig config, {
      bool apple = false,
    }) async {
      final tile = apple
          ? AdaptiveChoiceListTile<int>.apple(
              title: const Text('Choice'),
              labels: const {0: 'One', 1: 'Two', 2: 'Three'},
              value: 0,
              onChanged: (_) {},
              config: config,
            )
          : AdaptiveChoiceListTile<int>.material(
              title: const Text('Choice'),
              labels: const {0: 'One', 1: 'Two', 2: 'Three'},
              value: 0,
              onChanged: (_) {},
              config: config,
            );
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: tile)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await pump(const AdaptiveChoiceListTileConfig());
    expect(find.byType(SegmentedButton<int>), findsOneWidget);
    expect(
      tester.widget<AdaptiveListTile>(find.byType(AdaptiveListTile)).trailing,
      isNull,
    );
    await pump(const AdaptiveChoiceListTileConfig.choice());
    expect(find.byType(MenuAnchor), findsOneWidget);
    await pump(const AdaptiveChoiceListTileConfig(maxSegmentCount: 2));
    expect(find.byType(MenuAnchor), findsOneWidget);
    expect(
      tester.widget<AdaptiveListTile>(find.byType(AdaptiveListTile)).trailing,
      isNotNull,
    );
    await pump(
      const AdaptiveChoiceListTileConfig(
        maxSegmentCount: 2,
        segmented: AdaptiveChoiceLayout.stacked,
      ),
    );
    expect(
      tester.widget<AdaptiveListTile>(find.byType(AdaptiveListTile)).trailing,
      isNotNull,
    );
    await pump(
      const AdaptiveChoiceListTileConfig(
        maxSegmentCount: 2,
        choice: AdaptiveChoiceLayout.responsive,
      ),
    );
    expect(
      tester.widget<AdaptiveListTile>(find.byType(AdaptiveListTile)).trailing,
      isNull,
    );
    await pump(
      const AdaptiveChoiceListTileConfig(maxSegmentCount: 0),
      apple: true,
    );
    expect(find.byType(CupertinoMenuAnchor), findsOneWidget);
    expect(find.byType(CupertinoSlidingSegmentedControl<int>), findsNothing);
    expect(find.byType(MenuAnchor), findsNothing);
    expect(tester.getSize(find.byType(CupertinoButton)).height, 28);
  });

  testWidgets('Apple inline choice matches a normal row height', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: AdaptiveListSection.apple(
            children: [
              const AdaptiveListTile.apple(
                key: ValueKey('normal-row'),
                title: Text('Normal'),
              ),
              const AdaptiveListTile.apple(
                key: ValueKey('chevron-row'),
                title: Text('Chevron'),
                trailing: Icon(CupertinoIcons.chevron_forward),
              ),
              AdaptiveSwitchListTile.apple(
                key: const ValueKey('switch-row'),
                title: const Text('Switch'),
                value: true,
                onChanged: (_) {},
              ),
              AdaptiveChoiceListTile<int>.apple(
                key: const ValueKey('choice-row'),
                title: const Text('Choice'),
                labels: const {0: 'First', 1: 'Second'},
                value: 0,
                onChanged: (_) {},
                config: const AdaptiveChoiceListTileConfig.choice(),
              ),
              const AdaptiveListTile.apple(
                key: ValueKey('subtitle-row'),
                title: Text('Title'),
                subtitle: Text('Subtitle'),
              ),
              const AdaptiveListTile.apple(
                key: ValueKey('oversized-action-row'),
                title: Text('Oversized action'),
                trailing: SizedBox(
                  key: ValueKey('oversized-action'),
                  width: 40,
                  height: 60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final normalHeight = tester
        .getSize(find.byKey(const ValueKey('normal-row')))
        .height;
    expect(normalHeight, 54);
    for (final key in [
      'chevron-row',
      'switch-row',
      'choice-row',
      'oversized-action-row',
    ]) {
      expect(tester.getSize(find.byKey(ValueKey(key))).height, normalHeight);
    }
    final oversizedChild = find.byKey(const ValueKey('oversized-action'));
    expect(tester.getSize(oversizedChild).height, 40);
    expect(
      tester.getSize(find.byKey(const ValueKey('subtitle-row'))).height,
      60,
    );
    expect(tester.getSize(find.byType(CupertinoSwitch)).height, 39);
    expect(tester.getSize(find.byType(CupertinoButton)).height, 28);
    expect(find.byType(FittedBox), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Apple inline segmented control keeps its natural height', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: AdaptiveListSection.apple(
            children: [
              AdaptiveChoiceListTile<int>.apple(
                key: const ValueKey('segmented-row'),
                title: const Text('Segmented'),
                labels: const {0: 'First', 1: 'Second'},
                value: 0,
                onChanged: (_) {},
                config: const AdaptiveChoiceListTileConfig(
                  segmented: AdaptiveChoiceLayout.inline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey('segmented-row'))).height,
      54,
    );
    final control = find.byType(CupertinoSlidingSegmentedControl<int>);
    expect(tester.getSize(control).height, 34);
    expect(
      find.ancestor(of: control, matching: find.byType(FittedBox)),
      findsNothing,
    );
    final rowRect = tester.getRect(find.byKey(const ValueKey('segmented-row')));
    final paintedControlRect = tester.getRect(control);
    expect(paintedControlRect.height, lessThanOrEqualTo(34));
    expect(paintedControlRect.top, greaterThanOrEqualTo(rowRect.top));
    expect(paintedControlRect.bottom, lessThanOrEqualTo(rowRect.bottom));
    expect(tester.takeException(), isNull);
  });
}

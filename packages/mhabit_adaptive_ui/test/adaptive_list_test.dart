import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget host(Widget child, {TargetPlatform platform = TargetPlatform.iOS}) =>
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: Scaffold(body: child),
    );

void main() {
  for (final platform in TargetPlatform.values) {
    testWidgets('resolves $platform and preserves Material parameters', (
      tester,
    ) async {
      var taps = 0;
      const title = Text('Action');
      const subtitle = Text('Description');
      const leading = Icon(Icons.info);
      const trailing = Icon(Icons.chevron_right);
      await tester.pumpWidget(
        host(
          AdaptiveListTile(
            title: title,
            subtitle: subtitle,
            leading: leading,
            trailing: trailing,
            onTap: () => taps++,
          ),
          platform: platform,
        ),
      );
      final apple =
          platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
      expect(
        find.byType(CupertinoListTile),
        apple ? findsOneWidget : findsNothing,
      );
      if (!apple) {
        final tile = tester.widget<ListTile>(find.byType(ListTile));
        expect(tile.title, same(title));
        expect(tile.subtitle, same(subtitle));
        expect(tile.leading, same(leading));
        expect(tile.trailing, same(trailing));
        expect(tile.contentPadding, isNull);
        expect(tile.dense, isNull);
      }
      await tester.tap(find.text('Action'));
      await tester.pump();
      expect(taps, 1);
    });
  }
  testWidgets('forced constructors override scope', (tester) async {
    await tester.pumpWidget(
      host(
        const AdaptiveStyleScope(
          override: AdaptiveStyle.material,
          child: Column(
            children: [
              AdaptiveListTile.apple(title: Text('Apple')),
              AdaptiveListTile.material(title: Text('Material')),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(CupertinoListTile), findsOneWidget);
    expect(find.byType(ListTile), findsOneWidget);
  });
  for (final (platform, icon) in <(TargetPlatform, IconData)>[
    (TargetPlatform.android, Icons.open_in_new),
    (TargetPlatform.iOS, CupertinoIcons.arrow_up_right_square),
  ]) {
    testWidgets('external uses the $platform navigation indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AdaptiveListTile.external(title: Text('External')),
          platform: platform,
        ),
      );
      expect(find.byIcon(icon), findsOneWidget);
    });
  }
  testWidgets('keyboard and semantics activate once with visible focus', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      host(AdaptiveListTile(title: const Text('Action'), onTap: () => taps++)),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final decorations = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(AdaptiveListTile),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect(
      decorations.any(
        (box) =>
            box.position == DecorationPosition.foreground &&
            box.decoration is ShapeDecoration &&
            ((box.decoration as ShapeDecoration).shape as OutlinedBorder)
                    .side
                    .width >
                0,
      ),
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(taps, 2);
    final node = tester.getSemantics(find.text('Action'));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
    tester.binding.performSemanticsAction(
      SemanticsActionEvent(
        nodeId: node.id,
        viewId: tester.view.viewId,
        type: SemanticsAction.tap,
      ),
    );
    await tester.pump();
    expect(taps, 3);
  });
  testWidgets('information rows and trailing controls have independent input', (
    tester,
  ) async {
    var rowTaps = 0;
    var controlTaps = 0;
    await tester.pumpWidget(
      host(
        Column(
          children: [
            const AdaptiveListTile(title: Text('Information')),
            AdaptiveListTile(
              title: const Text('Action'),
              onTap: () => rowTaps++,
              trailing: CupertinoButton(
                onPressed: () => controlTaps++,
                child: const Text('Control'),
              ),
            ),
          ],
        ),
      ),
    );
    expect(
      tester
          .getSemantics(find.text('Information'))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );
    await tester.tap(find.text('Control'));
    await tester.pump();
    expect(controlTaps, 1);
    expect(rowTaps, 0);
    expect(
      tester.getSemantics(find.text('Control')).id,
      isNot(tester.getSemantics(find.text('Action')).id),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(rowTaps, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(controlTaps, 2);
    expect(rowTaps, 1);
  });
  for (final brightness in Brightness.values) {
    for (final direction in TextDirection.values) {
      testWidgets('long rich text wraps at 2x in $brightness $direction', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              platform: TargetPlatform.iOS,
              brightness: brightness,
            ),
            home: Scaffold(
              body: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: Directionality(
                  textDirection: direction,
                  child: const SingleChildScrollView(
                    child: SizedBox(
                      width: 280,
                      child: AdaptiveListSection(
                        header: Text('Language'),
                        children: [
                          AdaptiveListTile(
                            title: Text(
                              'A long title that must wrap onto multiple lines',
                            ),
                            subtitle: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'A long description ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        'whose entire contents must remain readable at large text sizes.',
                                  ),
                                ],
                              ),
                            ),
                            trailing: CupertinoListTileChevron(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(CupertinoListTile)).height,
          greaterThan(100),
        );
        for (final paragraph in tester.renderObjectList<RenderParagraph>(
          find.descendant(
            of: find.byType(CupertinoListTile),
            matching: find.byType(RichText),
          ),
        )) {
          expect(paragraph.didExceedMaxLines, isFalse);
        }
      });
    }
  }
  testWidgets('section forwards header and inset and hides empty rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Column(
          children: [
            AdaptiveListSection.apple(
              header: Text('Heading'),
              hasLeading: true,
              children: [
                AdaptiveListTile(
                  title: Text('Row'),
                  leading: Icon(CupertinoIcons.info),
                ),
              ],
            ),
            AdaptiveListSection.apple(header: Text('Empty'), children: []),
            AdaptiveListSection.material(
              header: Text('Material heading'),
              children: [AdaptiveListTile(title: Text('Material row'))],
            ),
          ],
        ),
      ),
    );
    expect(find.byType(ClipRSuperellipse), findsOneWidget);
    expect(find.text('Empty'), findsNothing);
    expect(find.byType(CupertinoListTile), findsOneWidget);
    expect(find.byType(ListTile), findsOneWidget);
    expect(
      tester
          .getSemantics(find.text('Material heading'))
          .getSemanticsData()
          .flagsCollection
          .isHeader,
      isTrue,
    );
  });
}

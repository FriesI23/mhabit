import 'package:adaptive_actions/cupertino.dart' show AdaptiveCupertinoTooltip;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/contributor.dart';
import 'package:mhabit/pages/common/_widgets/contributor_tile.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final direction in TextDirection.values) {
      testWidgets('Contributor groups and actions $platform $direction', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final calls = <MethodCall>[];
        const channel = MethodChannel('plugins.flutter.io/url_launcher');
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          (call) async {
            calls.add(call);
            return true;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            channel,
            null,
          ),
        );
        final contributors = Contributors.fromJson({
          'contributors': [
            {
              'name': 'Alice',
              'url': 'https://example.com/alice',
              'comment': 'Maintainer',
            },
            {'name': 'NoLink', 'comment': 'Offline contributor'},
            {'name': 'A very long contributor name that wraps across lines'},
          ],
          'translations': {
            'de': [
              {'name': 'Translator', 'url': 'https://example.com/translator'},
            ],
            'fr': [],
          },
        });
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              platform: platform,
              colorSchemeSeed: Colors.orange,
            ),
            builder: (context, child) => Directionality(
              textDirection: direction,
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: ContributorTile(contributors: contributors),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AdaptiveListSection), findsNWidgets(2));
        expect(find.byType(AdaptiveListTile), findsNWidgets(2));
        expect(find.byType(Divider), findsNothing);
        for (final row in tester.widgetList<AdaptiveListTile>(
          find.byType(AdaptiveListTile),
        )) {
          expect(row.onTap, isNull);
        }
        final apple = platform != TargetPlatform.android;
        expect(
          find.byType(AdaptiveCupertinoTooltip),
          apple ? findsNWidgets(2) : findsNothing,
        );
        expect(find.byType(Tooltip), apple ? findsNothing : findsNWidgets(2));
        expect(
          find.byType(CupertinoButton),
          apple ? findsNWidgets(2) : findsNothing,
        );
        expect(tester.takeException(), isNull);
        final link = find.text('@Alice');
        final linkContext = tester.element(link);
        expect(
          tester.widget<Text>(link).style!.color,
          apple
              ? CupertinoTheme.of(linkContext).primaryColor
              : Theme.of(linkContext).colorScheme.primary,
        );
        await tester.longPress(link);
        await tester.pumpAndSettle();
        expect(find.text('Maintainer'), findsOneWidget);
        expect(calls, isEmpty);
        await tester.tapAt(const Offset(1, 1));
        await tester.pumpAndSettle();
        await tester.tap(link);
        await tester.pumpAndSettle();
        expect(calls.where((call) => call.method == 'canLaunch'), hasLength(1));
        final launches = calls
            .where((call) => call.method == 'launch')
            .toList();
        expect(launches, hasLength(1));
        expect(launches.single.arguments['url'], 'https://example.com/alice');
        expect(launches.single.arguments['useSafariVC'], isFalse);
        expect(launches.single.arguments['useWebView'], isFalse);
        calls.clear();
        await tester.tap(find.text('@NoLink'));
        await tester.pumpAndSettle();
        expect(calls, isEmpty);
        await tester.longPress(find.text('@NoLink'));
        await tester.pumpAndSettle();
        expect(find.text('Offline contributor'), findsOneWidget);
        expect(calls, isEmpty);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Empty contributor data creates no groups', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContributorTile(contributors: Contributors.fromJson({})),
        ),
      ),
    );
    expect(find.byType(AdaptiveListSection), findsNothing);
    expect(find.byType(AdaptiveListTile), findsNothing);
    expect(find.text('Contributors'), findsNothing);
  });
}

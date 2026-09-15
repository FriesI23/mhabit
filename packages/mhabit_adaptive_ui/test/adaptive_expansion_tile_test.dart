import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets(
      'disclosure, independent action and controller replacement $platform',
      (tester) async {
        final first = ExpansibleController();
        final second = ExpansibleController()..expand();
        addTearDown(first.dispose);
        addTearDown(second.dispose);
        ExpansibleController? controller = first;
        var exports = 0;
        late StateSetter rebuild;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  rebuild = setState;
                  return AdaptiveListSection(
                    children: [
                      AdaptiveExpansionTile(
                        title: const Text('Failure'),
                        controller: controller,
                        trailing: AdaptiveIconButton(
                          icon: const Icon(Icons.save),
                          onPressed: () => exports++,
                        ),
                        children: const [Text('Error details')],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.tap(find.byIcon(Icons.save));
        await tester.pumpAndSettle();
        expect(exports, 1);
        expect(first.isExpanded, false);
        await tester.tap(find.text('Failure'));
        await tester.pumpAndSettle();
        expect(first.isExpanded, true);
        expect(find.text('Error details').hitTestable(), findsOneWidget);
        first.collapse();
        await tester.pumpAndSettle();
        expect(find.text('Error details').hitTestable(), findsNothing);
        rebuild(() => controller = second);
        await tester.pumpAndSettle();
        expect(find.text('Error details').hitTestable(), findsOneWidget);
        first.expand();
        second.collapse();
        await tester.pumpAndSettle();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(second.isExpanded, true);
        rebuild(() => controller = null);
        await tester.pumpAndSettle();
        expect(find.text('Error details').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Failure'));
        await tester.pumpAndSettle();
        expect(find.text('Error details').hitTestable(), findsNothing);
        rebuild(() => controller = second);
        await tester.pumpAndSettle();
        expect(find.text('Error details').hitTestable(), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        second.collapse(); // Borrowed controllers remain usable after unmount.
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'unkeyed disclosures do not read ancestor scroll storage $platform',
      (tester) async {
        final bucket = PageStorageBucket();
        late BuildContext savedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: PageStorage(
              bucket: bucket,
              child: KeyedSubtree(
                key: const PageStorageKey('scroll'),
                child: Builder(
                  builder: (context) {
                    savedContext = context;
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );
        bucket.writeState(savedContext, 240.0);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            home: Scaffold(
              body: PageStorage(
                bucket: bucket,
                child: const KeyedSubtree(
                  key: PageStorageKey('scroll'),
                  child: Column(
                    children: [
                      AdaptiveExpansionTile(
                        title: Text('First'),
                        children: [Text('First body')],
                      ),
                      AdaptiveExpansionTile(
                        title: Text('Second'),
                        children: [Text('Second body')],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('First'));
        await tester.pumpAndSettle();
        expect(find.text('First body').hitTestable(), findsOneWidget);
        expect(find.text('Second body').hitTestable(), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

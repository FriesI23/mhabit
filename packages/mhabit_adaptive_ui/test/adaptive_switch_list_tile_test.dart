import 'dart:ui' show Tristate;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    testWidgets('$style row, switch, semantics and keyboard toggle once', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        var value = false;
        var calls = 0;
        var enabled = true;
        late StateSetter rebuild;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              platform: style == AdaptiveStyle.apple
                  ? TargetPlatform.android
                  : TargetPlatform.iOS,
            ),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  rebuild = setState;
                  void changed(bool next) => setState(() {
                    value = next;
                    calls++;
                  });
                  final tile = switch (style) {
                    AdaptiveStyle.material => AdaptiveSwitchListTile.material(
                      title: const Text('Setting'),
                      subtitle: const Text('Description'),
                      value: value,
                      onChanged: enabled ? changed : null,
                    ),
                    AdaptiveStyle.apple => AdaptiveSwitchListTile.apple(
                      title: const Text('Setting'),
                      subtitle: const Text('Description'),
                      value: value,
                      onChanged: enabled ? changed : null,
                    ),
                  };
                  return switch (style) {
                    AdaptiveStyle.material => AdaptiveListSection.material(
                      children: [tile],
                    ),
                    AdaptiveStyle.apple => AdaptiveListSection.apple(
                      children: [tile],
                    ),
                  };
                },
              ),
            ),
          ),
        );
        final control = find.byType(
          style == AdaptiveStyle.apple ? CupertinoSwitch : Switch,
        );
        await tester.tap(control);
        await tester.pumpAndSettle();
        expect(value, true);
        expect(calls, 1);
        await tester.tap(find.text('Setting'));
        await tester.pumpAndSettle();
        expect(value, false);
        expect(calls, 2);
        final node = tester.getSemantics(find.byType(AdaptiveSwitchListTile));
        expect(node.getSemanticsData().label, contains('Setting'));
        expect(
          node.getSemanticsData().flagsCollection.isToggled,
          Tristate.isFalse,
        );
        node.owner!.performAction(node.id, SemanticsAction.tap);
        await tester.pumpAndSettle();
        expect(value, true);
        expect(calls, 3);
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(value, false);
        expect(calls, 4);
        rebuild(() => enabled = false);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Setting'));
        await tester.tap(control);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(calls, 4);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('default renderer follows $platform', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          home: Scaffold(
            body: AdaptiveSwitchListTile(
              title: const Text('Setting'),
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(
        find.byType(platform == TargetPlatform.iOS ? CupertinoSwitch : Switch),
        findsOneWidget,
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  group('AdaptiveDialog', () {
    testWidgets('is an AdaptiveModal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final modal = AdaptiveDialog<String>(
                context: context,
                builder: (_) => const SizedBox.shrink(),
              );
              expect(modal, isA<AdaptiveModal<String>>());
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('call shows a Material dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveDialog<String>(
                context: context,
                builder: (_) => const AlertDialog(title: Text('dialog')),
              )(),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('AdaptiveBottomSheet', () {
    testWidgets('call shows a Material bottom sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => AdaptiveBottomSheet<String>(
                context: context,
                builder: (_) => const SizedBox(height: 100),
              )(),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  group('AdaptiveStyleContext', () {
    testWidgets('maps iOS to apple', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) {
              expect(context.adaptiveStyle, AdaptiveStyle.apple);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('maps Android to material', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Builder(
            builder: (context) {
              expect(context.adaptiveStyle, AdaptiveStyle.material);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });

  group('AdaptiveSliverAppBar', () {
    testWidgets('renders a SliverAppBar via default dispatch', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [AdaptiveSliverAppBar(title: Text('title'))],
            ),
          ),
        ),
      );
      expect(find.byType(SliverAppBar), findsOneWidget);
    });

    testWidgets('.material renders a SliverAppBar on Apple platform', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const Scaffold(
            body: CustomScrollView(
              slivers: [AdaptiveSliverAppBar.material(title: Text('title'))],
            ),
          ),
        ),
      );
      expect(find.byType(SliverAppBar), findsOneWidget);
    });

    testWidgets('apple platform falls back to Material in Phase 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const Scaffold(
            body: CustomScrollView(
              slivers: [AdaptiveSliverAppBar(title: Text('title'))],
            ),
          ),
        ),
      );
      expect(find.byType(SliverAppBar), findsOneWidget);
    });
  });

  group('AdaptiveSliverSearchBar', () {
    testWidgets('renders a sliver search app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [AdaptiveSliverSearchBar(onChanged: (_) {})],
            ),
          ),
        ),
      );
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byType(SearchBar), findsOneWidget);
    });
  });
}

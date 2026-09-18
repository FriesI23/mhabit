import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/extensions/custom_color_extensions.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_color_type.dart';
import 'package:mhabit/models/habit_group.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/theme/color.dart'
    show darkCustomColors, lightCustomColors;
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'optional color and icon respect leading override on $style $brightness',
        (tester) async {
          final palette = brightness == Brightness.light
              ? lightCustomColors
              : darkCustomColors;
          const custom = HabitColor.custom(0xff4488cc, tinted: false);
          const builtIn = HabitColor.builtIn(HabitColorType.cc3);
          await tester.pumpWidget(
            AdaptiveStyleScope(
              override: style,
              child: MaterialApp(
                theme: ThemeData(brightness: brightness, extensions: [palette]),
                home: const Scaffold(
                  body: CustomScrollView(
                    slivers: [
                      SliverHabitGroupTree(
                        groups: [
                          HabitGroupTreeEntry(
                            id: 'colored',
                            title: Text('Colored'),
                            color: custom,
                            icon: GroupIcon.work,
                          ),
                          HabitGroupTreeEntry(
                            id: 'dot',
                            title: Text('Dot'),
                            color: builtIn,
                          ),
                          HabitGroupTreeEntry(
                            id: 'icon',
                            title: Text('Icon only'),
                            icon: GroupIcon.music,
                          ),
                          HabitGroupTreeEntry(
                            id: 'plain',
                            title: Text('Plain'),
                            isUngrouped: true,
                          ),
                          HabitGroupTreeEntry(
                            id: 'override',
                            title: Text('Override'),
                            color: custom,
                            icon: GroupIcon.star,
                            leading: Icon(Icons.favorite),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          final expected = palette.getColor(custom, brightness: brightness);
          expect(
            tester.widget<Icon>(find.byIcon(Icons.work_outline)).color,
            expected,
          );
          expect(
            DefaultTextStyle.of(
              tester.element(find.text('Colored')),
            ).style.color,
            expected,
          );
          expect(
            tester.widget<Icon>(find.byIcon(Icons.circle)).color,
            palette.getColor(builtIn, brightness: brightness),
          );
          expect(find.byIcon(Icons.music_note), findsOneWidget);
          expect(find.byIcon(Icons.star_outline), findsNothing);
          expect(find.byIcon(Icons.favorite), findsOneWidget);
          final plain = tester.widget<AdaptiveListTile>(
            find.descendant(
              of: find.byKey(const ValueKey('plain')),
              matching: find.byType(AdaptiveListTile),
            ),
          );
          expect(plain.leading, isNull);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'external controller and replacement preserve tree state on $style',
      (tester) async {
        final first = TreeSliverController();
        final second = TreeSliverController();
        TreeSliverController? controller = first;
        var showToggle = false;
        final toggles = <String>[];
        late StateSetter rebuild;
        await tester.pumpWidget(
          AdaptiveStyleScope(
            override: style,
            child: MaterialApp(
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    rebuild = setState;
                    return CustomScrollView(
                      slivers: [
                        SliverHabitGroupTree(
                          controller: controller,
                          onNodeToggle: (node) =>
                              toggles.add(node.content! as String),
                          showExpansionToggle: showToggle,
                          expansionToggleKey: const ValueKey('toggle-all'),
                          root: const HabitGroupTreeEntry(
                            id: 'root',
                            title: Text('Preview'),
                          ),
                          groups: const [
                            HabitGroupTreeEntry(
                              id: 'group',
                              title: Text('Group'),
                              children: [
                                HabitGroupTreeEntry(
                                  id: 'habit',
                                  title: Text('Habit'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
        expect(find.byKey(const ValueKey('toggle-all')), findsNothing);
        first.expandAll();
        await tester.pumpAndSettle();
        expect(find.text('Habit'), findsOneWidget);
        expect(toggles, contains('root'));
        await tester.tap(find.text('Group'));
        await tester.pumpAndSettle();
        expect(first.isExpanded(first.getNodeFor('group')!), isFalse);
        expect(toggles.last, 'group');
        rebuild(() => controller = second);
        await tester.pumpAndSettle();
        expect(second.isExpanded(second.getNodeFor('root')!), isTrue);
        expect(second.isExpanded(second.getNodeFor('group')!), isFalse);
        second.expandNode(second.getNodeFor('group')!);
        await tester.pumpAndSettle();
        expect(find.text('Habit'), findsOneWidget);
        rebuild(() => showToggle = true);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('toggle-all')));
        await tester.pumpAndSettle();
        expect(second.isExpanded(second.getNodeFor('root')!), isFalse);
        second.expandAll();
        await tester.pumpAndSettle();
        rebuild(() => controller = null);
        await tester.pumpAndSettle();
        expect(find.text('Habit'), findsOneWidget);
        await tester.tap(find.text('Group'));
        await tester.pumpAndSettle();
        expect(find.text('Habit'), findsNothing);
        rebuild(() => controller = first);
        await tester.pumpAndSettle();
        expect(first.isExpanded(first.getNodeFor('group')!), isFalse);
        first.collapseAll();
        await tester.pumpAndSettle();
        expect(find.text('Group'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('tree preserves expansion and custom slots on $style', (
      tester,
    ) async {
      var updated = false;
      var addHabit = false;
      var trailingTaps = 0;
      late StateSetter rebuild;
      await tester.pumpWidget(
        AdaptiveStyleScope(
          override: style,
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  rebuild = setState;
                  return CustomScrollView(
                    slivers: [
                      SliverHabitGroupTree(
                        root: const HabitGroupTreeEntry(
                          id: 'root',
                          title: Text('Preview'),
                        ),
                        groups: [
                          HabitGroupTreeEntry(
                            id: 'g1',
                            title: const Text('Same'),
                            leading: const Icon(
                              Icons.folder,
                              key: ValueKey('group-leading'),
                            ),
                            trailing: Text(updated ? 'Done' : 'Pending'),
                            children: [
                              HabitGroupTreeEntry(
                                id: 'h1',
                                title: const Text('Habit 1'),
                                leading: const Icon(
                                  Icons.circle,
                                  key: ValueKey('habit-leading'),
                                ),
                                trailing: IconButton(
                                  key: const ValueKey('habit-action'),
                                  onPressed: () => trailingTaps++,
                                  icon: const Icon(Icons.more_horiz),
                                ),
                              ),
                              if (addHabit)
                                const HabitGroupTreeEntry(
                                  id: 'h2',
                                  title: Text('Habit 2'),
                                ),
                            ],
                          ),
                          const HabitGroupTreeEntry(
                            id: 'g2',
                            title: Text('Same'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text('Same'), findsNothing);
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();
      expect(find.text('Same'), findsNWidgets(2));
      await tester.tap(find.byKey(const ValueKey('g1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('group-leading')), findsOneWidget);
      expect(find.byKey(const ValueKey('habit-leading')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('habit-action')));
      expect(trailingTaps, 1);
      rebuild(() => updated = true);
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Habit 1'), findsOneWidget);
      rebuild(() => addHabit = true);
      await tester.pumpAndSettle();
      expect(find.text('Habit 2'), findsOneWidget);
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();
      expect(find.text('Habit 1'), findsOneWidget);
      expect(find.text('Habit 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'tree works without root and preserves collapse when reordering on $style',
      (tester) async {
        var reverse = false;
        late StateSetter rebuild;
        await tester.pumpWidget(
          AdaptiveStyleScope(
            override: style,
            child: MaterialApp(
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    rebuild = setState;
                    final groups = [
                      const HabitGroupTreeEntry(
                        id: 'g1',
                        title: Text('Group 1'),
                        initiallyExpanded: true,
                        children: [
                          HabitGroupTreeEntry(id: 'h1', title: Text('Habit 1')),
                        ],
                      ),
                      const HabitGroupTreeEntry(
                        id: 'g2',
                        title: Text('Empty group'),
                      ),
                    ];
                    return CustomScrollView(
                      slivers: [
                        SliverHabitGroupTree(
                          groups: reverse ? groups.reversed.toList() : groups,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
        expect(find.text('Habit 1'), findsOneWidget);
        await tester.tap(find.text('Group 1'));
        await tester.pumpAndSettle();
        rebuild(() => reverse = true);
        await tester.pumpAndSettle();
        expect(find.text('Habit 1'), findsNothing);
        expect(find.text('Empty group'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('g2')),
            matching: find.byIcon(defaultGroupIcon),
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Group 1'));
        await tester.pumpAndSettle();
        expect(find.text('Habit 1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

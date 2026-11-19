// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'package:flutter/material.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/theme/color.dart';
import 'package:mhabit/widgets/widgets.dart';

void main() {
  for (final (locale, direction) in <(Locale, TextDirection?)>[
    (const Locale('en'), null),
    (const Locale('eo'), null),
    (const Locale('ar'), null),
    (const Locale('en'), TextDirection.rtl),
  ]) {
    for (final grid in [false, true]) {
      testWidgets(
        'reorder scope keeps modern resources for $locale $direction grid=$grid',
        (tester) async {
          late BuildContext outerContext;
          late BuildContext innerContext;
          final theme = ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff68328a),
              brightness: Brightness.dark,
            ),
            extensions: [lightCustomColors],
          );
          const items = [1, 2, 3];
          final moves = <(int, int)>[];
          void onReorder(int oldIndex, int newIndex) =>
              moves.add((oldIndex, newIndex));
          Widget itemBuilder(BuildContext context, int index) => SizedBox(
            key: ValueKey(items[index]),
            height: 40,
            child: Text('item ${items[index]}'),
          );
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              locale: locale,
              localizationsDelegates: appLocalizationsDelegates,
              supportedLocales: appSupportedLocales,
              builder: (context, child) => direction == null
                  ? child!
                  : Directionality(textDirection: direction, child: child!),
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    outerContext = context;
                    return ReorderableListLocalizations(
                      child: Builder(
                        builder: (context) {
                          innerContext = context;
                          return CustomScrollView(
                            slivers: [
                              if (grid)
                                SliverReorderableAnimatedList<int>.grid(
                                  scrollDirection: Axis.vertical,
                                  items: items,
                                  itemBuilder: itemBuilder,
                                  onReorder: onReorder,
                                  buildDefaultDragHandles: false,
                                  sliverGridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisExtent: 40,
                                      ),
                                )
                              else
                                SliverReorderableAnimatedList<int>(
                                  scrollDirection: Axis.vertical,
                                  items: items,
                                  itemBuilder: itemBuilder,
                                  onReorder: onReorder,
                                  buildDefaultDragHandles: false,
                                ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            Localizations.of<legacy.MaterialLocalizations>(
              outerContext,
              legacy.MaterialLocalizations,
            ),
            isNull,
          );
          expect(legacy.MaterialLocalizations.of(innerContext), isNotNull);
          expect(Localizations.localeOf(innerContext), locale);
          expect(
            Directionality.of(innerContext),
            Directionality.of(outerContext),
          );
          expect(Theme.of(innerContext), Theme.of(outerContext));
          expect(
            Theme.of(innerContext).extension<CustomColors>(),
            same(lightCustomColors),
          );
          expect(
            MaterialLocalizations.of(innerContext).copyButtonLabel,
            MaterialLocalizations.of(outerContext).copyButtonLabel,
          );
          expect(
            L10n.of(innerContext)?.appName,
            L10n.of(outerContext)?.appName,
          );
          expect(L10n.of(innerContext), isNotNull);

          final widgets = WidgetsLocalizations.of(innerContext);
          final outerWidgets = WidgetsLocalizations.of(outerContext);
          expect(widgets.reorderItemUp, outerWidgets.reorderItemUp);
          expect(widgets.reorderItemDown, outerWidgets.reorderItemDown);
          final semantics = tester.widgetList<Semantics>(
            find.ancestor(
              of: find.text('item 2'),
              matching: find.byType(Semantics),
            ),
          );
          final actions = <String, VoidCallback>{};
          for (final widget in semantics) {
            final callbacks = widget.properties.customSemanticsActions;
            if (callbacks == null) continue;
            for (final action in callbacks.entries) {
              final label = action.key.label;
              if (label != null) actions[label] = action.value;
            }
          }
          expect(
            actions.keys,
            containsAll([
              widgets.reorderItemUp,
              widgets.reorderItemDown,
              widgets.reorderItemToStart,
              widgets.reorderItemToEnd,
            ]),
          );
          actions[widgets.reorderItemUp]!();
          expect(moves, [(1, 0)]);
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pumpAndSettle();
          final list = tester.widget<ReorderableAnimatedListImpl<int>>(
            find.byType(ReorderableAnimatedListImpl<int>),
          );
          expect(list.buildDefaultDragHandles, isFalse);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

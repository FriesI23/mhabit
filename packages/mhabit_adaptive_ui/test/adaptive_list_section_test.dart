import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_adaptive_list_tile.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_list_section.dart';
import 'package:mhabit_adaptive_ui/src/material/material_list_section.dart';

void main() {
  testWidgets('adaptive section forwards custom exterior padding', (
    tester,
  ) async {
    const padding = EdgeInsetsDirectional.only(top: 12, bottom: 4);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AdaptiveListSection.apple(
                padding: padding,
                children: [Text('Apple row')],
              ),
              AdaptiveListSection.material(
                padding: padding,
                children: [Text('Material row')],
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester
          .widget<CupertinoAdaptiveListSection>(
            find.byType(CupertinoAdaptiveListSection),
          )
          .padding,
      padding,
    );
    expect(
      tester
          .widget<MaterialAdaptiveListSection>(
            find.byType(MaterialAdaptiveListSection),
          )
          .padding,
      padding,
    );
  });

  testWidgets(
    'Material ink keeps first middle last and single segment corners',
    (tester) async {
      for (final count in [1, 3]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AdaptiveListSection.material(
                children: [
                  for (var i = 0; i < count; i++)
                    AdaptiveListTile(title: Text('Row $i'), onTap: () {}),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < count; i++) {
          final row = find.ancestor(
            of: find.text('Row $i'),
            matching: find.byType(AdaptiveListTile),
          );
          final material = find
              .ancestor(
                of: row,
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Material &&
                      widget.shape is RoundedRectangleBorder,
                ),
              )
              .first;
          final ink = find.descendant(of: row, matching: find.byType(InkWell));
          final expected = RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(i == 0 ? 16 : 4),
              bottom: Radius.circular(i == count - 1 ? 16 : 4),
            ),
          );
          void expectMatchingShape() {
            expect(tester.widget<Material>(material).shape, expected);
            expect(tester.widget<InkWell>(ink).customBorder, expected);
          }

          expectMatchingShape();
          final pointer = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await pointer.addPointer(location: const Offset(790, 590));
          await pointer.moveTo(tester.getCenter(row));
          await tester.pumpAndSettle();
          expectMatchingShape();
          await pointer.down(tester.getCenter(row));
          await tester.pumpAndSettle();
          expectMatchingShape();
          await pointer.up();
          await pointer.removePointer();
          await tester.pumpAndSettle();
          expectMatchingShape();
        }
      }
    },
  );

  testWidgets(
    'local merge retains parent roles and falls back to global roles',
    (tester) async {
      final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);
      for (final override in [Colors.pink, null]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: scheme,
              extensions: const [
                AdaptiveListThemeData(
                  surfaceColor: Colors.red,
                  iconColor: Colors.green,
                  materialSurfaceColor: Colors.yellow,
                ),
              ],
            ),
            home: Scaffold(
              body: AdaptiveListTheme(
                data: const AdaptiveListThemeData(surfaceColor: Colors.purple),
                child: AdaptiveListTheme.merge(
                  data: const AdaptiveListThemeData(
                    foregroundColor: Colors.blue,
                  ),
                  child: Column(
                    children: [
                      CupertinoAdaptiveListSection(
                        surfaceColor: override,
                        children: [
                          CupertinoAdaptiveListTile(
                            title: const Text('Local title'),
                            subtitle: const Text('Default subtitle'),
                            foregroundColor: override,
                            trailing: const Icon(CupertinoIcons.add),
                          ),
                        ],
                      ),
                      const MaterialAdaptiveListSection(
                        children: [ListTile(title: Text('Material global'))],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.text('Local title'));
        final local = AdaptiveListTheme.of(context);
        expect(local.surfaceColor, Colors.purple);
        expect(local.foregroundColor, Colors.blue);
        expect(
          DefaultTextStyle.of(context).style.color,
          override ?? Colors.blue,
        );
        expect(
          DefaultTextStyle.of(
            tester.element(find.text('Default subtitle')),
          ).style.color,
          scheme.onSurfaceVariant,
        );
        expect(
          IconTheme.of(tester.element(find.byIcon(CupertinoIcons.add))).color,
          Colors.green,
        );
        expect(
          tester
              .widgetList<ColoredBox>(
                find.descendant(
                  of: find.byType(CupertinoAdaptiveListSection),
                  matching: find.byType(ColoredBox),
                ),
              )
              .map((box) => box.color),
          contains(override ?? Colors.purple),
        );
        expect(
          tester
              .widgetList<Material>(
                find.descendant(
                  of: find.byType(MaterialAdaptiveListSection),
                  matching: find.byType(Material),
                ),
              )
              .map((surface) => surface.color),
          contains(Colors.yellow),
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('renderer overrides can return to inherited theme defaults', (
    tester,
  ) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.teal);
    for (final override in [Colors.orange, null]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: scheme,
            extensions: const [
              AdaptiveListThemeData(
                surfaceColor: Colors.purple,
                foregroundColor: Colors.green,
              ),
            ],
          ),
          home: Scaffold(
            body: Column(
              children: [
                CupertinoAdaptiveListSection(
                  surfaceColor: override,
                  children: [
                    CupertinoAdaptiveListTile(
                      title: const Text('Apple override'),
                      foregroundColor: override,
                    ),
                  ],
                ),
                MaterialAdaptiveListSection(
                  surfaceColor: override,
                  children: const [ListTile(title: Text('Material override'))],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        DefaultTextStyle.of(
          tester.element(find.text('Apple override')),
        ).style.color,
        override ?? Colors.green,
      );
      expect(
        tester
            .widgetList<ColoredBox>(
              find.descendant(
                of: find.byType(CupertinoAdaptiveListSection),
                matching: find.byType(ColoredBox),
              ),
            )
            .map((box) => box.color),
        contains(override ?? Colors.purple),
      );
      expect(
        tester
            .widgetList<Material>(
              find.descendant(
                of: find.byType(MaterialAdaptiveListSection),
                matching: find.byType(Material),
              ),
            )
            .map((surface) => surface.color),
        contains(override ?? scheme.surfaceContainerHigh),
      );
      expect(tester.takeException(), isNull);
    }
  });

  for (final style in AdaptiveStyle.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '$style $brightness exterior and corners reveal host surface',
        (tester) async {
          final scheme = ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: brightness,
          );
          // Deliberately distinct from both the theme and Cupertino system gray.
          const hostColor = Color(0xff24536b);
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(colorScheme: scheme),
              home: Scaffold(
                body: Align(
                  alignment: Alignment.topLeft,
                  child: RepaintBoundary(
                    key: const ValueKey('capture'),
                    child: ColoredBox(
                      color: hostColor,
                      child: SizedBox(
                        width: 402,
                        height: 300,
                        child: AdaptiveStyleScope(
                          override: style,
                          child: AdaptiveListSection(
                            header: const Text('Language'),
                            children: [
                              AdaptiveListTile(
                                key: const ValueKey('first'),
                                title: const Text('Language'),
                                subtitle: const Text('Follow System (English)'),
                                onTap: () {},
                              ),
                              AdaptiveListTile(
                                key: const ValueKey('last'),
                                title: const Text('System Language Settings'),
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final first = tester.getRect(find.byKey(const ValueKey('first')));
          final last = tester.getRect(find.byKey(const ValueKey('last')));
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('capture')),
          );
          final image = await tester.runAsync(
            () => boundary.toImage(pixelRatio: 1),
          );
          final pixels = await tester.runAsync(() => image!.toByteData());
          Color pixel(double x, double y) {
            final offset = (y.floor() * image!.width + x.floor()) * 4;
            return Color.fromARGB(
              pixels!.getUint8(offset + 3),
              pixels.getUint8(offset),
              pixels.getUint8(offset + 1),
              pixels.getUint8(offset + 2),
            );
          }

          expect(pixel(5, first.center.dy), hostColor);
          expect(pixel(200, 8), hostColor);
          expect(pixel(first.left + 1, first.top + 1), hostColor);
          expect(pixel(last.right - 2, last.bottom - 2), hostColor);
          expect(
            pixel(first.left + 30, first.top + 5),
            style == AdaptiveStyle.material
                ? scheme.surfaceContainerHigh
                : scheme.surfaceContainer,
          );
          if (style == AdaptiveStyle.material) {
            expect(last.top - first.bottom, 2);
            expect(pixel(first.center.dx, first.bottom + 1), hostColor);
          } else {
            expect(
              last.top - first.bottom,
              closeTo(1 / tester.view.devicePixelRatio, .01),
            );
            expect(find.byType(BackdropFilter), findsNothing);
            expect(first.height, greaterThan(53));
            expect(last.height, greaterThanOrEqualTo(53));
          }
          image!.dispose();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'segmented position, press, focus and disabled rebuilds stay safe',
    (tester) async {
      var enabled = true;
      var taps = 0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return AdaptiveListSection.material(
                  children: [
                    AdaptiveListTile(
                      key: const ValueKey('first'),
                      title: const Text('First'),
                      onTap: enabled ? () => taps++ : null,
                    ),
                    const AdaptiveListTile(title: Text('Last')),
                  ],
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      RoundedRectangleBorder shape() =>
          tester
                  .widget<Material>(
                    find
                        .ancestor(
                          of: find.byKey(const ValueKey('first')),
                          matching: find.byWidgetPredicate(
                            (widget) =>
                                widget is Material &&
                                widget.shape is RoundedRectangleBorder,
                          ),
                        )
                        .first,
                  )
                  .shape!
              as RoundedRectangleBorder;
      expect(
        shape().borderRadius,
        const BorderRadius.vertical(
          top: Radius.circular(16),
          bottom: Radius.circular(4),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('First')),
      );
      await tester.pumpAndSettle();
      expect(
        shape().borderRadius,
        const BorderRadius.vertical(
          top: Radius.circular(16),
          bottom: Radius.circular(4),
        ),
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(taps, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        shape().borderRadius,
        const BorderRadius.vertical(
          top: Radius.circular(16),
          bottom: Radius.circular(4),
        ),
      );
      update(() => enabled = false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('First'));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  for (final style in AdaptiveStyle.values) {
    testWidgets('$style custom row keeps independent trailing interaction', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveStyleScope(
              override: style,
              child: AdaptiveListSection(
                children: [
                  AdaptiveListTile(
                    title: const Text('Setting'),
                    trailing: style == AdaptiveStyle.apple
                        ? CupertinoButton(
                            onPressed: () => taps++,
                            child: const Text('Change'),
                          )
                        : TextButton(
                            onPressed: () => taps++,
                            child: const Text('Change'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Setting'));
      expect(taps, 0);
      await tester.tap(find.text('Change'));
      await tester.pump();
      expect(taps, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(taps, 2);
      expect(tester.takeException(), isNull);
    });
  }
  for (final style in AdaptiveStyle.values) {
    testWidgets('$style keyed rows survive regrouping without duplicate keys', (
      tester,
    ) async {
      final rowKey = GlobalKey();
      var reverse = false;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                final rows = [
                  AdaptiveListTile(
                    key: rowKey,
                    title: const Text('Keyed'),
                    onTap: () {},
                  ),
                  const AdaptiveListTile(title: Text('Other')),
                ];
                return AdaptiveStyleScope(
                  override: style,
                  child: AdaptiveListSection(
                    children: reverse ? rows.reversed.toList() : rows,
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final original = rowKey.currentContext;
      update(() => reverse = true);
      await tester.pumpAndSettle();
      expect(rowKey.currentContext, same(original));
      expect(
        tester.getTopLeft(find.text('Keyed')).dy,
        greaterThan(tester.getTopLeft(find.text('Other')).dy),
      );
      expect(tester.takeException(), isNull);
    });
  }
}

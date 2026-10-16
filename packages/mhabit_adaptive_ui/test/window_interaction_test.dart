import 'dart:ui' show PointerDeviceKind;

import 'package:adaptive_actions/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

// Represents the app's native passthrough registration without opening channels.
class _NativeTarget extends StatelessWidget {
  const _NativeTarget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (_, _) => SizedBox(child: child));
}

Widget _host(Widget child, TextDirection direction) => MaterialApp(
  theme: ThemeData(platform: TargetPlatform.macOS),
  builder: (_, child) => Directionality(
    textDirection: direction,
    child: AdaptiveWindowInteractionBinding(
      wrapper: (child) => _NativeTarget(child: child),
      child: child!,
    ),
  ),
  home: child,
);

Finder _nativeAncestors(Finder target) =>
    find.ancestor(of: target, matching: find.byType(_NativeTarget));

void main() {
  for (final direction in TextDirection.values) {
    for (final width in [350.0, 1200.0]) {
      testWidgets(
        'search controls forward native input at $width in $direction',
        (tester) async {
          tester.view.physicalSize = Size(width, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final controller = TextEditingController();
          final focus = FocusNode();
          addTearDown(controller.dispose);
          addTearDown(focus.dispose);
          var leadingTaps = 0;
          final invoked = <String>[];
          await tester.pumpWidget(
            _host(
              CustomScrollView(
                slivers: [
                  CupertinoSliverSearchBar<String>(
                    title: const Text('Habits'),
                    leading: CupertinoButton(
                      key: const ValueKey('leading'),
                      padding: EdgeInsets.zero,
                      onPressed: () => leadingTaps++,
                      child: const Icon(CupertinoIcons.back),
                    ),
                    collection: ActionCollection<String>(
                      roots: [
                        AdaptiveAction<String>.action(
                          id: ActionId('select'),
                          metadata: const ActionMetadata(label: 'Select'),
                          payload: 'select',
                        ),
                      ],
                    ),
                    actions: CupertinoAppBarActionsConfig<String>(
                      iconBuilder: (_, _) => const Icon(
                        CupertinoIcons.checkmark,
                        key: ValueKey('select-action'),
                      ),
                    ),
                    onInvoke: (_, value) => invoked.add(value),
                    controller: controller,
                    focusNode: focus,
                    isSearchActive: false,
                    keyword: '',
                    onChanged: (_) {},
                    onSearchActivated: () {},
                    onSearchDismissed: () {},
                  ),
                ],
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
          final leading = find.byKey(const ValueKey('leading'));
          final action = find.byKey(const ValueKey('select-action'));
          expect(_nativeAncestors(leading), findsOneWidget);
          expect(_nativeAncestors(action), findsOneWidget);
          // Only the actual action consumes drag space, not its available budget.
          expect(
            tester.getSize(_nativeAncestors(action)).width,
            lessThanOrEqualTo(44),
          );
          await tester.tap(leading);
          await tester.tap(action);
          await tester.pumpAndSettle();
          expect(leadingTaps, 1);
          expect(invoked, ['select']);

          final activate = find.byKey(
            const ValueKey('activate-cupertino-search'),
          );
          if (activate.evaluate().isNotEmpty) {
            expect(_nativeAncestors(activate), findsOneWidget);
            await tester.tap(activate);
            await tester.pumpAndSettle();
          }
          final input = find.byType(CupertinoSearchTextField);
          expect(_nativeAncestors(input), findsOneWidget);
          await tester.enterText(input, 'retained search');
          expect(controller.text, 'retained search');
          expect(tester.takeException(), isNull);
        },
      );
    }

    for (final style in AppleSidebarStyle.values) {
      testWidgets('collapsed $style bar forwards mouse drag in $direction', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(900, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        var selected = 0;
        final selectedIndices = <int>[];
        await tester.pumpWidget(
          _host(
            StatefulBuilder(
              builder: (_, setState) => AdaptiveNavigationShell(
                selectedIndex: selected,
                destinations: [
                  for (final label in ['Habits', 'Today', 'Settings'])
                    AdaptiveNavigationDestination(
                      label: label,
                      icons: const NavigationDestinationIcons(
                        material: Icon(Icons.home),
                        materialSelected: Icon(Icons.home),
                        apple: Icon(CupertinoIcons.home),
                        appleSelected: Icon(CupertinoIcons.home),
                      ),
                    ),
                ],
                onDestinationSelected: (index) {
                  selectedIndices.add(index);
                  setState(() => selected = index);
                },
                appleSidebarStyle: style,
                child: const Scaffold(
                  appBar: AdaptiveAppBar.apple(title: Text('Page title')),
                  body: Text('Content'),
                ),
              ),
            ),
            direction,
          ),
        );
        await tester.pumpAndSettle();
        final bar = find.byKey(
          const ValueKey('cupertino-sidebar-collapsed-bar'),
        );
        final native = _nativeAncestors(bar);
        expect(native, findsOneWidget);
        expect(tester.getRect(native), tester.getRect(bar));
        Finder destination(int index) => find.byKey(
          ValueKey('cupertino-sidebar-collapsed-destination-$index'),
        );
        final start = tester.getCenter(destination(0));
        final end = tester.getCenter(destination(1));
        final gesture = await tester.startGesture(
          start,
          kind: PointerDeviceKind.mouse,
        );
        await gesture.moveTo(Offset.lerp(start, end, 0.5)!);
        await tester.pump();
        await gesture.moveTo(end);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(selectedIndices, [1]);
        expect(selected, 1);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

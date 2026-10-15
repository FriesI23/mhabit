import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/entries/common/app_root_view.dart';
import 'package:mhabit/extensions/desktop_window_chrome_extensions.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:provider/provider.dart';

import '../../support/adaptive_ui_theme.dart';
import '../../support/desktop_window_chrome_fakes.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final edges in ['left', 'right', 'both']) {
      for (final initialDirection in TextDirection.values) {
        for (final size in const [
          Size(350, 520),
          Size(700, 600),
          Size(1100, 700),
        ]) {
          testWidgets(
            '$style $edges $initialDirection $size ownership survives live direction change',
            (tester) async {
              tester.view.physicalSize = size;
              tester.view.devicePixelRatio = 1;
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              final api = FakeDesktopWindowChromeApi()
                ..snapshot = snapshotGeometry(
                  width: size.width,
                  height: size.height,
                  right: edges == 'right',
                );
              if (edges == 'both') {
                final right = snapshotGeometry(width: size.width, right: true);
                api.snapshot = snapshotGeometry(
                  width: size.width,
                  height: size.height,
                  buttons: [
                    ...api.snapshot.buttons.take(2),
                    right.buttons.last,
                  ],
                );
              }
              final chrome = DesktopWindowChrome(api: api);
              addTearDown(chrome.dispose);
              await chrome.initialize();
              final direction = ValueNotifier(initialDirection);
              final controller = TextEditingController();
              final focus = FocusNode();
              addTearDown(direction.dispose);
              addTearDown(controller.dispose);
              addTearDown(focus.dispose);
              var clicked = 0;
              final leading = IconButton(
                key: const ValueKey('business-leading'),
                onPressed: () => clicked++,
                icon: const Icon(Icons.arrow_back),
              );
              final actions = [
                IconButton(
                  key: const ValueKey('business-action'),
                  onPressed: () => clicked++,
                  icon: const Icon(Icons.more_vert),
                ),
              ];
              final page = AdaptiveNavigationShell(
                selectedIndex: 0,
                destinations: const [
                  AdaptiveNavigationDestination(
                    label: 'Habits',
                    icons: NavigationDestinationIcons(
                      material: Icon(Icons.home),
                      materialSelected: Icon(Icons.home),
                      apple: Icon(Icons.home),
                      appleSelected: Icon(Icons.home),
                    ),
                  ),
                  AdaptiveNavigationDestination(
                    label: 'Today',
                    icons: NavigationDestinationIcons(
                      material: Icon(Icons.home),
                      materialSelected: Icon(Icons.home),
                      apple: Icon(Icons.home),
                      appleSelected: Icon(Icons.home),
                    ),
                  ),
                ],
                onDestinationSelected: (_) {},
                child: Scaffold(
                  appBar: style == AdaptiveStyle.material
                      ? AdaptiveAppBar.material(
                          title: const Text('Chrome'),
                          toolbarHeight: 56,
                          leading: leading,
                          actions: actions,
                        )
                      : AdaptiveAppBar.apple(
                          title: const Text('Chrome'),
                          leading: leading,
                          actions: actions,
                        ),
                  body: TextField(
                    key: const ValueKey('stateful-search'),
                    controller: controller,
                    focusNode: focus,
                  ),
                ),
              );
              await tester.pumpWidget(
                ChangeNotifierProvider.value(
                  value: chrome,
                  child: TestAdaptiveUiTheme(
                    update: (parentTheme) => parentTheme.copyWith(style: style),
                    child: ValueListenableBuilder<TextDirection>(
                      valueListenable: direction,
                      child: page,
                      builder: (_, value, child) => AppRootView.withDefault(
                        textDirectionOverride: value,
                        lightThemeBuilder: (_) =>
                            ThemeData(platform: TargetPlatform.macOS),
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              final navigator = tester.state<NavigatorState>(
                find.byType(Navigator).first,
              );
              await tester.enterText(
                find.byKey(const ValueKey('stateful-search')),
                'keep search',
              );
              for (final value in [
                initialDirection,
                initialDirection == TextDirection.ltr
                    ? TextDirection.rtl
                    : TextDirection.ltr,
              ]) {
                direction.value = value;
                await tester.pumpAndSettle();
                final context = tester.element(
                  find.byKey(const ValueKey('stateful-search')),
                );
                final scope = AdaptiveWindowControlLayoutScope.maybeOf(
                  context,
                )!;
                final app = scope.appBarHorizontalAvoidanceFor(value);
                final side = scope.sideNavigationHorizontalAvoidanceFor(value);
                expect(
                  app.left + side.left,
                  chrome.adaptiveLayout.horizontalAvoidance.left,
                );
                expect(
                  app.right + side.right,
                  chrome.adaptiveLayout.horizontalAvoidance.right,
                );
                expect(app.left == 0 || side.left == 0, isTrue);
                expect(app.right == 0 || side.right == 0, isTrue);
                expect(
                  tester.state<NavigatorState>(find.byType(Navigator).first),
                  same(navigator),
                );
                expect(controller.text, 'keep search');
                expect(focus.hasFocus, isTrue);
                expect(tester.getTopLeft(find.byType(Scaffold).last).dy, 0);
                expect(api.configurations, [true]);
                for (final key in ['business-leading', 'business-action']) {
                  final target = find.byKey(ValueKey(key));
                  final rect = tester.getRect(target);
                  expect(
                    rect.left,
                    greaterThanOrEqualTo(
                      chrome.adaptiveLayout.horizontalAvoidance.left,
                    ),
                  );
                  expect(
                    rect.right,
                    lessThanOrEqualTo(
                      size.width -
                          chrome.adaptiveLayout.horizontalAvoidance.right,
                    ),
                  );
                  await tester.tap(target);
                }
                focus.requestFocus();
                await tester.pump();
              }
              expect(clicked, 4);
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_adaptive_ui/src/shell/navigation_sidebar_app_bar_leading.dart';

Widget _host({
  required TargetPlatform platform,
  required Widget appBar,
  Brightness brightness = Brightness.light,
  Widget Function(Widget child)? wrap,
}) {
  Widget child = Scaffold(
    body: CustomScrollView(
      slivers: [
        appBar,
        const SliverToBoxAdapter(child: SizedBox(height: 1200)),
      ],
    ),
  );
  if (wrap != null) child = wrap(child);
  return MaterialApp(
    theme: ThemeData(platform: platform, brightness: brightness),
    home: child,
  );
}

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController(text: 'Habit'));
  tearDown(() => controller.dispose());

  AdaptiveEditableSliverAppBar buildBar({
    AdaptiveStyle? forcedStyle,
    bool isCollapsed = false,
    ValueChanged<String>? onChanged,
    EditableAppBarStyles? styles,
    List<Widget> actions = const [SizedBox(key: ValueKey('editable-action'))],
  }) {
    final arguments = (
      title: 'Habit',
      controller: controller,
      isCollapsed: isCollapsed,
      onChanged: onChanged,
      hintText: 'Habit name',
      foregroundColor: const Color(0xFF123456),
      leading: const SizedBox(key: ValueKey('editable-leading')),
      actions: actions,
      styles: styles,
    );
    return switch (forcedStyle) {
      null => AdaptiveEditableSliverAppBar(
        title: arguments.title,
        controller: arguments.controller,
        isCollapsed: arguments.isCollapsed,
        onChanged: arguments.onChanged,
        hintText: arguments.hintText,
        foregroundColor: arguments.foregroundColor,
        leading: arguments.leading,
        actions: arguments.actions,
        styles: arguments.styles,
      ),
      AdaptiveStyle.material => AdaptiveEditableSliverAppBar.material(
        title: arguments.title,
        controller: arguments.controller,
        isCollapsed: arguments.isCollapsed,
        onChanged: arguments.onChanged,
        hintText: arguments.hintText,
        foregroundColor: arguments.foregroundColor,
        leading: arguments.leading,
        actions: arguments.actions,
        styles: arguments.styles,
      ),
      AdaptiveStyle.apple => AdaptiveEditableSliverAppBar.apple(
        title: arguments.title,
        controller: arguments.controller,
        isCollapsed: arguments.isCollapsed,
        onChanged: arguments.onChanged,
        hintText: arguments.hintText,
        foregroundColor: arguments.foregroundColor,
        leading: arguments.leading,
        actions: arguments.actions,
        styles: arguments.styles,
      ),
    };
  }

  testWidgets('default Material dispatch preserves editable large behavior', (
    tester,
  ) async {
    var changed = '';
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.android,
        appBar: buildBar(
          onChanged: (value) => changed = value,
          styles: const EditableAppBarStyles(
            material: MaterialEditableAppBarStyle(
              scrolledUnderElevation: 3,
              shadowColor: Colors.black,
            ),
          ),
        ),
      ),
    );

    final wrapper = tester.widget<WindowControlSliverAppBar>(
      find.byType(WindowControlSliverAppBar),
    );
    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(wrapper.pinned, isTrue);
    expect(wrapper.flexibleSpace, isNotNull);
    expect(wrapper.scrolledUnderElevation, 3);
    expect(wrapper.shadowColor, Colors.black);
    expect(appBar.foregroundColor, const Color(0xFF123456));
    expect(field.enabled, isTrue);
    expect(field.controller, same(controller));
    expect(field.decoration?.hintText, 'Habit name');
    expect(find.byKey(const ValueKey('editable-leading')), findsOneWidget);
    expect(find.byKey(const ValueKey('editable-action')), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Updated');
    expect(changed, 'Updated');
  });

  testWidgets('Material collapsed state disables the flexible-space editor', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.android,
        appBar: buildBar(isCollapsed: true),
      ),
    );

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets('Apple dispatch uses fixed toolbar and inset Cupertino field', (
    tester,
  ) async {
    var changed = '';
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        appBar: buildBar(onChanged: (value) => changed = value),
      ),
    );

    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
    expect(find.byType(WindowControlSliverAppBar), findsNothing);
    expect(tester.getSize(find.byType(CupertinoNavigationBar)).height, 44);
    final field = tester.widget<CupertinoTextField>(
      find.byKey(const ValueKey('editable-app-bar-apple-field')),
    );
    expect(field.controller, same(controller));
    expect(field.clearButtonMode, OverlayVisibilityMode.editing);
    expect(
      field.padding,
      const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: 12),
    );
    expect(field.decoration?.borderRadius, BorderRadius.circular(10));
    expect(find.byType(DecoratedSliver), findsNothing);
    expect(
      (field.decoration as BoxDecoration).color,
      CupertinoColors.tertiarySystemFill,
    );
    expect(
      find.byKey(const ValueKey('editable-app-bar-apple-title-placeholder')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ExcludeSemantics>(
            find.ancestor(
              of: find.byKey(
                const ValueKey('editable-app-bar-apple-title-placeholder'),
              ),
              matching: find.byType(ExcludeSemantics),
            ),
          )
          .excluding,
      isTrue,
    );
    expect(
      find.byKey(const ValueKey('editable-app-bar-apple-title')),
      findsNothing,
    );
    final sectionPadding = tester.widget<SliverPadding>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SliverPadding &&
            widget.padding ==
                const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
      ),
    );
    expect(
      sectionPadding.padding,
      const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
    );

    await tester.enterText(find.byType(CupertinoTextField), 'Updated');
    expect(changed, 'Updated');
  });

  testWidgets('Apple collapsed state shows the navigation title', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(platform: TargetPlatform.iOS, appBar: buildBar(isCollapsed: true)),
    );

    expect(
      find.byKey(const ValueKey('editable-app-bar-apple-title')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('editable-app-bar-apple-title')),
          )
          .style
          ?.color,
      const Color(0xFF123456),
    );
    expect(
      find.byKey(const ValueKey('editable-app-bar-apple-title-placeholder')),
      findsNothing,
    );
    expect(
      tester
          .widget<CupertinoTextField>(find.byType(CupertinoTextField))
          .enabled,
      isTrue,
    );
  });

  testWidgets('Apple dark field uses a translucent system fill', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        brightness: Brightness.dark,
        appBar: buildBar(forcedStyle: AdaptiveStyle.apple),
        wrap: (child) => MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: child,
        ),
      ),
    );

    final field = tester.widget<CupertinoTextField>(
      find.byKey(const ValueKey('editable-app-bar-apple-field')),
    );
    final resolvedFieldColor = CupertinoDynamicColor.resolve(
      (field.decoration as BoxDecoration).color!,
      tester.element(
        find.byKey(const ValueKey('editable-app-bar-apple-field')),
      ),
    );
    expect(
      resolvedFieldColor.toARGB32(),
      const Color.fromARGB(61, 118, 118, 128).toARGB32(),
    );
    expect(find.byType(DecoratedSliver), findsNothing);
  });

  testWidgets('Apple permits an explicit field-section background', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        appBar: buildBar(
          forcedStyle: AdaptiveStyle.apple,
          styles: const EditableAppBarStyles(
            apple: AppleEditableAppBarStyle(
              sectionBackgroundColor: Color(0xFF123456),
            ),
          ),
        ),
      ),
    );

    expect(
      (tester.widget<DecoratedSliver>(find.byType(DecoratedSliver)).decoration
              as BoxDecoration)
          .color,
      const Color(0xFF123456),
    );
  });

  testWidgets('named constructors override the host platform', (tester) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.android,
        appBar: buildBar(forcedStyle: AdaptiveStyle.apple),
      ),
    );
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);

    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        appBar: buildBar(forcedStyle: AdaptiveStyle.material),
      ),
    );
    expect(find.byType(SliverAppBar), findsOneWidget);
  });

  testWidgets('foreground color themes actions on both renderers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.android,
        appBar: buildBar(
          actions: [TextButton(onPressed: () {}, child: const Text('Action'))],
        ),
      ),
    );
    final materialContext = tester.element(find.byType(TextButton));
    expect(
      Theme.of(
        materialContext,
      ).textButtonTheme.style?.foregroundColor?.resolve(<WidgetState>{}),
      const Color(0xFF123456),
    );

    await tester.pumpWidget(
      _host(
        platform: TargetPlatform.iOS,
        appBar: buildBar(
          forcedStyle: AdaptiveStyle.apple,
          actions: [
            CupertinoButton(
              key: const ValueKey('themed-apple-action'),
              onPressed: () {},
              child: const Text('Action'),
            ),
          ],
        ),
      ),
    );
    final appleContext = tester.element(
      find.byKey(const ValueKey('themed-apple-action')),
    );
    expect(
      CupertinoTheme.of(appleContext).primaryColor,
      const Color(0xFF123456),
    );
  });

  testWidgets('renderers tolerate RTL and 3x text scaling', (tester) async {
    Widget wrap(Widget child) => MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(3)),
      child: Directionality(textDirection: TextDirection.rtl, child: child),
    );

    await tester.pumpWidget(
      _host(platform: TargetPlatform.android, appBar: buildBar(), wrap: wrap),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _host(platform: TargetPlatform.iOS, appBar: buildBar(), wrap: wrap),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Apple keeps avoidance, Sidebar composition, and pinned toolbar',
    (tester) async {
      await tester.pumpWidget(
        _host(
          platform: TargetPlatform.iOS,
          appBar: buildBar(),
          wrap: (child) => AdaptiveWindowControlLayoutScope(
            horizontalAvoidance: const EdgeInsets.only(left: 40, right: 12),
            verticalAvoidance: EdgeInsets.zero,
            owner: WindowControlLayoutOwner.appBar,
            child: NavigationSidebarAppBarLeading(
              toolbarAvoidance: const EdgeInsets.only(left: 40),
              toolbarTopInset: 0,
              progress: 1,
              child: child,
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('cupertino-sidebar-leading-anchor')),
        findsOneWidget,
      );
      final toolbar = tester
          .widgetList<NavigationToolbar>(find.byType(NavigationToolbar))
          .singleWhere((widget) => widget.leading is Padding);
      expect(
        (toolbar.leading! as Padding).padding,
        const EdgeInsetsDirectional.only(start: 56),
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byType(CupertinoNavigationBar)).dy, 0);
    },
  );

  test('style configs support copyWith and value equality', () {
    const material = MaterialEditableAppBarStyle();
    const apple = AppleEditableAppBarStyle();
    final styles = const EditableAppBarStyles(material: material, apple: apple)
        .copyWith(
          material: material.copyWith(scrolledUnderElevation: 2),
          apple: apple.copyWith(toolbarHeight: 52),
        );

    expect(
      styles.material,
      const MaterialEditableAppBarStyle(scrolledUnderElevation: 2),
    );
    expect(styles.apple, const AppleEditableAppBarStyle(toolbarHeight: 52));
  });
}

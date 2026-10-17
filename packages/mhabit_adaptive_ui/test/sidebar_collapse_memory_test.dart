import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart'
    show CupertinoSidebar, MaterialSidebar, SidebarPrimarySelection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

const _destinations = [
  AdaptiveNavigationDestination(
    label: 'Habits',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.home_outlined),
      materialSelected: Icon(Icons.home),
      apple: Icon(Icons.home_outlined),
      appleSelected: Icon(Icons.home),
    ),
  ),
  AdaptiveNavigationDestination(
    label: 'Today',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.calendar_today_outlined),
      materialSelected: Icon(Icons.calendar_today),
      apple: Icon(Icons.calendar_today_outlined),
      appleSelected: Icon(Icons.calendar_today),
    ),
  ),
];

class _Harness extends ChangeNotifier {
  _Harness(this.style);

  AdaptiveStyle style;
  int selectedIndex = 0;
  Key shellKey = UniqueKey();

  void select(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void switchStyle(AdaptiveStyle value) {
    style = value;
    notifyListeners();
  }

  void replaceShell() {
    shellKey = UniqueKey();
    notifyListeners();
  }

  Widget build() => MaterialApp(
    home: ListenableBuilder(
      listenable: this,
      builder: (context, child) => AppAdaptiveUiTheme(
        data: AppAdaptiveUiTheme.of(context).copyWith(style: style),
        child: AdaptiveNavigationShell(
          key: shellKey,
          selectedIndex: selectedIndex,
          destinations: _destinations,
          onDestinationSelected: select,
          child: const AdaptiveScaffold(
            appBar: AdaptiveAppBar(
              title: Text('Sidebar memory'),
              toolbarHeight: kToolbarHeight,
            ),
            body: _BranchProbe(),
          ),
        ),
      ),
    ),
  );
}

class _BranchProbe extends StatefulWidget {
  const _BranchProbe();

  @override
  State<_BranchProbe> createState() => _BranchProbeState();
}

class _BranchProbeState extends State<_BranchProbe> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => setState(() => _count++),
      child: Text('branch count $_count'),
    ),
  );
}

Future<_Harness> _pumpShell(
  WidgetTester tester,
  AdaptiveStyle style, {
  Size size = const Size(1000, 600),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final harness = _Harness(style);
  addTearDown(harness.dispose);
  await tester.pumpWidget(harness.build());
  await tester.pumpAndSettle();
  return harness;
}

bool _expanded(WidgetTester tester, AdaptiveStyle style) => switch (style) {
  AdaptiveStyle.material =>
    tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
  AdaptiveStyle.apple =>
    find.byKey(const ValueKey('cupertino-sidebar-panel')).evaluate().isNotEmpty,
};

Future<void> _toggle(WidgetTester tester, AdaptiveStyle style) async {
  await tester.tap(switch (style) {
    AdaptiveStyle.material => find.byIcon(
      _expanded(tester, style) ? Icons.menu_open : Icons.menu,
    ),
    AdaptiveStyle.apple => find.byKey(
      const ValueKey('cupertino-sidebar-toggle'),
    ),
  });
  await tester.pumpAndSettle();
}

Future<void> _resize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  await tester.pumpAndSettle();
}

void main() {
  for (final style in AdaptiveStyle.values) {
    group('Sidebar collapse memory on $style', () {
      testWidgets('retains manual collapse across forms and navigation', (
        tester,
      ) async {
        await _pumpShell(tester, style);
        expect(_expanded(tester, style), isTrue);
        await _toggle(tester, style);

        for (final size in const [
          Size(700, 600),
          Size(1000, 600),
          Size(1200, 600),
        ]) {
          await _resize(tester, size);
          expect(_expanded(tester, style), isFalse);
        }

        await tester.tap(switch (style) {
          AdaptiveStyle.material => find.byIcon(Icons.calendar_today_outlined),
          AdaptiveStyle.apple => find.byKey(
            const ValueKey('cupertino-sidebar-collapsed-destination-1'),
          ),
        });
        await tester.pumpAndSettle();
        expect(_expanded(tester, style), isFalse);
        expect(
          AdaptiveNavScope.of(tester.element(find.byType(_BranchProbe))).form,
          NavigationShellForm.expandedSide,
        );

        for (final compact in const [Size(599, 600), Size(1000, 479)]) {
          await _resize(tester, compact);
          expect(
            style == AdaptiveStyle.material
                ? find.byType(NavigationBar)
                : find.byKey(
                    const ValueKey('cupertino-adaptive-navigation-bar'),
                  ),
            findsOneWidget,
          );
          await _resize(tester, const Size(1000, 600));
          expect(_expanded(tester, style), isFalse);
        }

        await _toggle(tester, style);
        expect(_expanded(tester, style), isTrue);
        await _resize(tester, const Size(700, 600));
        expect(_expanded(tester, style), isFalse);
        await _resize(tester, const Size(1000, 600));
        expect(_expanded(tester, style), isTrue);
      });

      testWidgets('does not retain manual expansion through compact', (
        tester,
      ) async {
        await _pumpShell(tester, style, size: const Size(700, 600));
        expect(_expanded(tester, style), isFalse);
        for (final compact in const [Size(599, 600), Size(700, 479)]) {
          await _toggle(tester, style);
          await _resize(tester, const Size(710, 610));
          expect(_expanded(tester, style), isTrue);
          await _resize(tester, compact);
          await _resize(tester, const Size(700, 600));
          expect(_expanded(tester, style), isFalse);
        }
        await _resize(tester, const Size(1000, 600));
        expect(_expanded(tester, style), isTrue);
      });

      testWidgets('starts a new shell without the old collapse memory', (
        tester,
      ) async {
        final harness = await _pumpShell(tester, style);
        await _toggle(tester, style);
        harness.replaceShell();
        await tester.pumpAndSettle();
        expect(_expanded(tester, style), isTrue);
      });

      testWidgets('ignores width and selection controller notifications', (
        tester,
      ) async {
        await _pumpShell(tester, style, size: const Size(700, 600));
        final controller = switch (style) {
          AdaptiveStyle.material =>
            tester
                .widget<MaterialSidebar>(find.byType(MaterialSidebar))
                .controller,
          AdaptiveStyle.apple =>
            tester
                .widget<CupertinoSidebar>(find.byType(CupertinoSidebar))
                .controller,
        };

        void notifyWithoutExpansion(int selectedIndex) {
          controller.select(SidebarPrimarySelection(selectedIndex));
          controller.beginResize(
            const SideNavigationExtent(200),
            windowWidth: 700,
          );
          controller.updateResize(
            10,
            const SideNavigationExtent(200),
            windowWidth: 700,
          );
          controller.endResize();
          controller.clearManualWidth();
        }

        // These notifications must not turn the medium default into a user
        // preference, or opening the window wider would leave it collapsed.
        notifyWithoutExpansion(1);
        await tester.pumpAndSettle();
        await _resize(tester, const Size(1000, 600));
        expect(_expanded(tester, style), isTrue);

        // They must also leave an existing explicit collapse intact.
        await _toggle(tester, style);
        notifyWithoutExpansion(0);
        await tester.pumpAndSettle();
        await _resize(tester, const Size(700, 600));
        await _resize(tester, const Size(1000, 600));
        expect(_expanded(tester, style), isFalse);
      });

      testWidgets('shares collapse memory through theme switches', (
        tester,
      ) async {
        final harness = await _pumpShell(tester, style);
        final other = style == AdaptiveStyle.material
            ? AdaptiveStyle.apple
            : AdaptiveStyle.material;
        await tester.tap(find.text('branch count 0'));
        await tester.pump();
        final branch = tester.state(find.byType(_BranchProbe));
        await _toggle(tester, style);

        harness.switchStyle(other);
        await tester.pumpAndSettle();
        expect(_expanded(tester, other), isFalse);
        expect(tester.state(find.byType(_BranchProbe)), same(branch));
        expect(find.text('branch count 1'), findsOneWidget);

        await _toggle(tester, other);
        harness.switchStyle(style);
        await tester.pumpAndSettle();
        expect(_expanded(tester, style), isTrue);
        await _resize(tester, const Size(700, 600));
        harness.switchStyle(other);
        await tester.pumpAndSettle();
        await _resize(tester, const Size(1000, 600));
        expect(_expanded(tester, other), isTrue);
      });
    });
  }
}

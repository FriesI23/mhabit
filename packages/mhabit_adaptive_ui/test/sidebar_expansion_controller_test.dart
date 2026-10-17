import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/src/shell/navigation_shell_form.dart';
import 'package:mhabit_adaptive_ui/src/shell/sidebar_collapse_memory.dart';
import 'package:mhabit_adaptive_ui/src/shell/sidebar_expansion_controller.dart';

void main() {
  test('standalone memory retains collapse but not expansion across forms', () {
    final sidebar = SidebarExpansionController();
    addTearDown(sidebar.dispose);
    sidebar.updateForm(NavigationShellForm.expandedSide);
    sidebar.expanded = false;
    for (final form in [
      NavigationShellForm.constrainedSide,
      NavigationShellForm.expandedSide,
      NavigationShellForm.compact,
      NavigationShellForm.expandedSide,
    ]) {
      sidebar.updateForm(form);
      expect(sidebar.expanded, isFalse);
    }

    sidebar.expanded = true;
    sidebar.updateForm(NavigationShellForm.constrainedSide);
    expect(sidebar.expanded, isFalse);
    sidebar.expanded = true;
    sidebar.updateForm(NavigationShellForm.constrainedSide);
    expect(sidebar.expanded, isTrue);
    sidebar.updateForm(NavigationShellForm.compact);
    sidebar.updateForm(NavigationShellForm.constrainedSide);
    expect(sidebar.expanded, isFalse);
    sidebar.updateForm(NavigationShellForm.expandedSide);
    expect(sidebar.expanded, isTrue);
  });

  test('shared memory leaves renderer controllers and widths independent', () {
    final memory = SidebarCollapseMemory();
    final first = SidebarExpansionController();
    final second = SidebarExpansionController();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    first.updateForm(NavigationShellForm.expandedSide, collapseMemory: memory);
    first.beginResize(const SideNavigationExtent(200), windowWidth: 1800);
    first.updateResize(20, const SideNavigationExtent(200), windowWidth: 1800);
    first.endResize();
    first.expanded = false;

    second.updateForm(NavigationShellForm.expandedSide, collapseMemory: memory);
    expect(second.expanded, isFalse);
    expect(second, isNot(same(first)));
    expect(first.manualWidth, 220);
    expect(second.manualWidth, isNull);

    second.expanded = true;
    first.updateForm(
      NavigationShellForm.constrainedSide,
      collapseMemory: memory,
    );
    first.updateForm(NavigationShellForm.expandedSide, collapseMemory: memory);
    expect(first.expanded, isTrue);
    expect(first.manualWidth, 220);
  });

  test('preserves parent notifications through the base controller API', () {
    final sidebar = SidebarExpansionController();
    final baseline = AdaptiveNavigationController();
    addTearDown(sidebar.dispose);
    addTearDown(baseline.dispose);
    final actual = <List<Object?>>[];
    final expected = <List<Object?>>[];

    List<Object?> snapshot(AdaptiveNavigationController controller) => [
      controller.expanded,
      controller.selection,
      controller.resizing,
      controller.manualWidth,
    ];
    sidebar.addListener(() => actual.add(snapshot(sidebar)));
    baseline.addListener(() => expected.add(snapshot(baseline)));
    sidebar.updateForm(NavigationShellForm.constrainedSide);
    baseline.expanded = false;

    void exercise(AdaptiveNavigationController controller) {
      controller.select(const SidebarPrimarySelection(1));
      controller.beginResize(const SideNavigationExtent(200), windowWidth: 700);
      controller.updateResize(
        10,
        const SideNavigationExtent(200),
        windowWidth: 700,
      );
      controller.endResize();
      controller.clearManualWidth();
    }

    exercise(sidebar);
    exercise(baseline);
    sidebar.updateForm(NavigationShellForm.expandedSide);
    baseline.expanded = true;
    expect(sidebar.expanded, isTrue);
    sidebar.expanded = false;
    baseline.expanded = false;
    sidebar.expanded = false;
    baseline.expanded = false;
    sidebar.toggleExpanded();
    baseline.toggleExpanded();
    sidebar.updateForm(NavigationShellForm.constrainedSide);
    baseline.expanded = false;
    expect(actual, expected);
    expect(actual, hasLength(10));
  });

  test(
    'replacing shared memory preserves a standalone renderer preference',
    () {
      final sidebar = SidebarExpansionController();
      addTearDown(sidebar.dispose);
      sidebar.updateForm(NavigationShellForm.expandedSide);
      sidebar.expanded = false;

      sidebar.updateForm(
        NavigationShellForm.expandedSide,
        collapseMemory: SidebarCollapseMemory(),
      );
      expect(sidebar.expanded, isTrue);

      sidebar.updateForm(NavigationShellForm.expandedSide);
      expect(sidebar.expanded, isFalse);
    },
  );
}

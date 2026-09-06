import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/src/breakpoints/window_size_class.dart';
import 'package:mhabit_adaptive_ui/src/material/material_sliver_search_bar_layout.dart';

MaterialSliverSearchBarLayout _calculate({
  required WindowSizeClass widthClass,
  required double availableWidth,
  bool isSearchActive = false,
  bool hasLeading = true,
  double maxSearchWidth = 312,
  double preferredActionCapacity = 192,
}) => MaterialSliverSearchBarLayoutCalculator(
  widthClass: widthClass,
  availableWidth: availableWidth,
  isSearchActive: isSearchActive,
  hasLeading: hasLeading,
  maxSearchWidth: maxSearchWidth,
  preferredActionCapacity: preferredActionCapacity,
).calculate();

void main() {
  test('compact inactive search uses collapsed reserve and whole slots', () {
    final layout = _calculate(
      widthClass: WindowSizeClass.compact,
      availableWidth: 390,
    );

    expect(layout.isWide, isFalse);
    expect(layout.showWideTitle, isFalse);
    expect(layout.actionCapacity, 192);
  });

  test('compact active search keeps one More slot at narrow widths', () {
    final layout = _calculate(
      widthClass: WindowSizeClass.compact,
      availableWidth: 390,
      isSearchActive: true,
    );

    expect(layout.actionCapacity, 48);
  });

  test('medium layout keeps title below the trailing-width threshold', () {
    final layout = _calculate(
      widthClass: WindowSizeClass.medium,
      availableWidth: 800,
      preferredActionCapacity: 144,
    );

    expect(layout.isWide, isTrue);
    expect(layout.showWideTitle, isTrue);
    expect(layout.actionCapacity, 144);
  });

  test('medium layout hides title at the trailing-width threshold', () {
    final layout = _calculate(
      widthClass: WindowSizeClass.medium,
      availableWidth: 600,
      maxSearchWidth: 276,
      preferredActionCapacity: 144,
    );

    expect(layout.showWideTitle, isFalse);
    expect(layout.actionCapacity, 144);
  });

  test('capacity follows the sliver width inside a side panel', () {
    final layout = _calculate(
      widthClass: WindowSizeClass.medium,
      availableWidth: 525,
      isSearchActive: true,
    );

    expect(layout.showWideTitle, isFalse);
    expect(layout.actionCapacity, 96);
  });

  test('expanded layout always exposes its title', () {
    final layout = _calculate(
      widthClass: WindowSizeClass.expanded,
      availableWidth: 500,
    );

    expect(layout.showWideTitle, isTrue);
    expect(layout.actionCapacity, 48);
  });

  test('zero preferred action capacity does not reserve a More slot', () {
    final layout = _calculate(
      widthClass: WindowSizeClass.compact,
      availableWidth: 390,
      isSearchActive: true,
      preferredActionCapacity: 0,
    );

    expect(layout.actionCapacity, 0);
  });
}

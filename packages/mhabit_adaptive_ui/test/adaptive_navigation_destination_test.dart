import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  test('union navigation icons share one widget', () {
    const icon = IconData(0xe000);
    const widget = Icon(icon);
    const icons = NavigationDestinationIcons.union(widget);

    expect(identical(icons.material, widget), isTrue);
    expect(identical(icons.materialSelected, widget), isTrue);
    expect(identical(icons.apple, widget), isTrue);
    expect(identical(icons.appleSelected, widget), isTrue);
  });
}

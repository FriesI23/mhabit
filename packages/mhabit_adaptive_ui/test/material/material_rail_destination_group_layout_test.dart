import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/src/material/material_rail_destination_group_layout.dart';

const _layoutKey = ValueKey('layout');
const _childKey = ValueKey('child');

Widget _host({
  required double height,
  double minimumGap = 8,
  double maximumGap = 40,
}) => MaterialApp(
  home: Center(
    child: SizedBox(
      width: 100,
      height: height,
      child: MaterialRailDestinationGroupLayout(
        key: _layoutKey,
        minimumGap: minimumGap,
        maximumGap: maximumGap,
        child: const SizedBox(key: _childKey, width: 40, height: 100),
      ),
    ),
  ),
);

double _gap(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(_childKey)).dy -
    tester.getTopLeft(find.byKey(_layoutKey)).dy;

void main() {
  testWidgets('uses the maximum gap when height is available', (tester) async {
    await tester.pumpWidget(_host(height: 200));

    expect(_gap(tester), 40);
    expect(
      tester.getCenter(find.byKey(_childKey)).dx,
      tester.getCenter(find.byKey(_layoutKey)).dx,
    );
  });

  testWidgets('shrinks the gap between its maximum and minimum', (
    tester,
  ) async {
    await tester.pumpWidget(_host(height: 125));

    expect(_gap(tester), 25);
  });

  testWidgets('reports the minimum gap through intrinsic height', (
    tester,
  ) async {
    await tester.pumpWidget(_host(height: 108));

    final renderBox = tester.renderObject<RenderBox>(find.byKey(_layoutKey));
    expect(_gap(tester), 8);
    expect(renderBox.getMinIntrinsicHeight(100), 108);
    expect(renderBox.getMaxIntrinsicHeight(100), 108);
  });

  testWidgets('updates its gap constraints without replacing the render box', (
    tester,
  ) async {
    await tester.pumpWidget(_host(height: 200, minimumGap: 12, maximumGap: 24));
    final originalRenderObject = tester.renderObject(find.byKey(_layoutKey));
    expect(_gap(tester), 24);

    await tester.pumpWidget(_host(height: 200, minimumGap: 12, maximumGap: 16));

    expect(tester.renderObject(find.byKey(_layoutKey)), originalRenderObject);
    expect(_gap(tester), 16);
  });

  test('rejects invalid gaps', () {
    expect(
      () => MaterialRailDestinationGroupLayout(
        minimumGap: -1,
        maximumGap: 40,
        child: const SizedBox(),
      ),
      throwsAssertionError,
    );
    expect(
      () => MaterialRailDestinationGroupLayout(
        minimumGap: 8,
        maximumGap: 4,
        child: const SizedBox(),
      ),
      throwsAssertionError,
    );
  });
}

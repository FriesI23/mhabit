import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  const size = Size(900, 650);

  testWidgets('floating geometry respects each physical safe edge', (
    tester,
  ) async {
    late CupertinoFloatingSurfaceGeometry geometry;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: size,
          padding: EdgeInsets.only(left: 20, right: 90),
          viewPadding: EdgeInsets.only(left: 20, right: 90),
        ),
        child: Builder(
          builder: (context) {
            geometry = CupertinoFloatingSurfaceGeometry.resolveOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(geometry.horizontalPadding.left, greaterThanOrEqualTo(20));
    expect(geometry.horizontalPadding.right, greaterThanOrEqualTo(90));
  });

  for (final direction in TextDirection.values) {
    testWidgets('fixed toolbar clears asymmetric safe areas in $direction', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        CupertinoApp(
          home: Directionality(
            textDirection: direction,
            child: const MediaQuery(
              data: MediaQueryData(
                size: size,
                padding: EdgeInsets.only(left: 90, right: 30),
                viewPadding: EdgeInsets.only(left: 90, right: 30),
              ),
              child: CustomScrollView(
                slivers: [
                  AdaptiveSliverAppBar.apple(
                    height: 44,
                    title: Text('Habits'),
                    leading: SizedBox(key: ValueKey('leading'), width: 44),
                    actions: [SizedBox(key: ValueKey('action'), width: 44)],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      for (final key in ['leading', 'action']) {
        final bounds = tester.getRect(find.byKey(ValueKey(key)));
        expect(bounds.left, greaterThanOrEqualTo(90));
        expect(bounds.right, lessThanOrEqualTo(870));
      }
      expect(tester.takeException(), isNull);
    });
  }
}

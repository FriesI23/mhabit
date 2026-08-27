import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  Widget materialHost({
    required PreferredSizeWidget appBar,
    EdgeInsetsDirectional avoidance = EdgeInsetsDirectional.zero,
    WindowControlLayoutOwner owner = WindowControlLayoutOwner.appBar,
    TextDirection textDirection = TextDirection.ltr,
  }) => MaterialApp(
    home: Directionality(
      textDirection: textDirection,
      child: AdaptiveWindowControlLayoutScope(
        horizontalAvoidance: avoidance,
        verticalAvoidance: EdgeInsetsDirectional.zero,
        owner: owner,
        child: Scaffold(appBar: appBar),
      ),
    ),
  );

  testWidgets('Material moves slots while keeping title at window center', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      materialHost(
        avoidance: const EdgeInsetsDirectional.only(start: 40, end: 12),
        appBar: const WindowControlAppBar(
          centerTitle: true,
          title: SizedBox(
            key: ValueKey('title'),
            width: 80,
            child: Text('Title'),
          ),
          leading: SizedBox.expand(key: ValueKey('leading')),
          actions: [SizedBox(width: 48, key: ValueKey('action'))],
        ),
      ),
    );

    expect(tester.getCenter(find.byKey(const ValueKey('title'))).dx, 200);
    expect(tester.getTopLeft(find.byKey(const ValueKey('leading'))).dx, 52);
    expect(tester.getTopRight(find.byKey(const ValueKey('action'))).dx, 372);
  });

  testWidgets('zero avoidance matches stock Material toolbar geometry', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);

    Future<List<Rect>> pumpAndMeasure(PreferredSizeWidget appBar) async {
      await tester.pumpWidget(materialHost(appBar: appBar));
      return [
        tester.getRect(find.byKey(const ValueKey('leading'))),
        tester.getRect(find.byKey(const ValueKey('title'))),
        tester.getRect(find.byKey(const ValueKey('action'))),
      ];
    }

    const leading = SizedBox.expand(key: ValueKey('leading'));
    const title = SizedBox(
      key: ValueKey('title'),
      width: 80,
      child: Text('Title'),
    );
    const actions = [SizedBox(width: 48, key: ValueKey('action'))];
    final stockGeometry = await pumpAndMeasure(
      AppBar(
        centerTitle: true,
        leading: leading,
        title: title,
        actions: actions,
      ),
    );
    final wrappedGeometry = await pumpAndMeasure(
      const WindowControlAppBar(
        centerTitle: true,
        leading: leading,
        title: title,
        actions: actions,
      ),
    );

    expect(wrappedGeometry, stockGeometry);
  });

  testWidgets('Material explicit zero and rail owner disable avoidance', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);

    Future<double> leadingLeft({
      EdgeInsetsDirectional? explicitAvoidance,
      WindowControlLayoutOwner owner = WindowControlLayoutOwner.appBar,
    }) async {
      await tester.pumpWidget(
        materialHost(
          avoidance: const EdgeInsetsDirectional.only(start: 40),
          owner: owner,
          appBar: WindowControlAppBar(
            windowControlAvoidance: explicitAvoidance,
            leading: const SizedBox.expand(key: ValueKey('leading')),
          ),
        ),
      );
      return tester.getTopLeft(find.byKey(const ValueKey('leading'))).dx;
    }

    expect(await leadingLeft(explicitAvoidance: EdgeInsetsDirectional.zero), 0);
    expect(await leadingLeft(owner: WindowControlLayoutOwner.rail), 0);
  });

  testWidgets('Material edge padding is configurable and directional', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      materialHost(
        textDirection: TextDirection.rtl,
        avoidance: const EdgeInsetsDirectional.only(start: 20, end: 8),
        appBar: const WindowControlAppBar(
          windowControlEdgePadding: EdgeInsetsDirectional.only(
            start: 4,
            end: 6,
          ),
          leading: SizedBox.expand(key: ValueKey('leading')),
          actions: [SizedBox(width: 48, key: ValueKey('action'))],
        ),
      ),
    );

    expect(tester.getTopRight(find.byKey(const ValueKey('leading'))).dx, 376);
    expect(tester.getTopLeft(find.byKey(const ValueKey('action'))).dx, 14);
  });

  testWidgets('Cupertino keeps middle centered and pads controls internally', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const CupertinoApp(
        home: AdaptiveWindowControlLayoutScope(
          horizontalAvoidance: EdgeInsetsDirectional.only(start: 40, end: 12),
          verticalAvoidance: EdgeInsetsDirectional.zero,
          owner: WindowControlLayoutOwner.appBar,
          child: CupertinoPageScaffold(
            navigationBar: WindowControlCupertinoNavigationBar(
              automaticallyImplyLeading: false,
              middle: SizedBox(
                key: ValueKey('middle'),
                width: 80,
                child: Text('Title'),
              ),
              leading: SizedBox(width: 44, key: ValueKey('leading')),
              trailing: SizedBox(width: 44, key: ValueKey('trailing')),
            ),
            child: SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(tester.getCenter(find.byKey(const ValueKey('middle'))).dx, 200);
    expect(tester.getTopLeft(find.byKey(const ValueKey('leading'))).dx, 56);
    expect(tester.getTopRight(find.byKey(const ValueKey('trailing'))).dx, 372);
  });

  testWidgets('sliver large title uses internal toolbar avoidance', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdaptiveWindowControlLayoutScope(
          horizontalAvoidance: EdgeInsetsDirectional.only(start: 20),
          verticalAvoidance: EdgeInsetsDirectional.zero,
          owner: WindowControlLayoutOwner.appBar,
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                WindowControlSliverAppBar.large(
                  title: Text('Large'),
                  leading: SizedBox.expand(key: ValueKey('large-leading')),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(const ValueKey('large-leading'))).dx,
      32,
    );
  });

  testWidgets('safe-area geometry ignores unrelated scope updates', (
    tester,
  ) async {
    final layout = ValueNotifier((
      avoidance: EdgeInsetsDirectional.zero,
      horizontalAvoidance: const EdgeInsetsDirectional.only(start: 24, end: 18),
      verticalAvoidance: EdgeInsetsDirectional.zero,
      cornerRadii: const BorderRadius.all(Radius.circular(62)),
    ));
    final geometryBuilds =
        <
          ({
            EdgeInsetsDirectional horizontalAvoidance,
            EdgeInsetsDirectional verticalAvoidance,
            BorderRadius effectiveCornerRadii,
          })?
        >[];
    addTearDown(layout.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<
        ({
          EdgeInsetsDirectional avoidance,
          EdgeInsetsDirectional horizontalAvoidance,
          EdgeInsetsDirectional verticalAvoidance,
          BorderRadius cornerRadii,
        })
      >(
        valueListenable: layout,
        child: _SafeAreaGeometryProbe(onBuild: geometryBuilds.add),
        builder: (context, value, child) => AdaptiveWindowControlLayoutScope(
          horizontalAvoidance: value.avoidance,
          verticalAvoidance: EdgeInsetsDirectional.zero,
          horizontalSafeAreaAvoidance: value.horizontalAvoidance,
          verticalSafeAreaAvoidance: value.verticalAvoidance,
          effectiveCornerRadii: value.cornerRadii,
          owner: WindowControlLayoutOwner.appBar,
          child: child!,
        ),
      ),
    );
    expect(geometryBuilds, [
      (
        horizontalAvoidance: const EdgeInsetsDirectional.only(
          start: 24,
          end: 18,
        ),
        verticalAvoidance: EdgeInsetsDirectional.zero,
        effectiveCornerRadii: const BorderRadius.all(Radius.circular(62)),
      ),
    ]);

    layout.value = (
      avoidance: const EdgeInsetsDirectional.only(start: 40),
      horizontalAvoidance: layout.value.horizontalAvoidance,
      verticalAvoidance: layout.value.verticalAvoidance,
      cornerRadii: layout.value.cornerRadii,
    );
    await tester.pump();
    expect(geometryBuilds, hasLength(1));

    layout.value = (
      avoidance: layout.value.avoidance,
      horizontalAvoidance: layout.value.horizontalAvoidance,
      verticalAvoidance: const EdgeInsetsDirectional.only(bottom: 4),
      cornerRadii: layout.value.cornerRadii,
    );
    await tester.pump();
    expect(geometryBuilds, hasLength(2));

    layout.value = (
      avoidance: layout.value.avoidance,
      horizontalAvoidance: layout.value.horizontalAvoidance,
      verticalAvoidance: layout.value.verticalAvoidance,
      cornerRadii: const BorderRadius.all(Radius.circular(61)),
    );
    await tester.pump();
    expect(geometryBuilds, hasLength(3));
  });
}

class _SafeAreaGeometryProbe extends StatelessWidget {
  const _SafeAreaGeometryProbe({required this.onBuild});

  final ValueChanged<
    ({
      EdgeInsetsDirectional horizontalAvoidance,
      EdgeInsetsDirectional verticalAvoidance,
      BorderRadius effectiveCornerRadii,
    })?
  >
  onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild(AdaptiveWindowControlLayoutScope.safeAreaGeometryOf(context));
    return const SizedBox.shrink();
  }
}

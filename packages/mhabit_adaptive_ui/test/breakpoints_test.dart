import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

const material = MaterialBreakpoints();
const apple = AppleBreakpoints();

void main() {
  group('MaterialBreakpoints', () {
    test('classifies width into five classes', () {
      expect(material.widthClass(599), WindowSizeClass.compact);
      expect(material.widthClass(600), WindowSizeClass.medium);
      expect(material.widthClass(839), WindowSizeClass.medium);
      expect(material.widthClass(840), WindowSizeClass.expanded);
      expect(material.widthClass(1199), WindowSizeClass.expanded);
      expect(material.widthClass(1200), WindowSizeClass.large);
      expect(material.widthClass(1599), WindowSizeClass.large);
      expect(material.widthClass(1600), WindowSizeClass.extraLarge);
    });

    test('classifies height into three classes', () {
      expect(material.heightClass(479), WindowSizeClass.compact);
      expect(material.heightClass(480), WindowSizeClass.medium);
      expect(material.heightClass(899), WindowSizeClass.medium);
      expect(material.heightClass(900), WindowSizeClass.expanded);
    });
  });

  group('AppleBreakpoints', () {
    test('classifies width into compact, medium and large', () {
      expect(apple.widthClass(599), WindowSizeClass.compact);
      expect(apple.widthClass(600), WindowSizeClass.medium);
      expect(apple.widthClass(905), WindowSizeClass.medium);
      expect(apple.widthClass(906), WindowSizeClass.large);
      expect(apple.widthClass(1199), WindowSizeClass.large);
    });

    test('classifies height like material', () {
      expect(apple.heightClass(479), WindowSizeClass.compact);
      expect(apple.heightClass(480), WindowSizeClass.medium);
      expect(apple.heightClass(899), WindowSizeClass.medium);
      expect(apple.heightClass(900), WindowSizeClass.expanded);
    });
  });

  group('CustomBreakpoints', () {
    test('classifies with custom bounds', () {
      const custom = CustomBreakpoints(width: [500, 1000]);
      expect(custom.widthClass(499), WindowSizeClass.compact);
      expect(custom.widthClass(500), WindowSizeClass.medium);
      expect(custom.widthClass(1000), WindowSizeClass.expanded);
    });

    test('empty height bounds disable height classification', () {
      const custom = CustomBreakpoints(width: [600]);
      expect(custom.heightClass(100), isNull);
    });

    test('clamps extra bounds beyond five classes', () {
      const custom = CustomBreakpoints(width: [100, 200, 300, 400, 500, 600]);
      expect(custom.widthClass(700), WindowSizeClass.extraLarge);
    });
  });

  group('Breakpoints.of', () {
    testWidgets('falls back to material on the default platform', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox(key: ValueKey('box'))),
      );
      final context = tester.element(find.byKey(const ValueKey('box')));
      expect(Breakpoints.of(context), same(material));
    });

    testWidgets('selects apple on iOS platforms', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const SizedBox(key: ValueKey('box')),
        ),
      );
      final context = tester.element(find.byKey(const ValueKey('box')));
      expect(Breakpoints.of(context), same(apple));
    });

    testWidgets('selects apple on macOS platforms', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: const SizedBox(key: ValueKey('box')),
        ),
      );
      final context = tester.element(find.byKey(const ValueKey('box')));
      expect(Breakpoints.of(context), same(apple));
    });

    testWidgets('style override selects material breakpoints on macOS', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.macOS),
          home: const AdaptiveStyleScope(
            override: AdaptiveStyle.material,
            child: SizedBox(key: ValueKey('box')),
          ),
        ),
      );
      final context = tester.element(find.byKey(const ValueKey('box')));
      expect(Breakpoints.of(context), same(material));
    });

    testWidgets('style override selects apple breakpoints on material', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveStyleScope(
            override: AdaptiveStyle.apple,
            child: SizedBox(key: ValueKey('box')),
          ),
        ),
      );
      final context = tester.element(find.byKey(const ValueKey('box')));
      expect(Breakpoints.of(context), same(apple));
    });

    testWidgets('prefers the scope over the platform default', (tester) async {
      const custom = CustomBreakpoints(width: [300]);
      await tester.pumpWidget(
        const MaterialApp(
          home: BreakpointsScope(
            breakpoints: custom,
            child: SizedBox(key: ValueKey('box')),
          ),
        ),
      );
      final context = tester.element(find.byKey(const ValueKey('box')));
      expect(Breakpoints.of(context), same(custom));
    });

    testWidgets('uses the nearest scope', (tester) async {
      const outer = CustomBreakpoints(width: [300]);
      const inner = CustomBreakpoints(width: [400]);
      await tester.pumpWidget(
        const MaterialApp(
          home: BreakpointsScope(
            breakpoints: outer,
            child: BreakpointsScope(
              breakpoints: inner,
              child: SizedBox(key: ValueKey('box')),
            ),
          ),
        ),
      );
      final context = tester.element(find.byKey(const ValueKey('box')));
      expect(Breakpoints.of(context), same(inner));
    });
  });

  group('WindowSize.fromBreakpoints', () {
    const material = MaterialBreakpoints();

    test('classifies width and height through the breakpoints', () {
      final windowSize = WindowSize.fromBreakpoints(
        material,
        const Size(700, 500),
      );
      expect(windowSize.width, WindowSizeClass.medium);
      expect(windowSize.height, WindowSizeClass.medium);
    });

    test('classifies boundary values per class', () {
      final medium = WindowSize.fromBreakpoints(material, const Size(600, 480));
      expect(medium.width, WindowSizeClass.medium);
      expect(medium.height, WindowSizeClass.medium);

      final compact = WindowSize.fromBreakpoints(
        material,
        const Size(599, 479),
      );
      expect(compact.width, WindowSizeClass.compact);
      expect(compact.height, WindowSizeClass.compact);
    });

    test('height is null when breakpoints do not classify height', () {
      final windowSize = WindowSize.fromBreakpoints(
        const CustomBreakpoints(width: [600]),
        const Size(700, 100),
      );
      expect(windowSize.width, WindowSizeClass.medium);
      expect(windowSize.height, isNull);
    });

    test('compact height constrains every width tier on both styles', () {
      for (final breakpoints in [material, apple]) {
        for (final width in [
          599.0,
          600.0,
          839.0,
          840.0,
          905.0,
          906.0,
          1199.0,
          1200.0,
          1599.0,
          1600.0,
        ]) {
          final short = WindowSize.fromBreakpoints(
            breakpoints,
            Size(width, 479),
          );
          expect(short.width, WindowSizeClass.compact);
          expect(short.height, WindowSizeClass.compact);
          final tall = WindowSize.fromBreakpoints(
            breakpoints,
            Size(width, 480),
          );
          expect(tall.width, breakpoints.widthClass(width));
          expect(tall.height, WindowSizeClass.medium);
        }
      }
    });

    test('height constraint follows custom breakpoints', () {
      const custom = CustomBreakpoints(width: [500, 1000], height: [320, 600]);
      expect(
        WindowSize.fromBreakpoints(custom, const Size(1200, 319)).width,
        WindowSizeClass.compact,
      );
      expect(
        WindowSize.fromBreakpoints(custom, const Size(1200, 320)).width,
        WindowSizeClass.expanded,
      );
    });
  });

  group('WindowSize.fromLayoutConstraints', () {
    for (final viewport in [const Size(1000, 400), const Size(1000, 700)]) {
      testWidgets('uses viewport height for local constraints in $viewport', (
        tester,
      ) async {
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final sizes = <WindowSize>[];
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                sizes.addAll([
                  WindowSize.fromLayoutConstraints(
                    context,
                    const BoxConstraints(maxWidth: 700),
                  ),
                  WindowSize.fromLayoutConstraints(
                    context,
                    const BoxConstraints(maxWidth: 700, maxHeight: 100),
                  ),
                  WindowSize.fromLayoutConstraints(
                    context,
                    const BoxConstraints(),
                  ),
                  WindowSize.fromLayoutConstraints(
                    context,
                    const BoxConstraints(maxWidth: 500),
                  ),
                ]);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        final short = viewport.height < 480;
        expect(
          sizes[0].width,
          short ? WindowSizeClass.compact : WindowSizeClass.medium,
        );
        expect(sizes[1].width, sizes[0].width);
        expect(
          sizes[2].width,
          short ? WindowSizeClass.compact : WindowSizeClass.expanded,
        );
        expect(sizes[3].width, WindowSizeClass.compact);
        for (final size in sizes) {
          expect(
            size.height,
            short ? WindowSizeClass.compact : WindowSizeClass.medium,
          );
        }
      });
    }
  });

  group('WindowSize.of', () {
    testWidgets('classifies width and height from MediaQuery', (tester) async {
      tester.view.physicalSize = const Size(1000, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox(key: ValueKey('box'))),
      );
      final context = tester.element(find.byKey(const ValueKey('box')));
      final windowSize = WindowSize.of(context);
      expect(windowSize.width, WindowSizeClass.expanded);
      expect(windowSize.height, WindowSizeClass.medium);
    });
  });

  group('WindowSizeClass ordering', () {
    test('operator >= follows the declared class order', () {
      expect(WindowSizeClass.medium >= WindowSizeClass.compact, isTrue);
      expect(WindowSizeClass.compact >= WindowSizeClass.medium, isFalse);
      expect(WindowSizeClass.compact >= WindowSizeClass.compact, isTrue);
      expect(WindowSizeClass.extraLarge >= WindowSizeClass.large, isTrue);
      // Apple skips expanded, but the relative order still holds.
      expect(WindowSizeClass.large >= WindowSizeClass.medium, isTrue);
    });
  });

  group('WindowSize.contains', () {
    const tablet = WindowSize(
      width: WindowSizeClass.medium,
      height: WindowSizeClass.medium,
    );

    test('satisfies a threshold on both axes', () {
      expect(
        const WindowSize(
          width: WindowSizeClass.medium,
          height: WindowSizeClass.medium,
        ).contains(tablet),
        isTrue,
      );
      expect(
        const WindowSize(
          width: WindowSizeClass.large,
          height: WindowSizeClass.expanded,
        ).contains(tablet),
        isTrue,
      );
    });

    test('fails when one axis is below the threshold', () {
      expect(
        const WindowSize(
          width: WindowSizeClass.medium,
          height: WindowSizeClass.compact,
        ).contains(tablet),
        isFalse,
      );
    });

    test('ignores height when the threshold has no height class', () {
      const widthOnly = WindowSize(width: WindowSizeClass.medium);
      expect(
        const WindowSize(
          width: WindowSizeClass.expanded,
          height: WindowSizeClass.compact,
        ).contains(widthOnly),
        isTrue,
      );
    });

    test('fails when the size has no height class but the threshold does', () {
      expect(
        const WindowSize(width: WindowSizeClass.expanded).contains(tablet),
        isFalse,
      );
    });
  });
}

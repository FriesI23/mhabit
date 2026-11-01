import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/entries/common/app_root_view.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  group('appIPhoneDuoBreakpoints', () {
    test('Duo uses one complete profile on iOS', () {
      const breakpoints = appIPhoneDuoBreakpoints;

      expect(breakpoints.widthClass(599), WindowSizeClass.compact);
      expect(breakpoints.widthClass(600), WindowSizeClass.compact);
      expect(breakpoints.widthClass(669), WindowSizeClass.compact);
      expect(breakpoints.widthClass(699), WindowSizeClass.compact);
      expect(breakpoints.widthClass(700), WindowSizeClass.medium);
      expect(breakpoints.widthClass(840), WindowSizeClass.medium);
      expect(breakpoints.widthClass(905), WindowSizeClass.medium);
      expect(breakpoints.widthClass(906), WindowSizeClass.large);
      expect(breakpoints.widthClass(1200), WindowSizeClass.large);
      expect(breakpoints.widthClass(1600), WindowSizeClass.large);
      expect(breakpoints.heightClass(479), WindowSizeClass.compact);
      expect(breakpoints.heightClass(480), WindowSizeClass.medium);
      expect(breakpoints.heightClass(899), WindowSizeClass.medium);
      expect(breakpoints.heightClass(900), WindowSizeClass.expanded);

      final portrait = WindowSize.fromBreakpoints(
        breakpoints,
        const Size(669, 951),
      );
      final landscape = WindowSize.fromBreakpoints(
        breakpoints,
        const Size(951, 669),
      );
      expect(portrait.width, WindowSizeClass.compact);
      expect(landscape.width, WindowSizeClass.large);
      expect(
        WindowSize.fromBreakpoints(breakpoints, const Size(951, 479)).width,
        WindowSizeClass.compact,
      );
    });
  });

  for (final style in AdaptiveStyle.values) {
    testWidgets(
      '$style root retains explicit theme breakpoints on every platform',
      (tester) async {
        const explicit = CustomBreakpoints(width: [320, 1000]);
        await tester.pumpWidget(
          AppRootView.withDefault(
            adaptiveStyleOverride: style,
            lightThemeBuilder: (_) => ThemeData(
              platform: TargetPlatform.android,
              extensions: const [AppAdaptiveUiThemeData(breakpoints: explicit)],
            ),
            child: Builder(
              builder: (context) {
                expect(AdaptiveStyle.of(context), style);
                expect(Breakpoints.of(context), same(explicit));
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(
          tester
              .widget<AdaptiveWindowControlLayout>(
                find.byType(AdaptiveWindowControlLayout),
              )
              .topToolbarAlignmentHeight,
          64,
        );
      },
      variant: TargetPlatformVariant.all(),
    );

    testWidgets('Duo profile applies to $style through the theme scope', (
      tester,
    ) async {
      const breakpoints = appIPhoneDuoBreakpoints;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: AppAdaptiveUiTheme(
            data: AppAdaptiveUiThemeData(
              style: style,
              breakpoints: breakpoints,
            ),
            child: Builder(
              builder: (context) {
                expect(Breakpoints.of(context), same(breakpoints));
                expect(
                  Breakpoints.of(context).widthClass(669),
                  WindowSizeClass.compact,
                );
                expect(
                  Breakpoints.of(context).widthClass(840),
                  WindowSizeClass.medium,
                );
                expect(
                  Breakpoints.of(context).widthClass(951),
                  WindowSizeClass.large,
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });

    testWidgets(
      '$style root keeps other devices on the style defaults',
      (tester) async {
        await tester.pumpWidget(
          AppRootView.withDefault(
            adaptiveStyleOverride: style,
            child: Builder(
              builder: (context) {
                expect(AppAdaptiveUiTheme.of(context).breakpoints, isNull);
                expect(
                  Breakpoints.of(context),
                  same(
                    style == AdaptiveStyle.apple
                        ? const AppleBreakpoints()
                        : const MaterialBreakpoints(),
                  ),
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(
          tester
              .widget<AdaptiveWindowControlLayout>(
                find.byType(AdaptiveWindowControlLayout),
              )
              .allowTopToolbarReclamation,
          isFalse,
        );
      },
      variant: TargetPlatformVariant.all(),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/extensions/custom_color_extensions.dart';
import 'package:mhabit/models/app_theme_color.dart';
import 'package:mhabit/models/habit_color_type.dart';
import 'package:mhabit/theme/app_theme_builder.dart';
import 'package:mhabit/theme/color.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  const builder = AppThemeBuilder();
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
    TargetPlatform.windows,
    TargetPlatform.linux,
  ]) {
    for (final style in [
      if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS)
        AdaptiveStyle.apple,
      AdaptiveStyle.material,
    ]) {
      for (final mode in ['light', 'dark', 'elevated']) {
        if (platform != TargetPlatform.iOS && mode == 'elevated') continue;
        testWidgets(
          '$platform $style $mode list follows live app palette changes',
          (tester) async {
            debugDefaultTargetPlatformOverride = platform;
            try {
              Color? previousSurface;
              for (final selection in <AppThemeColor>[
                const SystemAppThemeColor(),
                const InternalAppThemeColor(colorType: HabitColorType.cc2),
                const InternalAppThemeColor(colorType: HabitColorType.cc5),
                const DynamicAppThemeColor(),
                const SystemAppThemeColor(),
              ]) {
                final build = switch (mode) {
                  'light' => builder.buildLight,
                  'dark' => builder.buildDark,
                  _ => builder.buildElevatedDark,
                };
                final theme = build(
                  themeColor: selection,
                  themeMainColor: Colors.blue,
                  dynamicScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
                );
                final colors = theme.colorScheme;
                if (selection case InternalAppThemeColor(:final colorType)) {
                  final seed = theme.extension<CustomColors>()!.getBuiltInColor(
                    colorType,
                  )!;
                  expect(
                    colors.surfaceContainer,
                    ColorScheme.fromSeed(
                      seedColor: seed,
                      brightness: theme.brightness,
                    ).surfaceContainer,
                  );
                }
                expect(colors.surfaceContainer, isNot(colors.surface));
                expect(colors.surfaceContainer, isNot(previousSurface));
                previousSurface = colors.surfaceContainer;
                await tester.pumpWidget(
                  MaterialApp(
                    theme: theme,
                    builder: (context, child) =>
                        AdaptiveStyleScope(override: style, child: child!),
                    home: Scaffold(
                      body: AdaptiveListSection(
                        header: const Text('Header'),
                        children: [
                          AdaptiveListTile(
                            title: const Text('Language'),
                            subtitle: const Text('Current language'),
                            trailing: const Icon(
                              CupertinoIcons.chevron_forward,
                            ),
                            onTap: () {},
                          ),
                          const AdaptiveListTile(
                            title: Text('System settings'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                await tester.pumpAndSettle();
                if (style == AdaptiveStyle.apple) {
                  final context = tester.element(
                    find.byType(AdaptiveListSection),
                  );
                  final system = selection is SystemAppThemeColor;
                  if (platform == TargetPlatform.macOS &&
                      system &&
                      mode == 'dark') {
                    expect(
                      theme.scaffoldBackgroundColor,
                      const Color(0xFF1E1E1E),
                    );
                    final surface = CupertinoDynamicColor.resolve(
                      theme.extension<AdaptiveListThemeData>()!.surfaceColor!,
                      context,
                    );
                    expect(surface.toARGB32(), 0xFF2C2C2E);
                    expect(
                      surface.computeLuminance() -
                          theme.scaffoldBackgroundColor.computeLuminance(),
                      greaterThan(0.01),
                    );
                  }
                  Color expected(Color systemColor, Color themedColor) => system
                      ? CupertinoDynamicColor.resolve(systemColor, context)
                      : themedColor;
                  final tile = tester.widget<CupertinoListTile>(
                    find.byType(CupertinoListTile).first,
                  );
                  expect(tile.backgroundColor, isNull);
                  expect(
                    tile.backgroundColorActivated,
                    expected(
                      CupertinoColors.systemGrey4,
                      colors.surfaceContainerHighest,
                    ),
                  );
                  expect(tile.onTap, isNotNull);
                  expect(
                    DefaultTextStyle.of(
                      tester.element(find.text('Language')),
                    ).style.color,
                    expected(CupertinoColors.label, colors.onSurface),
                  );
                  for (final text in ['Header', 'Current language']) {
                    expect(
                      DefaultTextStyle.of(
                        tester.element(find.text(text)),
                      ).style.color,
                      expected(
                        CupertinoColors.secondaryLabel,
                        colors.onSurfaceVariant,
                      ),
                    );
                  }
                  expect(
                    IconTheme.of(
                      tester.element(
                        find.byIcon(CupertinoIcons.chevron_forward),
                      ),
                    ).color,
                    expected(
                      CupertinoColors.systemGrey2,
                      colors.onSurfaceVariant,
                    ),
                  );
                  final painted = tester
                      .widgetList<ColoredBox>(
                        find.descendant(
                          of: find.byType(AdaptiveListSection),
                          matching: find.byType(ColoredBox),
                        ),
                      )
                      .map((box) => box.color.toARGB32());
                  expect(
                    painted,
                    containsAll([
                      expected(
                        platform == TargetPlatform.macOS
                            ? (mode == 'light'
                                  ? const Color(0xFFF2F2F7)
                                  : const Color(0xFF2C2C2E))
                            : CupertinoColors.secondarySystemBackground,
                        colors.surfaceContainer,
                      ).toARGB32(),
                      expected(
                        CupertinoColors.separator,
                        colors.outlineVariant,
                      ).toARGB32(),
                    ]),
                  );
                } else {
                  final surfaces = tester
                      .widgetList<Material>(
                        find.descendant(
                          of: find.byType(AdaptiveListSection),
                          matching: find.byType(Material),
                        ),
                      )
                      .map((material) => material.color);
                  expect(surfaces, contains(colors.surfaceContainerHigh));
                  expect(
                    colors.surfaceContainerHigh,
                    isNot(theme.scaffoldBackgroundColor),
                  );
                  if (mode == 'dark') {
                    expect(
                      colors.surfaceContainerHigh.computeLuminance(),
                      greaterThan(
                        theme.scaffoldBackgroundColor.computeLuminance(),
                      ),
                    );
                  }
                }
                expect(tester.takeException(), isNull);
              }
            } finally {
              debugDefaultTargetPlatformOverride = null;
            }
          },
        );
      }
    }
  }
}

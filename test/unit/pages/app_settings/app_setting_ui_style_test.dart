import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/entries/common/app_root_view.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_adaptive_style_mode.dart';
import 'package:mhabit/models/app_apple_sidebar_style_mode.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';
import 'package:mhabit/providers/app_ui/app_theme.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final locale in [
    const Locale('en'),
    const Locale('zh'),
    const Locale('de'),
  ]) {
    for (final size in [const Size(320, 900), const Size(1000, 900)]) {
      for (final style in AdaptiveStyle.values) {
        testWidgets('style labels and large text $locale $size $style', (
          tester,
        ) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          SharedPreferences.setMockInitialValues({
            'adaptiveStyleOverride': style == AdaptiveStyle.apple ? 2 : 1,
          });
          final profile = ProfileViewModel([
            AdaptiveStyleOverrideProfileHandler.new,
            AppleSidebarStyleModeProfileHandler.new,
          ]);
          await profile.init();
          final theme = AppThemeViewModel()..updateProfile(profile);
          addTearDown(theme.dispose);
          addTearDown(profile.dispose);
          await tester.pumpWidget(
            ChangeNotifierProvider<AppThemeViewModel>.value(
              value: theme,
              child: Consumer<AppThemeViewModel>(
                builder: (context, value, _) => AppRootView.withDefault(
                  language: locale,
                  adaptiveStyleOverride: value.adaptiveStyleOverride,
                  child: Builder(
                    builder: (context) => MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: const TextScaler.linear(2)),
                      child: const Scaffold(
                        body: SingleChildScrollView(
                          child: AdaptiveListSection(
                            children: [
                              AppSettingUiStyleTile(),
                              AppSettingAppleSidebarStyleTile(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final l10n = lookupL10n(locale);
          final chinese = locale.languageCode == 'zh';
          expect(
            l10n.appSetting_uiStyle_titleText,
            chinese ? '界面风格' : 'UI style',
          );
          expect(
            l10n.appSetting_appleSidebarStyle_titleText,
            chinese ? 'Apple 侧边栏外观' : 'Apple Sidebar appearance',
          );
          expect(find.text(l10n.appSetting_uiStyle_titleText), findsOneWidget);
          expect(
            find.text(l10n.appSetting_appleSidebarStyle_titleText),
            findsOneWidget,
          );
          Future<void> select(String key, String label) async {
            final control = find.byKey(ValueKey(key));
            await tester.ensureVisible(control);
            await tester.tap(control);
            await tester.pumpAndSettle();
            await tester.tap(find.text(label).last);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }

          await select(
            'settings-apple-sidebar-style-control',
            l10n.appSetting_appleSidebarStyle_edge,
          );
          expect(theme.appleSidebarStyleMode, AppAppleSidebarStyleMode.os27);
          await select(
            'settings-apple-sidebar-style-control',
            l10n.appSetting_appleSidebarStyle_inset,
          );
          expect(theme.appleSidebarStyleMode, AppAppleSidebarStyleMode.os26);
          await select('settings-ui-style-control', 'Apple');
          expect(theme.adaptiveStyleMode, AppAdaptiveStyleMode.apple);
          expect(
            AdaptiveStyle.of(
              tester.element(find.byType(AppSettingUiStyleTile)),
            ),
            AdaptiveStyle.apple,
          );
          await select('settings-ui-style-control', 'Material');
          expect(theme.adaptiveStyleOverride, AdaptiveStyle.material);
          await select(
            'settings-ui-style-control',
            l10n.appSetting_uiStyle_automatic,
          );
          expect(theme.adaptiveStyleOverride, isNull);
          expect(theme.appleSidebarStyleMode, AppAppleSidebarStyleMode.os26);
        });
      }
    }
  }
}

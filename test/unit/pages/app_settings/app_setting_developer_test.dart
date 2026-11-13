import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/distribution.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    final testName = 'Developer controls and callbacks $platform';
    testWidgets(testName, (tester) async {
      tester.view.physicalSize = const Size(320, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      TextDirection? direction;
      var debug = false;
      var active = true;
      var enabled = true;
      var debugCalls = 0;
      var directionCalls = 0;
      var exportCalls = 0;
      var clearCalls = 0;
      var supportResets = 0;
      var supportShows = 0;
      var supportDistribution = AppDistribution.github;
      var supportDistributionCalls = 0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  return AppAdaptiveUiTheme(
                    data: AppAdaptiveUiTheme.of(context),
                    child: Directionality(
                      textDirection: direction ?? TextDirection.ltr,
                      child: AppSettingDevelopSubGroup(
                        isInDevelopMode: active,
                        appSupportDistribution: supportDistribution,
                        onAppSupportDistributionChanged: enabled
                            ? (value) => setState(() {
                                supportDistribution = value;
                                supportDistributionCalls++;
                              })
                            : null,
                        onResetSupportReminderPressed: () => supportResets++,
                        onPreviewAppSupportPressed: () => supportShows++,
                        isDisplayDebugMenuSelect: debug,
                        textDirectionOverride: direction,
                        onDisplayDebugMenuSelectChanged: enabled
                            ? (value) => setState(() {
                                debug = value;
                                debugCalls++;
                              })
                            : null,
                        onTextDirectionOverrideChanged: enabled
                            ? (value) => setState(() {
                                direction = value;
                                directionCalls++;
                              })
                            : null,
                        onExportDBTilePressed: enabled
                            ? (_) => exportCalls++
                            : null,
                        onClearDBTilePressed: enabled
                            ? (_) => clearCalls++
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AdaptiveListSection>(
              find.byKey(const ValueKey('settings-developer')),
            )
            .children
            .length,
        7,
      );
      await tester.tap(
        find.byType(
          platform == TargetPlatform.android ? Switch : CupertinoSwitch,
        ),
      );
      await tester.pumpAndSettle();
      expect(debug, true);
      expect(debugCalls, 1);
      Future<void> select(String key, String label) async {
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
      }

      await select('developer-text-direction-control', 'RTL');
      expect(direction, TextDirection.rtl);
      await select('developer-text-direction-control', 'Auto');
      expect(direction, isNull);
      expect(directionCalls, 2);
      await select('developer-app-support-channel-control', 'Google Play');
      expect(supportDistribution, AppDistribution.googlePlay);
      await select('developer-app-support-channel-control', 'Default (GitHub)');
      expect(supportDistribution, AppDistribution.github);
      expect(supportDistributionCalls, 2);
      await tester.tap(find.text('Export DataBase'));
      await tester.tap(find.text('Clear DataBase'));
      expect(exportCalls, 1);
      expect(clearCalls, 1);
      update(() => enabled = false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export DataBase'));
      await tester.tap(find.text('Clear DataBase'));
      expect(exportCalls, 1);
      expect(clearCalls, 1);
      for (final key in [
        'developer-reset-app-support',
        'developer-show-app-support',
      ]) {
        final tile = find.byKey(ValueKey(key));
        await tester.ensureVisible(tile);
        await tester.tap(tile);
      }
      expect(supportResets, 1);
      expect(supportShows, 1);
      update(() => enabled = true);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AdaptiveChoiceListTile<AppDistribution>>(
              find.byWidgetPredicate(
                (widget) => widget is AdaptiveChoiceListTile<AppDistribution>,
              ),
            )
            .onChanged,
        isNotNull,
      );
      for (final key in [
        'developer-reset-app-support',
        'developer-show-app-support',
      ]) {
        final tile = find.byKey(ValueKey(key));
        expect(tester.widget<AdaptiveListTile>(tile).onTap, isNotNull);
        await tester.tap(tile);
      }
      expect(supportResets, 2);
      expect(supportShows, 2);
      update(() => active = false);
      await tester.pumpAndSettle();
      expect(find.text('Show debug menu').hitTestable(), findsNothing);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant({platform}));
  }
}

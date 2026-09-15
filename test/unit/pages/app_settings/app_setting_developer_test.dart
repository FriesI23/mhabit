import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/app_adaptive_style_mode.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    testWidgets('Developer controls and callbacks $platform', (tester) async {
      tester.view.physicalSize = const Size(320, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var mode = AppAdaptiveStyleMode.automatic;
      TextDirection? direction;
      var debug = false;
      var active = true;
      var enabled = true;
      var debugCalls = 0;
      var modeCalls = 0;
      var directionCalls = 0;
      var exportCalls = 0;
      var clearCalls = 0;
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
                  return AdaptiveStyleScope(
                    override: switch (mode) {
                      AppAdaptiveStyleMode.automatic => null,
                      AppAdaptiveStyleMode.material => AdaptiveStyle.material,
                      AppAdaptiveStyleMode.apple => AdaptiveStyle.apple,
                    },
                    child: Directionality(
                      textDirection: direction ?? TextDirection.ltr,
                      child: AppSettingDevelopSubGroup(
                        isInDevelopMode: active,
                        isDisplayDebugMenuSelect: debug,
                        adaptiveStyleMode: mode,
                        textDirectionOverride: direction,
                        onDisplayDebugMenuSelectChanged: enabled
                            ? (value) => setState(() {
                                debug = value;
                                debugCalls++;
                              })
                            : null,
                        onAdaptiveStyleModeChanged: enabled
                            ? (value) => setState(() {
                                mode = value;
                                modeCalls++;
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
        5,
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

      await select('developer-ui-style-control', 'Apple');
      expect(mode, AppAdaptiveStyleMode.apple);
      expect(modeCalls, 1);
      expect(find.byType(CupertinoMenuAnchor), findsNWidgets(2));
      await select('developer-ui-style-control', 'Material');
      expect(mode, AppAdaptiveStyleMode.material);
      expect(find.byType(CupertinoMenuAnchor), findsNothing);
      await select('developer-ui-style-control', 'Automatic');
      expect(mode, AppAdaptiveStyleMode.automatic);
      expect(modeCalls, 3);
      await select('developer-text-direction-control', 'RTL');
      expect(direction, TextDirection.rtl);
      await select('developer-text-direction-control', 'Auto');
      expect(direction, isNull);
      expect(directionCalls, 2);
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
      update(() => active = false);
      await tester.pumpAndSettle();
      expect(find.text('Show debug menu').hitTestable(), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

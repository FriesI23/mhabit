import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/enums.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';
import 'package:mhabit/providers/app_ui/group_expand_timer_config.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final width in [320.0, 900.0]) {
      testWidgets('Operation selection $platform width $width', (tester) async {
        tester.view.physicalSize = Size(width, 2200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        var action = UserAction.tap;
        var speed = GroupExpandTimerSpeed.defaultSpeed;
        var actionCalls = 0;
        var speedCalls = 0;
        var enabled = true;
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              ),
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    update = setState;
                    return AdaptiveListSection(
                      children: [
                        AppSettingDisplayRecordOperationTile(
                          title: const Text('Record gesture'),
                          subtitle: const Text('Choose how to change a record'),
                          inputAction: action,
                          useSideBySideLayout: width >= 600,
                          onSelected: enabled
                              ? (value) => setState(() {
                                  action = value;
                                  actionCalls++;
                                })
                              : null,
                        ),
                        AppSettingExpandTimerDelayTile(
                          title: const Text('Expand delay'),
                          subtitle: const Text('Choose the delay'),
                          speed: speed,
                          useSideBySideLayout: width >= 600,
                          onSelected: enabled
                              ? (value) => setState(() {
                                  speed = value;
                                  speedCalls++;
                                })
                              : null,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final l10n = L10n.of(
          tester.element(find.byType(AppSettingDisplayRecordOperationTile)),
        )!;
        expect(
          find.byType(SegmentedButton<UserAction>),
          platform == TargetPlatform.android ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(CupertinoSlidingSegmentedControl<UserAction>),
          platform == TargetPlatform.android ? findsNothing : findsOneWidget,
        );
        await tester.tap(find.text(l10n.userAction_doubleTap));
        await tester.pumpAndSettle();
        expect(action, UserAction.doubleTap);
        expect(actionCalls, 1);
        await tester.tap(find.text(l10n.appSetting_expandTimerDelay_fast));
        await tester.pumpAndSettle();
        expect(speed, GroupExpandTimerSpeed.fast);
        expect(speedCalls, 1);
        update(() => enabled = false);
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.userAction_longTap));
        await tester.tap(find.text(l10n.appSetting_expandTimerDelay_slow));
        await tester.pumpAndSettle();
        expect(actionCalls, 1);
        expect(speedCalls, 1);
        expect(tester.takeException(), isNull);
      });
    }
  }
}

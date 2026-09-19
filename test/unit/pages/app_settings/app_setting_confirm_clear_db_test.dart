import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/pages/app_settings/_widgets/app_setting_confirm_clear_db.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'clear database preserves backup and result contract $platform $brightness',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(320, 700);
          addTearDown(tester.view.reset);
          AppSettingConfirmClearDBOp? result;
          var completions = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: platform, brightness: brightness),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: Directionality(
                  textDirection: brightness == Brightness.dark
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: child!,
                ),
              ),
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () async {
                      result = await showAppSettingConfirmClearDBDiloag(
                        context: context,
                      );
                      completions++;
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          );
          Future<void> open() async {
            await tester.tap(find.text('Open'));
            await tester.pumpAndSettle();
          }

          bool checked() => platform == TargetPlatform.android
              ? tester
                    .widget<CheckboxListTile>(find.byType(CheckboxListTile))
                    .value!
              : tester
                    .widget<CupertinoCheckbox>(find.byType(CupertinoCheckbox))
                    .value!;
          await open();
          expect(checked(), isTrue);
          final dialog = tester.widget<AdaptiveDialog>(
            find.byType(AdaptiveDialog),
          );
          expect(dialog.actions.last.isDestructiveAction, isTrue);
          await tester.tap(find.text('confirm'));
          await tester.pumpAndSettle();
          expect(result, AppSettingConfirmClearDBOp.confirmWithExport);
          expect(completions, 1);
          await open();
          await tester.tap(find.text('backup first'));
          await tester.pumpAndSettle();
          expect(checked(), isFalse);
          expect(completions, 1);
          // Clicking the control itself also toggles exactly once.
          await tester.tap(
            find.byType(
              platform == TargetPlatform.android ? Checkbox : CupertinoCheckbox,
            ),
          );
          await tester.pumpAndSettle();
          expect(checked(), isTrue);
          await tester.tap(find.text('backup first'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('confirm'));
          await tester.pumpAndSettle();
          expect(result, AppSettingConfirmClearDBOp.confirm);
          expect(completions, 2);
          await open();
          expect(checked(), isTrue);
          await tester.tap(find.text('cancel'));
          await tester.pumpAndSettle();
          expect(result, AppSettingConfirmClearDBOp.cancel);
          expect(completions, 3);
          await open();
          await tester.tapAt(const Offset(5, 5));
          await tester.pumpAndSettle();
          expect(result, isNull);
          expect(completions, 4);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

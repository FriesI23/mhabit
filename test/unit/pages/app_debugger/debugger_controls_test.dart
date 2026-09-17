import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/logging/level.dart';
import 'package:mhabit/pages/app_debugger/widgets.dart';
import 'package:mhabit/pages/common/_widgets/loglevel_changer_tile.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'Logger pause style and disabled cards $platform $brightness',
        (tester) async {
          var value = true;
          var enabled = true;
          late StateSetter update;
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: platform, brightness: brightness),
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    update = setState;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          AdaptiveListSection(
                            children: [
                              ChangeLogsSwitcherTile(
                                value: value,
                                onChanged: enabled
                                    ? (next) => setState(() => value = next)
                                    : null,
                              ),
                            ],
                          ),
                          const DebuggerLogCard(
                            onDownloadPressed: null,
                            onClearPressed: null,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final apple = platform != TargetPlatform.android;
          final control = find.byType(apple ? CupertinoSwitch : Switch);
          final context = tester.element(control);
          const pause = Icons.pause;
          final thumbIcon = apple
              ? tester.widget<CupertinoSwitch>(control).thumbIcon!
              : tester.widget<Switch>(control).thumbIcon!;
          expect(thumbIcon.resolve({WidgetState.selected})!.icon, pause);
          expect(thumbIcon.resolve({}), isNull);
          if (apple) {
            final widget = tester.widget<CupertinoSwitch>(control);
            expect(
              widget.activeTrackColor,
              CupertinoColors.systemRed.resolveFrom(context),
            );
            expect(
              widget.thumbIcon!.resolve({WidgetState.selected})!.color,
              CupertinoColors.systemRed.resolveFrom(context),
            );
            final section = tester
                .widgetList<AdaptiveListSection>(
                  find.byType(AdaptiveListSection),
                )
                .last;
            expect(section.style, AdaptiveStyle.apple);
            expect((section.header! as Text).data, 'Logging Information');
            final clear = find.widgetWithText(AdaptiveListTile, 'Clear');
            expect(tester.widget<AdaptiveListTile>(clear).onTap, isNull);
          } else {
            final widget = tester.widget<Switch>(control);
            expect(
              widget.activeThumbColor,
              Theme.of(context).colorScheme.error,
            );
            expect(
              widget.activeTrackColor,
              Theme.of(context).colorScheme.errorContainer,
            );
            expect(
              tester
                  .widget<TextButton>(find.widgetWithText(TextButton, 'Clear'))
                  .onPressed,
              isNull,
            );
          }
          await tester.tap(control);
          await tester.pumpAndSettle();
          expect(value, isFalse);
          update(() {
            value = true;
            enabled = false;
          });
          await tester.pumpAndSettle();
          await tester.tap(find.text('Collect logs'));
          await tester.pumpAndSettle();
          expect(value, isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
    testWidgets('Debugger controls and independent actions $platform', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 1200);
      addTearDown(tester.view.reset);
      var collecting = false;
      var switchCalls = 0;
      var level = LogLevel.info;
      var levelCalls = 0;
      var downloads = 0;
      Rect? downloadAnchor;
      var clears = 0;
      var opens = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          locale: const Locale('de'),
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
            body: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: Column(
                  children: [
                    AdaptiveListSection(
                      children: [
                        ChangeLogsSwitcherTile(
                          value: collecting,
                          onChanged: (value) => setState(() {
                            collecting = value;
                            switchCalls++;
                          }),
                        ),
                        LogLevelChangerTile(
                          crtLevel: level,
                          onSelected: (value) => setState(() {
                            expect(find.byType(AdaptiveModal), findsOneWidget);
                            level = value;
                            levelCalls++;
                          }),
                        ),
                      ],
                    ),
                    DebuggerLogCard(
                      onDownloadPressed: (anchorContext) {
                        downloads++;
                        final box =
                            anchorContext.findRenderObject()! as RenderBox;
                        downloadAnchor =
                            box.localToGlobal(Offset.zero) & box.size;
                      },
                      onClearPressed: (_) => clears++,
                    ),
                    DebuggerInfoCard(onOpenPressed: (_) => opens++),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(ChangeLogsSwitcherTile));
      final l10n = L10n.of(context)!;
      await tester.tap(find.text(l10n.debug_collectLogTile_title));
      await tester.pumpAndSettle();
      expect(collecting, isTrue);
      expect(switchCalls, 1);
      final control = find.byType(
        platform == TargetPlatform.android ? Switch : CupertinoSwitch,
      );
      await tester.tap(control);
      await tester.pumpAndSettle();
      expect(collecting, isFalse);
      expect(switchCalls, 2);
      await tester.tap(find.text(l10n.debug_logLevelTile_title));
      await tester.pumpAndSettle();
      final errorOption = find.byKey(const ValueKey('log-level-option-error'));
      await Scrollable.ensureVisible(
        tester.element(errorOption),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(errorOption);
      await tester.pumpAndSettle();
      expect(level, LogLevel.error);
      expect(levelCalls, 1);
      expect(find.byType(AdaptiveModal), findsNothing);
      await tester.tap(find.text(l10n.debug_logLevelTile_title));
      await tester.pumpAndSettle();
      expect(tester.widget<Semantics>(errorOption).properties.selected, isTrue);
      await tester.tap(
        find.byKey(const ValueKey('adaptive-modal-implied-close')),
      );
      await tester.pumpAndSettle();
      expect(level, LogLevel.error);
      expect(levelCalls, 1);

      for (final label in [
        l10n.debug_debuggerLogCard_saveButton_text,
        l10n.debug_debuggerLogCard_clearButton_text,
        l10n.debug_debuggerInfoCard_openButton_text,
      ]) {
        final button = find.text(label);
        await Scrollable.ensureVisible(tester.element(button), alignment: 0.5);
        await tester.pumpAndSettle();
        await tester.tap(button);
        await tester.pumpAndSettle();
        if (label == l10n.debug_debuggerLogCard_saveButton_text) {
          final target = find.widgetWithText(
            platform == TargetPlatform.android ? TextButton : AdaptiveListTile,
            label,
          );
          expect(downloadAnchor, tester.getRect(target));
          expect(
            downloadAnchor!.height,
            lessThan(tester.getSize(find.byType(DebuggerLogCard)).height),
          );
        }
      }
      expect([downloads, clears, opens], [1, 1, 1]);
      expect(tester.takeException(), isNull);
    });
  }
}

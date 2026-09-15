// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_reminder_config.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';
import 'package:mhabit/routes/app_router.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final direction in TextDirection.values) {
      testWidgets('Reminder independent actions $platform $direction', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        try {
          tester.view.physicalSize = const Size(320, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          var config = AppReminderConfig.off;
          var switches = 0;
          final picked = <TimeOfDay>[];
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: platform),
              localizationsDelegates: L10n.localizationsDelegates,
              supportedLocales: L10n.supportedLocales,
              builder: (context, child) => Directionality(
                textDirection: direction,
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2)),
                  child: child!,
                ),
              ),
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) => AdaptiveListSection(
                    header: const Text('Reminder'),
                    children: [
                      AppSettingReminderTile(
                        config: config,
                        onSwitchButtonChanged: (value) => setState(() {
                          switches++;
                          config = config.copyWith(enabled: value);
                        }),
                        onTimePicked: picked.add,
                      ),
                      const AppSettingNotifyTile(),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final control = find.byType(
            platform == TargetPlatform.android ? Switch : CupertinoSwitch,
          );
          final node = tester.getSemantics(control);
          expect(node.getSemanticsData().label, 'Daily reminder');
          node.owner!.performAction(node.id, SemanticsAction.tap);
          await tester.pumpAndSettle();
          expect(switches, 1);
          expect(config.enabled, isTrue);
          expect(find.byType(TimePickerDialog), findsNothing);
          await tester.tap(control);
          await tester.pumpAndSettle();
          expect(switches, 2);
          expect(config.enabled, isFalse);
          expect(picked, isEmpty);
          expect(find.byType(TimePickerDialog), findsNothing);

          // The SDK picker is outside this group's narrow-layout migration.
          tester.view.physicalSize = const Size(800, 1200);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Daily reminder').first);
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<TimePickerDialog>(find.byType(TimePickerDialog))
                .initialTime,
            config.timeOfDay,
          );
          final dialogContext = tester.element(find.byType(TimePickerDialog));
          await tester.tap(
            find.text(
              MaterialLocalizations.of(dialogContext).cancelButtonLabel,
            ),
          );
          await tester.pumpAndSettle();
          expect(picked, isEmpty);
          expect(switches, 2);
          await tester.tap(find.text('Daily reminder').first);
          await tester.pumpAndSettle();
          await tester.tap(
            find.text(
              MaterialLocalizations.of(
                tester.element(find.byType(TimePickerDialog)),
              ).okButtonLabel,
            ),
          );
          await tester.pumpAndSettle();
          expect(picked, [config.timeOfDay]);
          expect(switches, 2);
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      });
    }

    testWidgets('Notifications keeps app route on host with $platform style', (
      tester,
    ) async {
      var visits = 0;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: AdaptiveListSection(children: [AppSettingNotifyTile()]),
            ),
          ),
          GoRoute(
            path: '/notify',
            name: AppRoute.settingsNotify.name,
            builder: (context, state) {
              visits++;
              return const Scaffold(body: Text('Notification destination'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          theme: ThemeData(platform: platform),
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byIcon(CupertinoIcons.chevron_forward),
        platform == TargetPlatform.android ? findsNothing : findsOneWidget,
      );
      await tester.tap(find.byType(AppSettingNotifyTile));
      await tester.pumpAndSettle();
      expect(find.text('Notification destination'), findsOneWidget);
      expect(visits, 1);
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(AppSettingNotifyTile), findsOneWidget);
    });
  }
}

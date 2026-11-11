// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/app_info.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/entries/app/entry.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_reminder_config.dart';
import 'package:mhabit/providers/workflow/app_reminder.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ReminderAccess extends ChangeNotifier implements AppReminderAccess {
  _ReminderAccess(this.onStartup);

  final VoidCallback onStartup;

  @override
  AppReminderConfig get reminder => defaultAppReminder;
  @override
  bool get isChannelEnabled => true;
  @override
  Future<bool?> requestReminderPermission() async => true;
  @override
  Future<bool> processReminder(AppReminderContent? content) async => true;
  @override
  Future<void> processTrigger(
    AppReminderTrigger trigger, {
    AppReminderContent? content,
  }) async {
    if (trigger.reason == AppReminderTriggerReason.startup) onStartup();
  }
}

void main() {
  testWidgets('post-init dispatches startup once outside widget build', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'mhabit',
      packageName: 'test.mhabit',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await tester.runAsync(AppInfo().init);
    SharedPreferences.setMockInitialValues({
      'lastChangelogVersion': AppInfo().changelogVersion,
    });
    final profile = ProfileViewModel([
      AppLastChangelogVersionProfileHandler.new,
    ]);
    addTearDown(profile.dispose);
    expect(await profile.init(), isTrue);
    final postInit = GlobalKey();
    final dispatchDuringBuild = <bool>[];
    final reminder = _ReminderAccess(
      () => dispatchDuringBuild.add(postInit.currentContext!.debugDoingBuild),
    );
    addTearDown(reminder.dispose);
    final rebuild = ValueNotifier(0);
    addTearDown(rebuild.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: profile),
          ListenableProvider<AppReminderAccess>.value(value: reminder),
        ],
        child: MaterialApp(
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
          home: ValueListenableBuilder<int>(
            valueListenable: rebuild,
            builder: (_, value, _) =>
                AppPostInit(key: postInit, child: Text('content $value')),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(dispatchDuringBuild, [false]);
    rebuild.value++;
    await tester.pump();
    expect(find.text('content 1'), findsOneWidget);
    expect(dispatchDuringBuild, [false]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

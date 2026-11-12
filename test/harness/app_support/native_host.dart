// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

// Run three times with --flavor f_dev on the same device. This isolated host
// exercises real preferences and production dialogs across process restarts.
// Reminder keys and probe metadata are temporary; original values are restored
// on completion or failure. It does not open a browser or access habit data.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mhabit/common/distribution.dart';
import 'package:mhabit/common/flavor.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/logging/logger_manager.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/providers/support/about_info.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'native_preferences.dart';

void _require(bool condition, String message) {
  if (!condition) throw StateError(message);
}

AdaptiveDialog? _dialog() {
  AdaptiveDialog? found;
  void visit(Element element) {
    if (element.widget case final AdaptiveDialog dialog) found = dialog;
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  return found;
}

AppSupportCarousel? _carousel() {
  AppSupportCarousel? found;
  void visit(Element element) {
    if (element.widget case final AppSupportCarousel carousel) found = carousel;
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  return found;
}

Future<void> _waitForDialog() async {
  for (var i = 0; i < 200 && _dialog() == null; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 16));
    await _frame();
  }
  _require(_dialog() != null, 'dialog visible');
}

Future<void> _frame() => WidgetsBinding.instance.endOfFrame;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLoggerMananger(t: AppLoggerHandlerType.custom);
  final package = await PackageInfo.fromPlatform();
  AppSupportNativePreferences.requireDevelopmentInstall(
    flavor: appFlavor,
    packageName: package.packageName,
  );
  debugPrint(
    'SUPPORT_PROBE_DISTRIBUTION ${Platform.operatingSystem} '
    'flavor=$appFlavor system=$systemAppDistribution default=${defaultAppDistribution.value}',
  );
  DesktopWindowChrome? chrome;
  if (Platform.isMacOS) {
    chrome = DesktopWindowChrome();
    await chrome.initialize();
  }
  final scaffoldKey = GlobalKey<ScaffoldState>();
  runApp(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      home: Scaffold(
        key: scaffoldKey,
        body: const Center(child: Text('App support native verification')),
      ),
    ),
  );
  // The verification driver starts UI operations after the scaffold is mounted.
  await WidgetsBinding.instance.endOfFrame;
  final context = scaffoldKey.currentContext!;
  final info = await loadAboutInfo();
  await chrome?.show();
  final preferences = (await SharedPreferences.getInstance());
  final fixture = AppSupportNativePreferences(preferences);
  final profile = ProfileViewModel([AppSupportReminderProfileHandler.new]);
  await profile.init();
  final reminder = profile.getHandler<AppSupportReminderProfileHandler>()!;
  try {
    final stage = await fixture.readStage();
    if (stage == null) {
      await fixture.begin();
      final first = AppSupportOwner(profile: profile);
      _require(await first.init(), 'fresh init');
      _require(
        !first.checkReminderEligibility(canShowDialog: true),
        'fresh must not show a reminder',
      );
      _require(
        await reminder.set((
          minimumDate: DateTime.utc(2000),
          launches: 9,
          closed: false,
        )),
        'eligible fixture saved',
      );
      final owner = AppSupportOwner(profile: profile);
      _require(await owner.init(), 'eligible init');
      _require(
        owner.checkReminderEligibility(canShowDialog: true),
        'eligible must show a reminder',
      );
      var attempts = 0;
      for (var i = 0; i < 2; i++) {
        if (!context.mounted) throw StateError('host disposed');
        final failure = showAppSupportDialog(
          context: context,
          info: info,
          openUrl: (_) async {
            attempts++;
            _require(_dialog() == null, 'dialog closes before external action');
            if (attempts == 2) throw StateError('expected launcher failure');
            return false;
          },
        );
        await _waitForDialog();
        _carousel()!.onSelected(AppSupportAction.githubStar);
        _require(
          await failure == AppSupportResult.actionFailed,
          'failed action',
        );
      }
      _require(
        attempts == 2 && _dialog() == null,
        'failures leave dialog closed',
      );
      if (!context.mounted) throw StateError('host disposed');
      final dialogResult = showAppSupportDialog(context: context, info: info);
      await _waitForDialog();
      debugPrint('SUPPORT_PROBE_DIALOG_READY ${Platform.operatingSystem}');
      await Future<void>.delayed(const Duration(seconds: 3));
      _dialog()!.actions[1].onPressed!();
      _require(
        await owner.recordReminderResult(await dialogResult),
        'later saved',
      );
      await fixture.saveStage(AppSupportNativeStage.later);
      debugPrint(
        'SUPPORT_PROBE_PASS first-and-later ${Platform.operatingSystem}',
      );
    } else if (stage == AppSupportNativeStage.later) {
      final restored = AppSupportOwner(profile: profile);
      _require(await restored.init(), 'later restart init');
      _require(
        !restored.checkReminderEligibility(canShowDialog: true),
        'later restored',
      );
      _require(reminder.get()?.launches == 1, 'later count restored');
      _require(
        await reminder.set((
          minimumDate: DateTime.utc(2000),
          launches: 9,
          closed: false,
        )),
        'second eligible fixture saved',
      );
      final owner = AppSupportOwner(profile: profile);
      _require(await owner.init(), 'second eligible init');
      _require(
        owner.checkReminderEligibility(canShowDialog: true),
        'second eligible reminder',
      );
      if (!context.mounted) throw StateError('host disposed');
      final dialogResult = showAppSupportDialog(context: context, info: info);
      await _waitForDialog();
      _dialog()!.actions.first.onPressed!();
      _require(
        await owner.recordReminderResult(await dialogResult),
        'never saved',
      );
      await fixture.saveStage(AppSupportNativeStage.never);
      debugPrint(
        'SUPPORT_PROBE_PASS later-restart-and-never ${Platform.operatingSystem}',
      );
    } else {
      _require(stage == AppSupportNativeStage.never, 'known probe stage');
      final restored = AppSupportOwner(profile: profile);
      _require(await restored.init(), 'never restart init');
      _require(
        !restored.checkReminderEligibility(canShowDialog: true),
        'never restored',
      );
      await fixture.restore();
      debugPrint(
        'SUPPORT_PROBE_PASS never-restart-and-restored ${Platform.operatingSystem}',
      );
    }
    await _frame();
    exit(0);
  } catch (error, stackTrace) {
    try {
      await fixture.restore();
    } catch (restoreError) {
      debugPrint('SUPPORT_PROBE_RESTORE_PENDING $restoreError');
    }
    debugPrint('SUPPORT_PROBE_FAILED $error\n$stackTrace');
    exit(1);
  }
}

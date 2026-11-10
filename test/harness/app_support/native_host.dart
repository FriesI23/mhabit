// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

// Run three times with --flavor f_dev on the same device. This isolated host
// exercises real preferences and production dialogs across process restarts.
// Reminder keys and probe metadata are temporary; original values are restored
// on completion or failure. It does not open a browser or access habit data.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mhabit/common/flavor.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/logging/logger_manager.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
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

Future<void> _frame() => WidgetsBinding.instance.endOfFrame;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLoggerMananger(t: AppLoggerHandlerType.custom);
  final package = await PackageInfo.fromPlatform();
  AppSupportNativePreferences.requireDevelopmentInstall(
    flavor: appFlavor,
    packageName: package.packageName,
  );
  DesktopWindowChrome? chrome;
  if (Platform.isMacOS) {
    chrome = DesktopWindowChrome();
    await chrome.initialize();
  }
  final ready = Completer<BuildContext>();
  runApp(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      home: Builder(
        builder: (context) {
          if (!ready.isCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!ready.isCompleted) ready.complete(context);
            });
          }
          return const Scaffold(
            body: Center(child: Text('App support native verification')),
          );
        },
      ),
    ),
  );
  final context = await ready.future;
  await chrome?.show();
  final preferences = SharedPreferencesAsync();
  final fixture = AppSupportNativePreferences(preferences);
  try {
    final stage = await fixture.readStage();
    if (stage == null) {
      await fixture.begin();
      final first = AppSupportOwner();
      _require(await first.initialize(), 'fresh init');
      _require(!first.claimPrompt(canPresent: true), 'fresh must not prompt');
      await preferences.setInt(
        'appSupport_minimumDate',
        DateTime.utc(2000).millisecondsSinceEpoch,
      );
      await preferences.setInt('appSupport_launches', 9);
      final owner = AppSupportOwner();
      _require(await owner.initialize(), 'eligible init');
      _require(owner.claimPrompt(canPresent: true), 'eligible must prompt');
      var attempts = 0;
      if (!context.mounted) throw StateError('host disposed');
      final prompt = showAppSupportDialog(
        context: context,
        target: Uri.parse('https://github.com/FriesI23/mhabit'),
        openUrl: (_) async {
          attempts++;
          if (attempts == 2) throw StateError('expected launcher failure');
          return false;
        },
      );
      await _frame();
      _require(_dialog() != null, 'dialog visible');
      for (var i = 0; i < 2; i++) {
        _dialog()!.actions.last.onPressed!();
        await _frame();
      }
      _require(attempts == 2 && _dialog() != null, 'retry keeps dialog');
      debugPrint('SUPPORT_PROBE_DIALOG_READY ${Platform.operatingSystem}');
      await Future<void>.delayed(const Duration(seconds: 3));
      _dialog()!.actions[1].onPressed!();
      _require(await owner.consume(await prompt), 'later saved');
      await fixture.saveStage(AppSupportNativeStage.later);
      debugPrint(
        'SUPPORT_PROBE_PASS first-and-later ${Platform.operatingSystem}',
      );
    } else if (stage == AppSupportNativeStage.later) {
      final restored = AppSupportOwner();
      _require(await restored.initialize(), 'later restart init');
      _require(!restored.claimPrompt(canPresent: true), 'later restored');
      _require(
        await preferences.getInt('appSupport_launches') == 1,
        'later count restored',
      );
      await preferences.setInt(
        'appSupport_minimumDate',
        DateTime.utc(2000).millisecondsSinceEpoch,
      );
      await preferences.setInt('appSupport_launches', 9);
      final owner = AppSupportOwner();
      _require(await owner.initialize(), 'second eligible init');
      _require(owner.claimPrompt(canPresent: true), 'second eligible prompt');
      if (!context.mounted) throw StateError('host disposed');
      final prompt = showAppSupportDialog(
        context: context,
        target: Uri.parse('https://github.com/FriesI23/mhabit'),
      );
      await _frame();
      _require(_dialog() != null, 'second dialog visible');
      _dialog()!.actions.first.onPressed!();
      _require(await owner.consume(await prompt), 'never saved');
      await fixture.saveStage(AppSupportNativeStage.never);
      debugPrint(
        'SUPPORT_PROBE_PASS later-restart-and-never ${Platform.operatingSystem}',
      );
    } else {
      _require(stage == AppSupportNativeStage.never, 'known probe stage');
      final restored = AppSupportOwner();
      _require(await restored.initialize(), 'never restart init');
      _require(!restored.claimPrompt(canPresent: true), 'never restored');
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

// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

// Interactive native smoke host. Only f_dev installs are accepted. Reminder
// conditions are in memory: this host never writes preferences or habit data,
// launches a browser, requests native reviews, or invokes a real payment action.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mhabit/common/flavor.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/logging/logger_manager.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/providers/support/about_info.dart';
import 'package:mhabit/providers/workflow/app_support.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'native_preferences.dart';

class _MemoryPreferences extends SharedPreferencesAsync {
  final _values = <String, Object>{};

  @override
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) async => {
    for (final entry in _values.entries)
      if (allowList == null || allowList.contains(entry.key))
        entry.key: entry.value,
  };

  @override
  Future<int?> getInt(String key) async => _values[key] as int?;

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<void> setInt(String key, int value) async => _values[key] = value;

  @override
  Future<void> setBool(String key, bool value) async => _values[key] = value;
}

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
  runApp(
    ChangeNotifierProvider(
      lazy: false,
      create: (_) => AppSupportOwner(preferences: _MemoryPreferences())..init(),
      child: const _Host(),
    ),
  );
  await WidgetsBinding.instance.endOfFrame;
  await chrome?.show();
  debugPrint('SUPPORT_CAROUSEL_HOST_READY ${Platform.operatingSystem}');
}

class _Host extends StatefulWidget {
  const _Host();
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  AdaptiveStyle _style = Platform.isAndroid
      ? AdaptiveStyle.material
      : AdaptiveStyle.apple;
  bool _dark = false;
  bool _fail = false;
  bool _reduced = false;
  bool _chinese = false;

  Future<bool> _open(Uri target) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    debugPrint(
      'SUPPORT_CAROUSEL_LINK ${_fail ? 'failure' : 'success'} $target',
    );
    return !_fail;
  }

  Future<void> _prompt(BuildContext context) async {
    final owner = context.read<AppSupportOwner>();
    final info = await loadAboutInfo();
    if (!context.mounted) return;
    final result = await showAppSupportDialog(
      context: context,
      info: info,
      hideDonate: false,
      openUrl: _open,
      showDonation: (_) async {
        debugPrint('SUPPORT_CAROUSEL_DONATION_SELECTED');
      },
    );
    if (!context.mounted) return;
    if (result == AppSupportPromptResult.supportOpened ||
        result == AppSupportPromptResult.storeOpened) {
      await owner.recordSupportOpened(result);
    } else if (result == AppSupportPromptResult.never) {
      await owner.consume(result);
    }
    debugPrint('SUPPORT_CAROUSEL_DIALOG_RESULT ${result.name}');
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(brightness: _dark ? Brightness.dark : Brightness.light),
    locale: _chinese ? const Locale('zh') : const Locale('en'),
    localizationsDelegates: L10n.localizationsDelegates,
    supportedLocales: L10n.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: _reduced),
      child: child!,
    ),
    home: AppAdaptiveUiTheme(
      data: AppAdaptiveUiTheme.of(context).copyWith(style: _style),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Support carousel verification')),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  children: [
                    TextButton(
                      onPressed: () => _prompt(context),
                      child: const Text('Show dialog'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await context
                            .read<AppSupportOwner>()
                            .resetForNextLaunch();
                      },
                      child: const Text('Reset'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _style = _style == AdaptiveStyle.material
                            ? AdaptiveStyle.apple
                            : AdaptiveStyle.material;
                      }),
                      child: Text(_style.name),
                    ),
                  ],
                ),
                SwitchListTile(
                  title: const Text('Dark theme'),
                  value: _dark,
                  onChanged: (value) => setState(() => _dark = value),
                ),
                SwitchListTile(
                  title: const Text('Simulate link failure'),
                  value: _fail,
                  onChanged: (value) => setState(() => _fail = value),
                ),
                SwitchListTile(
                  title: const Text('Reduce motion'),
                  value: _reduced,
                  onChanged: (value) => setState(() => _reduced = value),
                ),
                SwitchListTile(
                  title: const Text('Chinese'),
                  value: _chinese,
                  onChanged: (value) => setState(() => _chinese = value),
                ),
                AppSettingSupportSection(
                  hideDonate: false,
                  openUrl: _open,
                  showDonation: (_) async {
                    debugPrint('SUPPORT_CAROUSEL_DONATION_SELECTED');
                  },
                ),
                const SizedBox(height: 1000),
                const Text('Scroll back up to check the idle timer restarts.'),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

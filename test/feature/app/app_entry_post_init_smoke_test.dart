import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/app_info.dart';
import 'package:mhabit/entries/app/entry.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_reminder_config.dart';
import 'package:mhabit/models/app_sync_options.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/models/app_sync_server_form.dart';
import 'package:mhabit/providers/app_ui/app_debugger.dart';
import 'package:mhabit/providers/workflow/app_reminder.dart';
import 'package:mhabit/providers/workflow/app_sync.dart';
import 'package:mhabit/reminders/notification_channel.dart';
import 'package:mhabit/reminders/notification_details.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

Future<void> _initAppInfo() async {
  PackageInfo.setMockInitialValues(
    appName: 'mhabit',
    packageName: 'io.github.friesi23.mhabit',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  await AppInfo().init();
}

final class _FakeNotificationChannelData extends NotificationChannelData {
  _FakeNotificationChannelData()
    : super(
        androidChannel: NotificationAndroidChannelData(
          debug: const AndroidNotificationDetails('debug', 'debug'),
          habitReminder: const AndroidNotificationDetails(
            'habitReminder',
            'habitReminder',
          ),
          appReminder: const AndroidNotificationDetails(
            'appReminder',
            'appReminder',
          ),
          appDebugger: const AndroidNotificationDetails(
            'appDebugger',
            'appDebugger',
          ),
          appSyncing: const AndroidNotificationDetails(
            'appSyncing',
            'appSyncing',
          ),
          appSyncFailed: const AndroidNotificationDetails(
            'appSyncFailed',
            'appSyncFailed',
          ),
        ),
      );

  @override
  void onL10nUpdate(L10n? l10n) {}
}

final class _TrackingAppDebuggerViewModel extends AppDebuggerViewModel {
  int processCallCount = 0;
  L10n? lastL10n;

  @override
  void processDebuggingNotification([L10n? l10n]) {
    processCallCount++;
    lastL10n = l10n;
  }
}

final class _TrackingAppReminderAccess extends ChangeNotifier
    implements AppReminderAccess {
  final triggers = <AppReminderTrigger>[];
  int processCallCount = 0;
  AppReminderContent? lastContent;

  @override
  bool get isChannelEnabled => true;

  @override
  Future<bool?> requestReminderPermission() async => true;

  @override
  Future<void> processTrigger(
    AppReminderTrigger trigger, {
    AppReminderContent? content,
  }) async {
    triggers.add(trigger);
    lastContent = content;
  }

  @override
  AppReminderConfig get reminder => AppReminderConfig.off;

  @override
  Future<bool> processReminder(AppReminderContent? content) async {
    processCallCount++;
    lastContent = content;
    return true;
  }
}

final class _FakeAppSyncAccess extends ChangeNotifier
    implements AppSyncSettingsAccess, AppSyncWorkflowAccess {
  int onL10nUpdateCallCount = 0;
  L10n? lastL10n;

  @override
  bool get enabled => true;

  @override
  AppSyncFetchInterval get fetchInterval => AppSyncFetchInterval.values.first;

  @override
  AppSyncServer? get serverConfig => null;

  @override
  AppSyncStatusSnapshot? get syncStatus => null;

  @override
  bool get canStartSync => true;

  @override
  Future? get syncProcessing => null;

  @override
  Stream<AppSyncNeedConfirmEvent> get confirmEvents =>
      const Stream<AppSyncNeedConfirmEvent>.empty();

  @override
  Stream<String> get startSyncEvents => const Stream<String>.empty();

  @override
  Future<bool> deleteServerConfig() async => true;

  @override
  void delayedStartTaskOnce({Duration delay = kAppSyncOnceDelay}) {}

  @override
  void cancelSync() {}

  @override
  void onL10nUpdate(L10n? l10n) {
    onL10nUpdateCallCount++;
    lastL10n = l10n;
  }

  @override
  Future<String> readPasswordDisplayText() async => '';

  @override
  Future<String?> readPassword({String? identity}) async => null;

  @override
  Future<bool> saveServerConfigForm(
    AppSyncServerForm form, {
    bool resetStatus = false,
  }) async => true;

  @override
  Future<void> setFetchInterval(
    AppSyncFetchInterval value, {
    bool listen = true,
  }) async {}

  @override
  Future<void> setSyncSwitch(bool value, {bool listen = true}) async {}

  @override
  Future<void> startSync({Duration? initWait}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_initAppInfo);

  testWidgets(
    'AppPostInit runs startup sync once and keeps AppSync l10n wired',
    (tester) async {
      final appSync = _FakeAppSyncAccess();
      final debugger = _TrackingAppDebuggerViewModel();
      final reminder = _TrackingAppReminderAccess();
      final channelData = _FakeNotificationChannelData();

      Widget buildTestApp() {
        return MultiProvider(
          providers: [
            Provider<NotificationChannelData>.value(value: channelData),
            ChangeNotifierProvider<AppDebuggerViewModel>.value(value: debugger),
            ListenableProvider<AppReminderAccess>.value(value: reminder),
            ListenableProvider<AppSyncSettingsAccess>.value(value: appSync),
            ListenableProvider<AppSyncTriggerAccess>.value(value: appSync),
            ListenableProvider<AppSyncWorkflowAccess>.value(value: appSync),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            home: AppPostInit(child: SizedBox.shrink()),
          ),
        );
      }

      addTearDown(() {
        reminder.dispose();
        debugger.dispose();
        appSync.dispose();
      });

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(debugger.processCallCount, 1);
      expect(reminder.triggers, hasLength(1));
      expect(reminder.triggers.single.reason, AppReminderTriggerReason.startup);
      expect(reminder.triggers.single.nextReminder, isNull);
      expect(reminder.processCallCount, 0);
      expect(debugger.lastL10n, isNotNull);
      expect(
        reminder.lastContent,
        AppReminderContent.fromL10n(lookupL10n(const Locale('en'))),
      );
      expect(appSync.lastL10n, isNotNull);

      final initialL10nUpdateCount = appSync.onL10nUpdateCallCount;
      expect(initialL10nUpdateCount, greaterThanOrEqualTo(2));

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(debugger.processCallCount, 1);
      expect(reminder.triggers, hasLength(1));
      expect(reminder.triggers.single.reason, AppReminderTriggerReason.startup);
      expect(reminder.triggers.single.nextReminder, isNull);
      expect(reminder.processCallCount, 0);
      expect(appSync.onL10nUpdateCallCount, initialL10nUpdateCount);
    },
  );
}

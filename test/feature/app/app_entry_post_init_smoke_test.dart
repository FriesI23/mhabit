import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as flutter_local_notifications
    show NotificationDetails;
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/app_info.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/entries/app/entry.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_reminder_config.dart';
import 'package:mhabit/models/app_sync_options.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/models/app_sync_server_form.dart';
import 'package:mhabit/models/app_sync_tasks.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_reminder.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/providers/app_ui/app_debugger.dart';
import 'package:mhabit/providers/workflow/app_reminder.dart';
import 'package:mhabit/providers/workflow/app_sync.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/reminders/notification_channel.dart';
import 'package:mhabit/reminders/notification_details.dart';
import 'package:mhabit/reminders/notification_service.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:mhabit/widgets/widgets.dart' show DateChangeNotifier;
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/adaptive_dialog.dart';

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

final class _FakeNotificationService implements NotificationService {
  int cancelHabitReminderCallCount = 0;
  flutter_local_notifications.NotificationDetails? lastReminderDetails;
  int regrHabitReminderCallCount = 0;

  @override
  Future<bool> cancelHabitReminder({required int id, Duration? timeout}) async {
    cancelHabitReminderCallCount += 1;
    return true;
  }

  @override
  Future<bool> regrHabitReminder<T>({
    required int id,
    required String uuid,
    required String name,
    String? quest,
    required HabitReminder reminder,
    required HabitDate? lastUntrackDate,
    required flutter_local_notifications.NotificationDetails details,
    DateTime? crtDate,
    Duration? timeout,
  }) async {
    regrHabitReminderCallCount += 1;
    lastReminderDetails = details;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeAppSyncAccess extends ChangeNotifier
    implements AppSyncSettingsAccess, AppSyncWorkflowAccess {
  final confirmations = StreamController<AppSyncNeedConfirmEvent>.broadcast();

  @override
  void dispose() {
    confirmations.close();
    super.dispose();
  }

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
  Stream<AppSyncNeedConfirmEvent> get confirmEvents => confirmations.stream;

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

final class _TrackingStartupHabitsAccess extends HabitsManager {
  final List<HabitSummaryData> _loadedHabits;

  _TrackingStartupHabitsAccess({
    super.notificationService,
    required List<HabitSummaryData> loadedHabits,
  }) : _loadedHabits = List.unmodifiable(loadedHabits);

  int refreshCallCount = 0;
  final refreshParamsList = <HabitReminderRefreshParams>[];

  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async {
    final collection = initedCollection ?? HabitSummaryDataCollection();
    for (final habit in _loadedHabits) {
      if (habitUUIDs == null || habitUUIDs.contains(habit.uuid)) {
        collection.addHabit(habit, forceAdd: true);
      }
    }
    return collection;
  }

  @override
  Future<void> refreshHabitReminders({
    required HabitReminderRefreshParams params,
  }) async {
    refreshCallCount += 1;
    refreshParamsList.add(params);
    await super.refreshHabitReminders(params: params);
  }
}

HabitSummaryData _buildStartupHabitSummaryData({
  HabitUUID uuid = 'startup-habit-1',
}) => HabitSummaryData(
  id: 1,
  uuid: uuid,
  type: HabitType.normal,
  name: 'Startup habit',
  desc: '',
  color: const HabitColor.builtIn(HabitColorType.cc1),
  dailyGoal: 1,
  targetDays: 1,
  frequency: HabitFrequency.daily,
  startDate: HabitDate.dateTime(DateTime(2026, 1, 1)),
  status: HabitStatus.activated,
  reminder: HabitReminder.dailyMidnight,
  reminderQuest: 'Startup proof',
  sortPostion: 1,
  createTime: DateTime(2026, 1, 1),
);

void main() {
  setUpAll(_initAppInfo);

  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final emptyDir in [true, false]) {
      for (final choice in ['confirm', 'cancel', 'barrier', 'back']) {
        testWidgets('$platform sync confirmation empty=$emptyDir $choice', (
          tester,
        ) async {
          final appSync = _FakeAppSyncAccess();
          SharedPreferences.setMockInitialValues({
            'lastChangelogVersion': AppInfo().changelogVersion,
          });
          final profile = ProfileViewModel([
            AppLastChangelogVersionProfileHandler.new,
          ]);
          await profile.init();
          addTearDown(appSync.dispose);
          addTearDown(profile.dispose);
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<ProfileViewModel>.value(value: profile),
                ListenableProvider<AppSyncSettingsAccess>.value(value: appSync),
                ListenableProvider<AppSyncWorkflowAccess>.value(value: appSync),
              ],
              child: MaterialApp(
                theme: ThemeData(platform: platform),
                localizationsDelegates: L10n.localizationsDelegates,
                supportedLocales: L10n.supportedLocales,
                home: const AppPostInit(child: Scaffold(body: Text('App'))),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final event = AppSyncNeedConfirmEvent(
            WebDavConfigTaskChecklist.dirChecker(
              needCreateHabitsDir: emptyDir,
              needCreateWarningFile: emptyDir,
            ),
          );
          var completions = 0;
          event.future.then((_) => completions++);
          // Use the production event subscription and dialog route.
          appSync.confirmations.add(event);
          await tester.pumpAndSettle();
          expect(adaptiveDialogFinder, findsOneWidget);
          final l10n = L10n.of(tester.element(adaptiveDialogFinder))!;
          expect(
            find.text(
              emptyDir
                  ? l10n.appSync_webdav_newServerConfirmDialog_titleText
                  : l10n.appSync_webdav_oldServerConfirmDialog_titleText,
            ),
            findsOneWidget,
          );
          expect(
            find.text(
              emptyDir
                  ? l10n.appSync_webdav_newServerConfirmDialog_subtitleText
                  : l10n.appSync_webdav_oldServerConfirmDialog_subtitleText,
            ),
            findsOneWidget,
          );
          final icon = find.byIcon(
            emptyDir
                ? MdiIcons.folderMultiplePlusOutline
                : MdiIcons.folderAlertOutline,
          );
          expect(
            icon,
            platform == TargetPlatform.android ? findsOneWidget : findsNothing,
          );
          expect(
            find.byType(MaterialAdaptiveDialog),
            platform == TargetPlatform.android ? findsOneWidget : findsNothing,
          );
          expect(
            find.byType(CupertinoAdaptiveDialog),
            platform == TargetPlatform.android ? findsNothing : findsOneWidget,
          );
          final actions = adaptiveDialogActions(tester);
          expect(actions, hasLength(2));
          expect(actions.first.label, l10n.confirmDialog_cancel_text);
          expect(
            actions.last.label,
            emptyDir
                ? l10n.appSync_webdav_newServerConfirmDialog_confirmText
                : l10n.appSync_webdav_oldServerConfirmDialog_confirmText,
          );
          expect(actions.last.isDestructiveAction, !emptyDir);
          expect(actions.last.isDefaultAction, emptyDir);
          expect(completions, 0);
          final stale = actions.last.onPressed!;
          switch (choice) {
            case 'confirm':
              stale();
              stale();
            case 'cancel':
              actions.first.onPressed!();
            case 'barrier':
              await tester.tapAt(const Offset(5, 5));
              stale();
            case 'back':
              await tester.binding.handlePopRoute();
              stale();
          }
          await tester.pumpAndSettle();
          expect(await event.future, choice == 'confirm');
          expect(completions, 1);
          expect(find.text('App'), findsOneWidget);
          // Reopening uses a fresh route and can still cancel normally.
          final next = AppSyncNeedConfirmEvent(event.checklist);
          appSync.confirmations.add(next);
          await tester.pumpAndSettle();
          adaptiveDialogActions(tester).first.onPressed!();
          await tester.pumpAndSettle();
          expect(await next.future, isFalse);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets(
    'AppPostInit runs startup triggers once, refreshes habit reminders on restart and desktop date changes, and keeps AppSync l10n wired',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      final appSync = _FakeAppSyncAccess();
      final dateChangeNotifier = DateChangeNotifier(
        dateTime: HabitDate.dateTime(DateTime(2026, 1, 1)),
        timezoneName: 'UTC',
      );
      final debugger = _TrackingAppDebuggerViewModel();
      final notificationService = _FakeNotificationService();
      final reminder = _TrackingAppReminderAccess();
      final channelData = _FakeNotificationChannelData();
      final habitsAccess = _TrackingStartupHabitsAccess(
        notificationService: notificationService,
        loadedHabits: [_buildStartupHabitSummaryData()],
      )..setNotificationChannelData(channelData);

      SharedPreferences.setMockInitialValues({});
      final profile = ProfileViewModel(const []);
      await profile.init();

      try {
        Widget buildTestApp() {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<ProfileViewModel>.value(value: profile),
              ChangeNotifierProvider<DateChangeNotifier>.value(
                value: dateChangeNotifier,
              ),
              Provider<NotificationChannelData>.value(value: channelData),
              ChangeNotifierProvider<AppDebuggerViewModel>.value(
                value: debugger,
              ),
              ListenableProvider<AppReminderAccess>.value(value: reminder),
              Provider<HabitsDisplayAccess>.value(value: habitsAccess),
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

        await tester.pumpWidget(buildTestApp());
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(debugger.processCallCount, 1);
        expect(reminder.triggers, hasLength(1));
        expect(
          reminder.triggers.single.reason,
          AppReminderTriggerReason.startup,
        );
        expect(reminder.triggers.single.nextReminder, isNull);
        expect(reminder.processCallCount, 0);
        expect(habitsAccess.refreshCallCount, 1);
        expect(habitsAccess.refreshParamsList, [
          const HabitReminderRefreshParams.startup(),
        ]);
        expect(notificationService.regrHabitReminderCallCount, 1);
        expect(notificationService.cancelHabitReminderCallCount, 0);
        expect(
          notificationService.lastReminderDetails?.android?.channelId,
          channelData.habitReminder.android?.channelId,
        );
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
        expect(
          reminder.triggers.single.reason,
          AppReminderTriggerReason.startup,
        );
        expect(reminder.triggers.single.nextReminder, isNull);
        expect(reminder.processCallCount, 0);
        expect(habitsAccess.refreshCallCount, 1);
        expect(habitsAccess.refreshParamsList, [
          const HabitReminderRefreshParams.startup(),
        ]);
        expect(notificationService.regrHabitReminderCallCount, 1);
        expect(notificationService.cancelHabitReminderCallCount, 0);
        expect(appSync.onL10nUpdateCallCount, initialL10nUpdateCount);

        // ignore: invalid_use_of_protected_member
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        await tester.pump();
        // ignore: invalid_use_of_protected_member
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        await tester.pump();
        // ignore: invalid_use_of_protected_member
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();
        // ignore: invalid_use_of_protected_member
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
        await tester.pump();
        // ignore: invalid_use_of_protected_member
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        await tester.pump();
        // ignore: invalid_use_of_protected_member
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(debugger.processCallCount, 1);
        expect(reminder.triggers, hasLength(1));
        expect(reminder.processCallCount, 0);
        expect(habitsAccess.refreshCallCount, 2);
        expect(habitsAccess.refreshParamsList, [
          const HabitReminderRefreshParams.startup(),
          const HabitReminderRefreshParams.restart(),
        ]);
        expect(notificationService.regrHabitReminderCallCount, 2);
        expect(notificationService.cancelHabitReminderCallCount, 0);
        expect(appSync.onL10nUpdateCallCount, initialL10nUpdateCount);

        dateChangeNotifier.dateTime = HabitDate.dateTime(DateTime(2026, 1, 2));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(habitsAccess.refreshCallCount, 3);
        expect(habitsAccess.refreshParamsList, [
          const HabitReminderRefreshParams.startup(),
          const HabitReminderRefreshParams.restart(),
          const HabitReminderRefreshParams.dateChange(),
        ]);
        expect(notificationService.regrHabitReminderCallCount, 3);
        expect(notificationService.cancelHabitReminderCallCount, 0);

        dateChangeNotifier.tzName = 'Asia/Shanghai';
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(habitsAccess.refreshCallCount, 4);
        expect(habitsAccess.refreshParamsList, [
          const HabitReminderRefreshParams.startup(),
          const HabitReminderRefreshParams.restart(),
          const HabitReminderRefreshParams.dateChange(),
          const HabitReminderRefreshParams.dateChange(),
        ]);
        expect(notificationService.regrHabitReminderCallCount, 4);
        expect(notificationService.cancelHabitReminderCallCount, 0);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        dateChangeNotifier.dispose();
        reminder.dispose();
        debugger.dispose();
        appSync.dispose();
        profile.dispose();
      }
    },
  );
}

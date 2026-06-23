// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show NotificationDetails;
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/app_info.dart';
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/models/app_notify_config.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/models/habit_freq.dart';
import 'package:mhabit/models/habit_reminder.dart';
import 'package:mhabit/models/habit_repo_actions.dart';
import 'package:mhabit/models/habit_summary.dart';
import 'package:mhabit/providers/workflow/app_notify_config.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/reminders/notification_channel.dart';
import 'package:mhabit/reminders/notification_service.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';
import 'package:mhabit/storage/db_helper_provider.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

final class _FakeNotificationService implements NotificationService {
  int cancelHabitReminderCallCount = 0;
  int regrHabitReminderCallCount = 0;
  int requestPermissionsCallCount = 0;
  NotificationDetails? lastReminderDetails;

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
    required NotificationDetails details,
    DateTime? crtDate,
    Duration? timeout,
  }) async {
    regrHabitReminderCallCount += 1;
    lastReminderDetails = details;
    return true;
  }

  @override
  Future<bool?> requestPermissions() async {
    requestPermissionsCallCount += 1;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeAppNotifyConfigAccess extends ChangeNotifier
    with ProfileHandlerLoadedMixin
    implements AppNotifyConfigAccess {
  _FakeAppNotifyConfigAccess({required this.notifyConfig});

  @override
  AppNotifyConfig notifyConfig;

  bool _mounted = true;

  @override
  bool get mounted => _mounted;

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    super.dispose();
  }

  @override
  bool isChannelEnabled(NotificationChannelId channelId) =>
      notifyConfig.isChannelEnabled(channelId);

  @override
  ReminderStatus getReminderStatus(NotificationChannelId channelId) =>
      isChannelEnabled(channelId)
      ? const ReminderStatus.ready()
      : const ReminderStatus.channelDisabled();

  @override
  Future<void> updateConfig(
    AppNotifyConfig newConfig, {
    bool listen = true,
  }) async {
    notifyConfig = newConfig;
    if (listen) notifyListeners();
  }
}

final class _RefreshEntryHabitsManager extends HabitsManager {
  final List<HabitSummaryData>? _loadedHabits;

  _RefreshEntryHabitsManager({
    super.notificationService,
    required List<HabitSummaryData>? loadedHabits,
  }) : _loadedHabits = loadedHabits == null
           ? null
           : List.unmodifiable(loadedHabits);

  List<HabitUUID>? lastLoadedHabitUUIDs;
  int loadHabitSummaryCallCount = 0;

  @override
  Future<HabitSummaryDataCollection> loadHabitSummaryCollectionData({
    HabitSummaryDataCollection? initedCollection,
    List<String>? habitsColmns,
    List<HabitUUID>? habitUUIDs,
  }) async {
    loadHabitSummaryCallCount += 1;
    lastLoadedHabitUUIDs = habitUUIDs == null
        ? null
        : List.unmodifiable(habitUUIDs);
    if (_loadedHabits == null) {
      return super.loadHabitSummaryCollectionData(
        initedCollection: initedCollection,
        habitsColmns: habitsColmns,
        habitUUIDs: habitUUIDs,
      );
    }
    final collection = initedCollection ?? HabitSummaryDataCollection();
    for (final habit in _loadedHabits) {
      if (habitUUIDs == null || habitUUIDs.contains(habit.uuid)) {
        collection.addHabit(habit, forceAdd: true);
      }
    }
    return collection;
  }
}

HabitSummaryData _buildHabitSummaryData({
  HabitStatus status = HabitStatus.activated,
  HabitReminder? reminder = HabitReminder.dailyMidnight,
  HabitUUID uuid = 'habit-1',
}) => HabitSummaryData(
  id: 1,
  uuid: uuid,
  type: HabitType.normal,
  name: 'Test habit',
  desc: '',
  color: const HabitColor.builtIn(HabitColorType.cc1),
  dailyGoal: 1,
  targetDays: 1,
  frequency: HabitFrequency.daily,
  startDate: HabitDate.dateTime(DateTime(2026, 1, 1)),
  status: status,
  reminder: reminder,
  reminderQuest: 'Stay on track',
  sortPostion: 1,
  createTime: DateTime(2026, 1, 1),
);

HabitDBCell _buildHabitDBCell({
  HabitUUID uuid = 'habit-db-1',
  HabitStatus status = HabitStatus.activated,
  HabitReminder? reminder = HabitReminder.dailyMidnight,
}) => HabitDBCell(
  type: HabitType.normal.dbCode,
  createT: DateTime(2026, 1, 1).millisecondsSinceEpoch ~/ onSecondMS,
  uuid: uuid,
  status: status.dbCode,
  name: 'DB Habit',
  desc: '',
  color: HabitColorType.cc1.dbCode,
  dailyGoal: 1,
  dailyGoalUnit: defaultHabitDailyGoalUnit,
  freqType: HabitFrequency.daily.type.dbCode,
  freqCustom: jsonEncode(HabitFrequency.daily.toJson()['args']),
  startDate: HabitDate.dateTime(DateTime(2026, 1, 1)).epochDay,
  targetDays: 1,
  remindCustom: reminder == null ? null : jsonEncode(reminder.toJson()),
  remindQuestion: 'Stay on track',
  sortPosition: 1,
);

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

void main() {
  setUpAll(_initAppInfo);

  group('HabitsManager reminder channel gating', () {
    test('requestReminderPermission exposes the habit reminder gate', () async {
      final notificationService = _FakeNotificationService();
      final manager = HabitsManager(notificationService: notificationService);

      final result = await manager.requestReminderPermission();

      expect(result, isTrue);
      expect(notificationService.requestPermissionsCallCount, 1);
      expect(notificationService.regrHabitReminderCallCount, 0);
      expect(notificationService.cancelHabitReminderCallCount, 0);
    });

    test(
      'updateHabitReminders skips notification service when habit channel is disabled',
      () async {
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(
            channels: {NotificationChannelId.habitReminder: false},
          ),
        );
        final manager = HabitsManager(notificationService: notificationService)
          ..attachNotifyConfig(notifyConfig)
          ..setNotificationChannelData(NotificationChannelData());

        await manager.updateHabitReminders([_buildHabitSummaryData()]);

        expect(notificationService.regrHabitReminderCallCount, 0);
        expect(notificationService.cancelHabitReminderCallCount, 0);

        notifyConfig.dispose();
      },
    );

    test('habit reminder status exposes the disabled habit channel reason', () {
      final notifyConfig = _FakeAppNotifyConfigAccess(
        notifyConfig: const AppNotifyConfig(
          channels: {NotificationChannelId.habitReminder: false},
        ),
      );

      final status = notifyConfig.getReminderStatus(
        NotificationChannelId.habitReminder,
      );

      expect(status.isReady, isFalse);
      expect(status.isChannelDisabled, isTrue);
      expect(status.isPermissionDenied, isFalse);

      notifyConfig.dispose();
    });

    test(
      'updateHabitReminders cancels habit reminder when activated habit no longer has a reminder',
      () async {
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(),
        );
        final manager = HabitsManager(notificationService: notificationService)
          ..attachNotifyConfig(notifyConfig)
          ..setNotificationChannelData(NotificationChannelData());

        await manager.updateHabitReminders([
          _buildHabitSummaryData(reminder: null),
        ]);

        expect(notificationService.regrHabitReminderCallCount, 0);
        expect(notificationService.cancelHabitReminderCallCount, 1);

        notifyConfig.dispose();
      },
    );

    test(
      'updateHabitReminders cancels habit reminder when habit is archived',
      () async {
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(),
        );
        final manager = HabitsManager(notificationService: notificationService)
          ..attachNotifyConfig(notifyConfig)
          ..setNotificationChannelData(NotificationChannelData());

        await manager.updateHabitReminders([
          _buildHabitSummaryData(status: HabitStatus.archived),
        ]);

        expect(notificationService.regrHabitReminderCallCount, 0);
        expect(notificationService.cancelHabitReminderCallCount, 1);

        notifyConfig.dispose();
      },
    );

    test(
      'updateHabitReminders routes enabled habit reminder through notification service',
      () async {
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(),
        );
        final channelData = NotificationChannelData();
        final manager = HabitsManager(notificationService: notificationService)
          ..attachNotifyConfig(notifyConfig)
          ..setNotificationChannelData(channelData);

        await manager.updateHabitReminders([_buildHabitSummaryData()]);

        expect(notificationService.regrHabitReminderCallCount, 1);
        expect(notificationService.cancelHabitReminderCallCount, 0);
        expect(
          notificationService.lastReminderDetails?.android?.channelId,
          channelData.habitReminder.android?.channelId,
        );

        notifyConfig.dispose();
      },
    );

    test(
      'refreshHabitReminders rehydrates reconcile params before reaching the reminder sink',
      () async {
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(),
        );
        const habitUUID = 'detail-habit-1';
        final habit = HabitSummaryData(
          id: 2,
          uuid: habitUUID,
          type: HabitType.normal,
          name: 'Detail habit',
          desc: '',
          color: const HabitColor.builtIn(HabitColorType.cc1),
          dailyGoal: 1,
          targetDays: 1,
          frequency: HabitFrequency.daily,
          startDate: HabitDate.dateTime(DateTime(2026, 1, 2)),
          status: HabitStatus.activated,
          reminder: HabitReminder.dailyMidnight,
          reminderQuest: 'Refresh me',
          sortPostion: 2,
          createTime: DateTime(2026, 1, 2),
        );
        final manager =
            _RefreshEntryHabitsManager(
                notificationService: notificationService,
                loadedHabits: [habit],
              )
              ..attachNotifyConfig(notifyConfig)
              ..setNotificationChannelData(NotificationChannelData());

        await manager.refreshHabitReminders(
          params: HabitReminderRefreshParams.habitUUID(habitUUID),
        );

        expect(manager.lastLoadedHabitUUIDs, [habitUUID]);
        expect(notificationService.regrHabitReminderCallCount, 1);
        expect(notificationService.cancelHabitReminderCallCount, 0);

        notifyConfig.dispose();
      },
    );

    test(
      'repairHabitReminders reuses loaded habits without entering the reload path',
      () async {
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(),
        );
        final loadedHabit = _buildHabitSummaryData();
        final manager =
            _RefreshEntryHabitsManager(
                notificationService: notificationService,
                loadedHabits: const [],
              )
              ..attachNotifyConfig(notifyConfig)
              ..setNotificationChannelData(NotificationChannelData());

        await manager.repairHabitReminders(
          params: HabitReminderRepairParams.loadedHabits([loadedHabit]),
        );

        expect(manager.lastLoadedHabitUUIDs, isNull);
        expect(notificationService.regrHabitReminderCallCount, 1);
        expect(notificationService.cancelHabitReminderCallCount, 0);

        notifyConfig.dispose();
      },
    );

    test(
      'refreshHabitReminders loads all habits for startup triggers',
      () async {
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(),
        );
        final startupHabit = _buildHabitSummaryData(uuid: 'startup-habit-1');
        final manager =
            _RefreshEntryHabitsManager(
                notificationService: notificationService,
                loadedHabits: [startupHabit],
              )
              ..attachNotifyConfig(notifyConfig)
              ..setNotificationChannelData(NotificationChannelData());

        await manager.refreshHabitReminders(
          params: const HabitReminderRefreshParams.startup(),
        );

        expect(manager.lastLoadedHabitUUIDs, isNull);
        expect(notificationService.regrHabitReminderCallCount, 1);
        expect(notificationService.cancelHabitReminderCallCount, 0);

        notifyConfig.dispose();
      },
    );

    test(
      'refreshHabitReminders loads all habits for restart triggers',
      () async {
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(),
        );
        final restartHabit = _buildHabitSummaryData(uuid: 'restart-habit-1');
        final manager =
            _RefreshEntryHabitsManager(
                notificationService: notificationService,
                loadedHabits: [restartHabit],
              )
              ..attachNotifyConfig(notifyConfig)
              ..setNotificationChannelData(NotificationChannelData());

        await manager.refreshHabitReminders(
          params: const HabitReminderRefreshParams.restart(),
        );

        expect(manager.lastLoadedHabitUUIDs, isNull);
        expect(notificationService.regrHabitReminderCallCount, 1);
        expect(notificationService.cancelHabitReminderCallCount, 0);

        notifyConfig.dispose();
      },
    );

    test(
      'refreshHabitReminders loads all habits for date-change triggers',
      () async {
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(),
        );
        final dateChangeHabit = _buildHabitSummaryData(
          uuid: 'date-change-habit-1',
        );
        final manager =
            _RefreshEntryHabitsManager(
                notificationService: notificationService,
                loadedHabits: [dateChangeHabit],
              )
              ..attachNotifyConfig(notifyConfig)
              ..setNotificationChannelData(NotificationChannelData());

        await manager.refreshHabitReminders(
          params: const HabitReminderRefreshParams.dateChange(),
        );

        expect(manager.lastLoadedHabitUUIDs, isNull);
        expect(notificationService.regrHabitReminderCallCount, 1);
        expect(notificationService.cancelHabitReminderCallCount, 0);

        notifyConfig.dispose();
      },
    );

    test(
      'saveNewHabitAndUpdateReminder keeps owner-local save follow-up off the reload path',
      () async {
        final habitUUID = 'save-habit-${DateTime.now().microsecondsSinceEpoch}';
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(),
        );
        final dbHelper = DBHelperViewModel();
        await dbHelper.init();
        final manager =
            _RefreshEntryHabitsManager(
                notificationService: notificationService,
                loadedHabits: const [],
              )
              ..updateDBHelper(dbHelper)
              ..attachNotifyConfig(notifyConfig)
              ..setNotificationChannelData(NotificationChannelData());

        final saved = await manager.saveNewHabitAndUpdateReminder(
          _buildHabitDBCell(uuid: habitUUID),
        );

        expect(saved?.uuid, habitUUID);
        expect(manager.loadHabitSummaryCallCount, 0);
        expect(notificationService.regrHabitReminderCallCount, 1);
        expect(notificationService.cancelHabitReminderCallCount, 0);

        dbHelper.dispose();
        notifyConfig.dispose();
      },
    );

    test(
      'changeHabitStatus keeps owner-local status follow-up off the reload path',
      () async {
        final habitUUID =
            'status-habit-${DateTime.now().microsecondsSinceEpoch}';
        final notificationService = _FakeNotificationService();
        final notifyConfig = _FakeAppNotifyConfigAccess(
          notifyConfig: const AppNotifyConfig(),
        );
        final dbHelper = DBHelperViewModel();
        await dbHelper.init();
        final manager =
            _RefreshEntryHabitsManager(
                notificationService: notificationService,
                loadedHabits: null,
              )
              ..updateDBHelper(dbHelper)
              ..attachNotifyConfig(notifyConfig)
              ..setNotificationChannelData(NotificationChannelData());
        await manager.habitDBHelper.insertNewHabit(
          _buildHabitDBCell(uuid: habitUUID),
        );

        final loaded = await manager.loadHabitSummaryCollectionData(
          habitUUIDs: [habitUUID],
        );
        final previousLoadCallCount = manager.loadHabitSummaryCallCount;

        final results = await manager.changeHabitStatus(
          action: ChangeMultiHabitStatusAction([
            loaded.getHabitByUUID(habitUUID)!,
          ], status: HabitStatus.archived),
        );

        expect(results.single.data.status, HabitStatus.archived);
        expect(manager.loadHabitSummaryCallCount, previousLoadCallCount);
        expect(notificationService.cancelHabitReminderCallCount, 1);
        expect(notificationService.regrHabitReminderCallCount, 0);

        dbHelper.dispose();
        notifyConfig.dispose();
      },
    );
  });
}

// Copyright 2026 Fries_I23
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/providers/support/commons.dart';
import 'package:mhabit/providers/workflow/group_manager.dart';
import 'package:mhabit/providers/workflow/habits_file_importer.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';

void main() {
  test(
    'monitor observes out-of-order habit completion and isolates errors',
    () async {
      final access = _HabitAccess();
      final runner = HabitFileImportRunner()..attachAccess(access);
      final monitor = ImportMonitor(3);
      addTearDown(runner.dispose);
      addTearDown(monitor.dispose);
      final snapshots = <List<ImportItemStatus>>[];
      monitor.addListener(() => snapshots.add(monitor.statuses));
      final mapping = <String, GroupUUID>{'old': 'new'};
      final task = runner.importHabitsData(
        [0, 1, 'invalid'],
        monitor: monitor,
        groupUuidMapping: mapping,
      );
      expect(access.pending.keys, [0, 1]);
      expect(monitor.isRunning, isTrue);
      expect(access.mapping, same(mapping));
      access.pending[1]!.completeError(StateError('write failed'));
      await Future<void>.delayed(Duration.zero);
      expect(monitor.statuses, [
        ImportItemStatus.running,
        ImportItemStatus.failed,
        ImportItemStatus.failed,
      ]);
      expect(monitor.processed, 2);
      access.pending[0]!.complete();
      expect(await task, 3);
      expect(monitor.succeeded, 1);
      expect(monitor.failed, 2);
      expect(monitor.isCompleted, isTrue);
      expect(monitor.isRunning, isFalse);
      expect(snapshots.first, everyElement(ImportItemStatus.pending));
      expect(snapshots.last.first, ImportItemStatus.succeeded);
      expect(
        () => monitor.statuses[0] = ImportItemStatus.pending,
        throwsUnsupportedError,
      );
      await expectLater(
        runner.importHabitsData([0, 1, 'invalid'], monitor: monitor),
        throwsStateError,
      );
    },
  );

  test(
    'groups start concurrently and merge duplicate UUIDs in input order',
    () async {
      final access = _GroupAccess();
      final runner = HabitFileImportRunner()..attachGroupAccess(access);
      final monitor = ImportMonitor(4);
      addTearDown(runner.dispose);
      addTearDown(monitor.dispose);
      final task = runner.importGroupsData([
        'ok',
        'skip',
        'throw',
        'later',
      ], monitor: monitor);
      expect(access.started, ['ok', 'skip', 'throw', 'later']);
      await Future<void>.delayed(Duration.zero);
      expect(monitor.statuses, [
        ImportItemStatus.running,
        ImportItemStatus.failed,
        ImportItemStatus.failed,
        ImportItemStatus.succeeded,
      ]);
      access.first.complete({'old': 'first'});
      expect(await task, {'old': 'last', 'later': 'new-later'});
      expect(monitor.succeeded, 2);
      expect(monitor.failed, 2);
      expect(monitor.isCompleted, isTrue);
    },
  );

  test(
    'empty imports complete; missing group access reports failure',
    () async {
      final runner = HabitFileImportRunner();
      final empty = ImportMonitor(0);
      final group = ImportMonitor(1);
      addTearDown(runner.dispose);
      addTearDown(empty.dispose);
      addTearDown(group.dispose);
      expect(await runner.importHabitsData([], monitor: empty), 0);
      expect(empty.isCompleted, isTrue);
      expect(await runner.importGroupsData(['group'], monitor: group), isEmpty);
      expect(group.statuses, [ImportItemStatus.failed]);
      expect(group.failed, 1);
    },
  );

  test(
    'disposed monitor detaches listeners while storage work completes',
    () async {
      final access = _HabitAccess();
      final runner = HabitFileImportRunner()..attachAccess(access);
      addTearDown(runner.dispose);
      final monitor = ImportMonitor(1);
      expect(monitor, isA<ProviderMounted>());
      expect(monitor.mounted, isTrue);
      var notifications = 0;
      monitor.addListener(() => notifications++);
      final task = runner.importHabitsData([0], monitor: monitor);
      monitor.dispose();
      expect(monitor.mounted, isFalse);
      monitor.dispose();
      final before = notifications;
      access.pending[0]!.complete();
      expect(await task, 1);
      expect(notifications, before);
      expect(monitor.isCompleted, isTrue);
    },
  );
}

class _HabitAccess implements HabitImportAccess {
  final pending = <int, Completer<void>>{};
  Map<String, GroupUUID>? mapping;

  @override
  List<Future<void>> importHabitsData(
    Iterable<Object?> jsonData, {
    bool withRecords = true,
    Map<String, GroupUUID>? groupUuidMapping,
  }) {
    mapping = groupUuidMapping;
    final index = jsonData.single;
    if (index is! int) throw const FormatException('bad entry');
    final completer = Completer<void>();
    pending[index] = completer;
    return [completer.future];
  }

  @override
  int getImportHabitsCount(Iterable<Object?> jsonData) => jsonData.length;
}

class _GroupAccess implements GroupImportAccess {
  final first = Completer<Map<String, GroupUUID>>();
  final started = <Object?>[];

  @override
  Future<Map<String, GroupUUID>> importGroupsData(
    Iterable<Object?> jsonData,
  ) async {
    started.add(jsonData.single);
    return switch (jsonData.single) {
      'ok' => await first.future,
      'skip' => {},
      'throw' => throw const FormatException('bad entry'),
      _ => {'old': 'last', 'later': 'new-later'},
    };
  }

  @override
  int getImportGroupsCount(Iterable<Object?> jsonData) => jsonData.length;
}

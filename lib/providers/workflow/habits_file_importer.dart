// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../common/types.dart';
import '../../logging/helper.dart';
import '../../logging/logger_stack.dart';
import '../support/commons.dart';
import 'group_manager.dart';
import 'habits_manager.dart';

enum ImportItemStatus { pending, running, succeeded, failed }

typedef ImportItemStatusListener =
    void Function(int index, ImportItemStatus previous, ImportItemStatus next);

/// Observable progress for one import batch; execution belongs to the runner.
/// The consumer owns disposal; disposing detaches observation, not storage work.
class ImportMonitor extends ChangeNotifier implements ProviderMounted {
  ImportMonitor(int total)
    : _statuses = List.filled(total, ImportItemStatus.pending),
      _failures = List.filled(total, null);

  final List<ImportItemStatus> _statuses;
  final List<AsyncError?> _failures;
  final Map<int, Set<ImportItemStatusListener>> _itemListeners = {};
  bool _started = false;
  bool _completed = false;
  bool _mounted = true;
  int _succeeded = 0;
  int _failed = 0;

  int get total => _statuses.length;
  int get succeeded => _succeeded;
  int get failed => _failed;
  int get processed => succeeded + failed;
  bool get isRunning => _started && !_completed;
  bool get isCompleted => _completed;
  @override
  bool get mounted => _mounted;
  List<ImportItemStatus> get statuses => List.unmodifiable(_statuses);
  ImportItemStatus statusAt(int index) => _statuses[index];
  AsyncError? failureAt(int index) => _failures[index];

  void addItemListener(int index, ImportItemStatusListener listener) {
    _itemListeners.putIfAbsent(index, () => {}).add(listener);
  }

  void removeItemListener(int index, ImportItemStatusListener listener) {
    final listeners = _itemListeners[index];
    listeners?.remove(listener);
    if (listeners?.isEmpty ?? false) _itemListeners.remove(index);
  }

  void _publish() {
    if (mounted) notifyListeners();
  }

  void _start() {
    if (_started || !mounted) {
      throw StateError('Import monitor is not available');
    }
    _started = true;
    _publish();
  }

  void _update(int index, ImportItemStatus status, {AsyncError? failure}) {
    final previous = _statuses[index];
    _statuses[index] = status;
    _failures[index] = failure;
    if (status == ImportItemStatus.succeeded) _succeeded++;
    if (status == ImportItemStatus.failed) _failed++;
    _publish();
    for (final listener
        in _itemListeners[index]?.toList() ??
            const <ImportItemStatusListener>[]) {
      listener(index, previous, status);
    }
  }

  void _complete() {
    _completed = true;
    _publish();
  }

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    _itemListeners.clear();
    super.dispose();
  }
}

class HabitFileImportRunner extends ChangeNotifier implements ProviderMounted {
  static const maxConcurrentItems = 4;
  bool _mounted = true;
  late HabitImportAccess _access;
  GroupImportAccess? _groupAccess;

  void attachAccess(HabitImportAccess newAccess) => _access = newAccess;
  void attachGroupAccess(GroupImportAccess newAccess) =>
      _groupAccess = newAccess;

  @override
  void dispose() {
    if (!_mounted) return;
    super.dispose();
    _mounted = false;
  }

  /// Runs a bounded number of entries while retaining input result order.
  Future<List<T?>> _run<T>(
    Iterable<Object?> jsonData,
    ImportMonitor monitor,
    String operation,
    Future<T> Function(Object? entry) action,
  ) async {
    final entries = List<Object?>.of(jsonData);
    if (entries.length != monitor.total) {
      throw ArgumentError('Import data and monitor totals must match');
    }
    monitor._start();
    final results = List<T?>.filled(entries.length, null);
    var nextIndex = 0;
    Future<void> runWorker() async {
      while (nextIndex < entries.length) {
        final index = nextIndex++;
        results[index] = await _runItem(
          index,
          entries[index],
          monitor,
          operation,
          action,
        );
      }
    }

    try {
      await Future.wait([
        for (var i = 0; i < math.min(maxConcurrentItems, entries.length); i++)
          runWorker(),
      ]);
    } finally {
      monitor._complete();
    }
    return results;
  }

  Future<T?> _runItem<T>(
    int index,
    Object? entry,
    ImportMonitor monitor,
    String operation,
    Future<T> Function(Object? entry) action,
  ) async {
    monitor._update(index, ImportItemStatus.running);
    try {
      final result = await action(entry);
      monitor._update(index, ImportItemStatus.succeeded);
      return result;
    } catch (error, stackTrace) {
      final failure = AsyncError(error, stackTrace);
      appLog.import.error(
        '$runtimeType.$operation',
        ex: ['Failed to import item', index],
        error: error,
        stackTrace: LoggerStackTrace.from(stackTrace),
      );
      monitor._update(index, ImportItemStatus.failed, failure: failure);
      return null;
    }
  }

  Future<int> importHabitsData(
    Iterable<Object?> jsonData, {
    required ImportMonitor monitor,
    bool listen = true,
    Map<String, GroupUUID>? groupUuidMapping,
  }) async {
    await _run<void>(jsonData, monitor, 'importHabitsData', (entry) async {
      final futures = _access.importHabitsData([
        entry,
      ], groupUuidMapping: groupUuidMapping);
      if (futures.isEmpty) throw StateError('No habit import task');
      await Future.wait(futures);
    });
    if (listen && mounted) notifyListeners();
    return monitor.processed;
  }

  int importHabitsDataDryRun(Iterable<Object?> jsonData) =>
      _access.getImportHabitsCount(jsonData);

  int importGroupsDataDryRun(Iterable<Object?> jsonData) =>
      _groupAccess?.getImportGroupsCount(jsonData) ?? 0;

  Future<Map<String, GroupUUID>> importGroupsData(
    Iterable<Object?> jsonData, {
    required ImportMonitor monitor,
    bool listen = true,
  }) async {
    final results = await _run<Map<String, GroupUUID>>(
      jsonData,
      monitor,
      'importGroupsData',
      (entry) async {
        final result = await _groupAccess?.importGroupsData([entry]) ?? {};
        if (result.isEmpty) throw StateError('Group was not imported');
        return result;
      },
    );
    // Merge in input order, preserving duplicate-UUID behavior under concurrency.
    final mapping = <String, GroupUUID>{};
    for (final result in results) {
      if (result != null) mapping.addAll(result);
    }
    if (listen && mounted) notifyListeners();
    return mapping;
  }

  @override
  bool get mounted => _mounted;
}

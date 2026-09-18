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

import 'package:flutter/foundation.dart';

import '../../common/types.dart';
import '../support/commons.dart';
import 'group_manager.dart';
import 'habits_manager.dart';

enum ImportItemStatus { pending, running, succeeded, failed }

/// Observable progress for one import batch; execution belongs to the runner.
/// The consumer owns disposal; disposing detaches observation, not storage work.
class ImportMonitor extends ChangeNotifier implements ProviderMounted {
  ImportMonitor(int total)
    : _statuses = List.filled(total, ImportItemStatus.pending);

  final List<ImportItemStatus> _statuses;
  bool _started = false;
  bool _completed = false;
  bool _mounted = true;
  int _succeeded = 0;
  int _failed = 0;

  List<ImportItemStatus> get statuses => List.unmodifiable(_statuses);
  int get total => _statuses.length;
  int get succeeded => _succeeded;
  int get failed => _failed;
  int get processed => succeeded + failed;
  bool get isRunning => _started && !_completed;
  bool get isCompleted => _completed;

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

  void _update(int index, ImportItemStatus status) {
    _statuses[index] = status;
    if (status == ImportItemStatus.succeeded) _succeeded++;
    if (status == ImportItemStatus.failed) _failed++;
    _publish();
  }

  void _complete() {
    _completed = true;
    _publish();
  }

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    super.dispose();
  }

  @override
  bool get mounted => _mounted;
}

class HabitFileImportRunner extends ChangeNotifier implements ProviderMounted {
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

  /// Starts entries concurrently and retains input order when collecting results.
  Future<List<T?>> _run<T>(
    Iterable<Object?> jsonData,
    ImportMonitor monitor,
    Future<T> Function(Object? entry) action,
  ) async {
    final entries = List<Object?>.of(jsonData);
    if (entries.length != monitor.total) {
      throw ArgumentError('Import data and monitor totals must match');
    }
    monitor._start();
    final results = await Future.wait([
      for (final (index, entry) in entries.indexed)
        _runItem(index, entry, monitor, action),
    ]);
    monitor._complete();
    return results;
  }

  Future<T?> _runItem<T>(
    int index,
    Object? entry,
    ImportMonitor monitor,
    Future<T> Function(Object? entry) action,
  ) async {
    monitor._update(index, ImportItemStatus.running);
    try {
      final result = await action(entry);
      monitor._update(index, ImportItemStatus.succeeded);
      return result;
    } catch (_) {
      monitor._update(index, ImportItemStatus.failed);
      return null;
    }
  }

  Future<int> importHabitsData(
    Iterable<Object?> jsonData, {
    required ImportMonitor monitor,
    bool listen = true,
    Map<String, GroupUUID>? groupUuidMapping,
  }) async {
    await _run<void>(jsonData, monitor, (entry) async {
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
    final results = await _run<Map<String, GroupUUID>>(jsonData, monitor, (
      entry,
    ) async {
      final result = await _groupAccess?.importGroupsData([entry]) ?? {};
      if (result.isEmpty) throw StateError('Group was not imported');
      return result;
    });
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

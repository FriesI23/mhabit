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

import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';

import '../../../common/consts.dart';
import '../../../common/types.dart';
import '../../../extensions/habit_group_extensions.dart';
import '../../../logging/helper.dart';
import '../../../models/app_event.dart';
import '../../../models/habit_color.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_group.dart';
import '../../../models/habit_group_display.dart';
import '../../../providers/support/commons.dart';
import '../../../providers/support/page_load_runtime.dart';
import '../../../providers/workflow/app_event.dart';
import '../../../providers/workflow/group_manager.dart';
import '../../../storage/profile/handlers.dart';
import '../../../storage/profile_provider.dart';

/// Page-scoped ViewModel for the Group management page.
///
/// Sort type/direction are nullable session overrides: when null, the effective
/// value falls back to the global [DisplayGroupModeProfileHandler] config.
class GroupManageViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin
    implements ProviderMounted, AppEventLoaded {
  GroupManageViewModel({String? initialGroupUUID})
    : _initialGroupUUID = initialGroupUUID;

  // dependencies
  GroupManager? _groupManager;
  DisplayGroupModeProfileHandler? _groupModeHandler;

  // data
  GroupCollection? _groupCollection;
  var _sortableCache = const _GroupsSortableCache(
    sortType: defaultGroupType,
    sortDirection: defaultGroupSortDirection,
  );

  /// The sorted domain list for UI consumption.
  List<HabitGroupData> get groups => _sortableCache.lastSortedDataCache;

  /// Session-level override — null means use global config.
  HabitDisplayGroupType? _sortType;
  HabitDisplaySortDirection? _sortDirection;

  HabitDisplayGroupType? get sortType => _sortType;
  HabitDisplaySortDirection? get sortDirection => _sortDirection;

  /// Effective sort type for the management page.
  ///
  /// Falls back through session → global profile → [defaultGroupType].
  /// When the global profile is set to an extrinsic type (e.g.
  /// [HabitDisplayGroupType.habitCount]) that has no Group-intrinsic
  /// equivalent, skips it and falls through to [defaultGroupType].
  HabitDisplayGroupType get effectiveSortType {
    if (_sortType != null) return _sortType!;
    final profileType = _groupModeHandler?.groupType;
    if (profileType != null &&
        HabitGroupOrderType.fromGroupType(profileType) != null) {
      return profileType;
    }
    return defaultGroupType;
  }

  HabitDisplaySortDirection get effectiveSortDirection =>
      _sortDirection ??
      _groupModeHandler?.groupDirection ??
      defaultGroupSortDirection;

  // selection state
  bool _selectionMode = false;
  final Set<String> _selectedGroupUUIDs = {};

  bool get selectionMode => _selectionMode;
  Set<String> get selectedUUIDs => _selectedGroupUUIDs;
  int get selectedCount => _selectedGroupUUIDs.length;

  // loading lifecycle
  final _pageLoad = PageLoadRuntime();
  bool _nextRefreshForceReload = false;
  bool _firstLoadCompleted = false;
  bool _mounted = true;

  /// Set via navigation from the home page Group header long-press menu.
  /// Consumed on the first successful [loadGroups] call.
  final String? _initialGroupUUID;

  @override
  bool get mounted => _mounted;

  bool get hasLoad => _pageLoad.hasLoad;
  bool get hasLoaded => _pageLoad.hasLoaded;

  bool consumeForceReloadFlag() {
    final result = _nextRefreshForceReload;
    _nextRefreshForceReload = false;
    return result;
  }

  // undo
  List<String> _lastDeletedUUIDs = [];

  /// Snapshot of the last batch of deleted UUIDs, for undo event firing.
  List<String> get lastDeletedUUIDs => List.unmodifiable(_lastDeletedUUIDs);

  // event subscriptions
  StreamSubscription<GroupChangedEvent>? _groupEventSub;
  StreamSubscription<ReloadDataEvent>? _reloadDataSub;

  @override
  void dispose() {
    if (!_mounted) return;
    _groupEventSub?.cancel();
    _reloadDataSub?.cancel();
    _pageLoad.cancel(logName: "$runtimeType.dispose");
    _mounted = false;
    super.dispose();
  }

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _groupModeHandler = newProfile.getHandler<DisplayGroupModeProfileHandler>();
  }

  void attachGroupManager(GroupManager value) {
    _groupManager = value;
  }

  @override
  void updateAppEvent(AppEventBus newAppEvent) {
    _groupEventSub?.cancel();
    _reloadDataSub?.cancel();
    _groupEventSub = newAppEvent.on<GroupChangedEvent>().listen((event) {
      if (event.isInTrace(AppEventPageSource.groupManage)) return;
      appLog.habit.debug("GroupManage.reload", ex: ["GroupChangedEvent"]);
      requestReload();
    });
    _reloadDataSub = newAppEvent.on<ReloadDataEvent>().listen((event) {
      if (event.isInTrace(AppEventPageSource.groupManage)) return;
      appLog.habit.debug("GroupManage.reload", ex: ["ReloadDataEvent", event]);
      requestReload();
    });
  }

  void requestReload() {
    _nextRefreshForceReload = true;
    _pageLoad.cancel(logName: "$runtimeType.requestReload");
    notifyListeners();
  }

  Future<void> loadGroups({bool listen = true}) {
    void loadingFailed(
      CancelableCompleter<void> loading,
      List<Object?> errmsg,
    ) {
      appLog.load.error("$runtimeType.load", ex: [...errmsg, loading.hashCode]);
      if (!loading.isCompleted) {
        loading.completeError(
          FlutterError(errmsg.join(" ")),
          StackTrace.current,
        );
      }
    }

    void loadingCancelled(CancelableCompleter<void> loading) {
      appLog.load.info(
        "$runtimeType.load",
        ex: ['cancelled', loading.hashCode],
      );
    }

    return _pageLoad.run(
      logName: "$runtimeType.loadGroups",
      alreadyLoadingEx: ["groups already loading"],
      loadData: (loading) async {
        if (!mounted) {
          return loadingFailed(loading, ["viewmodel disposed"]);
        }
        if (loading.isCanceled) return loadingCancelled(loading);

        // Load groups via GroupManager → GroupCollection.
        _groupCollection = await _groupManager?.tryLoadGroupCollection();
        if (!mounted) {
          return loadingFailed(loading, ["viewmodel disposed"]);
        }
        if (loading.isCanceled) return loadingCancelled(loading);
        if (loading.isCompleted) return;

        // On first successful load, enter manual-sort + selection mode
        // when navigated from the home page Group header long-press menu.
        if (!_firstLoadCompleted && _initialGroupUUID != null) {
          _firstLoadCompleted = true;
          _sortType = HabitDisplayGroupType.manual;
          _sortDirection = HabitDisplaySortDirection.asc;
          _selectionMode = true;
          _selectedGroupUUIDs.add(_initialGroupUUID);
        }
        _resortData();

        loading.complete();
        if (listen) notifyListeners();
      },
      onError: (loading, e, s) {
        if (loading.isCanceled) return loadingCancelled(loading);
        loadingFailed(loading, ["unexpected error", e]);
        appLog.load.error(
          "$runtimeType.load",
          ex: ["caught", e, loading.hashCode],
        );
      },
    );
  }

  /// Used by dialogs that need the domain model for editing/updating.
  Future<HabitGroupData?> loadGroupDataByUUID(String uuid) =>
      _groupManager?.loadGroupDataByUUID(uuid) ?? Future.value(null);

  void setSortOptions(
    HabitDisplayGroupType type,
    HabitDisplaySortDirection direction,
  ) {
    _sortType = type;
    _sortDirection = direction;
    _resortData();
    notifyListeners();
  }

  void _resortData() {
    if (_groupCollection == null) return;
    _sortableCache = _sortableCache.copyWithData(
      _groupCollection!,
      sortType: effectiveSortType,
      sortDirection: effectiveSortDirection,
    );
  }

  /// Sort types that have a meaningful Group-level interpretation.
  static const List<HabitDisplayGroupType> supportedSortTypes = [
    HabitDisplayGroupType.name,
    HabitDisplayGroupType.colorType,
    HabitDisplayGroupType.createDate,
    HabitDisplayGroupType.manual,
  ];

  void enterSelectionMode(String initialUUID, {bool listen = true}) {
    _selectionMode = true;
    _selectedGroupUUIDs.add(initialUUID);
    if (listen) notifyListeners();
  }

  /// Enter selection mode without selecting any item.
  /// Used by the AppBar reorder button.
  void enterSelectionModeWithoutNotification() {
    _selectionMode = true;
    notifyListeners();
  }

  void exitSelectionMode() {
    _selectionMode = false;
    _selectedGroupUUIDs.clear();
    notifyListeners();
  }

  void toggleSelection(String uuid) {
    if (!_selectionMode) return;
    if (_selectedGroupUUIDs.contains(uuid)) {
      _selectedGroupUUIDs.remove(uuid);
      if (_selectedGroupUUIDs.isEmpty) {
        exitSelectionMode();
        return;
      }
    } else {
      _selectedGroupUUIDs.add(uuid);
    }
    notifyListeners();
  }

  void selectAll() {
    if (!_selectionMode) return;
    final all = groups.map((g) => g.uuid).toSet();
    _selectedGroupUUIDs
      ..clear()
      ..addAll(all);
    notifyListeners();
  }

  bool isSelected(String uuid) => _selectedGroupUUIDs.contains(uuid);

  Future<void> deleteSingleGroup(String uuid) async {
    await _groupManager?.deleteGroup(uuid);
    if (!mounted) return;
    _lastDeletedUUIDs = [uuid];
    exitSelectionMode();
    requestReload();
  }

  Future<void> deleteSelectedGroups() async {
    final uuids = List<String>.of(_selectedGroupUUIDs);
    for (final uuid in uuids) {
      await _groupManager?.deleteGroup(uuid);
      if (!mounted) return;
    }
    _lastDeletedUUIDs = uuids;
    exitSelectionMode();
    requestReload();
  }

  Future<void> undoLastDelete() async {
    final uuids = List<String>.of(_lastDeletedUUIDs);
    _lastDeletedUUIDs = [];
    final all = await _groupManager?.loadAllActiveGroups() ?? [];
    if (!mounted) return;
    final lookup = all.map((g) => g.uuid).toSet();

    for (final uuid in uuids) {
      if (lookup.contains(uuid)) continue;
      await _groupManager?.restoreGroup(uuid);
      if (!mounted) return;
    }
    requestReload();
  }

  Future<HabitGroupData> createGroup({
    required String name,
    String? desc,
    GroupIcon? icon,
    GroupColor? color,
  }) async {
    final gm = _groupManager;
    if (gm == null) throw StateError('GroupManager not attached');
    final result = await gm.createGroup(
      name: name,
      desc: desc,
      icon: icon,
      color: color,
    );
    if (!mounted) return result;
    requestReload();
    return result;
  }

  Future<void> updateGroup({
    required String uuid,
    required String name,
    String? desc,
    GroupIcon? icon,
    HabitColor? color,
  }) async {
    final gm = _groupManager;
    if (gm == null) throw StateError('GroupManager not attached');
    await gm.updateGroupData(
      uuid: uuid,
      name: name,
      desc: desc,
      icon: icon,
      color: color,
    );
    if (!mounted) return;
    requestReload();
  }

  /// Persists reorder results after a drag-and-drop completes on the
  /// management page and notifies the home page to refresh.
  Future<void> onGroupReorderComplete(List<String> newOrder) async {
    if (_groupCollection == null) return;

    final allGroups = _groupCollection!.toList();
    final uuidToGroup = {for (final g in allGroups) g.uuid: g};
    final ordered = newOrder
        .map((uuid) => uuidToGroup[uuid])
        .whereType<HabitGroupData>()
        .toList();

    if (ordered.isEmpty) return;

    final gm = _groupManager;
    if (gm == null) return;

    await gm.fixAndSaveSortPositions(
      ordered,
      increaseStep: sortPositionConflictIncreaseStep,
      decimalPlaces: sortPositionConflictDecimalPlaces,
    );

    notifyListeners();
  }
}

/// Simple sortable cache for groups (no grouping/search/filter — groups are
/// flat and always displayed).
///
/// Mirrors the pattern of [_HabitsSortableCache] in habit_summary but
/// deliberately simpler.
class _GroupsSortableCache {
  final HabitDisplayGroupType sortType;
  final HabitDisplaySortDirection sortDirection;
  final List<HabitGroupData> lastSortedDataCache;

  const _GroupsSortableCache({
    required this.sortType,
    required this.sortDirection,
    this.lastSortedDataCache = const [],
  });

  /// Produces a new cache with a fresh sorted list from [collection].
  _GroupsSortableCache copyWithData(
    GroupCollection collection, {
    required HabitDisplayGroupType sortType,
    required HabitDisplaySortDirection sortDirection,
  }) {
    final groups = List.of(collection.toList());
    final orderType =
        HabitGroupOrderType.fromGroupType(sortType) ?? defaultGroupOrderType;
    final sorted = groups.sortedBy(orderType, sortDirection);
    return _GroupsSortableCache(
      sortType: sortType,
      sortDirection: sortDirection,
      lastSortedDataCache: sorted,
    );
  }
}

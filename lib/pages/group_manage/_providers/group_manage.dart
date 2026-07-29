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

import '../../../common/collation.dart';
import '../../../common/consts.dart';
import '../../../common/sort_generation.dart';
import '../../../common/types.dart';
import '../../../extensions/collation_extensions.dart';
import '../../../extensions/habit_group_extensions.dart';
import '../../../logging/helper.dart';
import '../../../models/app_event.dart';
import '../../../models/habit_color.dart';
import '../../../models/habit_display.dart';
import '../../../models/habit_group.dart';
import '../../../models/habit_group_display.dart';
import '../../../pages/common/widgets.dart';
import '../../../providers/support/commons.dart';
import '../../../providers/support/page_load_runtime.dart';
import '../../../providers/workflow/app_event.dart';
import '../../../providers/workflow/group_manager.dart';
import '../../../storage/profile/handlers.dart';
import '../../../storage/profile_provider.dart';

extension on AppEventSubscriptions {
  void pushGroupChanged({
    String? msg,
    required List<GroupUUID> uuidList,
    GroupChangeType changeType = GroupChangeType.unknown,
  }) => push(
    GroupChangedEvent(
      msg: msg,
      uuidList: uuidList,
      changeType: changeType,
      trace: const {
        AppEventPageSource.groupManage: {AppEventFunctionSource.groupChanged},
      },
    ),
  );
}

/// Page-scoped ViewModel for the Group management page.
///
/// Sort type/direction are nullable session overrides: when null, the effective
/// value falls back to the global [DisplayGroupModeProfileHandler] config.
///
/// Event push is centralized through [AppEventSubscriptions] via the
/// file-private [_GroupEventPush] extension, keeping trace construction in one
/// place.
class GroupManageViewModel extends ChangeNotifier
    with ProfileHandlerLoadedMixin
    implements
        ProviderMounted,
        AppEventLoaded,
        PopScopeHandler,
        AppEventSubscriber {
  GroupManageViewModel({String? initialGroupUUID})
    : _initialGroupUUID = initialGroupUUID;

  // dependencies
  GroupManager? _groupManager;
  DisplayGroupModeProfileHandler? _groupModeHandler;
  NaturalSortExperimentalFeature? _naturalSortHandler;
  AppLanguageProfileHanlder? _languageHandler;

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
  final _sortGuard = SortGuard();

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
  AppEventSubscriptions? _subs;

  @override
  bool shouldReceive(AppEvent event) =>
      !event.isInTrace(AppEventPageSource.groupManage);

  @override
  void handleEvent(AppEvent event) => switch (event) {
    GroupChangedEvent() => _handleGroupChanged(event),
    ReloadDataEvent() => _handleReloadData(event),
    HabitDataChangedEvent() => _handleHabitDataChanged(event),
    HabitStatusChangedEvent() || HabitRecordsChangedEvent() => null,
  };

  void _handleGroupChanged(GroupChangedEvent event) {
    appLog.habit.debug("GroupManage.reload", ex: ["GroupChangedEvent", event]);
    requestReload();
  }

  void _handleReloadData(ReloadDataEvent event) {
    appLog.habit.debug("GroupManage.reload", ex: ["ReloadDataEvent", event]);
    requestReload();
  }

  void _handleHabitDataChanged(HabitDataChangedEvent event) {
    appLog.habit.debug(
      "GroupManage.reload",
      ex: ["HabitDataChangedEvent", event],
    );
    requestReload();
  }

  @override
  void dispose() {
    if (!_mounted) return;
    _subs?.cancelAll();
    _pageLoad.cancel(logName: "$runtimeType.dispose");
    _mounted = false;
    super.dispose();
  }

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    _groupModeHandler = newProfile.getHandler<DisplayGroupModeProfileHandler>();
    _naturalSortHandler = newProfile
        .getHandler<NaturalSortExperimentalFeature>();
    _languageHandler = newProfile.getHandler<AppLanguageProfileHanlder>();
  }

  void attachGroupManager(GroupManager value) {
    _groupManager = value;
  }

  @override
  void updateAppEvent(AppEventBus newAppEvent) {
    _subs?.cancelAll();
    _subs = AppEventSubscriptions(this, newAppEvent)
      ..subscribe<GroupChangedEvent>()
      ..subscribe<ReloadDataEvent>();
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
        _sortGuard.bump();
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
        await _resortData();
        loading.complete();
        if (mounted && listen) notifyListeners();
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

  Future<void> setSortOptions(
    HabitDisplayGroupType type,
    HabitDisplaySortDirection direction,
  ) async {
    _sortType = type;
    _sortDirection = direction;
    await _resortData();
    if (mounted) notifyListeners();
  }

  Future<void> _resortData() async {
    if (_groupCollection == null) return;

    final sortType = effectiveSortType;
    final sortDirection = effectiveSortDirection;

    Future<_GroupsSortableCache> defaultSort() async =>
        _sortableCache.copyWithData(
          _groupCollection!,
          sortType: sortType,
          sortDirection: sortDirection,
        );

    Future<_GroupsSortableCache> naturalSort() async {
      if (sortType != HabitDisplayGroupType.name) return defaultSort();
      if (!(_naturalSortHandler?.enabled ?? false)) return defaultSort();
      final groups = _groupCollection!.toList();
      if (groups.isEmpty) return defaultSort();
      final locale = _languageHandler?.get()?.toLanguageTag();
      try {
        final sorted = await CollationApi.instance.naturalSort(
          items: groups,
          idOf: (g) => g.uuid,
          valueOf: (g) => g.name,
          descending: sortDirection == HabitDisplaySortDirection.desc,
          locale: locale,
        );
        return _GroupsSortableCache(
          sortType: sortType,
          sortDirection: sortDirection,
          lastSortedDataCache: sorted,
        );
      } catch (e) {
        appLog.load.warn('Natural sort failed', ex: [e]);
        return defaultSort();
      }
    }

    _sortableCache =
        await _sortGuard.run(naturalSort, debugLabel: 'GroupManage') ??
        _sortableCache;
  }

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

  @override
  bool get canPop => !_selectionMode;

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
    _subs?.pushGroupChanged(
      msg: "group_manage.deleteSingleGroup",
      uuidList: [uuid],
      changeType: GroupChangeType.deleted,
    );
  }

  Future<void> deleteSelectedGroups() async {
    final uuids = List<String>.of(_selectedGroupUUIDs);
    final gm = _groupManager;
    if (gm == null || uuids.isEmpty) return;
    await gm.deleteGroups(uuids);
    if (!mounted) return;
    _lastDeletedUUIDs = uuids;
    exitSelectionMode();
    requestReload();
    _subs?.pushGroupChanged(
      msg: "group_manage.deleteSelectedGroups",
      uuidList: uuids,
      changeType: GroupChangeType.deleted,
    );
  }

  Future<void> undoLastDelete() async {
    final uuids = List<String>.of(_lastDeletedUUIDs);
    _lastDeletedUUIDs = [];
    final all = await _groupManager?.loadAllActiveGroups() ?? [];
    if (!mounted) return;
    final lookup = all.map((g) => g.uuid).toSet();
    final toRestore = uuids.where((uuid) => !lookup.contains(uuid)).toList();
    if (toRestore.isNotEmpty) {
      await _groupManager?.restoreGroups(toRestore);
      if (!mounted) return;
    }
    requestReload();
    _subs?.pushGroupChanged(
      msg: "group_manage.undoLastDelete",
      uuidList: uuids,
      changeType: GroupChangeType.created,
    );
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
    _subs?.pushGroupChanged(
      msg: "group_manage.createGroup",
      uuidList: [result.uuid],
      changeType: GroupChangeType.created,
    );
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
    _subs?.pushGroupChanged(
      msg: "group_manage.updateGroup",
      uuidList: [uuid],
      changeType: GroupChangeType.updated,
    );
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
    _subs?.pushGroupChanged(
      msg: "group_manage.onGroupReorderComplete",
      uuidList: ordered.map((g) => g.uuid).toList(),
      changeType: GroupChangeType.updated,
    );
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
    final sorted = List.of(collection.toList()).sortedBy(
      HabitGroupOrderType.fromGroupType(sortType) ?? defaultGroupOrderType,
      sortDirection,
    );
    return _GroupsSortableCache(
      sortType: sortType,
      sortDirection: sortDirection,
      lastSortedDataCache: sorted,
    );
  }
}

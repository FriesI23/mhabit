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
import 'package:flutter/widgets.dart';

import '../../../common/types.dart';
import '../../../logging/helper.dart';
import '../../../models/app_event.dart';
import '../../../models/habit_group.dart';
import '../../../models/habit_summary.dart';
import '../../../pages/common/_widgets/group_edit_form.dart';
import '../../../providers/app_ui/app_caches.dart';
import '../../../providers/support/commons.dart';
import '../../../providers/support/page_load_runtime.dart';
import '../../../providers/workflow/app_event.dart';
import '../../../providers/workflow/group_manager.dart';
import '../helpers.dart';

/// Dialog-scoped ViewModel for the habit-group batch-modify selector.
///
/// Owns group-list loading, selection state, skip-confirm persistence, and
/// the confirm-orchestration logic (one-step vs two-step flow).  Created
/// when the dialog opens and disposed when it closes — not added to
/// [PageProviders].
///
/// Subscribes to [AppEventBus] so the group list refreshes automatically
/// when groups are created / updated / deleted elsewhere while the dialog
/// is open (same pattern as [GroupManageViewModel]).
class HabitGroupModifyViewModel extends ChangeNotifier
    implements ProviderMounted {
  final List<HabitSummaryData> _selectedData;

  GroupManager? _groupManager;
  AppCachesViewModel? _appCaches;
  AppEventBus? _appEventBus;

  //#region lifecycle

  bool _mounted = true;
  StreamSubscription<GroupChangedEvent>? _groupEventSub;
  StreamSubscription<ReloadDataEvent>? _reloadDataSub;
  final _pageLoad = PageLoadRuntime();
  bool _nextRefreshForceReload = false;

  @override
  bool get mounted => _mounted;

  bool get hasLoad => _pageLoad.hasLoad;

  bool get hasLoaded => _pageLoad.hasLoaded;

  bool consumeForceReloadFlag() {
    final result = _nextRefreshForceReload;
    _nextRefreshForceReload = false;
    return result;
  }

  @override
  void dispose() {
    if (!_mounted) return;
    _groupEventSub?.cancel();
    _reloadDataSub?.cancel();
    _pageLoad.cancel(logName: "$runtimeType.dispose");
    _mounted = false;
    super.dispose();
  }

  //#endregion

  //#region state

  FormMode _mode = FormMode.select;

  List<HabitGroupData> _groups = [];
  GroupUUID? _selectedGroupId;
  bool _skipConfirm = false;

  /// Form key for the create-mode form, set by the UI so that
  /// [actionsBuilder] can trigger validation.
  // ignore: use_setters_to_change_properties
  GlobalKey<GroupEditFormState>? createFormKey;

  FormMode get mode => _mode;
  bool get isCreateMode => _mode == FormMode.create;
  bool get isSelectMode => _mode == FormMode.select;

  List<HabitGroupData> get groups => _groups;
  GroupUUID? get selectedGroupId => _selectedGroupId;
  bool get skipConfirm => _skipConfirm;

  /// Whether the flow should use the two-step confirm dialog (selected
  /// habits are provided and group-name lookup is available).
  bool get isTwoStep => _selectedData.isNotEmpty;

  /// The originally selected habits (for creating confirm-dialog handlers
  /// in create mode).
  List<HabitSummaryData> get selectedData => _selectedData;

  HabitGroupModifyViewModel({required List<HabitSummaryData> selectedData})
    : _selectedData = selectedData;

  //#endregion

  //#region dependency wiring

  void attachGroupManager(GroupManager gm) {
    _groupManager = gm;
  }

  void attachCaches(AppCachesViewModel caches) {
    _appCaches = caches;
    _skipConfirm = caches.appFlagSkipGroupChangeConfirm;
  }

  /// Subscribes to group-changed and reload-data events so the group list
  /// stays current while the dialog is open.
  ///
  /// Mirrors [GroupManageViewModel.updateAppEvent].
  void attachAppEventBus(AppEventBus bus) {
    _appEventBus = bus;
    _groupEventSub?.cancel();
    _reloadDataSub?.cancel();
    _groupEventSub = bus.on<GroupChangedEvent>().listen((_) {
      appLog.habit.debug("HabitGroupModify.reload", ex: ["GroupChangedEvent"]);
      requestReload();
    });
    _reloadDataSub = bus.on<ReloadDataEvent>().listen((event) {
      if (event.isInTrace(AppEventPageSource.groupManage)) return;
      appLog.habit.debug(
        "HabitGroupModify.reload",
        ex: ["ReloadDataEvent", event],
      );
      requestReload();
    });
  }

  void requestReload() {
    _nextRefreshForceReload = true;
    _pageLoad.cancel(logName: "$runtimeType.requestReload");
    notifyListeners();
  }

  void _pushGroupChanged(String? uuid, GroupChangeType changeType) {
    _appEventBus?.push(
      GroupChangedEvent(
        msg: "HabitGroupModify",
        groupUUID: uuid,
        changeType: changeType,
        trace: {
          AppEventPageSource.habitDisplay: {
            AppEventFunctionSource.groupChanged,
          },
        },
      ),
    );
  }

  //#endregion

  void selectGroup(GroupUUID? uuid) {
    if (_selectedGroupId == uuid) return;
    _selectedGroupId = uuid;
    notifyListeners();
  }

  void toggleSkipConfirm(bool v) {
    if (_skipConfirm == v) return;
    _skipConfirm = v;
    _appCaches?.updateAppFlagSkipGroupChangeConfirm(v);
    notifyListeners();
  }

  void switchToCreateMode() {
    if (_mode == FormMode.create) return;
    _mode = FormMode.create;
    notifyListeners();
  }

  void switchToSelectMode() {
    if (_mode == FormMode.select) return;
    _mode = FormMode.select;
    notifyListeners();
  }

  //#region group creation

  /// Creates a new group via [GroupManager], refreshes the group list, and
  /// auto-selects the newly created group.
  ///
  /// Returns the created [HabitGroupData].  Throws [StateError] when
  /// [GroupManager] has not been attached.
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
    _pushGroupChanged(result.uuid, GroupChangeType.created);
    _selectedGroupId = result.uuid;
    requestReload();
    return result;
  }

  /// Loads the active group list from [GroupManager].
  ///
  /// Sets [selectedGroupId] to the first group on first load when no
  /// selection has been made yet.  On subsequent reloads (e.g. triggered
  /// by [AppEventBus]), clears a stale selection if the previously selected
  /// group no longer exists.
  ///
  /// Uses [PageLoadRuntime] to manage concurrent load requests (same pattern
  /// as [GroupManageViewModel.loadGroups]).
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

        final gm = _groupManager;
        if (gm == null) {
          return loadingFailed(loading, ["groupManager not attached"]);
        }
        final collection = await gm.tryLoadGroupCollection();
        if (!mounted) {
          return loadingFailed(loading, ["viewmodel disposed"]);
        }
        if (loading.isCanceled) return loadingCancelled(loading);
        if (loading.isCompleted) return;

        _groups = collection?.toList() ?? [];
        if (_selectedGroupId != null &&
            !_groups.any((g) => g.uuid == _selectedGroupId)) {
          _selectedGroupId = _groups.isNotEmpty ? _groups.first.uuid : null;
        } else if (_selectedGroupId == null && _groups.isNotEmpty) {
          _selectedGroupId = _groups.first.uuid;
        }

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

  //#endregion

  String? getGroupName(GroupUUID? uuid) {
    if (uuid == null) return null;
    for (final g in _groups) {
      if (g.uuid == uuid) return g.name;
    }
    return null;
  }

  String? get targetGroupName =>
      _selectedGroupId != null ? getGroupName(_selectedGroupId) : null;

  //#region handler (lazy, cached)

  HabitGroupModifyHandler? _cachedHandler;
  GroupUUID? _cachedHandlerGroupId;

  HabitGroupModifyHandler _handler() {
    if (_cachedHandler == null || _cachedHandlerGroupId != _selectedGroupId) {
      _cachedHandler = HabitGroupModifyHandler(
        selectedData: _selectedData,
        getGroupName: getGroupName,
        targetGroupId: _selectedGroupId,
      );
      _cachedHandlerGroupId = _selectedGroupId;
    }
    return _cachedHandler!;
  }

  List<HabitGroupModifyItem> get affectedHabits => _handler().affectedHabits;

  bool get allAlreadyInTarget => _handler().allAlreadyInTarget;

  /// Source groups for the confirm-dialog display.
  Map<String?, List<HabitGroupModifyItem>> get sourceGroups =>
      _handler().sourceGroups;
}

//#endregion

/// Internal mode for the group-modify selector; not part of the public API.
enum FormMode { select, create }

// Copyright 2025 Fries_I23
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

import '../common/types.dart';
import 'habit_form.dart';

enum AppEventPageSource {
  appSetting,
  habitDisplay,
  habitToday,
  habitDetail,
  habitEdit,
  habitStatusChanger
}

enum AppEventFunctionSource {
  habitImport,
  databaseCleared,
  habitCreated,
  habitChanged,
  recordChanged
}

abstract interface class AppEvent {
  Map<AppEventPageSource, Set<AppEventFunctionSource>> get trace;
}

abstract class AppEventBase implements AppEvent {
  @override
  final Map<AppEventPageSource, Set<AppEventFunctionSource>> trace;

  const AppEventBase({this.trace = const {}});

  AppEventBase extendSource(
      AppEventPageSource page, AppEventFunctionSource function);

  bool isInTrace(AppEventPageSource page, [AppEventFunctionSource? function]) {
    final functions = trace[page];
    if (functions == null) return false;
    return function == null || functions.contains(function);
  }

  bool isAllInTrace(
          Iterable<(AppEventPageSource, AppEventFunctionSource?)> sources) =>
      sources.every((entry) => isInTrace(entry.$1, entry.$2));

  Map<AppEventPageSource, Set<AppEventFunctionSource>> buildNewTrace(
      AppEventPageSource page, AppEventFunctionSource function) {
    return {
      ...trace,
      page: {if (trace.containsKey(page)) ...trace[page]!, function},
    };
  }
}

final class ReloadDataEvent extends AppEventBase {
  final String? msg;
  final bool exiEditMode;
  final bool clearSnackBar;

  const ReloadDataEvent({
    this.msg,
    this.exiEditMode = false,
    this.clearSnackBar = false,
    super.trace,
  });

  @override
  ReloadDataEvent extendSource(
          AppEventPageSource page, AppEventFunctionSource function) =>
      ReloadDataEvent(
        msg: msg,
        exiEditMode: exiEditMode,
        clearSnackBar: clearSnackBar,
        trace: buildNewTrace(page, function),
      );

  @override
  String toString() {
    final bf = StringBuffer("ReloadDataEvent(");
    final data = <String>[
      if (msg != null) "msg=$msg",
      "exiEditMode=$exiEditMode",
      "clearSnackBar=$clearSnackBar",
      "trace=$trace",
    ];
    bf.writeAll(data, ",");
    bf.write(")");
    return bf.toString();
  }
}

final class HabitStatusChangedEvent extends AppEventBase {
  final String? msg;
  final List<HabitUUID> uuidList;
  final HabitStatus status;

  const HabitStatusChangedEvent({
    this.msg,
    required this.uuidList,
    required this.status,
    super.trace,
  });

  @override
  HabitStatusChangedEvent extendSource(
          AppEventPageSource page, AppEventFunctionSource function) =>
      HabitStatusChangedEvent(
        msg: msg,
        uuidList: uuidList,
        status: status,
        trace: buildNewTrace(page, function),
      );

  @override
  String toString() {
    final bf = StringBuffer("HabitStatusChangedEvent(");
    final data = <String>[
      if (msg != null) "msg=$msg",
      "uuidList=$uuidList",
      "status=$status",
      "trace=$trace",
    ];
    bf.writeAll(data, ",");
    bf.write(")");
    return bf.toString();
  }
}

final class HabitRecordsChangedEvents extends AppEventBase {
  final String? msg;
  final List<HabitUUID> uuidList;
  final List<HabitRecordDate> dateList;
  final HabitRecordStatus? status;
  final String? reason;

  const HabitRecordsChangedEvents({
    this.msg,
    required this.uuidList,
    required this.dateList,
    this.status,
    this.reason,
    super.trace,
  }) : assert(status != HabitRecordStatus.unknown);

  @override
  HabitRecordsChangedEvents extendSource(
          AppEventPageSource page, AppEventFunctionSource function) =>
      HabitRecordsChangedEvents(
        msg: msg,
        uuidList: uuidList,
        dateList: dateList,
        status: status,
        reason: reason,
        trace: buildNewTrace(page, function),
      );

  @override
  String toString() {
    final bf = StringBuffer("HabitRecordsChangedEvents(");
    final data = <String>[
      if (msg != null) "msg=$msg",
      "uuidList=$uuidList",
      "dateList=$dateList",
      "status=$status",
      "reason=$reason",
      "trace=$trace",
    ];
    bf.writeAll(data, ",");
    bf.write(")");
    return bf.toString();
  }
}

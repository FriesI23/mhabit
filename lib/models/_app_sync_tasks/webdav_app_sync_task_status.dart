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

import '../../l10n/localizations.dart';
import 'app_sync_task.dart';
import 'webdav_app_sync_models.dart';

enum WebDavAppSyncTaskResultStatus {
  success,
  cancelled,
  failed,
  multi;

  String getStatusTextString([
    WebDavAppSyncTaskResultSubStatus? reason,
    L10n? l10n,
  ]) {
    if (l10n != null) {
      return reason == null
          ? l10n.appSync_webdav_resultStatus(name)
          : l10n.appSync_webdav_resultStatus_withReason(
              name,
              reason.getReasonString(l10n),
            );
    }
    final baseText = switch (this) {
      success => "Completed",
      cancelled => "Cancelled",
      failed => "Failed",
      multi => "Multiple statuses",
    };
    return reason == null
        ? baseText
        : "$baseText with ${reason.getReasonString()}";
  }
}

enum WebDavAppSyncTaskResultSubStatus {
  timeout,
  error,
  userAction,
  missingHabitUuid,
  empty;

  String getReasonString([L10n? l10n]) {
    if (l10n != null) {
      return l10n.appSync_webdav_resultReason(name);
    }
    return switch (this) {
      WebDavAppSyncTaskResultSubStatus.timeout => "timeout",
      WebDavAppSyncTaskResultSubStatus.error => "error",
      WebDavAppSyncTaskResultSubStatus.userAction => "user action",
      WebDavAppSyncTaskResultSubStatus.missingHabitUuid => "missing habit UUID",
      WebDavAppSyncTaskResultSubStatus.empty => "empty data",
    };
  }
}

class WebDavAppSyncTaskResult implements AppSyncTaskResult {
  final WebDavAppSyncTaskResultStatus status;
  final WebDavAppSyncTaskResultSubStatus? reason;

  @override
  final ({Object? error, StackTrace? trace}) error;

  const WebDavAppSyncTaskResult._({
    required this.status,
    this.reason,
    Object? error,
    StackTrace? trace,
  }) : error = (error: error, trace: trace);

  const WebDavAppSyncTaskResult.success({
    WebDavAppSyncTaskResultSubStatus? reason,
  }) : this._(status: WebDavAppSyncTaskResultStatus.success, reason: reason);

  const WebDavAppSyncTaskResult.failed({
    WebDavAppSyncTaskResultSubStatus? reason,
    Object? error,
    StackTrace? trace,
  }) : this._(
         status: WebDavAppSyncTaskResultStatus.failed,
         reason: reason,
         error: error,
         trace: trace,
       );

  const WebDavAppSyncTaskResult.cancelled({
    WebDavAppSyncTaskResultSubStatus? reason,
    Object? error,
    StackTrace? trace,
  }) : this._(
         status: WebDavAppSyncTaskResultStatus.cancelled,
         reason: reason,
         error: error,
         trace: trace,
       );

  const WebDavAppSyncTaskResult.timeout({Object? error, StackTrace? trace})
    : this.failed(
        reason: WebDavAppSyncTaskResultSubStatus.timeout,
        error: error,
        trace: trace,
      );

  const WebDavAppSyncTaskResult.error({Object? error, StackTrace? trace})
    : this.failed(
        reason: WebDavAppSyncTaskResultSubStatus.error,
        error: error,
        trace: trace,
      );

  factory WebDavAppSyncTaskResult.multi({
    required Map<WebDavAppSyncHabitInfo, WebDavAppSyncTaskResult> results,
    Object? error,
    StackTrace? trace,
  }) => WebDavAppSyncTaskMultiResult(
    habitResults: results,
    error: error,
    trace: trace,
  );

  @override
  bool get isCancelled => status == WebDavAppSyncTaskResultStatus.cancelled;

  @override
  bool get isSuccessed => status == WebDavAppSyncTaskResultStatus.success;

  @override
  bool get isTimeout => reason == WebDavAppSyncTaskResultSubStatus.timeout;

  @override
  bool get withError =>
      reason == WebDavAppSyncTaskResultSubStatus.error || error.error != null;

  @override
  String toString() =>
      "WebDavAppSyncTaskResult(status=$status, reason=$reason, "
      "error=${error.error})";
}

class WebDavAppSyncTaskMultiResult extends WebDavAppSyncTaskResult {
  final Map<WebDavAppSyncHabitInfo, WebDavAppSyncTaskResult> habitResults;

  const WebDavAppSyncTaskMultiResult({
    super.error,
    super.trace,
    this.habitResults = const {},
  }) : super._(status: WebDavAppSyncTaskResultStatus.multi);

  @override
  bool get isSuccessed {
    final result = habitResults.values.every((e) => e.isSuccessed);
    return result || super.isSuccessed;
  }

  @override
  bool get isCancelled {
    final result =
        habitResults.values.every((e) => e.isCancelled || e.isSuccessed) &&
        habitResults.values.any((e) => e.isCancelled);
    return result || super.isCancelled;
  }

  @override
  bool get isTimeout {
    final result = habitResults.values.every((e) => e.isTimeout);
    return result || super.isTimeout;
  }

  @override
  String toString() {
    final counterMap =
        <
          (WebDavAppSyncTaskResultStatus, WebDavAppSyncTaskResultSubStatus?),
          int
        >{};
    for (var entry in habitResults.entries) {
      final key = (entry.value.status, entry.value.reason);
      counterMap[key] = (counterMap[key] ?? 0) + 1;
    }

    return "WebDavAppSyncTaskMultiResult("
        "error=${error.error}, habits=(all=${habitResults.length}, "
        "${counterMap.entries.map((e) => "${e.key}=${e.value}").join(", ")}))";
  }
}

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

import 'dart:async';

import '../app_sync_server.dart';
import 'app_sync_task.dart';

enum WebDavAppSyncTaskResultStatus { success, cancelled, timeout, error }

class WebDavAppSyncTaskResult implements AppSyncTaskResult {
  final WebDavAppSyncTaskResultStatus status;

  @override
  final ({Object? error, StackTrace? trace}) error;

  const WebDavAppSyncTaskResult._(
      {required this.status, Object? error, StackTrace? trace})
      : error = (error: error, trace: trace);

  const WebDavAppSyncTaskResult.success()
      : this._(status: WebDavAppSyncTaskResultStatus.success);

  const WebDavAppSyncTaskResult.cancelled({Object? error, StackTrace? trace})
      : this._(
          status: WebDavAppSyncTaskResultStatus.cancelled,
          error: error,
          trace: trace,
        );

  const WebDavAppSyncTaskResult.timeout({Object? error, StackTrace? trace})
      : this._(
          status: WebDavAppSyncTaskResultStatus.timeout,
          error: error,
          trace: trace,
        );

  const WebDavAppSyncTaskResult.error({Object? error, StackTrace? trace})
      : this._(
          status: WebDavAppSyncTaskResultStatus.error,
          error: error,
          trace: trace,
        );

  @override
  bool get isCancelled => status == WebDavAppSyncTaskResultStatus.cancelled;

  @override
  bool get isSuccessed => status == WebDavAppSyncTaskResultStatus.success;

  @override
  bool get isTimeout => status == WebDavAppSyncTaskResultStatus.timeout;

  @override
  bool get withError =>
      status == WebDavAppSyncTaskResultStatus.error || error.error != null;
}

class WebDavAppSyncTask extends AppSyncTaskFramework<AppSyncTaskResult> {
  @override
  final AppSyncServer config;

  WebDavAppSyncTask({required this.config, super.timeout = Duration.zero});

  @override
  Future<AppSyncTaskResult> error([Object? e, StackTrace? s]) =>
      Future.sync(() => switch (e) {
            TimeoutException() =>
              WebDavAppSyncTaskResult.timeout(error: e, trace: s),
            _ => WebDavAppSyncTaskResult.error(error: e, trace: s),
          });

  @override
  Future<AppSyncTaskResult> exec() {
    // TODO: implement exec
    return Future.delayed(
        const Duration(seconds: 3), WebDavAppSyncTaskResult.success);
  }
}

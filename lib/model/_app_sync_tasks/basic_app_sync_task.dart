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

enum BasicAppSyncTaskResultStatus { success, cancelled, timeout, error }

class BasicAppSyncTaskResult implements AppSyncTaskResult {
  final BasicAppSyncTaskResultStatus status;

  @override
  final ({Object? error, StackTrace? trace}) error;

  const BasicAppSyncTaskResult._(
      {required this.status, Object? error, StackTrace? trace})
      : error = (error: error, trace: trace);

  const BasicAppSyncTaskResult.success()
      : this._(status: BasicAppSyncTaskResultStatus.success);

  const BasicAppSyncTaskResult.cancelled({Object? error, StackTrace? trace})
      : this._(
          status: BasicAppSyncTaskResultStatus.cancelled,
          error: error,
          trace: trace,
        );

  const BasicAppSyncTaskResult.timeout({Object? error, StackTrace? trace})
      : this._(
          status: BasicAppSyncTaskResultStatus.timeout,
          error: error,
          trace: trace,
        );

  const BasicAppSyncTaskResult.error({Object? error, StackTrace? trace})
      : this._(
          status: BasicAppSyncTaskResultStatus.error,
          error: error,
          trace: trace,
        );

  @override
  bool get isCancelled => status == BasicAppSyncTaskResultStatus.cancelled;

  @override
  bool get isSuccessed => status == BasicAppSyncTaskResultStatus.success;

  @override
  bool get isTimeout => status == BasicAppSyncTaskResultStatus.timeout;

  @override
  bool get withError =>
      status == BasicAppSyncTaskResultStatus.error || error.error != null;
}

class BasicAppSyncTask extends AppSyncTaskFramework<AppSyncTaskResult> {
  @override
  final AppSyncServer config;
  @override
  final String sessionId;

  Future<AppSyncTaskResult> Function(AppSyncTask<AppSyncTaskResult> task)?
      onExec;

  BasicAppSyncTask(
      {required this.config,
      required this.onExec,
      this.sessionId = 'fake-session-id',
      super.timeout = Duration.zero});

  @override
  Future<AppSyncTaskResult> error([Object? e, StackTrace? s]) =>
      Future.sync(() => switch (e) {
            TimeoutException() =>
              BasicAppSyncTaskResult.timeout(error: e, trace: s),
            _ => BasicAppSyncTaskResult.error(error: e, trace: s),
          });

  @override
  Future<AppSyncTaskResult> exec() {
    Future<BasicAppSyncTaskResult> defaultOnExec(BasicAppSyncTask task) =>
        Future.sync(BasicAppSyncTaskResult.success);

    return (onExec ?? defaultOnExec)(this);
  }
}

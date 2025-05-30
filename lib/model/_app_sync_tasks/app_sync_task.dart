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

abstract interface class AppSyncTaskResult {
  ({Object? error, StackTrace? trace}) get error;

  bool get isCancelled;

  bool get isSuccessed;

  bool get isTimeout;

  bool get withError;
}

enum AppSyncTaskStatus { idle, running, cancelling, cancelled, completed }

abstract interface class AppSyncContext {
  String get sessionId;

  AppSyncServer get config;

  AppSyncTaskStatus get status;

  bool get isProcessing;

  bool get isCancalling;

  bool get isDone;
}

abstract interface class AppSyncTask<T extends AppSyncTaskResult>
    implements AppSyncContext {
  Future<T> get result;

  Future<T> run();

  Future<void> cancel();
}

abstract interface class AppSyncSubTask<T> {
  Future<T> run(AppSyncContext context);
}

abstract class AppSyncTaskFramework<T extends AppSyncTaskResult>
    implements AppSyncTask<T> {
  AppSyncTaskStatus _status = AppSyncTaskStatus.idle;
  final Completer<T> _completer;
  final Duration timeout;

  AppSyncTaskFramework({required this.timeout}) : _completer = Completer();

  @override
  AppSyncTaskStatus get status => _status;

  @override
  Future<T> get result => _completer.future;

  @override
  bool get isProcessing =>
      status == AppSyncTaskStatus.running ||
      status == AppSyncTaskStatus.cancelling;

  @override
  bool get isCancalling =>
      status == AppSyncTaskStatus.cancelling ||
      status == AppSyncTaskStatus.cancelled;

  @override
  bool get isDone =>
      status == AppSyncTaskStatus.completed ||
      status == AppSyncTaskStatus.cancelled;

  Future<T> exec();

  FutureOr<T> error(Object e, StackTrace s);

  @override
  Future<T> run() {
    if (_status != AppSyncTaskStatus.idle) return result;

    _status = AppSyncTaskStatus.running;
    (timeout != Duration.zero ? exec().timeout(timeout) : exec())
        .onError(error)
        .then((result) {
      if (_completer.isCompleted) return;
      _completer.complete(result);
      _status = _status == AppSyncTaskStatus.cancelling && result.isCancelled
          ? AppSyncTaskStatus.cancelled
          : AppSyncTaskStatus.completed;
    }).catchError((e, s) {
      if (_completer.isCompleted) return;
      _completer.completeError(e, s);
    });

    return result;
  }

  @override
  Future<void> cancel() {
    if (_status == AppSyncTaskStatus.running) {
      _status = AppSyncTaskStatus.cancelling;
    }
    return result;
  }
}

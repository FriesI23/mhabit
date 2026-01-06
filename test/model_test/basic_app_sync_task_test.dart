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

// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/models/app_sync_tasks.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

@GenerateMocks([AppSyncServer])
import 'basic_app_sync_task_test.mocks.dart';

void main() {
  group('Test BasicAppSyncTask', () {
    late MockAppSyncServer mockServer;

    setUp(() {
      mockServer = MockAppSyncServer();
    });

    test('Task should start in idle state', () {
      final task = BasicAppSyncTask(
        config: mockServer,
        onExec: (task) async => BasicAppSyncTaskResult.success(),
      );
      expect(task.status, AppSyncTaskStatus.idle);
    });

    test('Task should transition to running state when started', () async {
      final task = BasicAppSyncTask(
        config: mockServer,
        onExec: (task) async {
          expect(task.status, AppSyncTaskStatus.running);
          return BasicAppSyncTaskResult.success();
        },
      );
      await task.run();
    });

    test('Task should complete and transition to completed state', () async {
      final task = BasicAppSyncTask(
        config: mockServer,
        onExec: (task) async => BasicAppSyncTaskResult.success(),
      );
      await task.run();
      expect(task.status, AppSyncTaskStatus.completed);
    });

    test(
      'Cancelling a running task should transition to cancelling state',
      () async {
        final result = BasicAppSyncTaskResult.cancelled();
        final task = BasicAppSyncTask(
          config: mockServer,
          onExec: (task) async {
            await Future.delayed(Duration(milliseconds: 200));
            if (task.isCancalling) return result;
            return BasicAppSyncTaskResult.success();
          },
        );
        task.run();
        await Future.delayed(Duration(milliseconds: 100));
        task.cancel();
        expect(task.status, AppSyncTaskStatus.cancelling);
        expect(task.result, completion(result));
      },
    );

    test(
      'Task should return cancelled status if cancelled before completion',
      () async {
        final task = BasicAppSyncTask(
          config: mockServer,
          onExec: (task) async {
            await Future.delayed(Duration(milliseconds: 200));
            if (task.isCancalling) {
              return BasicAppSyncTaskResult.cancelled();
            }
            return BasicAppSyncTaskResult.success();
          },
        );
        task.run();
        await Future.delayed(Duration(milliseconds: 100));
        await task.cancel();
        final result = await task.result;
        expect(result.isCancelled, isTrue);
        expect(result.isSuccessed, isFalse);
        expect(result.isTimeout, isFalse);
        expect(result.withError, isFalse);
        expect(task.status, AppSyncTaskStatus.cancelled);
      },
    );

    test('Task should timeout and return timeout status', () async {
      final task = BasicAppSyncTask(
        config: mockServer,
        timeout: Duration(milliseconds: 100),
        onExec: (task) async {
          await Future.delayed(Duration(milliseconds: 200));
          return BasicAppSyncTaskResult.success();
        },
      );
      final result = await task.run();
      expect(result.isCancelled, isFalse);
      expect(result.isSuccessed, isFalse);
      expect(result.isTimeout, isTrue);
      expect(result.withError, isTrue);
      expect(result.error.error, TypeMatcher<TimeoutException>());
      expect(result.error.trace, TypeMatcher<StackTrace>());
    });

    test('Task throwing exception should return error status', () async {
      final task = BasicAppSyncTask(
        config: mockServer,
        onExec: (task) async {
          throw Exception('Test exception');
        },
      );
      final result = await task.run();
      expect(result.isCancelled, isFalse);
      expect(result.isSuccessed, isFalse);
      expect(result.isTimeout, isFalse);
      expect(result.withError, isTrue);
      expect(result.error.error!.toString(), contains('Test exception'));
    });
  });
}

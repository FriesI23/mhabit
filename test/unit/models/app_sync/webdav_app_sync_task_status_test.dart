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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/_app_sync_tasks/webdav_app_sync_models.dart';
import 'package:mhabit/models/_app_sync_tasks/webdav_app_sync_task_status.dart';

WebDavAppSyncHabitInfo _habit(String uuid) => WebDavAppSyncHabitInfo(
  configUUID: 'cfg-1',
  uuid: uuid,
  status: WebDavAppSyncInfoStatus.local,
);

WebDavAppSyncGroupInfo _group(String uuid) => WebDavAppSyncGroupInfo(
  configUUID: 'cfg-1',
  uuid: uuid,
  status: WebDavAppSyncInfoStatus.local,
);

void main() {
  group('WebDavAppSyncTaskResult.multi', () {
    test('default groupResults is empty', () {
      final result = WebDavAppSyncTaskResult.multi(results: {});
      expect(result, isA<WebDavAppSyncTaskMultiResult>());
      final multi = result as WebDavAppSyncTaskMultiResult;
      expect(multi.habitResults, isEmpty);
      expect(multi.groupResults, isEmpty);
    });

    test('passes groupResults through', () {
      final groups = <WebDavAppSyncGroupInfo, WebDavAppSyncTaskResult>{
        _group('g1'): const WebDavAppSyncTaskResult.success(),
      };
      final result = WebDavAppSyncTaskResult.multi(
        results: {},
        groupResults: groups,
      );
      final multi = result as WebDavAppSyncTaskMultiResult;
      expect(multi.groupResults, same(groups));
    });
  });

  group('WebDavAppSyncTaskMultiResult.isSuccessed', () {
    test('true when all habits and groups succeed', () {
      final multi = WebDavAppSyncTaskMultiResult(
        habitResults: {_habit('h1'): const WebDavAppSyncTaskResult.success()},
        groupResults: {_group('g1'): const WebDavAppSyncTaskResult.success()},
      );
      expect(multi.isSuccessed, isTrue);
    });

    test('false when any habit fails', () {
      final multi = WebDavAppSyncTaskMultiResult(
        habitResults: {
          _habit('h1'): const WebDavAppSyncTaskResult.success(),
          _habit('h2'): const WebDavAppSyncTaskResult.failed(),
        },
        groupResults: {_group('g1'): const WebDavAppSyncTaskResult.success()},
      );
      expect(multi.isSuccessed, isFalse);
    });

    test('false when any group fails', () {
      final multi = WebDavAppSyncTaskMultiResult(
        habitResults: {_habit('h1'): const WebDavAppSyncTaskResult.success()},
        groupResults: {
          _group('g1'): const WebDavAppSyncTaskResult.failed(
            reason: WebDavAppSyncTaskResultSubStatus.error,
          ),
        },
      );
      expect(multi.isSuccessed, isFalse);
    });

    test('false when only group fails (no habits)', () {
      final multi = WebDavAppSyncTaskMultiResult(
        habitResults: const {},
        groupResults: {
          _group('g1'): const WebDavAppSyncTaskResult.failed(
            reason: WebDavAppSyncTaskResultSubStatus.error,
          ),
        },
      );
      expect(multi.isSuccessed, isFalse);
    });
  });

  group('WebDavAppSyncTaskMultiResult.isCancelled', () {
    test('true when all cancelled (even if no habits)', () {
      final multi = WebDavAppSyncTaskMultiResult(
        habitResults: const {},
        groupResults: {_group('g1'): const WebDavAppSyncTaskResult.cancelled()},
      );
      expect(multi.isCancelled, isTrue);
    });

    test('false when one group failed (not cancelled/succeeded)', () {
      final multi = WebDavAppSyncTaskMultiResult(
        groupResults: {
          _group('g1'): const WebDavAppSyncTaskResult.cancelled(),
          _group('g2'): const WebDavAppSyncTaskResult.failed(),
        },
      );
      expect(multi.isCancelled, isFalse);
    });
  });

  group('WebDavAppSyncTaskMultiResult.isTimeout', () {
    test('true when all results (habits + groups) are timeout', () {
      final multi = WebDavAppSyncTaskMultiResult(
        habitResults: {_habit('h1'): const WebDavAppSyncTaskResult.timeout()},
        groupResults: {_group('g1'): const WebDavAppSyncTaskResult.timeout()},
      );
      expect(multi.isTimeout, isTrue);
    });

    test('false when one group is not timeout', () {
      final multi = WebDavAppSyncTaskMultiResult(
        groupResults: {
          _group('g1'): const WebDavAppSyncTaskResult.timeout(),
          _group('g2'): const WebDavAppSyncTaskResult.success(),
        },
      );
      expect(multi.isTimeout, isFalse);
    });
  });

  group('WebDavAppSyncTaskMultiResult.toString', () {
    test('includes group count', () {
      final multi = WebDavAppSyncTaskMultiResult(
        habitResults: {_habit('h1'): const WebDavAppSyncTaskResult.success()},
        groupResults: {
          _group('g1'): const WebDavAppSyncTaskResult.success(),
          _group('g2'): const WebDavAppSyncTaskResult.success(),
        },
      );
      expect(multi.toString(), contains('groups=(all=2)'));
    });

    test('shows groups=0 when empty', () {
      const multi = WebDavAppSyncTaskMultiResult(
        habitResults: {},
        groupResults: {},
      );
      expect(multi.toString(), contains('groups=(all=0)'));
    });
  });
}

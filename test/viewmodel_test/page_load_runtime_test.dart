// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/providers/support/page_load_runtime.dart';

void main() {
  group('PageLoadRuntime', () {
    test('routes synchronous loadData failures through onError', () async {
      final runtime = PageLoadRuntime();
      final error = StateError('boom');
      Object? caughtError;

      await expectLater(
        runtime.run(
          logName: 'PageLoadRuntime.run',
          alreadyLoadingEx: const ['already loading'],
          loadData: (_) => throw error,
          onError: (loading, e, s) {
            caughtError = e;
            if (!loading.isCompleted) loading.completeError(e, s);
          },
        ),
        throwsA(same(error)),
      );

      expect(caughtError, same(error));
      expect(runtime.hasLoad, isTrue);
      expect(runtime.hasLoaded, isTrue);
      expect(runtime.currentLoadId, 1);
    });
  });
}

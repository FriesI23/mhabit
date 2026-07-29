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
import 'package:mhabit/common/sort_generation.dart';

void main() {
  group('SortGuard', () {
    group('run', () {
      test('returns result when no bump during sort', () async {
        final guard = SortGuard();
        final result = await guard.run(() => 42);
        expect(result, equals(42));
      });

      test('returns null when bump occurs during sort', () async {
        final guard = SortGuard();
        final future = guard.run(() {
          guard.bump(); // reload during sort
          return 42;
        });
        final result = await future;
        expect(result, isNull);
      });

      test('returns result after bump (captured after bump)', () async {
        final guard = SortGuard();
        guard.bump();
        final result = await guard.run(() => 42);
        expect(result, equals(42));
      });
    });

    group('capture / isCurrent', () {
      test('isCurrent returns true when no bump occurred', () {
        final guard = SortGuard();
        final token = guard.capture();
        expect(guard.isCurrent(token), isTrue);
      });

      test('isCurrent returns false after bump', () {
        final guard = SortGuard();
        final token = guard.capture();
        guard.bump();
        expect(guard.isCurrent(token), isFalse);
      });

      test('bump after bump invalidates all prior tokens', () {
        final guard = SortGuard();
        final t1 = guard.capture();
        guard.bump();
        final t2 = guard.capture();
        guard.bump();
        final t3 = guard.capture();

        expect(guard.isCurrent(t1), isFalse);
        expect(guard.isCurrent(t2), isFalse);
        expect(guard.isCurrent(t3), isTrue);
      });
    });
  });
}

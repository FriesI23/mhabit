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
import 'package:mhabit/common/types.dart';
import 'package:mhabit/models/cache.dart';
import 'package:mhabit/storage/profile/profile_helper.dart';

final class _FakeJsonHandler implements ProfileHelperHandler<JsonMap> {
  @override
  final String key = 'test-cache';

  JsonMap? storedValue;
  bool setResult;

  _FakeJsonHandler({this.setResult = true});

  @override
  JsonMap? get() => storedValue == null ? null : {...storedValue!};

  @override
  Future<bool> remove() async {
    storedValue = null;
    return true;
  }

  @override
  Future<bool> set(JsonMap value) async {
    if (setResult) {
      storedValue = {...value};
    }
    return setResult;
  }
}

void main() {
  group('AppCacheDelegate.isDirty', () {
    test('successful update keeps cache clean', () async {
      final handler = _FakeJsonHandler();
      final cache = AppCacheDelegate<_FakeJsonHandler>(handler: handler);

      expect(cache.isDirty, isFalse);

      await cache.updateCache<int>('count', 1);

      expect(cache.isDirty, isFalse);
      expect(cache.getCache<int>('count'), 1);
      expect(handler.storedValue, {'count': 1});
    });

    test('failed update leaves cache dirty and rolls back value', () async {
      final handler = _FakeJsonHandler(setResult: false);
      final cache = AppCacheDelegate<_FakeJsonHandler>(handler: handler);

      expect(cache.isDirty, isFalse);

      await cache.updateCache<int>('count', 1);

      expect(cache.isDirty, isTrue);
      expect(cache.getCache<int>('count'), isNull);
      expect(handler.storedValue, isNull);
    });

    test(
      'successful remove keeps cache clean and returns removed value',
      () async {
        final handler = _FakeJsonHandler();
        final cache = AppCacheDelegate<_FakeJsonHandler>(handler: handler);
        int? removedValue;
        bool? removeResult;

        await cache.updateCache<int>('count', 1);
        await cache.removeCache<int>(
          'count',
          onRemoved: (result, oldValue) {
            removeResult = result;
            removedValue = oldValue;
          },
        );

        expect(cache.isDirty, isFalse);
        expect(cache.getCache<int>('count'), isNull);
        expect(handler.storedValue, isEmpty);
        expect(removeResult, isTrue);
        expect(removedValue, 1);
      },
    );

    test(
      'failed remove keeps cache dirty and restores removed value',
      () async {
        final handler = _FakeJsonHandler();
        final cache = AppCacheDelegate<_FakeJsonHandler>(handler: handler);
        int? removedValue;
        bool? removeResult;

        await cache.updateCache<int>('count', 1);
        handler.setResult = false;

        await cache.removeCache<int>(
          'count',
          onRemoved: (result, oldValue) {
            removeResult = result;
            removedValue = oldValue;
          },
        );

        expect(cache.isDirty, isTrue);
        expect(cache.getCache<int>('count'), 1);
        expect(handler.storedValue, {'count': 1});
        expect(removeResult, isFalse);
        expect(removedValue, 1);
      },
    );

    test('successful clear keeps cache clean and empties cache', () async {
      final handler = _FakeJsonHandler();
      final cache = AppCacheDelegate<_FakeJsonHandler>(handler: handler);
      bool? clearResult;

      await cache.updateCache<int>('count', 1);
      await cache.clear(onClear: (result) => clearResult = result);

      expect(cache.isDirty, isFalse);
      expect(cache.getCache<int>('count'), isNull);
      expect(handler.storedValue, isEmpty);
      expect(clearResult, isTrue);
    });

    test('failed clear keeps cache dirty and restores old cache', () async {
      final handler = _FakeJsonHandler();
      final cache = AppCacheDelegate<_FakeJsonHandler>(handler: handler);
      bool? clearResult;

      await cache.updateCache<int>('count', 1);
      handler.setResult = false;

      await cache.clear(onClear: (result) => clearResult = result);

      expect(cache.isDirty, isTrue);
      expect(cache.getCache<int>('count'), 1);
      expect(handler.storedValue, {'count': 1});
      expect(clearResult, isFalse);
    });
  });
}

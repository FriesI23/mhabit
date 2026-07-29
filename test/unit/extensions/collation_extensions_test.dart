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
import 'package:mhabit/extensions/collation_extensions.dart';

/// Simple record for testing.
typedef _Item = ({String id, String name});

_Item _i(String id, String name) => (id: id, name: name);

void main() {
  group('sortByRank', () {
    test('sorts by rank order (asc)', () {
      final items = [_i('c', 'C'), _i('a', 'A'), _i('b', 'B')];
      final result = sortByRank(
        items: items,
        rankedIds: ['a', 'b', 'c'],
        idOf: (e) => e.id,
        valueOf: (e) => e.name,
      );
      expect(result.map((e) => e.id), ['a', 'b', 'c']);
    });

    test('sorts by rank order (desc)', () {
      final items = [_i('c', 'C'), _i('a', 'A'), _i('b', 'B')];
      final result = sortByRank(
        items: items,
        rankedIds: ['a', 'b', 'c'],
        idOf: (e) => e.id,
        valueOf: (e) => e.name,
        descending: true,
      );
      expect(result.map((e) => e.id), ['c', 'b', 'a']);
    });

    test('falls back to compareTo for ids not in rank', () {
      final items = [_i('x', 'X'), _i('a', 'A'), _i('y', 'Y'), _i('b', 'B')];
      final result = sortByRank(
        items: items,
        rankedIds: ['a', 'b'], // x, y not in rank
        idOf: (e) => e.id,
        valueOf: (e) => e.name,
      );
      // a, b by rank; x, y by name compareTo
      expect(result.map((e) => e.id), ['a', 'b', 'x', 'y']);
    });

    test('ranks items not in rankedIds after all ranked items', () {
      final items = [_i('new', 'New'), _i('a', 'A')];
      final result = sortByRank(
        items: items,
        rankedIds: ['a'], // 'new' not in rank
        idOf: (e) => e.id,
        valueOf: (e) => e.name,
      );
      expect(result.map((e) => e.id), ['a', 'new']);
    });

    test('partial rank — one in, one out (in before out)', () {
      final items = [_i('a', 'A'), _i('x', 'X')];
      final result = sortByRank(
        items: items,
        rankedIds: ['a'],
        idOf: (e) => e.id,
        valueOf: (e) => e.name,
      );
      // a ranked → first; x unranked → after
      expect(result.map((e) => e.id), ['a', 'x']);
    });

    test('partial rank — one out, one in (out before in)', () {
      final items = [_i('x', 'X'), _i('a', 'A')];
      final result = sortByRank(
        items: items,
        rankedIds: ['a'],
        idOf: (e) => e.id,
        valueOf: (e) => e.name,
      );
      // a ranked → first; x unranked → after
      expect(result.map((e) => e.id), ['a', 'x']);
    });

    test('unranked items sorted by name when multiple unranked exist', () {
      final items = [_i('a', 'A'), _i('z', 'Z'), _i('m', 'M')];
      final result = sortByRank(
        items: items,
        rankedIds: ['a'],
        idOf: (e) => e.id,
        valueOf: (e) => e.name,
      );
      // a by rank; z, m by name → M, Z
      expect(result.map((e) => e.id), ['a', 'm', 'z']);
    });

    test('empty rankedIds → all items sorted by name', () {
      final items = [_i('c', 'C'), _i('a', 'A'), _i('b', 'B')];
      final result = sortByRank(
        items: items,
        rankedIds: [],
        idOf: (e) => e.id,
        valueOf: (e) => e.name,
      );
      expect(result.map((e) => e.id), ['a', 'b', 'c']);
    });

    test('empty items → returns empty', () {
      final result = sortByRank<_Item>(
        items: [],
        rankedIds: ['a', 'b'],
        idOf: (e) => e.id,
        valueOf: (e) => e.name,
      );
      expect(result, isEmpty);
    });

    test('preserves original items (returns new list)', () {
      final items = [_i('b', 'B'), _i('a', 'A')];
      final result = sortByRank(
        items: items,
        rankedIds: ['a', 'b'],
        idOf: (e) => e.id,
        valueOf: (e) => e.name,
      );
      expect(result.length, 2);
      expect(result[0].id, 'a');
      expect(result[1].id, 'b');
      // original unchanged
      expect(items[0].id, 'b');
    });

    test('duplicate ids in rankedIds — last position wins', () {
      final items = [_i('a', 'A'), _i('b', 'B')];
      final result = sortByRank(
        items: items,
        rankedIds: ['b', 'a', 'b'], // b appears at 0 and 2 → rank 2
        idOf: (e) => e.id,
        valueOf: (e) => e.name,
      );
      // a rank 1, b rank 2 → a, b
      expect(result.map((e) => e.id), ['a', 'b']);
    });
  });
}

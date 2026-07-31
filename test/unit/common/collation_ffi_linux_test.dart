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

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/collation_ffi_linux.dart';

/// A mock sort-key function that returns a single-byte key.
///
/// The byte value equals the desired sort position (lower = earlier).
/// Unmapped values get a key of [0xFF], placing them last.
Uint8List Function(String) mockSortKeyFn(Map<String, int> mapping) {
  return (String value) {
    final pos = mapping[value];
    if (pos != null) return Uint8List.fromList([pos]);
    return Uint8List.fromList([0xFF]);
  };
}

void main() {
  group('IcuCollation.sort (pure-Dart logic)', () {
    test('sorts by sort-key order (asc)', () {
      final c = IcuCollation.test(mockSortKeyFn({'A': 1, 'B': 2, 'C': 3}));
      final items = ['C', 'A', 'B'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['A', 'B', 'C']);
    });

    test('sorts by sort-key order (desc)', () {
      final c = IcuCollation.test(mockSortKeyFn({'A': 1, 'B': 2, 'C': 3}));
      final items = ['C', 'A', 'B'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
        descending: true,
      );
      expect(result, ['C', 'B', 'A']);
    });

    test('tie-breaks by id when sort keys are equal', () {
      final c = IcuCollation.test((_) => Uint8List.fromList([0]));
      final items = ['C', 'A', 'B'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['A', 'B', 'C']);
    });

    test('tie-break by id respects non-trivial ids', () {
      final c = IcuCollation.test((_) => Uint8List.fromList([0]));
      final items = ['zebra', 'alpha', 'mango'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => 'x',
      );
      expect(result, ['alpha', 'mango', 'zebra']);
    });

    test('descending + tie-break still reverses', () {
      final c = IcuCollation.test((_) => Uint8List.fromList([0]));
      final items = ['C', 'A', 'B'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
        descending: true,
      );
      expect(result, ['C', 'B', 'A']);
    });

    test('empty items → empty result', () {
      final c = IcuCollation.test((_) => Uint8List(0));
      final result = c.sort<String>(
        items: [],
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, isEmpty);
    });

    test('single item → same item', () {
      final c = IcuCollation.test((_) => Uint8List.fromList([42]));
      final result = c.sort<String>(
        items: ['only'],
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['only']);
    });

    test('preserves original list (returns new list)', () {
      final c = IcuCollation.test(mockSortKeyFn({'A': 1, 'B': 2}));
      final items = ['B', 'A'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['A', 'B']);
      expect(items, ['B', 'A']);
    });

    test('values not in sort-key map go last', () {
      final c = IcuCollation.test(mockSortKeyFn({'known': 5}));
      final items = ['known', 'unknown'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['known', 'unknown']);
    });

    test('multiple unmapped values sorted by id', () {
      final c = IcuCollation.test((_) => Uint8List.fromList([0xFF]));
      final items = ['z', 'a'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['a', 'z']);
    });

    test('multi-byte keys: shorter prefix wins', () {
      final c = IcuCollation.test(
        (s) => switch (s) {
          'ab' => Uint8List.fromList([1, 2]),
          'a' => Uint8List.fromList([1]),
          'abc' => Uint8List.fromList([1, 2, 3]),
          _ => Uint8List(0),
        },
      );
      final items = ['abc', 'ab', 'a'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['a', 'ab', 'abc']);
    });

    test('multi-byte keys: first differing byte decides', () {
      final c = IcuCollation.test(
        (s) => switch (s) {
          'X' => Uint8List.fromList([2, 1]),
          'Y' => Uint8List.fromList([2, 5]),
          'Z' => Uint8List.fromList([2, 5, 0]),
          _ => Uint8List(0),
        },
      );
      final items = ['Z', 'X', 'Y'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['X', 'Y', 'Z']);
    });

    test('valueOf uses a different field than idOf', () {
      final c = IcuCollation.test(
        mockSortKeyFn({'first': 1, 'second': 2, 'third': 3}),
      );
      final items = ['c', 'a', 'b'];
      final valueMap = {'c': 'third', 'a': 'first', 'b': 'second'};
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => valueMap[s]!,
      );
      expect(result, ['a', 'b', 'c']);
    });

    test('idOf and valueOf can return different data types', () {
      final c = IcuCollation.test(mockSortKeyFn({'A': 10, 'B': 20, 'C': 30}));
      final items = [
        (id: 2, name: 'B'),
        (id: 1, name: 'A'),
        (id: 3, name: 'C'),
      ];
      final result = c.sort<({int id, String name})>(
        items: items,
        idOf: (e) => e.id.toString(),
        valueOf: (e) => e.name,
      );
      expect(result.map((e) => e.name), ['A', 'B', 'C']);
    });
  });
}

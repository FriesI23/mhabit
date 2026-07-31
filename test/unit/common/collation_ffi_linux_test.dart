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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/collation_ffi.dart';
import 'package:mhabit/common/collation_ffi_linux.dart';

/// A mock collation comparator backed by an explicit position map.
///
/// [mapping] assigns each known value a sort position (lower = earlier).
/// Unknown values compare collation-equal to each other (tie → broken by
/// id) and sort after all known values.
int Function(String, String) mockCompareFn(Map<String, int> mapping) {
  return (String a, String b) {
    final pa = mapping[a];
    final pb = mapping[b];
    if (pa == null && pb == null) return 0;
    if (pa == null) return 1;
    if (pb == null) return -1;
    return pa.compareTo(pb);
  };
}

void main() {
  group('IcuCollation.sort (pure-Dart logic)', () {
    test('sorts by collation order (asc)', () {
      final c = IcuCollation.test(mockCompareFn({'A': 1, 'B': 2, 'C': 3}));
      final items = ['C', 'A', 'B'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['A', 'B', 'C']);
    });

    test('sorts by collation order (desc)', () {
      final c = IcuCollation.test(mockCompareFn({'A': 1, 'B': 2, 'C': 3}));
      final items = ['C', 'A', 'B'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
        descending: true,
      );
      expect(result, ['C', 'B', 'A']);
    });

    test('collation order wins over id order', () {
      // Position order B < C < A differs from id (lexicographic) order.
      final c = IcuCollation.test(mockCompareFn({'A': 3, 'B': 1, 'C': 2}));
      final items = ['C', 'A', 'B'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['B', 'C', 'A']);
    });

    test('tie-breaks by id when collation-equal', () {
      final c = IcuCollation.test((_, _) => 0);
      final items = ['C', 'A', 'B'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['A', 'B', 'C']);
    });

    test('tie-break by id respects non-trivial ids', () {
      final c = IcuCollation.test((_, _) => 0);
      final items = ['zebra', 'alpha', 'mango'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => 'x',
      );
      expect(result, ['alpha', 'mango', 'zebra']);
    });

    test('descending + tie-break still reverses', () {
      final c = IcuCollation.test((_, _) => 0);
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
      final c = IcuCollation.test((_, _) => 0);
      final result = c.sort<String>(
        items: [],
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, isEmpty);
    });

    test('single item → same item', () {
      final c = IcuCollation.test((_, _) => 0);
      final result = c.sort<String>(
        items: ['only'],
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['only']);
    });

    test('preserves original list (returns new list)', () {
      final c = IcuCollation.test(mockCompareFn({'A': 1, 'B': 2}));
      final items = ['B', 'A'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['A', 'B']);
      expect(items, ['B', 'A']);
    });

    test('values not in the map go last', () {
      final c = IcuCollation.test(mockCompareFn({'known': 5}));
      final items = ['known', 'unknown'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['known', 'unknown']);
    });

    test('multiple unmapped values sorted by id', () {
      final c = IcuCollation.test((_, _) => 0);
      final items = ['z', 'a'];
      final result = c.sort<String>(
        items: items,
        idOf: (s) => s,
        valueOf: (s) => s,
      );
      expect(result, ['a', 'z']);
    });

    test('valueOf uses a different field than idOf', () {
      final c = IcuCollation.test(
        mockCompareFn({'first': 1, 'second': 2, 'third': 3}),
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
      final c = IcuCollation.test(mockCompareFn({'A': 10, 'B': 20, 'C': 30}));
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

  group('IcuCollationLinuxRules', () {
    final rules = IcuCollationLinuxRules();

    test('extractVersionMajor parses soname versions', () {
      expect(rules.extractVersionMajor('libicui18n.so'), isNull);
      expect(
        rules.extractVersionMajor('/usr/lib/x86_64-linux-gnu/libicui18n.so.72'),
        72,
      );
      expect(
        rules.extractVersionMajor('/lib/aarch64-linux-gnu/libicui18n.so.74.1'),
        74,
      );
    });

    test('extractVersionSuffix derives the symbol suffix', () {
      expect(rules.extractVersionSuffix('libicui18n.so'), '');
      expect(rules.extractVersionSuffix('libicui18n.so.72'), '_72');
      expect(rules.extractVersionSuffix('libicui18n.so.74.1'), '_74');
    });

    test('searchDirs covers host and Flatpak layouts', () {
      expect(rules.searchDirs, contains('/app/lib'));
      expect(rules.searchDirs, contains('/usr/lib/${rules.multiarchTriplet}'));
      expect(rules.searchDirs, contains('/lib/${rules.multiarchTriplet}'));
    });

    test('candidates resolve unversioned → recommended → highest', () {
      expect(rules.candidates([]), [
        'libicui18n.so',
        'libicui18n.so.${IcuCollationLinuxRules.recommendedVersion}',
      ]);
      expect(rules.candidates(['/a/libicui18n.so.74', '/a/libicui18n.so.70']), [
        'libicui18n.so',
        'libicui18n.so.${IcuCollationLinuxRules.recommendedVersion}',
        '/a/libicui18n.so.74',
      ]);
    });

    test('recommendedVersion pins a widely-deployed stable ICU release', () {
      expect(IcuCollationLinuxRules.recommendedVersion, 72);
    });

    test('discoverCandidates lists libicui18n files by version desc', () async {
      final tmp = await Directory.systemTemp.createTemp('icu_candidates');
      addTearDown(() => tmp.delete(recursive: true));
      for (final name in [
        'libicui18n.so.72',
        'libicui18n.so.74',
        'libicui18n.so.74.1',
        'libicui18n.so',
        'other.so.99',
      ]) {
        await File('${tmp.path}/$name').create();
      }

      final candidates = await rules.discoverCandidates([tmp.path]);
      final names = candidates.map((p) => p.split('/').last).toList();
      expect(names, [
        'libicui18n.so.74.1',
        'libicui18n.so.74',
        'libicui18n.so.72',
        'libicui18n.so',
      ]);
    });
  });
}

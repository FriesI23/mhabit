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

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/storage/utils.dart';

void main() {
  group("test processDuplicatedMap", () {
    late Equality uuidListEquality;

    setUp(() {
      uuidListEquality = ListEquality(
        EqualityBy<MapEntry<String, String>, (String, String)>(
          (entry) => (entry.key, entry.value),
        ),
      );
    });

    test('Test case 1: No duplicates', () {
      final input = {'a': 'x', 'b': 'y', 'c': 'z'};

      final result = processDuplicatedMap(input);
      expect(
        uuidListEquality.equals(result.updateList, [
          MapEntry('a', 'x'),
          MapEntry('b', 'y'),
          MapEntry('c', 'z'),
        ]),
        isTrue,
      );
      expect(result.deleteList, isEmpty);
    });

    test('Test case 2: Duplicate values', () {
      final input = {'a': 'x', 'b': 'x', 'c': 'y'};

      final result = processDuplicatedMap(input);
      expect(
        uuidListEquality.equals(result.updateList, [
          MapEntry('a', 'x'),
          MapEntry('c', 'y'),
        ]),
        isTrue,
      );
      expect(
        uuidListEquality.equals(result.deleteList, [MapEntry('b', 'x')]),
        isTrue,
      );
    });

    test('Test case 3: Value is also a key', () {
      final input = {'a': 'x', 'b': 'a', 'c': 'y'};

      final result = processDuplicatedMap(input);
      expect(
        uuidListEquality.equals(result.updateList, [
          MapEntry('a', 'x'),
          MapEntry('b', 'a'),
          MapEntry('c', 'y'),
        ]),
        isTrue,
      );
      expect(result.deleteList, isEmpty);
    });

    test('Test case 4: Value duplicates and key conflict', () {
      final input = {'a': 'b', 'b': 'x', 'c': 'x', 'd': 'a'};

      final result = processDuplicatedMap(input);
      expect(
        uuidListEquality.equals(result.updateList, [
          MapEntry('b', 'x'),
          MapEntry('a', 'b'),
          MapEntry('d', 'a'),
        ]),
        isTrue,
      );
      expect(
        uuidListEquality.equals(result.deleteList, [MapEntry('c', 'x')]),
        isTrue,
      );
    });

    test('Test case 5: Complex mixed case', () {
      final input = {
        'a': 'x',
        'b': 'a',
        'c': 'x',
        'd': 'b',
        'e': 'x',
        'f': 'z',
      };

      final result = processDuplicatedMap(input);
      expect(
        uuidListEquality.equals(result.updateList, [
          MapEntry('a', 'x'),
          MapEntry('b', 'a'),
          MapEntry('d', 'b'),
          MapEntry('f', 'z'),
        ]),
        isTrue,
      );
      expect(
        uuidListEquality.equals(result.deleteList, [
          MapEntry('c', 'x'),
          MapEntry('e', 'x'),
        ]),
        isTrue,
      );
    });
    test('Test case 6: Empty case', () {
      final input = <String, String>{};

      final result = processDuplicatedMap(input);
      expect(result.updateList, isEmpty);
      expect(result.deleteList, isEmpty);
    });
  });
}

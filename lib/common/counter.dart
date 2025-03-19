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

import 'dart:math';

class Counter<T> {
  final Map<T, int> _counts = {};

  Counter([Iterable<T>? iterable]) {
    if (iterable != null) {
      for (var element in iterable) {
        _counts[element] = (_counts[element] ?? 0) + 1;
      }
    }
  }

  int operator [](T element) => _counts[element] ?? 0;

  Iterable<T> get keys => _counts.keys;

  Iterable<int> get values => _counts.values;

  int get length => _counts.length;

  void forEach(void Function(T element, int count) action) {
    _counts.forEach(action);
  }

  void increase(T element, [int count = 1]) {
    _counts[element] = (_counts[element] ?? 0) + max(count, 0);
  }

  @override
  String toString() => _counts.toString();
}

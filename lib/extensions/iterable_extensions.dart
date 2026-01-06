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

import 'dart:math' as math;

extension SortPostionRankExtension on Iterable<num> {
  List<num> makeUniqueAndIncreasing(
    num increment, {
    bool isSorted = true,
    int? decimalPlaces,
  }) {
    if (increment <= 0) {
      throw ArgumentError("should > 0, got $increment", "increment");
    }

    if (isEmpty) return [];

    final result = List.of(this);
    if (!isSorted) result.sort();

    num calcFactor() {
      final incrementSlices = increment.toString().split('.');
      return incrementSlices.length > 1 ? incrementSlices[1].length : 0;
    }

    final factor = math.pow(10, decimalPlaces ?? calcFactor());

    num prev, current;
    for (var i = 1; i < result.length; i++) {
      prev = result[i - 1];
      current = result[i];
      if (current > prev) continue;
      final newCurrent = ((current + increment) * factor).round() / factor;
      result[i] = newCurrent > prev
          ? newCurrent
          : ((prev + increment) * factor).round() / factor;
    }

    return result;
  }
}

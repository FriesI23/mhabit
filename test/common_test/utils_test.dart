// Copyright 2023 Fries_I23
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

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/utils.dart';

void main() {
  group("test combineIterables", () {
    test("test normal combine", () {
      var list1 = [1, 4, 7, 10, 99];
      var list2 = [2, 4, 8, 9, 12, 45];
      var list3 = [];
      list3
        ..addAll(list1)
        ..addAll(list2);
      list3.sort();
      combineIterables(list1, list2, compare: (a, b) => a.compareTo(b))
          .forEachIndexed((index, element) {
        assert(element == list3[index], true);
      });
    });
  });
}

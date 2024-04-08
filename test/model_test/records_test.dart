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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/persistent/local/handler/record.dart';

void main() {
  group("RecordDBCell", () {
    final record1 = RecordDBCell(
        id: 1,
        parentId: 1,
        recordDate: 1,
        recordType: 1,
        recordValue: 1.2,
        createT: 1,
        modifyT: 1,
        uuid: 'xxx');
    final record2 = RecordDBCell(
        parentId: 1,
        recordDate: 1,
        recordValue: 1.2,
        createT: 1,
        modifyT: 1,
        uuid: 'xxx');
    test("toMap", () {
      final result1 = record1.toJson();
      expect(result1[RecordDBCellKey.parentId], 1);
      expect(result1[RecordDBCellKey.id], 1);
      expect(result1[RecordDBCellKey.recordType], 1);
      final result2 = record2.toJson();
      expect(result2[RecordDBCellKey.parentId], 1);
      expect(result2.containsKey(RecordDBCellKey.id), false);
    });
    test('toString', () {
      expect(record1.toString().startsWith("RecordDB"), true);
    });
  });
}

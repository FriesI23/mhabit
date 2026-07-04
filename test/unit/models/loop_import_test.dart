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

import 'package:archive/archive.dart';
import 'package:mhabit/models/loop_import.dart';
import 'package:test/test.dart';

import '../../support/loop_csv_sample.dart';

void main() {
  group('LoopCsvImporter.fromZipBytes', () {
    late LoopCsvImporter importer;

    setUp(() {
      final zipBytes = buildLoopSampleZip();
      importer = LoopCsvImporter.fromZipBytes(zipBytes);
    });

    test('habitCount is correct', () {
      expect(importer.habitCount, 3);
    });

    test('totalRecordCount is correct', () {
      expect(importer.totalRecordCount, 7);
    });

    test('first habit (Meditate) fields', () {
      final h = importer.habits[0];
      expect(h.position, 1);
      expect(h.name, 'Meditate');
      expect(h.type, 'YES_NO');
      expect(h.question, 'Did you meditate this morning?');
      expect(h.description, 'this is a test description');
      expect(h.freqNum, 1);
      expect(h.freqDen, 1);
      expect(h.colorHex, '#FF8F00');
      expect(h.unit, '');
      expect(h.targetType, '');
      expect(h.targetValue, 0);
      expect(h.archived, false);
    });

    test('second habit (Run) NUMERICAL fields', () {
      final h = importer.habits[1];
      expect(h.position, 2);
      expect(h.name, 'Run');
      expect(h.type, 'NUMERICAL');
      expect(h.unit, 'miles');
      expect(h.targetType, 'AT_LEAST');
      expect(h.targetValue, 2.0);
      expect(h.archived, false);
    });

    test('third habit (Wake up early) archived', () {
      final h = importer.habits[2];
      expect(h.position, 3);
      expect(h.name, 'Wake up early');
      expect(h.type, 'YES_NO');
      expect(h.freqNum, 2);
      expect(h.freqDen, 3);
      expect(h.colorHex, '#AFB42B');
      expect(h.archived, true);
    });

    test('Meditate records', () {
      final records = importer.recordsByHabit[0];
      expect(records.length, 3);
      expect(records[0].date, '2025-01-25');
      expect(records[0].valueStr, 'YES_MANUAL');
      expect(records[0].notes, 'Did great!');
      expect(records[1].date, '2025-01-24');
      expect(records[1].valueStr, 'NO');
      expect(records[1].notes, '');
      expect(records[2].date, '2025-01-23');
      expect(records[2].valueStr, 'SKIP');
      expect(records[2].notes, 'Sick');
    });

    test('Run records preserve numeric value as string', () {
      final records = importer.recordsByHabit[1];
      expect(records.length, 3);
      expect(records[0].valueStr, '2000');
      expect(records[1].valueStr, '3000');
      expect(records[2].valueStr, 'SKIP');
    });

    test('Wake up early records', () {
      final records = importer.recordsByHabit[2];
      expect(records.length, 1);
      expect(records[0].date, '2025-01-20');
      expect(records[0].valueStr, 'YES_MANUAL');
    });

    test('recordsByHabit length matches habits length', () {
      expect(importer.recordsByHabit.length, importer.habits.length);
    });
  });

  group('LoopCsvImporter error handling', () {
    test('throws FormatException when Habits.csv missing', () {
      final archive = Archive();
      archive.addFile(ArchiveFile('other.txt', 0, []));
      final encoder = ZipEncoder();
      final bytes = Uint8List.fromList(encoder.encode(archive));

      expect(
        () => LoopCsvImporter.fromZipBytes(bytes),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Habits.csv not found'),
          ),
        ),
      );
    });
  });

  group('LoopCsvImporter.fromZipBytes with real Loop v2.3.1 data', () {
    late LoopCsvImporter importer;

    setUp(() {
      final zipBytes = loadLoopRealZip();
      importer = LoopCsvImporter.fromZipBytes(zipBytes);
    });

    test('habitCount matches real data', () {
      expect(importer.habitCount, 3);
    });

    test('totalRecordCount matches real data', () {
      expect(importer.totalRecordCount, 7);
    });

    test('recordsByHabit length matches habits length', () {
      expect(importer.recordsByHabit.length, importer.habits.length);
    });

    test('archived habit has zero records (empty Checkmarks.csv)', () {
      // 001 someone is archived and has an empty Checkmarks.csv (only header)
      expect(importer.recordsByHabit[0], isEmpty);
    });

    test('NUMERICAL habit fields', () {
      final h = importer.habits[1]; // 002 value habit
      expect(h.position, 2);
      expect(h.name, 'value habit');
      expect(h.type, 'NUMERICAL');
      expect(h.freqNum, 1);
      expect(h.freqDen, 30);
      expect(h.archived, false);
    });

    test('YES_NO habit with custom frequency', () {
      final h = importer.habits[2]; // 003 bool habit
      expect(h.position, 3);
      expect(h.name, 'bool habit');
      expect(h.type, 'YES_NO');
      expect(h.freqNum, 3);
      expect(h.freqDen, 14);
      expect(h.colorHex, '#FF8F00');
      expect(h.archived, false);
    });

    test('archived habit flag', () {
      final h = importer.habits[0]; // 001 someone
      expect(h.position, 1);
      expect(h.name, 'someone');
      expect(h.archived, true);
    });

    test('records for value habit have correct types', () {
      final records = importer.recordsByHabit[1]; // 002 value habit
      expect(records.length, 3);
      // Verify all records have valid date format
      for (final r in records) {
        expect(r.date, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      }
    });

    test('records for bool habit have correct types', () {
      final records = importer.recordsByHabit[2]; // 003 bool habit
      expect(records.length, 4);
      for (final r in records) {
        expect(r.date, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
        // YES_NO habits only have YES_MANUAL, NO, SKIP, or UNKNOWN
        expect(
          r.valueStr,
          anyOf('YES_MANUAL', 'NO', 'SKIP', 'UNKNOWN', 'YES_AUTO'),
        );
      }
    });
  });
}

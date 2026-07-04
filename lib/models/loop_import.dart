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

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';

import '../logging/helper.dart';

// ---------------------------------------------------------------------------
// Loop Habit Data – parsed row from Habits.csv
// ---------------------------------------------------------------------------

class LoopHabitData {
  final int position;
  final String name;
  final String type;
  final String question;
  final String description;
  final int freqNum;
  final int freqDen;
  final String colorHex;
  final String unit;
  final String targetType;
  final double targetValue;
  final bool archived;

  const LoopHabitData({
    required this.position,
    required this.name,
    required this.type,
    required this.question,
    required this.description,
    required this.freqNum,
    required this.freqDen,
    required this.colorHex,
    required this.unit,
    required this.targetType,
    required this.targetValue,
    required this.archived,
  });
}

// ---------------------------------------------------------------------------
// Loop Record Data – parsed row from Checkmarks.csv
// ---------------------------------------------------------------------------

class LoopRecordData {
  final String date;
  final String valueStr;
  final String notes;

  const LoopRecordData({
    required this.date,
    required this.valueStr,
    required this.notes,
  });
}

// ---------------------------------------------------------------------------
// CSV Importer – ZIP decompression + CSV parsing
// ---------------------------------------------------------------------------

class LoopCsvImporter {
  final List<LoopHabitData> habits;
  final List<List<LoopRecordData>> recordsByHabit;

  const LoopCsvImporter._(this.habits, this.recordsByHabit);

  int get habitCount => habits.length;
  int get totalRecordCount =>
      recordsByHabit.fold(0, (sum, r) => sum + r.length);

  static const _csvDecoder = CsvDecoder();

  static List<LoopHabitData> _parseHabits(ArchiveFile file) {
    final text = utf8.decode(file.content);
    final rows = _csvDecoder.convert(text);
    if (rows.isEmpty) return const [];

    final habits = <LoopHabitData>[];
    for (var i = 1; i < rows.length; i++) {
      final fields = rows[i];
      if (fields.length < 12) {
        appLog.import.warn(
          '$LoopCsvImporter._parseHabits',
          ex: [
            'skip Habits.csv line $i: expected >=12 fields, got ${fields.length}',
          ],
        );
        continue;
      }

      habits.add(
        LoopHabitData(
          position: int.parse('${fields[0]}'),
          name: '${fields[1]}',
          type: '${fields[2]}',
          question: '${fields[3]}',
          description: '${fields[4]}',
          freqNum: int.parse('${fields[5]}'),
          freqDen: int.parse('${fields[6]}'),
          colorHex: '${fields[7]}',
          unit: '${fields[8]}',
          targetType: '${fields[9]}',
          targetValue: double.tryParse('${fields[10]}') ?? 0,
          archived: '${fields[11]}' == 'true',
        ),
      );
    }

    appLog.import.info(
      '$LoopCsvImporter._parseHabits',
      ex: ['parsed ${habits.length} habits'],
    );
    return habits;
  }

  static List<LoopRecordData> _parseRecords(ArchiveFile file) {
    final text = utf8.decode(file.content);
    final rows = _csvDecoder.convert(text);
    if (rows.isEmpty) return const [];

    final records = <LoopRecordData>[];
    for (var i = 1; i < rows.length; i++) {
      final fields = rows[i];
      if (fields.length < 3) {
        appLog.import.warn(
          '$LoopCsvImporter._parseRecords',
          ex: [
            'skip Checkmarks.csv line $i: '
                'expected >=3 fields, got ${fields.length}',
          ],
        );
        continue;
      }

      records.add(
        LoopRecordData(
          date: '${fields[0]}',
          valueStr: '${fields[1]}',
          notes: '${fields[2]}',
        ),
      );
    }

    appLog.import.info(
      '$LoopCsvImporter._parseRecords',
      ex: ['parsed ${records.length} records'],
    );
    return records;
  }

  /// Create a [LoopCsvImporter] from raw ZIP bytes.
  ///
  /// Expects a ZIP archive with the Loop Habit Tracker CSV export structure:
  /// - `Habits.csv` at the root
  /// - `{position03d} {name}/Checkmarks.csv` per habit
  factory LoopCsvImporter.fromZipBytes(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);

    // 1. Locate and parse Habits.csv
    final habitsCsv = archive.findFile('Habits.csv');
    if (habitsCsv == null) {
      throw const FormatException('Habits.csv not found in ZIP archive');
    }
    final habits = _parseHabits(habitsCsv);

    // 2. For each habit, locate its Checkmarks.csv by position prefix
    final recordsByHabit = <List<LoopRecordData>>[];
    for (final habit in habits) {
      final dirPrefix = '${habit.position.toString().padLeft(3, '0')} ';
      ArchiveFile? found;
      for (final f in archive.files) {
        if (f.name.startsWith(dirPrefix) &&
            f.name.endsWith('/Checkmarks.csv')) {
          found = f;
          break;
        }
      }
      recordsByHabit.add(
        found != null ? _parseRecords(found) : <LoopRecordData>[],
      );
    }

    appLog.import.info(
      '$LoopCsvImporter.fromZipBytes',
      ex: [
        'habits=${habits.length}',
        'totalRecords=${recordsByHabit.fold<int>(0, (s, r) => s + r.length)}',
      ],
    );

    return LoopCsvImporter._(habits, recordsByHabit);
  }
}

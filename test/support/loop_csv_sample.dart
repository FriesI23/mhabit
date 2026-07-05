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
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Load the real Loop Habit Tracker v2.3.1 CSV export ZIP from disk.
///
/// The ZIP is stored at `test/support/loop_habits_csv_v2.3.1.zip` and is
/// loaded in-memory at test time — it is never unpacked in the source tree.
///
/// ⚠️ Test-only helper (blocking I/O). Do not use in production code or
/// from the UI isolate.
Uint8List loadLoopRealZip() =>
    File('test/support/loop_habits_csv_v2.3.1.zip').readAsBytesSync();

/// Sample Loop CSV export ZIP for the Loop Habit Tracker CSV format.
///
/// Habits:
/// - 001 Meditate (YES_NO, active, 1/1 daily)
/// - 002 Run (NUMERICAL, active, 1/1 daily, unit=miles, target AT_LEAST 2.0)
/// - 003 Wake up early (YES_NO, archived, 2/3)
///
/// Optional named parameters allow overriding:
/// - Frequency and color for the first habit （Meditate）.
/// - Target type and value for the second habit （Run, NUMERICAL）.
Uint8List buildLoopSampleZip({
  int? freqNum,
  int? freqDen,
  String? colorHex,
  String? numericalTargetType,
  double? numericalTargetValue,
}) {
  final archive = Archive();

  // Habits.csv
  final effectiveFreqNum = freqNum ?? 1;
  final effectiveFreqDen = freqDen ?? 1;
  final effectiveColor = colorHex ?? '#FF8F00';
  final effectiveTargetType = numericalTargetType ?? 'AT_LEAST';
  final effectiveTargetValue = numericalTargetValue ?? 2.0;
  final habitsCsv =
      '''
Position,Name,Type,Question,Description,FrequencyNumerator,FrequencyDenominator,Color,Unit,Target Type,Target Value,Archived?
001,Meditate,YES_NO,Did you meditate this morning?,this is a test description,$effectiveFreqNum,$effectiveFreqDen,$effectiveColor,,,,false
002,Run,NUMERICAL,How many miles did you run today?,,1,1,#E64A19,miles,$effectiveTargetType,$effectiveTargetValue,false
003,Wake up early,YES_NO,Did you wake up before 6am?,,2,3,#AFB42B,,,,true
''';
  archive.addFile(
    ArchiveFile('Habits.csv', habitsCsv.length, habitsCsv.codeUnits),
  );

  // 001 Meditate/Checkmarks.csv
  archive.addFile(
    ArchiveFile(
      '001 Meditate/Checkmarks.csv',
      _checkmarks001.length,
      _checkmarks001.codeUnits,
    ),
  );

  // 002 Run/Checkmarks.csv
  archive.addFile(
    ArchiveFile(
      '002 Run/Checkmarks.csv',
      _checkmarks002.length,
      _checkmarks002.codeUnits,
    ),
  );

  // 003 Wake up early/Checkmarks.csv
  archive.addFile(
    ArchiveFile(
      '003 Wake up early/Checkmarks.csv',
      _checkmarks003.length,
      _checkmarks003.codeUnits,
    ),
  );

  final encoder = ZipEncoder();
  return Uint8List.fromList(encoder.encode(archive));
}

const _checkmarks001 = '''
Date,Value,Notes
2025-01-25,YES_MANUAL,Did great!
2025-01-24,NO,
2025-01-23,SKIP,Sick
''';

const _checkmarks002 = '''
Date,Value,Notes
2025-01-25,2000,
2025-01-24,3000,Good run
2025-01-22,SKIP,
''';

const _checkmarks003 = '''
Date,Value,Notes
2025-01-20,YES_MANUAL,
''';

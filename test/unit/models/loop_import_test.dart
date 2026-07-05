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
import 'package:mhabit/common/consts.dart';
import 'package:mhabit/common/exceptions.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_export.dart';
import 'package:mhabit/models/habit_form.dart';
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

  //#endregion

  //#region toExportJson

  group('LoopCsvImporter.toExportJson', () {
    late LoopCsvImporter importer;
    late List<Map<String, dynamic>> jsonList;

    setUp(() {
      importer = LoopCsvImporter.fromZipBytes(buildLoopSampleZip());
      jsonList = importer.toExportJson();
    });

    test('produces correct number of habits', () {
      expect(jsonList.length, 3);
    });

    test('each habit JSON can round-trip through HabitExportData.fromJson', () {
      for (final json in jsonList) {
        final exportData = HabitExportData.fromJson(json);
        expect(exportData, isA<HabitExportData>());
        final dbCell = exportData.toHabitDBCell();
        expect(dbCell.name, isNotEmpty);
      }
    });

    test('Meditate (YES_NO, daily) → correct JSON fields', () {
      final json = jsonList[0];
      expect(json[HabitExportDataKey.name], 'Meditate');
      expect(json[HabitExportDataKey.desc], 'this is a test description');
      expect(json[HabitExportDataKey.type], HabitType.normal.dbCode);
      expect(json[HabitExportDataKey.status], HabitStatus.activated.dbCode);
      expect(json[HabitExportDataKey.dailyGoal], defaultHabitDailyGoal);
      expect(json[HabitExportDataKey.dailyGoalUnit], '');
      expect(json[HabitExportDataKey.targetDays], defaultHabitTargetDays);
    });

    test('Meditate frequency: 1/1 → custom [1,1] (daily)', () {
      final json = jsonList[0];
      expect(
        json[HabitExportDataKey.freqType],
        HabitFrequencyType.custom.dbCode,
      );
      expect(jsonDecode(json[HabitExportDataKey.freqCustom] as String), [1, 1]);
    });

    test('Wake up early frequency: 2/3 → custom [2,3]', () {
      final json = jsonList[2];
      expect(
        json[HabitExportDataKey.freqType],
        HabitFrequencyType.custom.dbCode,
      );
      expect(jsonDecode(json[HabitExportDataKey.freqCustom] as String), [2, 3]);
    });

    test('Meditate color #FF8F00 mapped to a built-in or custom color', () {
      final json = jsonList[0];
      expect(json[HabitExportDataKey.color], isA<int>());
      // #FF8F00 (amber) should match cc8 (#FF9800) — distance ~24 < 80
      final customColor = json[HabitExportDataKey.customColor];
      if (customColor != null) {
        expect(json[HabitExportDataKey.customColorTinted], 1);
      }
    });

    test('Meditate records: YES_AUTO/NO filtered, only manual+skip kept', () {
      final records = jsonList[0][HabitExportDataKey.records] as List;
      expect(records.length, 2); // YES_MANUAL + SKIP (YES_AUTO/NO filtered)
      expect(records[0][RecordExportDataKey.recordType], 1); // YES_MANUAL→done
      expect(
        records[0][RecordExportDataKey.recordValue],
        defaultHabitDailyGoal,
      );
      expect(records[1][RecordExportDataKey.recordType], 2); // SKIP
      expect(records[1][RecordExportDataKey.recordValue], 0);
    });

    test('Run (NUMERICAL) records: numeric values parsed as N/1000', () {
      final records = jsonList[1][HabitExportDataKey.records] as List;
      expect(records.length, 3);
      expect(records[0][RecordExportDataKey.recordValue], 2.0); // 2000/1000
      expect(records[1][RecordExportDataKey.recordValue], 3.0); // 3000/1000
      expect(records[2][RecordExportDataKey.recordType], 2); // SKIP
    });

    test('Run dailyGoal is targetValue', () {
      final json = jsonList[1];
      expect(json[HabitExportDataKey.dailyGoal], 2.0);
      expect(json[HabitExportDataKey.dailyGoalUnit], 'miles');
    });

    test('Wake up early is archived', () {
      final json = jsonList[2];
      expect(json[HabitExportDataKey.status], HabitStatus.archived.dbCode);
    });

    test('startDate is earliest record date', () {
      // Meditate: 2025-01-23 is earliest
      final json = jsonList[0];
      final expectedEpoch = HabitDate.dateTime(
        DateTime.parse('2025-01-23'),
      ).epochDay;
      expect(json[HabitExportDataKey.startDate], expectedEpoch);
    });

    test('recordDate is stored as epoch day int', () {
      final records = jsonList[0][HabitExportDataKey.records] as List;
      expect(records[0][RecordExportDataKey.recordDate], isA<int>());
    });
  });

  group('_mapFrequency edge cases', () {
    /// Helper: builds a single-habit JSON with the given frequency.
    /// Always returns the first habit (Meditate) from the sample ZIP.
    Map<String, dynamic> habitJsonForFreq(int freqNum, int freqDen) {
      final jsonList = LoopCsvImporter.fromZipBytes(
        buildLoopSampleZip(freqNum: freqNum, freqDen: freqDen),
      ).toExportJson();
      return jsonList.first;
    }

    test('1/7 → weekly(freq:1)', () {
      final json = habitJsonForFreq(1, 7);
      expect(
        json[HabitExportDataKey.freqType],
        HabitFrequencyType.weekly.dbCode,
      );
      expect(jsonDecode(json[HabitExportDataKey.freqCustom] as String), [1]);
    });

    test('3/7 → weekly(freq:3)', () {
      final json = habitJsonForFreq(3, 7);
      expect(
        json[HabitExportDataKey.freqType],
        HabitFrequencyType.weekly.dbCode,
      );
      expect(jsonDecode(json[HabitExportDataKey.freqCustom] as String), [3]);
    });

    test('2/30 → monthly(freq:2)', () {
      final json = habitJsonForFreq(2, 30);
      expect(
        json[HabitExportDataKey.freqType],
        HabitFrequencyType.monthly.dbCode,
      );
      expect(jsonDecode(json[HabitExportDataKey.freqCustom] as String), [2]);
    });

    test('1/31 → monthly(freq:1)', () {
      final json = habitJsonForFreq(1, 31);
      expect(
        json[HabitExportDataKey.freqType],
        HabitFrequencyType.monthly.dbCode,
      );
      expect(jsonDecode(json[HabitExportDataKey.freqCustom] as String), [1]);
    });

    test('5/5 → custom [1,1] (daily)', () {
      final json = habitJsonForFreq(5, 5);
      expect(
        json[HabitExportDataKey.freqType],
        HabitFrequencyType.custom.dbCode,
      );
      expect(jsonDecode(json[HabitExportDataKey.freqCustom] as String), [1, 1]);
    });

    test('3/14 → custom [3,14]', () {
      final json = habitJsonForFreq(3, 14);
      expect(
        json[HabitExportDataKey.freqType],
        HabitFrequencyType.custom.dbCode,
      );
      expect(jsonDecode(json[HabitExportDataKey.freqCustom] as String), [
        3,
        14,
      ]);
    });

    test('0/1 → FormatException in toExportJson', () {
      expect(() => habitJsonForFreq(0, 1), throwsA(isA<FormatException>()));
    });

    test('1/0 → FormatException in toExportJson', () {
      expect(() => habitJsonForFreq(1, 0), throwsA(isA<FormatException>()));
    });
  });

  group('_mapColor edge cases', () {
    test('exact match: #6750A4 → cc1', () {
      final jsonList = LoopCsvImporter.fromZipBytes(
        buildLoopSampleZip(colorHex: '#6750A4'),
      ).toExportJson();
      final json = jsonList[0];
      expect(json[HabitExportDataKey.color], HabitColorType.cc1.dbCode);
      expect(json[HabitExportDataKey.customColor], isNull);
    });

    test('close match: #D32F2F → cc2 (#F44336)', () {
      final jsonList = LoopCsvImporter.fromZipBytes(
        buildLoopSampleZip(colorHex: '#D32F2F'),
      ).toExportJson();
      final json = jsonList[0];
      // distance sqrt((211-244)²+(47-67)²+(47-54)²) ≈ sqrt(1089+400+49)≈39
      expect(json[HabitExportDataKey.color], HabitColorType.cc2.dbCode);
      expect(json[HabitExportDataKey.customColor], isNull);
    });

    test('far color: #123456 → custom', () {
      final jsonList = LoopCsvImporter.fromZipBytes(
        buildLoopSampleZip(colorHex: '#123456'),
      ).toExportJson();
      final json = jsonList[0];
      expect(json[HabitExportDataKey.customColor], isNotNull);
      expect(json[HabitExportDataKey.customColorTinted], 1);
    });
  });

  //#endregion

  //#region AT_MOST → negative mapping

  group('AT_MOST target → negative habit mapping', () {
    test(
      'AT_MOST → negative type, dailyGoal=0, dailyGoalExtra=targetValue',
      () {
        final jsonList = LoopCsvImporter.fromZipBytes(
          buildLoopSampleZip(
            numericalTargetType: 'AT_MOST',
            numericalTargetValue: 5.0,
          ),
        ).toExportJson();

        // Habit 1 (index 1) is Run with AT_MOST
        final json = jsonList[1];
        expect(json[HabitExportDataKey.type], HabitType.negative.dbCode);
        expect(json[HabitExportDataKey.dailyGoal], 0);
        expect(json[HabitExportDataKey.dailyGoalExtra], 5.0);
        expect(json[HabitExportDataKey.dailyGoalUnit], 'miles');
      },
    );

    test('AT_MOST records: numeric values parsed as N/1000', () {
      final jsonList = LoopCsvImporter.fromZipBytes(
        buildLoopSampleZip(
          numericalTargetType: 'AT_MOST',
          numericalTargetValue: 5.0,
        ),
      ).toExportJson();

      final records = jsonList[1][HabitExportDataKey.records] as List;
      expect(records.length, 3);
      expect(records[0][RecordExportDataKey.recordValue], 2.0); // 2000/1000
      expect(records[1][RecordExportDataKey.recordValue], 3.0); // 3000/1000
      expect(records[2][RecordExportDataKey.recordType], 2); // SKIP
    });

    test('AT_LEAST (default) → normal type, dailyGoal=targetValue', () {
      final jsonList = LoopCsvImporter.fromZipBytes(
        buildLoopSampleZip(),
      ).toExportJson();

      final json = jsonList[1];
      expect(json[HabitExportDataKey.type], HabitType.normal.dbCode);
      expect(json[HabitExportDataKey.dailyGoal], 2.0);
      expect(json.containsKey(HabitExportDataKey.dailyGoalExtra), isFalse);
    });

    test('YES_NO numeric-looking value is ignored', () {
      final archive = Archive();
      const habitsCsv =
          'Position,Name,Type,Question,Description,'
          'FrequencyNumerator,FrequencyDenominator,Color,Unit,'
          'Target Type,Target Value,Archived?\n'
          '001,Meditate,YES_NO,,desc,1,1,#FF8F00,,,,false\n';
      const checkmarksCsv =
          'Date,Value,Notes\n'
          '2025-01-25,1000,Should be ignored for YES_NO\n'
          '2025-01-24,YES_MANUAL,Manual done\n';
      archive.addFile(
        ArchiveFile('Habits.csv', habitsCsv.length, habitsCsv.codeUnits),
      );
      archive.addFile(
        ArchiveFile(
          '001 Meditate/Checkmarks.csv',
          checkmarksCsv.length,
          checkmarksCsv.codeUnits,
        ),
      );

      final bytes = Uint8List.fromList(ZipEncoder().encode(archive));
      final jsonList = LoopCsvImporter.fromZipBytes(bytes).toExportJson();
      final records = jsonList[0][HabitExportDataKey.records] as List;

      expect(records.length, 1);
      expect(records[0][RecordExportDataKey.recordType], 1);
      expect(
        records[0][RecordExportDataKey.recordValue],
        defaultHabitDailyGoal,
      );
    });
  });

  //#endregion

  //#region annotateJson

  group('LoopCsvImporter.annotateJson', () {
    test('prefixes desc with [From: Loop Habit Tracker]', () {
      final jsonList = LoopCsvImporter.fromZipBytes(
        buildLoopSampleZip(),
      ).toExportJson();
      LoopCsvImporter.dummy.annotateJson(jsonList);

      for (final json in jsonList) {
        final desc = json[HabitExportDataKey.desc] as String;
        expect(desc, startsWith('[From: Loop Habit Tracker]'));
      }
    });

    test('annotates even empty desc', () {
      // Run (002) has empty description
      final importer = LoopCsvImporter.fromZipBytes(buildLoopSampleZip());
      final jsonList = importer.toExportJson();
      // Find the Run habit (index 1, desc is empty)
      final runJson = jsonList[1];
      expect(runJson[HabitExportDataKey.desc], '');

      LoopCsvImporter.dummy.annotateJson(jsonList);

      expect(runJson[HabitExportDataKey.desc], '[From: Loop Habit Tracker]');
    });

    test('preserves original desc after prefix', () {
      final jsonList = LoopCsvImporter.fromZipBytes(
        buildLoopSampleZip(),
      ).toExportJson();
      const originalDesc = 'this is a test description';

      LoopCsvImporter.dummy.annotateJson(jsonList);

      final medJson = jsonList[0];
      expect(
        medJson[HabitExportDataKey.desc],
        '[From: Loop Habit Tracker] $originalDesc',
      );
    });
  });

  //#endregion

  //#region error handling

  group('LoopCsvImporter error handling', () {
    test('throws ThirdPartyImportException when Habits.csv missing', () {
      final archive = Archive();
      archive.addFile(ArchiveFile('other.txt', 0, []));
      final encoder = ZipEncoder();
      final bytes = Uint8List.fromList(encoder.encode(archive));

      expect(
        () => LoopCsvImporter.fromZipBytes(bytes),
        throwsA(
          isA<ThirdPartyImportException>().having(
            (e) => e.type,
            'type',
            ThirdPartyImportErrorType.parseError,
          ),
        ),
      );
    });

    test('does not crash when Checkmarks.csv is missing for a habit', () {
      // Build ZIP with Habits.csv but no Checkmarks.csv for any habit
      final archive = Archive();
      const habitsCsv =
          'Position,Name,Type,Question,Description,'
          'FrequencyNumerator,FrequencyDenominator,Color,Unit,'
          'Target Type,Target Value,Archived?\n'
          '001,Meditate,YES_NO,,desc,1,1,#FF8F00,,,,false\n'
          '002,Run,NUMERICAL,,,1,1,#E64A19,miles,AT_LEAST,2.0,false\n'
          '003,Wake,YES_NO,,,2,3,#AFB42B,,,,true\n';
      archive.addFile(
        ArchiveFile('Habits.csv', habitsCsv.length, habitsCsv.codeUnits),
      );
      final encoder = ZipEncoder();
      final bytes = Uint8List.fromList(encoder.encode(archive));

      // Should not throw
      final importer = LoopCsvImporter.fromZipBytes(bytes);
      expect(importer.habitCount, 3);
      expect(importer.totalRecordCount, 0);
      // Each habit should have an empty records list
      for (final records in importer.recordsByHabit) {
        expect(records, isEmpty);
      }
    });
  });

  //#endregion
}

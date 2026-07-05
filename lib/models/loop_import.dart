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
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';

import '../common/consts.dart';
import '../common/exceptions.dart';
import '../logging/helper.dart';
import 'habit_color.dart';
import 'habit_date.dart';
import 'habit_export.dart';
import 'habit_form.dart';
import 'thirdparty_import.dart';

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

class LoopCsvImporter implements ThirdPartyImporter {
  final List<LoopHabitData> habits;
  final List<List<LoopRecordData>> recordsByHabit;

  const LoopCsvImporter._(this.habits, this.recordsByHabit);

  /// Creates a dummy instance for calling [parseFromBytes] (which delegates to
  /// static parsers internally).
  static const LoopCsvImporter dummy = LoopCsvImporter._([], []);

  @override
  ThirdPartyProvider get provider => ThirdPartyProvider.loopHabitTracker;

  @override
  String get displayName => provider.displayName;

  @override
  ImporterVersion get supportedVersion => _loopVersion;

  static const _loopVersion = LoopImporterVersion();

  @override
  void annotateJson(List<Map<String, dynamic>> jsonList) {
    final prefix = '[From: $displayName]';
    for (final json in jsonList) {
      final rawDesc = (json[HabitExportDataKey.desc] as String?) ?? '';
      json[HabitExportDataKey.desc] = rawDesc.isEmpty
          ? prefix
          : '$prefix $rawDesc';
    }
  }

  @override
  Future<List<Map<String, dynamic>>> parseFromBytes(Uint8List bytes) async {
    try {
      final importer = LoopCsvImporter.fromZipBytes(bytes);
      return importer.toExportJson();
    } on FormatException catch (e) {
      throw ThirdPartyImportException(
        ThirdPartyImportErrorType.parseError,
        detail: e.message,
      );
    } on RangeError catch (e) {
      throw ThirdPartyImportException(
        ThirdPartyImportErrorType.parseError,
        detail: e.toString(),
      );
    }
  }

  int get habitCount => habits.length;
  int get totalRecordCount =>
      recordsByHabit.fold(0, (sum, r) => sum + r.length);

  static const _csvDecoder = CsvDecoder();

  static double _parseTargetValue(Object rawValue, int rowIndex) {
    final rawText = '$rawValue'.trim();
    if (rawText.isEmpty) return 0;

    final parsed = double.tryParse(rawText);
    if (parsed != null) return parsed;

    throw FormatException(
      'Invalid target value "$rawText" at Habits.csv row $rowIndex',
    );
  }

  static List<LoopHabitData> _parseHabits(String text) {
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
          targetValue: _parseTargetValue(fields[10], i),
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
      throw const ThirdPartyImportException(
        ThirdPartyImportErrorType.parseError,
        detail:
            'Habits.csv not found in the ZIP file. '
            'Please make sure you selected a valid Loop Habit Tracker export.',
      );
    }

    // Decode Habits.csv once; throws FormatException on invalid UTF-8.
    final String habitsText;
    try {
      habitsText = utf8.decode(habitsCsv.content);
    } on FormatException {
      throw const ThirdPartyImportException(
        ThirdPartyImportErrorType.parseError,
        detail:
            'The file contains non-UTF-8 encoded text. '
            'Loop Habit Tracker exports should be UTF-8.',
      );
    }

    final habits = _parseHabits(habitsText);

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
      if (found == null) {
        appLog.import.warn(
          '$LoopCsvImporter.fromZipBytes',
          ex: ['Missing Checkmarks.csv for habit', habit.name],
        );
        recordsByHabit.add(<LoopRecordData>[]);
      } else {
        recordsByHabit.add(_parseRecords(found));
      }
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

  /// Convert parsed Loop CSV data into mhabit [HabitExportData]-compatible
  /// JSON maps.
  ///
  /// Each map uses [HabitExportDataKey] constants as keys; nested `records`
  /// arrays use [RecordExportDataKey] constants.  The output can be fed
  /// directly to `HabitExportData.fromJson()`.
  List<Map<String, dynamic>> toExportJson() {
    final result = <Map<String, dynamic>>[];
    for (var i = 0; i < habits.length; i++) {
      final habit = habits[i];
      final records = recordsByHabit[i];

      final freq = _mapFrequency(habit.freqNum, habit.freqDen);
      final color = _mapColor(habit.colorHex);
      final mappedRecords = _mapRecords(habit, records);
      final startDate = _calcStartDate(records);

      final isNumerical = habit.type == 'NUMERICAL';
      final isAtMost = isNumerical && habit.targetType == 'AT_MOST';

      result.add({
        HabitExportDataKey.name: habit.name,
        HabitExportDataKey.desc: habit.description,
        HabitExportDataKey.type: isAtMost
            ? HabitType.negative.dbCode
            : HabitType.normal.dbCode,
        HabitExportDataKey.status: habit.archived
            ? HabitStatus.archived.dbCode
            : HabitStatus.activated.dbCode,
        HabitExportDataKey.color: color.dbColorType.dbCode,
        if (color.dbCustomColor != null)
          HabitExportDataKey.customColor: color.dbCustomColor,
        if (color.dbCustomColorTinted != null)
          HabitExportDataKey.customColorTinted: color.dbCustomColorTinted,
        HabitExportDataKey.dailyGoal: switch ((isNumerical, isAtMost)) {
          (true, true) => 0, // AT_MOST → negative
          (true, false) => habit.targetValue, // AT_LEAST → normal
          (false, _) => defaultHabitDailyGoal, // YES_NO → normal
        },
        HabitExportDataKey.dailyGoalUnit: habit.unit,
        if (isAtMost) HabitExportDataKey.dailyGoalExtra: habit.targetValue,
        HabitExportDataKey.freqType: freq.key,
        HabitExportDataKey.freqCustom: freq.value,
        HabitExportDataKey.startDate: startDate,
        HabitExportDataKey.targetDays: defaultHabitTargetDays,
        HabitExportDataKey.records: mappedRecords,
      });
    }
    return result;
  }

  /// Map Loop frequency (num/den) → mhabit freqType + freqCustom.
  ///
  /// Loop Habit Tracker's frequency model:
  /// - **Daily**: `num == den` (normalized to `1/1` internally).
  /// - **Weekly**: `den == 7` (e.g. `3/7` = 3 times per week).
  /// - **Monthly**: `den == 30` (or rarely `31` from manual editing).
  ///   The picker always uses `30`; `den == 28` is **not** monthly in uhabit
  ///   — it is treated as a custom "X per Y days" frequency.
  /// - **Custom**: everything else stored as `freqNum/freqDen`.
  ///
  /// Returns a [MapEntry] where `.key` is the dbCode of [HabitFrequencyType]
  /// and `.value` is the JSON-encoded freqCustom string.
  static MapEntry<int, String> _mapFrequency(int freqNum, int freqDen) {
    if (freqNum <= 0 || freqDen <= 0) {
      throw FormatException(
        'Invalid frequency $freqNum/$freqDen in Habits.csv',
      );
    }
    if (freqDen == 7) {
      return MapEntry(HabitFrequencyType.weekly.dbCode, jsonEncode([freqNum]));
    }
    // uhabit always uses den=30 for monthly in its picker.
    if (freqDen >= 30) {
      return MapEntry(HabitFrequencyType.monthly.dbCode, jsonEncode([freqNum]));
    }
    if (freqNum == freqDen) {
      // daily → custom(1, 1)
      return MapEntry(HabitFrequencyType.custom.dbCode, jsonEncode([1, 1]));
    }
    return MapEntry(
      HabitFrequencyType.custom.dbCode,
      jsonEncode([freqNum, freqDen]),
    );
  }

  /// Map Loop hex color to a [HabitColor].
  ///
  /// Uses Euclidean distance in RGB space (threshold 80) to find the
  /// closest built-in color; falls back to a [CustomHabitColor] otherwise.
  static HabitColor _mapColor(String hex) {
    final r = int.parse(hex.substring(1, 3), radix: 16);
    final g = int.parse(hex.substring(3, 5), radix: 16);
    final b = int.parse(hex.substring(5, 7), radix: 16);

    const builtInColors = <({HabitColorType type, int argb})>[
      (type: HabitColorType.cc1, argb: 0xFF6750A4),
      (type: HabitColorType.cc2, argb: 0xFFF44336),
      (type: HabitColorType.cc3, argb: 0xFF9C27B0),
      (type: HabitColorType.cc4, argb: 0xFF3F51B5),
      (type: HabitColorType.cc5, argb: 0xFF009688),
      (type: HabitColorType.cc6, argb: 0xFF4CAF50),
      (type: HabitColorType.cc7, argb: 0xFFFFC107),
      (type: HabitColorType.cc8, argb: 0xFFFF9800),
      (type: HabitColorType.cc9, argb: 0xFF8BC34A),
      (type: HabitColorType.cc10, argb: 0xFF673AB7),
    ];

    const threshold = 80;
    ({HabitColorType type, int argb})? bestMatch;
    double bestDist = double.infinity;

    for (final c in builtInColors) {
      final cr = (c.argb >> 16) & 0xFF;
      final cg = (c.argb >> 8) & 0xFF;
      final cb = c.argb & 0xFF;
      final dr = r - cr;
      final dg = g - cg;
      final db = b - cb;
      final dist = math.sqrt(dr * dr + dg * dg + db * db);
      if (dist < bestDist) {
        bestDist = dist;
        bestMatch = c;
      }
    }

    if (bestDist < threshold && bestMatch != null) {
      return HabitColor.builtIn(bestMatch.type);
    }

    final argb = (0xFF000000) | (r << 16) | (g << 8) | b;
    return HabitColor.custom(argb, tinted: true);
  }

  /// Map Loop records to mhabit record JSON entries.
  static List<Map<String, dynamic>> _mapRecords(
    LoopHabitData habit,
    List<LoopRecordData> records,
  ) {
    final isNumerical = habit.type == 'NUMERICAL';
    final isAtMost = isNumerical && habit.targetType == 'AT_MOST';
    final dailyGoal = switch ((isNumerical, isAtMost)) {
      (true, true) => 0, // AT_MOST → negative, goal=0
      (true, false) => habit.targetValue, // AT_LEAST → normal, goal=target
      (false, _) => defaultHabitDailyGoal, // YES_NO → normal, goal=1
    };

    final result = <Map<String, dynamic>>[];
    for (final r in records) {
      final entry = _mapRecordEntry(r.valueStr, isNumerical, dailyGoal);
      if (entry == null) continue;

      result.add({
        RecordExportDataKey.recordDate: _dateToEpochDay(r.date),
        RecordExportDataKey.recordType: entry.recordType,
        RecordExportDataKey.recordValue: entry.recordValue,
      });
    }
    return result;
  }

  /// Map a single Loop record value to mhabit record fields.
  ///
  /// Returns `null` for entries that should be skipped
  /// (YES_AUTO, NO, UNKNOWN, empty).
  static ({int recordType, num recordValue})? _mapRecordEntry(
    String valueStr,
    bool isNumerical,
    num dailyGoal,
  ) {
    if (isNumerical) {
      final numericValue = int.tryParse(valueStr);
      if (numericValue != null) {
        return (recordType: 1, recordValue: numericValue / 1000.0);
      }
    }

    return switch (valueStr) {
      'YES_MANUAL' => (recordType: 1, recordValue: dailyGoal),
      'SKIP' => (recordType: 2, recordValue: 0),
      _ => null, // YES_AUTO, NO, UNKNOWN — skip
    };
  }

  /// Convert a "YYYY-MM-DD" date string to a UTC-based epoch day integer
  /// matching the convention used by [HabitDate.fromEpochDay].
  static int _dateToEpochDay(String dateStr) =>
      HabitDate.dateTime(DateTime.parse(dateStr)).epochDay;

  /// Calculate the start date (epoch day) from the earliest record date.
  ///
  /// Falls back to today (UTC) if there are no records.
  static int _calcStartDate(List<LoopRecordData> records) {
    if (records.isEmpty) return HabitDate.now().epochDay;

    return records
        .map((r) => HabitDate.dateTime(DateTime.parse(r.date)))
        .reduce((a, b) => a.isBefore(b) ? a : b)
        .epochDay;
  }
}

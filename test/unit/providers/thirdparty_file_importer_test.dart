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
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/exceptions.dart';
import 'package:mhabit/models/thirdparty_import.dart';
import 'package:mhabit/providers/workflow/thirdparty_file_importer.dart';

void main() {
  group('ThirdPartyImportOwner.parseThirdPartyFile error handling', () {
    final owner = ThirdPartyImportOwner();
    const provider = ThirdPartyProvider.loopHabitTracker;

    test(
      'ZIP without Habits.csv → ThirdPartyImportException(parseError)',
      () async {
        final archive = Archive();
        archive.addFile(ArchiveFile('other.txt', 8, [0, 0, 0, 0, 0, 0, 0, 0]));
        final encoder = ZipEncoder();
        final bytes = Uint8List.fromList(encoder.encode(archive));

        expect(
          () => owner.parseThirdPartyFile(provider, bytes),
          throwsA(
            isA<ThirdPartyImportException>().having(
              (e) => e.type,
              'type',
              ThirdPartyImportErrorType.parseError,
            ),
          ),
        );
      },
    );

    test('Habits.csv header only (no data rows) → noHabitsFound', () async {
      final archive = Archive();
      const header =
          'Position,Name,Type,Question,Description,'
          'FrequencyNumerator,FrequencyDenominator,Color,Unit,'
          'Target Type,Target Value,Archived?\n';
      archive.addFile(
        ArchiveFile('Habits.csv', header.length, header.codeUnits),
      );
      final encoder = ZipEncoder();
      final bytes = Uint8List.fromList(encoder.encode(archive));

      expect(
        () => owner.parseThirdPartyFile(provider, bytes),
        throwsA(
          isA<ThirdPartyImportException>().having(
            (e) => e.type,
            'type',
            ThirdPartyImportErrorType.noHabitsFound,
          ),
        ),
      );
    });

    test('invalid numeric field in Habits.csv → parseError', () async {
      final archive = Archive();
      const habitsCsv =
          'Position,Name,Type,Question,Description,'
          'FrequencyNumerator,FrequencyDenominator,Color,Unit,'
          'Target Type,Target Value,Archived?\n'
          '001,Meditate,YES_NO,,desc,NaN,1,#FF8F00,,,,false\n';
      archive.addFile(
        ArchiveFile('Habits.csv', habitsCsv.length, habitsCsv.codeUnits),
      );
      final encoder = ZipEncoder();
      final bytes = Uint8List.fromList(encoder.encode(archive));

      expect(
        () => owner.parseThirdPartyFile(provider, bytes),
        throwsA(
          isA<ThirdPartyImportException>().having(
            (e) => e.type,
            'type',
            ThirdPartyImportErrorType.parseError,
          ),
        ),
      );
    });

    test('invalid non-empty target value in Habits.csv → parseError', () async {
      final archive = Archive();
      const habitsCsv =
          'Position,Name,Type,Question,Description,'
          'FrequencyNumerator,FrequencyDenominator,Color,Unit,'
          'Target Type,Target Value,Archived?\n'
          '001,Run,NUMERICAL,,desc,1,1,#FF8F00,miles,AT_LEAST,abc,false\n';
      archive.addFile(
        ArchiveFile('Habits.csv', habitsCsv.length, habitsCsv.codeUnits),
      );
      final encoder = ZipEncoder();
      final bytes = Uint8List.fromList(encoder.encode(archive));

      expect(
        () => owner.parseThirdPartyFile(provider, bytes),
        throwsA(
          isA<ThirdPartyImportException>().having(
            (e) => e.type,
            'type',
            ThirdPartyImportErrorType.parseError,
          ),
        ),
      );
    });

    test('zero frequency numerator in Habits.csv → parseError', () async {
      final archive = Archive();
      const habitsCsv =
          'Position,Name,Type,Question,Description,'
          'FrequencyNumerator,FrequencyDenominator,Color,Unit,'
          'Target Type,Target Value,Archived?\n'
          '001,Meditate,YES_NO,,desc,0,1,#FF8F00,,,,false\n';
      archive.addFile(
        ArchiveFile('Habits.csv', habitsCsv.length, habitsCsv.codeUnits),
      );
      final encoder = ZipEncoder();
      final bytes = Uint8List.fromList(encoder.encode(archive));

      expect(
        () => owner.parseThirdPartyFile(provider, bytes),
        throwsA(
          isA<ThirdPartyImportException>().having(
            (e) => e.type,
            'type',
            ThirdPartyImportErrorType.parseError,
          ),
        ),
      );
    });

    test('zero frequency denominator in Habits.csv → parseError', () async {
      final archive = Archive();
      const habitsCsv =
          'Position,Name,Type,Question,Description,'
          'FrequencyNumerator,FrequencyDenominator,Color,Unit,'
          'Target Type,Target Value,Archived?\n'
          '001,Meditate,YES_NO,,desc,1,0,#FF8F00,,,,false\n';
      archive.addFile(
        ArchiveFile('Habits.csv', habitsCsv.length, habitsCsv.codeUnits),
      );
      final encoder = ZipEncoder();
      final bytes = Uint8List.fromList(encoder.encode(archive));

      expect(
        () => owner.parseThirdPartyFile(provider, bytes),
        throwsA(
          isA<ThirdPartyImportException>().having(
            (e) => e.type,
            'type',
            ThirdPartyImportErrorType.parseError,
          ),
        ),
      );
    });
  });
}

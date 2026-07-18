// Copyright 2026 Fries_I23
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

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/types.dart';
import 'package:mhabit/models/habit_export.dart';
import 'package:mhabit/providers/workflow/habits_file_exporter.dart';
import 'package:mhabit/providers/workflow/habits_file_importer.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/utils/app_path_provider.dart';

final class _FakeHabitExportAccess implements HabitExportAccess {
  _FakeHabitExportAccess({required this.result});

  Iterable<HabitExportData> result;
  List<HabitUUID>? lastUuidList;
  bool? lastWithRecords;

  @override
  Future<Iterable<HabitExportData>> loadHabitExportData({
    List<HabitUUID>? uuidList,
    bool withRecords = true,
  }) async {
    lastUuidList = uuidList;
    lastWithRecords = withRecords;
    return result;
  }
}

final class _FakeHabitImportAccess implements HabitImportAccess {
  _FakeHabitImportAccess({this.importResult = const [], this.dryRunCount = 0});

  List<Future<void>> importResult;
  int dryRunCount;
  List<Object?>? lastJsonData;
  bool? lastWithRecords;
  Map<String, String>? lastGroupUuidMapping;

  @override
  int getImportHabitsCount(Iterable<Object?> jsonData) {
    lastJsonData = jsonData.toList(growable: false);
    return dryRunCount;
  }

  @override
  List<Future<void>> importHabitsData(
    Iterable<Object?> jsonData, {
    bool withRecords = true,
    Map<String, String>? groupUuidMapping,
  }) {
    lastJsonData = jsonData.toList(growable: false);
    lastWithRecords = withRecords;
    lastGroupUuidMapping = groupUuidMapping;
    return importResult;
  }
}

final class _FakeAppPathProvider implements AppPathProvider {
  const _FakeAppPathProvider(this.exportDirPath);

  final String exportDirPath;

  @override
  Future<String> getExportHabitsDirPath() async => exportDirPath;

  @override
  Future<Directory> getTempDir() => throw UnimplementedError();

  @override
  Future<String> getAppDebugLogFilePath() => throw UnimplementedError();

  @override
  Future<String> getAppDebugInfoFilePath() => throw UnimplementedError();

  @override
  Future<Directory> getSyncFailLogDir() => throw UnimplementedError();

  @override
  Future<String> getSyncFailedLogFilePath([String? sessionId]) =>
      throw UnimplementedError();

  @override
  Future<String> getDatabaseDirPath() => throw UnimplementedError();
}

void main() {
  group('HabitFileImportRunner:commands', () {
    test(
      'importHabitsData routes through commands and tracks completion',
      () async {
        final access = _FakeHabitImportAccess(
          importResult: [
            Future<void>.value(),
            Future<void>.microtask(() => throw StateError('import failed')),
          ],
        );
        final provider = HabitFileImportRunner()..attachAccess(access);
        final progress = <String>[];
        final allProgress = <String>[];

        final result = await provider.importHabitsData(
          const [
            {'name': 'A'},
            {'name': 'B'},
          ],
          whenloadHabit: (count, failed, total) {
            progress.add('$count/$failed/$total');
          },
          whenloadAllHabits: (count, failed, total) {
            allProgress.add('$count/$failed/$total');
          },
        );

        expect(result, 2);
        expect(access.lastJsonData, hasLength(2));
        expect(access.lastWithRecords, isTrue);
        expect(progress, containsAll(['1/0/2', '1/1/2']));
        expect(allProgress, ['1/1/2']);

        provider.dispose();
      },
    );

    test('importHabitsDataDryRun routes through commands', () {
      final access = _FakeHabitImportAccess(dryRunCount: 3);
      final provider = HabitFileImportRunner()..attachAccess(access);

      final count = provider.importHabitsDataDryRun(const [
        {'name': 'A'},
        {'name': 'B'},
        {'name': 'C'},
      ]);

      expect(count, 3);
      expect(access.lastJsonData, hasLength(3));

      provider.dispose();
    });
  });

  group('HabitFileExportRunner:queries', () {
    test(
      'exportMultiHabitsData routes through queries and writes json file',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'mhabit-export-test-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final access = _FakeHabitExportAccess(
          result: const [HabitExportData(name: 'Read Book')],
        );
        final provider = HabitFileExportRunner(
          pathProvider: _FakeAppPathProvider(tempDir.path),
        )..attachAccess(access);

        final filePath = await provider.exportMultiHabitsData(const [
          '11111111-1111-4111-8111-111111111111',
        ], withRecords: false);

        expect(filePath, isNotNull);
        expect(access.lastUuidList, ['11111111-1111-4111-8111-111111111111']);
        expect(access.lastWithRecords, isFalse);

        final rawJson = await File(filePath!).readAsString();
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        final habits = decoded['habits'] as List<dynamic>;
        expect(habits, hasLength(1));
        expect(habits.single['name'], 'Read Book');
      },
    );
  });
}

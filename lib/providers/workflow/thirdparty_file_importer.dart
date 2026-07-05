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

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

import '../../logging/helper.dart';
import '../../logging/logger_stack.dart';
import '../../models/loop_import.dart';
import '../../models/thirdparty_import.dart';
import '../support/commons.dart';

abstract interface class ThirdPartyImportAccess implements Listenable {
  Future<List<Map<String, dynamic>>> parseThirdPartyFile(
    ThirdPartyProvider provider,
    Uint8List bytes,
  );
}

final class ThirdPartyImportOwner extends ChangeNotifier
    implements ThirdPartyImportAccess, ProviderMounted {
  bool _mounted = true;

  @override
  void dispose() {
    if (!_mounted) return;
    super.dispose();
    _mounted = false;
  }

  @override
  bool get mounted => _mounted;

  @override
  Future<List<Map<String, dynamic>>> parseThirdPartyFile(
    ThirdPartyProvider provider,
    Uint8List bytes,
  ) async {
    final importer = switch (provider) {
      ThirdPartyProvider.loopHabitTracker => LoopCsvImporter.dummy,
    };

    final result = await importer.parseFromBytes(bytes);
    importer.annotateJson(result);
    if (result.isEmpty) {
      throw const FormatException('No habits found in import file');
    }
    return result;
  }
}

class ThirdPartyFileImportRunner extends ChangeNotifier
    implements ProviderMounted {
  bool _mounted = true;
  late ThirdPartyImportAccess _access;

  void attachAccess(ThirdPartyImportAccess newAccess) {
    _access = newAccess;
  }

  @override
  void dispose() {
    if (!_mounted) return;
    super.dispose();
    _mounted = false;
  }

  @override
  bool get mounted => _mounted;

  Future<Iterable<Object?>?> loadHabitsData(
    ThirdPartyProvider provider, {
    bool listen = true,
  }) async {
    final file =
        await openFile(
          acceptedTypeGroups: [XTypeGroup(extensions: provider.fileExtensions)],
        ).catchError((e, s) {
          appLog.load.error(
            '$runtimeType.loadHabitsData',
            ex: ["Can't open file picker"],
            error: e,
            stackTrace: LoggerStackTrace.from(StackTrace.current),
          );
          return null;
        });

    if (file == null) return null;

    final Uint8List? bytes = await file
        .readAsBytes()
        .then<Uint8List?>((value) => value)
        .timeout(const Duration(seconds: 10))
        .catchError((e, s) {
          appLog.load.error(
            '$runtimeType.loadHabitsData',
            ex: ["Can't read file", file],
            error: e,
            stackTrace: LoggerStackTrace.from(StackTrace.current),
          );
          return null;
        });

    if (bytes == null) return null;

    final habitsData = await _access.parseThirdPartyFile(provider, bytes);
    if (listen) notifyListeners();
    return habitsData;
  }
}

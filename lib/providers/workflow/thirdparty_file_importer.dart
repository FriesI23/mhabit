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

import '../../common/exceptions.dart';
import '../../logging/helper.dart';
import '../../logging/logger_stack.dart';
import '../../models/loop_import.dart';
import '../../models/thirdparty_import.dart';
import '../support/commons.dart';

/// Return the [ThirdPartyImporter.supportedVersion] for [provider].
///
/// This is a thin lookup so callers (e.g. the provider selection dialog)
/// can display version information without depending on concrete importer
/// classes directly.
ImporterVersion getThirdPartyImporterVersion(ThirdPartyProvider provider) {
  return switch (provider) {
    ThirdPartyProvider.loopHabitTracker =>
      LoopCsvImporter.dummy.supportedVersion,
  };
}

final class ThirdPartyImportOwner extends ChangeNotifier
    implements ProviderMounted {
  bool _mounted = true;

  @override
  void dispose() {
    if (!_mounted) return;
    super.dispose();
    _mounted = false;
  }

  @override
  bool get mounted => _mounted;

  /// Parse raw file bytes from a third-party provider into importable JSON.
  ///
  /// Exposed as a public method so unit tests can verify error-mapping
  /// without simulating the full file-picker flow.
  Future<List<Map<String, dynamic>>> parseThirdPartyFile(
    ThirdPartyProvider provider,
    Uint8List bytes,
  ) async {
    final importer = switch (provider) {
      ThirdPartyProvider.loopHabitTracker => LoopCsvImporter.dummy,
    };

    final List<Map<String, dynamic>> result;
    try {
      result = await importer.parseFromBytes(bytes);
    } on ThirdPartyImportException {
      rethrow;
    } catch (e, s) {
      appLog.import.error(
        '$ThirdPartyImportOwner.parseThirdPartyFile',
        ex: ['Unexpected parse error', provider.displayName],
        error: e,
        stackTrace: LoggerStackTrace.from(s),
      );
      throw ThirdPartyImportException(
        ThirdPartyImportErrorType.unknown,
        detail: e.toString(),
      );
    }

    importer.annotateJson(result);
    if (result.isEmpty) {
      throw const ThirdPartyImportException(
        ThirdPartyImportErrorType.noHabitsFound,
      );
    }
    return result;
  }

  /// Open a file picker filtered to [provider]'s file extensions, read the
  /// selected file, parse it, and return importable JSON.
  ///
  /// Returns `null` when the user cancels the file picker.
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
            stackTrace: LoggerStackTrace.from(s),
          );
          return null;
        });

    if (file == null) return null;

    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes().timeout(const Duration(seconds: 10));
    } catch (e, s) {
      appLog.load.error(
        '$runtimeType.loadHabitsData',
        ex: ["Can't read file", file],
        error: e,
        stackTrace: LoggerStackTrace.from(s),
      );
      throw const ThirdPartyImportException(
        ThirdPartyImportErrorType.fileReadError,
      );
    }

    final habitsData = await parseThirdPartyFile(provider, bytes);
    if (listen) notifyListeners();
    return habitsData;
  }
}

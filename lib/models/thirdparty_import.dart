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

/// Version metadata for a third-party importer.
///
/// Each [ThirdPartyImporter] implementation provides an instance that carries
/// the target app version and a link to the corresponding release page.
sealed class ImporterVersion {
  const ImporterVersion();

  /// The version string (e.g. `"2.3.1"`).
  String get version;

  /// URL to the release page on the third-party project's repository.
  Uri get releaseUrl;
}

/// Version info from the Loop Habit Tracker CSV export format.
///
/// URL is internally derived from the version:
/// `https://github.com/iSoron/uhabits/releases/tag/v{version}`.
final class LoopImporterVersion extends ImporterVersion {
  const LoopImporterVersion();

  @override
  String get version => '2.3.1';

  @override
  Uri get releaseUrl =>
      Uri.parse('https://github.com/iSoron/uhabits/releases/tag/v$version');
}

/// Identifies a supported third-party habit tracker that mhabit can import from.
enum ThirdPartyProvider {
  /// [Loop Habit Tracker](https://github.com/iSoron/uhabits) CSV export.
  loopHabitTracker(fileExtensions: ['zip'], displayName: 'Loop Habit Tracker');

  /// File extensions accepted by the file picker for this provider.
  final List<String> fileExtensions;

  /// Human-readable name shown in the UI (confirm dialogs, error messages).
  final String displayName;

  const ThirdPartyProvider({
    required this.fileExtensions,
    required this.displayName,
  });
}

/// Abstract interface for parsing a third-party export file into
/// mhabit-compatible [HabitExportData] JSON maps.
///
/// Each implementation handles one [ThirdPartyProvider].
abstract interface class ThirdPartyImporter {
  /// Which provider this importer handles.
  ThirdPartyProvider get provider;

  /// Human-readable label for the source, used in confirm dialogs and
  /// error messages.  Defaults to [ThirdPartyProvider.displayName].
  String get displayName => provider.displayName;

  /// The version of the third-party app that this importer targets.
  ///
  /// Shown in the provider selection dialog so users can verify
  /// compatibility.  Each importer implementation owns its own
  /// [ImporterVersion] instance; future importers for newer formats can
  /// return a different version without changing the interface.
  ImporterVersion get supportedVersion;

  /// Parse raw file bytes into a list of [HabitExportData]-compatible JSON maps.
  ///
  /// Each map in the returned list uses [HabitExportDataKey] constants as keys
  /// and can be fed directly to [HabitExportData.fromJson] and the existing
  /// [HabitFileImportRunner] pipeline.
  Future<List<Map<String, dynamic>>> parseFromBytes(Uint8List bytes);

  /// Annotate parsed JSON with source metadata before feeding it into the
  /// import pipeline.  Called by `ThirdPartyImportOwner` after
  /// [parseFromBytes].
  ///
  /// The default implementation is a no-op.  Providers that want to stamp
  /// each habit (e.g. with a source prefix in the description) override
  /// this method.
  void annotateJson(List<Map<String, dynamic>> jsonList) {}
}

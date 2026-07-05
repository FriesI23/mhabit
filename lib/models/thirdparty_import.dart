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

  /// Parse raw file bytes into a list of [HabitExportData]-compatible JSON maps.
  ///
  /// Each map in the returned list uses [HabitExportDataKey] constants as keys
  /// and can be fed directly to [HabitExportData.fromJson] and the existing
  /// [HabitFileImportRunner] pipeline.
  Future<List<Map<String, dynamic>>> parseFromBytes(Uint8List bytes);

  /// Annotate parsed JSON with source metadata before feeding it into the
  /// import pipeline.  Called by [ThirdPartyImportOwner] after
  /// [parseFromBytes].
  ///
  /// The default implementation is a no-op.  Providers that want to stamp
  /// each habit (e.g. with a source prefix in the description) override
  /// this method.
  void annotateJson(List<Map<String, dynamic>> jsonList) {}
}

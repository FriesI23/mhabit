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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/_app_sync_tasks/webdav_app_sync_models.dart';
import 'package:mhabit/models/habit_form.dart';
import 'package:mhabit/storage/db/handlers/habit.dart';

/// These helpers mirror the pre-`custom_color`/`_schema_version`
/// `WebDavSyncHabitData` shape (see git history of
/// webdav_app_sync_models.dart before this feature): a "legacy" client only
/// ever reads the `color` key and passes it straight through to
/// [HabitDBCell] with no `customColor`/`schemaVersion` awareness at all.
/// They let tests assert what an old, already-installed app build would do
/// when it receives a payload written by this (newer) code, without
/// depending on the old source actually being present in this repo.
int? _legacyColorFromJson(Map<String, Object?> json) =>
    (json['color'] as num?)?.toInt();

void _legacyValidate(Map<String, Object?> json) {
  final color = _legacyColorFromJson(json);
  if (color != null &&
      HabitColorType.getFromDBCode(color, withDefault: null) == null) {
    throw TypeError();
  }
}

HabitDBCell _legacyToHabitDBCell(Map<String, Object?> json) => HabitDBCell(
  uuid: json['uuid'] as String?,
  color: _legacyColorFromJson(json),
);

Map<String, Object?> _legacyToJson(HabitDBCell cell) => {
  '_convert_type': 'habit_',
  'uuid': cell.uuid,
  'color': cell.color,
};

void main() {
  group('WebDavSyncHabitData custom_color', () {
    test('fromJson on legacy payload without custom_color key', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc3.dbCode,
      });
      expect(data.customColor, isNull);
      expect(data.color, HabitColorType.cc3.dbCode);
    });

    test('fromHabitDBCell: custom color round-trips through DB cell', () {
      const argb = 0xFF123456;
      final cell = HabitDBCell(
        color: HabitColorType.cc1.dbCode,
        customColor: argb,
      );
      final data = WebDavSyncHabitData.fromHabitDBCell(cell);

      expect(data.customColor, argb);
      expect(data.color, isNull);

      final json = data.toJson();
      final restored = WebDavSyncHabitData.fromJson(json);
      expect(restored.customColor, argb);
      expect(restored.color, isNull);

      final restoredCell = restored.toHabitDBCell();
      expect(restoredCell.customColor, argb);
      expect(restoredCell.color, HabitColorType.cc1.dbCode);
    });

    test('fromHabitDBCell: built-in color round-trips through DB cell', () {
      final cell = HabitDBCell(
        color: HabitColorType.cc5.dbCode,
        customColor: null,
      );
      final data = WebDavSyncHabitData.fromHabitDBCell(cell);

      expect(data.customColor, isNull);
      expect(data.color, HabitColorType.cc5.dbCode);

      final json = data.toJson();
      final restored = WebDavSyncHabitData.fromJson(json);
      expect(restored.customColor, isNull);
      expect(restored.color, HabitColorType.cc5.dbCode);

      final restoredCell = restored.toHabitDBCell();
      expect(restoredCell.customColor, isNull);
      expect(restoredCell.color, HabitColorType.cc5.dbCode);
    });

    test('validate() does not throw for a custom-color habit', () {
      final cell = HabitDBCell(
        color: HabitColorType.cc1.dbCode,
        customColor: 0xFFABCDEF,
      );
      final data = WebDavSyncHabitData.fromHabitDBCell(cell);
      expect(data.validate, returnsNormally);
    });
  });

  group('WebDavSyncHabitData schema_version', () {
    test('fromJson on legacy payload without _schema_version key', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc3.dbCode,
      });
      expect(data.schemaVersion, 1);
    });

    test('toJson omits _schema_version when schemaVersion == 1', () {
      const data = WebDavSyncHabitData(schemaVersion: 1);
      expect(data.toJson(), isNot(contains('_schema_version')));
    });

    test('toJson includes _schema_version when schemaVersion >= 2', () {
      const data = WebDavSyncHabitData(
        schemaVersion: WebDavSyncHabitData.currentSchemaVersion,
      );
      expect(data.toJson()['_schema_version'], 2);
    });

    test('fromHabitDBCell stamps currentSchemaVersion', () {
      final cell = HabitDBCell(color: HabitColorType.cc5.dbCode);
      final data = WebDavSyncHabitData.fromHabitDBCell(cell);
      expect(data.schemaVersion, WebDavSyncHabitData.currentSchemaVersion);
    });

    test('validate() does not throw for a future schema version', () {
      const data = WebDavSyncHabitData(schemaVersion: 99);
      expect(data.validate, returnsNormally);
    });
  });

  group('cross-version compatibility: legacy client receives v2 payload', () {
    test(
      'custom-color habit: legacy client degrades color to null, no crash',
      () {
        final cell = HabitDBCell(
          color: HabitColorType.cc1.dbCode,
          customColor: 0xFF112233,
        );
        final json = WebDavSyncHabitData.fromHabitDBCell(cell).toJson();

        // sanity: this really is a v2 payload carrying keys a legacy
        // client has never heard of.
        expect(json[WebDavSyncHabitKey.customColor], 0xFF112233);
        expect(json[WebDavSyncHabitKey.schemaVersion], 2);

        // a legacy client only ever reads `color`; the unknown keys are
        // simply ignored, not inspected, so they can't throw.
        expect(() => _legacyValidate(json), returnsNormally);
        final legacyCell = _legacyToHabitDBCell(json);
        expect(legacyCell.color, isNull);
      },
    );

    test('built-in-color habit: legacy client is unaffected by new keys', () {
      final cell = HabitDBCell(color: HabitColorType.cc7.dbCode);
      final json = WebDavSyncHabitData.fromHabitDBCell(cell).toJson();

      expect(json[WebDavSyncHabitKey.schemaVersion], 2);
      expect(() => _legacyValidate(json), returnsNormally);
      final legacyCell = _legacyToHabitDBCell(json);
      expect(legacyCell.color, HabitColorType.cc7.dbCode);
    });

    test('fromJson tolerates a still-unknown, even-newer field', () {
      final json = {
        '_convert_type': 'habit_',
        'color': HabitColorType.cc2.dbCode,
        '_schema_version': 99,
        'some_future_field': 'unrecognized-by-this-build',
      };
      final data = WebDavSyncHabitData.fromJson(json);
      expect(data.schemaVersion, 99);
      expect(data.color, HabitColorType.cc2.dbCode);
      expect(data.validate, returnsNormally);
    });

    test('legacy client round-tripping a v2 payload silently drops '
        'custom_color/schema_version, but does not corrupt later reads', () {
      final cell = HabitDBCell(
        color: HabitColorType.cc1.dbCode,
        customColor: 0xFFAABBCC,
      );
      final newJson = WebDavSyncHabitData.fromHabitDBCell(cell).toJson();

      // legacy client downloads (loses custom_color/_schema_version),
      // then re-uploads using its own, older field set.
      final legacyCell = _legacyToHabitDBCell(newJson);
      final reuploaded = _legacyToJson(legacyCell);

      // a v2 client later downloading the legacy client's re-upload sees
      // a colorless habit, not a crash or a corrupted value.
      final redownloaded = WebDavSyncHabitData.fromJson(reuploaded);
      expect(redownloaded.color, isNull);
      expect(redownloaded.customColor, isNull);
      expect(redownloaded.schemaVersion, 1);
      expect(redownloaded.validate, returnsNormally);
    });
  });
}

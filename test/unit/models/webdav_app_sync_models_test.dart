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

String? _futureGroupIdFromJson(Map<String, Object?> json) =>
    json['group_id'] as String?;

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

    test('fromHabitDBCell: custom_color_tinted round-trips through DB cell '
        '(tinted)', () {
      const argb = 0xFF123456;
      final cell = HabitDBCell(
        color: HabitColorType.cc1.dbCode,
        customColor: argb,
        customColorTinted: 1,
      );
      final data = WebDavSyncHabitData.fromHabitDBCell(cell);

      expect(data.customColorTinted, 1);

      final json = data.toJson();
      final restored = WebDavSyncHabitData.fromJson(json);
      expect(restored.customColorTinted, 1);

      final restoredCell = restored.toHabitDBCell();
      expect(restoredCell.customColorTinted, 1);
    });

    test('fromHabitDBCell: custom_color_tinted round-trips through DB cell '
        '(not tinted)', () {
      const argb = 0xFF123456;
      final cell = HabitDBCell(
        color: HabitColorType.cc1.dbCode,
        customColor: argb,
        customColorTinted: 0,
      );
      final data = WebDavSyncHabitData.fromHabitDBCell(cell);

      expect(data.customColorTinted, 0);

      final json = data.toJson();
      final restored = WebDavSyncHabitData.fromJson(json);
      expect(restored.customColorTinted, 0);

      final restoredCell = restored.toHabitDBCell();
      expect(restoredCell.customColorTinted, 0);
    });

    test('fromJson on legacy payload without custom_color_tinted key defaults '
        'to null', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': null,
        'custom_color': 0xFF123456,
      });
      expect(data.customColorTinted, isNull);
      // toHabitDBCell -> HabitColor.fromRaw -> dbCustomColorTinted treats
      // the missing key as tinted-on, same default used everywhere else.
      expect(data.toHabitDBCell().customColorTinted, 1);
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

    test('toHabitDBCell() falls back to cc1 instead of throwing when both '
        'color and custom_color are missing', () {
      // validate() only range-checks `color` when it is present, so a
      // payload with neither key (a malformed write, or one from some
      // future/legacy client that omits both) passes validate() but must
      // not crash the DB write path that follows it.
      final data = WebDavSyncHabitData.fromJson({'_convert_type': 'habit_'});
      expect(data.validate, returnsNormally);
      expect(data.toHabitDBCell, returnsNormally);
      final cell = data.toHabitDBCell();
      expect(cell.color, HabitColorType.cc1.dbCode);
      expect(cell.customColor, isNull);
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
      final data = WebDavSyncHabitData(schemaVersion: 1);
      expect(data.toJson(), isNot(contains('_schema_version')));
    });

    test('toJson includes _schema_version when schemaVersion >= 2', () {
      final data = WebDavSyncHabitData(
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
      final data = WebDavSyncHabitData(schemaVersion: 99);
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

        // sanity: this really is a current-schema payload carrying keys a
        // legacy client has never heard of.
        expect(json[WebDavSyncHabitKey.customColor], 0xFF112233);
        expect(
          json[WebDavSyncHabitKey.schemaVersion],
          WebDavSyncHabitData.currentSchemaVersion,
        );

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

      expect(
        json[WebDavSyncHabitKey.schemaVersion],
        WebDavSyncHabitData.currentSchemaVersion,
      );
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

  group('WebDavSyncHabitData _unknown bucket', () {
    test('fromJson captures unknown keys into _unknown', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc3.dbCode,
        'group_id': 'g-abc-123',
        'future_field': 42,
      });
      expect(data.unknown, isNotNull);
      expect(data.unknown!['group_id'], 'g-abc-123');
      expect(data.unknown!['future_field'], 42);
    });

    test('fromJson with only known keys leaves _unknown null', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc5.dbCode,
        'uuid': 'test-uuid',
        'name': 'Test Habit',
      });
      expect(data.unknown, isNull);
    });

    test('toJson merges _unknown back into output', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc3.dbCode,
        'uuid': 'test-uuid',
        'group_id': 'g-xyz',
        'future_field': 'hello',
      });
      final json = data.toJson();
      expect(json['group_id'], 'g-xyz');
      expect(json['future_field'], 'hello');
    });

    test('known field wins over _unknown in toJson', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc4.dbCode,
        'uuid': 'test-uuid',
      });
      data.unknown = {'uuid': 'evil-override', 'group_id': 'g-ok'};
      final json = data.toJson();
      expect(json['uuid'], 'test-uuid');
      expect(json['group_id'], 'g-ok');
    });

    test('_unknown does not appear as a JSON key', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc2.dbCode,
        'group_id': 'g-test',
      });
      final json = data.toJson();
      expect(json.containsKey('_unknown'), isFalse);
    });

    test('empty _unknown map is no-op in toJson', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc3.dbCode,
      });
      data.unknown = {};
      final json = data.toJson();
      expect(json['color'], HabitColorType.cc3.dbCode);
      expect(json.length, greaterThanOrEqualTo(2));
    });

    test('_unknown survives fromJson → toJson round-trip', () {
      final originalJson = {
        '_convert_type': 'habit_',
        'color': HabitColorType.cc6.dbCode,
        'uuid': 'roundtrip-uuid',
        'name': 'Roundtrip',
        'group_id': 'g-roundtrip',
        'extra_nested': {
          'a': 1,
          'b': [2, 3],
        },
      };
      final data = WebDavSyncHabitData.fromJson(originalJson);
      final roundtripped = WebDavSyncHabitData.fromJson(data.toJson());
      expect(roundtripped.unknown, isNotNull);
      expect(roundtripped.unknown!['group_id'], 'g-roundtrip');
      expect(roundtripped.unknown!['extra_nested'], {
        'a': 1,
        'b': [2, 3],
      });
    });

    test('future field survives old-schema forwarder round-trip', () {
      final serverPayload = {
        '_convert_type': 'habit_',
        'uuid': 'future-forward-uuid',
        'color': HabitColorType.cc6.dbCode,
        'group_id': 'future-group',
      };

      final oldSchemaClient = WebDavSyncHabitData.fromJson(serverPayload);
      final cell = oldSchemaClient.toHabitDBCell();
      final forwarded = WebDavSyncHabitData.fromHabitDBCell(
        cell,
        unknown: decodeSyncExtras(cell.syncExtras),
      ).toJson();

      expect(forwarded['group_id'], 'future-group');
      expect(_futureGroupIdFromJson(forwarded), 'future-group');
    });
  });

  group('WebDavSyncHabitKey ↔ WebDavSyncHabitKeys alignment', () {
    test(
      'every WebDavSyncHabitKeys entry has a matching WebDavSyncHabitKey const',
      () {
        const classKeyValues = <String>{
          WebDavSyncHabitKey.uuid,
          WebDavSyncHabitKey.createT,
          WebDavSyncHabitKey.modifyT,
          WebDavSyncHabitKey.type,
          WebDavSyncHabitKey.status,
          WebDavSyncHabitKey.name,
          WebDavSyncHabitKey.desc,
          WebDavSyncHabitKey.color,
          WebDavSyncHabitKey.customColor,
          WebDavSyncHabitKey.customColorTinted,
          WebDavSyncHabitKey.dailyGoal,
          WebDavSyncHabitKey.dailyGoalUnit,
          WebDavSyncHabitKey.dailyGoalExtra,
          WebDavSyncHabitKey.freqType,
          WebDavSyncHabitKey.freqCustom,
          WebDavSyncHabitKey.reminder,
          WebDavSyncHabitKey.reminderQuest,
          WebDavSyncHabitKey.startDate,
          WebDavSyncHabitKey.targetDays,
          WebDavSyncHabitKey.sortPosition,
          WebDavSyncHabitKey.sessionId,
          WebDavSyncHabitKey.records,
          WebDavSyncHabitKey.convertType,
          WebDavSyncHabitKey.schemaVersion,
        };

        expect(
          classKeyValues.length,
          WebDavSyncHabitKeys.values.length,
          reason:
              'WebDavSyncHabitKey and WebDavSyncHabitKeys are out of sync — '
              'did you forget to add/remove a constant on both sides?',
        );
        expect(classKeyValues, WebDavSyncHabitKeys.allKnownKeys);
      },
    );

    test('key missing from allKnownKeys is captured by _unknown', () {
      final knownKeySet = WebDavSyncHabitKeys.allKnownKeys;
      const nonexistentKey = '_this_key_definitely_does_not_exist_';
      expect(knownKeySet.contains(nonexistentKey), isFalse);

      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        nonexistentKey: 'surprise',
      });
      expect(data.unknown, isNotNull);
      expect(data.unknown![nonexistentKey], 'surprise');
    });
  });

  group('WebDavSyncHabitData syncExtras cell round-trip', () {
    test('toHabitDBCell encodes _unknown into syncExtras', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc3.dbCode,
        'uuid': 'test-uuid',
        'group_id': 'g-encode',
      });
      final cell = data.toHabitDBCell();
      expect(cell.syncExtras, isNotNull);
      expect(cell.syncExtras, contains('group_id'));
      expect(cell.syncExtras, contains('g-encode'));
    });

    test('toHabitDBCell with null _unknown sets syncExtras to null', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc4.dbCode,
        'uuid': 'no-unknown',
      });
      final cell = data.toHabitDBCell();
      expect(cell.syncExtras, isNull);
    });

    test('fromHabitDBCell with unknown injects _unknown', () {
      final cell = HabitDBCell(
        uuid: 'test-uuid',
        color: HabitColorType.cc4.dbCode,
        syncExtras: '{"group_id":"g-inject","extra":true}',
      );
      final unknown = decodeSyncExtras(cell.syncExtras)!;
      final data = WebDavSyncHabitData.fromHabitDBCell(cell, unknown: unknown);
      expect(data.unknown, isNotNull);
      expect(data.unknown!['group_id'], 'g-inject');
      expect(data.unknown!['extra'], true);
      final json = data.toJson();
      expect(json['group_id'], 'g-inject');
      expect(json['extra'], true);
    });

    test('fromHabitDBCell without unknown leaves _unknown null', () {
      final cell = HabitDBCell(
        uuid: 'test-uuid',
        color: HabitColorType.cc5.dbCode,
      );
      final data = WebDavSyncHabitData.fromHabitDBCell(cell);
      expect(data.unknown, isNull);
    });

    test('full cell round-trip preserves unknown fields', () {
      final original = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc2.dbCode,
        'uuid': 'full-roundtrip',
        'name': 'Original',
        'group_id': 'g-full',
        'custom_attr': [1, 2, 3],
      });

      // toHabitDBCell → decode syncExtras
      final cell = original.toHabitDBCell();
      final unknown = decodeSyncExtras(cell.syncExtras);

      // fromHabitDBCell with unknown
      final restored = WebDavSyncHabitData.fromHabitDBCell(
        cell,
        unknown: unknown,
      );

      expect(restored.uuid, 'full-roundtrip');
      expect(restored.name, 'Original');
      expect(restored.unknown, isNotNull);
      expect(restored.unknown!['group_id'], 'g-full');
      expect(restored.unknown!['custom_attr'], [1, 2, 3]);
      final restoredJson = restored.toJson();
      expect(restoredJson['group_id'], 'g-full');
      expect(restoredJson['custom_attr'], [1, 2, 3]);
    });
  });
}

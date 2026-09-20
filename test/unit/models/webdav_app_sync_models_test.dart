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
import 'package:mhabit/annotations/_json_converters/normalizing_list_converter.dart';
import 'package:mhabit/models/_app_sync_tasks/webdav_app_sync_models.dart';
import 'package:mhabit/models/group.dart';
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

String? _futureFieldIdFromJson(Map<String, Object?> json) =>
    json['x_group_id'] as String?;

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
      final data = WebDavSyncHabitData.fromHabitDBCell(cell, unknown: null);

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
      final data = WebDavSyncHabitData.fromHabitDBCell(cell, unknown: null);

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
      final data = WebDavSyncHabitData.fromHabitDBCell(cell, unknown: null);

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
      final data = WebDavSyncHabitData.fromHabitDBCell(cell, unknown: null);

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
      final data = WebDavSyncHabitData.fromHabitDBCell(cell, unknown: null);
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
      final data = WebDavSyncHabitData.fromHabitDBCell(cell, unknown: null);
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
        final json = WebDavSyncHabitData.fromHabitDBCell(
          cell,
          unknown: null,
        ).toJson();

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
      final json = WebDavSyncHabitData.fromHabitDBCell(
        cell,
        unknown: null,
      ).toJson();

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
      final newJson = WebDavSyncHabitData.fromHabitDBCell(
        cell,
        unknown: null,
      ).toJson();

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

  test('pre-extras Group and Record readers tolerate future fields', () {
    final groupPayload = WebDavSyncGroupData.fromJson({
      '_convert_type': 'group_',
      'uuid': 'legacy-group',
      'name': 'Known Group',
      'status': 1,
      'future_group': {
        'nested': [1, 2],
      },
    }).toJson();
    final recordPayload = WebDavSyncRecordData.fromJson({
      '_convert_type': 'record_',
      'uuid': 'legacy-record',
      'parent_uuid': 'legacy-habit',
      'record_date': 20000,
      'record_type': 1,
      'record_value': 2,
      'future_record': {
        'nested': [3, 4],
      },
    }).toJson();

    // Pre-extras readers used these known fields and ignored other JSON keys.
    // Reconstruct their output without unknown-field preservation.
    final legacyGroup = WebDavSyncGroupData(
      uuid: groupPayload['uuid'] as String?,
      name: groupPayload['name'] as String?,
      status: (groupPayload['status'] as num?)?.toInt(),
    );
    final legacyRecord = WebDavSyncRecordData(
      uuid: recordPayload['uuid'] as String?,
      parentUUID: recordPayload['parent_uuid'] as String?,
      recordDate: (recordPayload['record_date'] as num?)?.toInt(),
      recordType: (recordPayload['record_type'] as num?)?.toInt(),
      recordValue: recordPayload['record_value'] as num?,
    );

    expect(legacyGroup.name, 'Known Group');
    expect(legacyGroup.toJson().containsKey('future_group'), isFalse);
    expect(legacyRecord.recordValue, 2);
    expect(legacyRecord.toJson().containsKey('future_record'), isFalse);
    expect(legacyGroup.validate, returnsNormally);
    expect(legacyRecord.validated, returnsNormally);
  });

  group('WebDavSyncHabitData _unknown bucket', () {
    test('fromJson captures unknown keys into _unknown', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc3.dbCode,
        'x_group_id': 'g-abc-123',
        'future_field': 42,
      });
      expect(data.unknown, isNotNull);
      expect(data.unknown!['x_group_id'], 'g-abc-123');
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
        'x_group_id': 'g-xyz',
        'future_field': 'hello',
      });
      final json = data.toJson();
      expect(json['x_group_id'], 'g-xyz');
      expect(json['future_field'], 'hello');
    });

    test('known field wins over _unknown in toJson', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc4.dbCode,
        'uuid': 'test-uuid',
      }).copyWith(unknown: {'uuid': 'evil-override', 'x_group_id': 'g-ok'});
      final json = data.toJson();
      expect(json['uuid'], 'test-uuid');
      expect(json['x_group_id'], 'g-ok');
    });

    test('_unknown does not appear as a JSON key', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc2.dbCode,
        'x_group_id': 'g-test',
      });
      final json = data.toJson();
      expect(json.containsKey('_unknown'), isFalse);
    });

    test('empty _unknown map is no-op in toJson', () {
      final data = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc3.dbCode,
      }).copyWith(unknown: {});
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
        'x_group_id': 'g-roundtrip',
        'extra_nested': {
          'a': 1,
          'b': [2, 3],
        },
      };
      final data = WebDavSyncHabitData.fromJson(originalJson);
      final roundtripped = WebDavSyncHabitData.fromJson(data.toJson());
      expect(roundtripped.unknown, isNotNull);
      expect(roundtripped.unknown!['x_group_id'], 'g-roundtrip');
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
        'x_group_id': 'future-group',
      };

      final oldSchemaClient = WebDavSyncHabitData.fromJson(serverPayload);
      final cell = oldSchemaClient.toHabitDBCell();
      final forwarded = WebDavSyncHabitData.fromHabitDBCell(
        cell,
        unknown: decodeSyncExtras(cell.syncExtras),
      ).toJson();

      expect(forwarded['x_group_id'], 'future-group');
      expect(_futureFieldIdFromJson(forwarded), 'future-group');
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
          WebDavSyncHabitKey.groupId,
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
        'x_group_id': 'g-encode',
      });
      final cell = data.toHabitDBCell();
      expect(cell.syncExtras, isNotNull);
      expect(cell.syncExtras, contains('x_group_id'));
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

    test('fromHabitDBCell accepts decoded unknown', () {
      final cell = HabitDBCell(
        uuid: 'test-uuid',
        color: HabitColorType.cc4.dbCode,
        syncExtras: '{"x_group_id":"g-inject","extra":true}',
      );
      final data = WebDavSyncHabitData.fromHabitDBCell(
        cell,
        unknown: decodeSyncExtras(cell.syncExtras),
      );
      expect(data.unknown, isNotNull);
      expect(data.unknown!['x_group_id'], 'g-inject');
      expect(data.unknown!['extra'], true);
      final json = data.toJson();
      expect(json['x_group_id'], 'g-inject');
      expect(json['extra'], true);
    });

    test(
      'fromHabitDBCell uses supplied unknown without reading syncExtras',
      () {
        final cell = HabitDBCell(
          color: HabitColorType.cc4.dbCode,
          syncExtras: '{"stored":"value"}',
        );
        final data = WebDavSyncHabitData.fromHabitDBCell(
          cell,
          unknown: {'provided': 'value'},
        );

        expect(data.unknown, {'provided': 'value'});
        expect(data.toJson().containsKey('stored'), isFalse);
      },
    );

    test('fromHabitDBCell with null unknown leaves _unknown null', () {
      final cell = HabitDBCell(
        uuid: 'test-uuid',
        color: HabitColorType.cc5.dbCode,
      );
      final data = WebDavSyncHabitData.fromHabitDBCell(cell, unknown: null);
      expect(data.unknown, isNull);
    });

    test('full cell round-trip preserves unknown fields', () {
      final original = WebDavSyncHabitData.fromJson({
        '_convert_type': 'habit_',
        'color': HabitColorType.cc2.dbCode,
        'uuid': 'full-roundtrip',
        'name': 'Original',
        'x_group_id': 'g-full',
        'custom_attr': [1, 2, 3],
      });

      // The DB loader decodes syncExtras before constructing sync data.
      final cell = original.toHabitDBCell();
      final restored = WebDavSyncHabitData.fromHabitDBCell(
        cell,
        unknown: decodeSyncExtras(cell.syncExtras),
      );

      expect(restored.uuid, 'full-roundtrip');
      expect(restored.name, 'Original');
      expect(restored.unknown, isNotNull);
      expect(restored.unknown!['x_group_id'], 'g-full');
      expect(restored.unknown!['custom_attr'], [1, 2, 3]);
      final restoredJson = restored.toJson();
      expect(restoredJson['x_group_id'], 'g-full');
      expect(restoredJson['custom_attr'], [1, 2, 3]);
    });
  });

  group('WebDavSyncGroupData sortPosition', () {
    test('fromGroupDBCell passes sortPosition through', () {
      const cell = GroupDBCell(
        uuid: 'g-sync-sort',
        name: 'Sync Sort',
        sortPosition: 2.5,
      );

      final data = WebDavSyncGroupData.fromGroupDBCell(cell, unknown: null);
      expect(data.sortPosition, 2.5);
    });

    test('fromGroupDBCell with null sortPosition', () {
      const cell = GroupDBCell(uuid: 'g-sync-null', name: 'No Sort');

      final data = WebDavSyncGroupData.fromGroupDBCell(cell, unknown: null);
      expect(data.sortPosition, isNull);
    });

    test('toGroupDBCell passes sortPosition through', () {
      const data = WebDavSyncGroupData(
        uuid: 'g-cell-sort',
        name: 'Cell Sort',
        sortPosition: 7.5,
      );

      final cell = data.toGroupDBCell();
      expect(cell.sortPosition, 7.5);
    });

    test('toGroupDBCell with null sortPosition', () {
      const data = WebDavSyncGroupData(uuid: 'g-cell-null', name: 'No Sort');

      final cell = data.toGroupDBCell();
      expect(cell.sortPosition, isNull);
    });

    test('JSON round-trip preserves sortPosition', () {
      const original = WebDavSyncGroupData(
        uuid: 'g-json-rt',
        name: 'JSON RT',
        sortPosition: 3.75,
      );

      final json = original.toJson();
      final restored = WebDavSyncGroupData.fromJson(json);
      expect(restored.sortPosition, 3.75);
    });

    test('fromJson tolerates missing sort_position key', () {
      final json = {'uuid': 'g-old-json', 'name': 'Old JSON'};

      final data = WebDavSyncGroupData.fromJson(json);
      expect(data.sortPosition, isNull);
    });
  });

  test('record unknown fields round-trip without replacing known keys', () {
    final record = WebDavSyncRecordData.fromJson({
      '_convert_type': 'record_',
      'uuid': 'record-1',
      'record_type': 1,
      'future': {
        'nested': [1, 2],
      },
    });
    expect(record.unknown, {
      'future': {
        'nested': [1, 2],
      },
    });
    final json = record
        .copyWith(unknown: {...record.unknown!, 'uuid': 'wrong-uuid'})
        .toJson();
    expect(json['uuid'], 'record-1');
    expect(json['future'], {
      'nested': [1, 2],
    });
    expect(json.containsKey('unknown'), isFalse);
  });

  test('habit upload preserves unknown fields on later records', () {
    const habit = WebDavSyncHabitData(
      uuid: 'habit-1',
      records: {
        'record-1': WebDavSyncRecordData(uuid: 'record-1'),
        'record-2': WebDavSyncRecordData(
          uuid: 'record-2',
          unknown: {'future_record': 'keep-me'},
        ),
      },
    );

    final uploaded = habit.toJson();
    final restored = WebDavSyncHabitData.fromJson(uploaded);
    expect(restored.records['record-2']!.unknown?['future_record'], 'keep-me');
  });

  test('mixed record extras remain readable by the pre-extras client', () {
    const newerHabit = WebDavSyncHabitData(
      uuid: 'habit-1',
      records: {
        'record-1': WebDavSyncRecordData(
          uuid: 'record-1',
          recordType: 1,
          recordValue: 1,
        ),
        'record-2': WebDavSyncRecordData(
          uuid: 'record-2',
          recordType: 1,
          recordValue: 2,
          unknown: {'future_record': 'keep-me'},
        ),
      },
    );
    final uploaded = newerHabit.toJson();
    expect(WebDavSyncHabitData.fromJson(uploaded).validate, returnsNormally);
    final wireRows = (uploaded['records'] as List)
        .map((row) => row as List)
        .toList();

    // The decoder is unchanged from the pre-extras client. Its record model
    // reads known fields and ignores the additional column.
    final decodedRows = const NormalizingListConverter().fromJson(wireRows);
    expect(decodedRows[0]['future_record'], isNull);
    expect(decodedRows[1]['future_record'], 'keep-me');
    final legacyRecords = {
      for (final row in decodedRows)
        row['uuid'] as String: WebDavSyncRecordData(
          uuid: row['uuid'] as String,
          recordType: (row['record_type'] as num?)?.toInt(),
          recordValue: row['record_value'] as num?,
        ),
    };
    expect(legacyRecords['record-1']!.recordValue, 1);
    expect(legacyRecords['record-2']!.recordValue, 2);
    for (final record in legacyRecords.values) {
      expect(record.validated, returnsNormally);
    }

    // A pre-extras client re-uploads its known field set. The newer client
    // must still read the records, although the old client drops extras.
    final legacyUpload = WebDavSyncHabitData(
      uuid: newerHabit.uuid,
      records: legacyRecords,
    ).toJson();
    final newerRead = WebDavSyncHabitData.fromJson(legacyUpload);
    expect(newerRead.validate, returnsNormally);
    expect(newerRead.records['record-1']!.recordValue, 1);
    expect(newerRead.records['record-2']!.recordValue, 2);
    expect(newerRead.records['record-2']!.unknown, isNull);
  });

  test('new fields on one habit do not appear on another habit', () {
    const firstHabit = WebDavSyncHabitData(
      uuid: 'habit-1',
      unknown: {'future_extra': 'existing'},
    );
    const secondHabit = WebDavSyncHabitData(
      uuid: 'habit-2',
      unknown: {'new_field': 'new'},
    );

    final firstUpload = firstHabit.toJson();
    final secondUpload = secondHabit.toJson();
    expect(firstUpload['future_extra'], 'existing');
    expect(firstUpload.containsKey('new_field'), isFalse);
    expect(secondUpload['new_field'], 'new');
    expect(secondUpload.containsKey('future_extra'), isFalse);
    expect(WebDavSyncHabitData.fromJson(firstUpload).unknown, {
      'future_extra': 'existing',
    });
    expect(WebDavSyncHabitData.fromJson(secondUpload).unknown, {
      'new_field': 'new',
    });
  });

  test('group unknown fields cannot replace known keys', () {
    final group = WebDavSyncGroupData.fromJson({
      '_convert_type': 'group_',
      'uuid': 'group-1',
      'future': {
        'nested': [3, 4],
      },
    });
    final json = group
        .copyWith(unknown: {...group.unknown!, 'uuid': 'wrong-uuid'})
        .toJson();
    expect(json['uuid'], 'group-1');
    expect(json['future'], {
      'nested': [3, 4],
    });
  });
}

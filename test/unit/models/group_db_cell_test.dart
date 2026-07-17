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
import 'package:mhabit/models/group.dart';

GroupDBCell _buildCell({
  int id = 1,
  int createT = 100000,
  int modifyT = 100001,
  String uuid = 'test-uuid',
  String name = 'Test Group',
  String? desc,
  int? icon,
  int? color,
  int? customColor,
  int? customColorTinted,
  int status = 1,
}) {
  return GroupDBCell(
    id: id,
    createT: createT,
    modifyT: modifyT,
    uuid: uuid,
    name: name,
    desc: desc,
    icon: icon,
    color: color,
    customColor: customColor,
    customColorTinted: customColorTinted,
    status: status,
  );
}

void main() {
  group('GroupDBCell.toJson — nullable color/icon field inclusion', () {
    test('all fields non-null includes everything', () {
      final cell = _buildCell(desc: 'A group', icon: 0);
      final json = cell.toJson();

      expect(json['id_'], 1);
      expect(json['create_t'], 100000);
      expect(json['modify_t'], 100001);
      expect(json['uuid'], 'test-uuid');
      expect(json['name'], 'Test Group');
      expect(json['desc'], 'A group');
      expect(json['icon'], 0);
      expect(json['color'], isNull);
      expect(json['custom_color'], isNull);
      expect(json['custom_color_tinted'], isNull);
      expect(json['status'], 1);
    });

    test('icon null is explicitly included', () {
      final cell = _buildCell(/* icon defaults to null */);
      final json = cell.toJson();

      expect(json.containsKey('icon'), isTrue);
      expect(json['icon'], isNull);
    });

    test('color null is explicitly included', () {
      final cell = _buildCell(color: null);
      final json = cell.toJson();

      expect(json.containsKey('color'), isTrue);
      expect(json['color'], isNull);
    });

    test('customColor null is explicitly included', () {
      final cell = _buildCell(customColor: null);
      final json = cell.toJson();

      expect(json.containsKey('custom_color'), isTrue);
      expect(json['custom_color'], isNull);
    });

    test('customColorTinted null is explicitly included', () {
      final cell = _buildCell(customColorTinted: null);
      final json = cell.toJson();

      expect(json.containsKey('custom_color_tinted'), isTrue);
      expect(json['custom_color_tinted'], isNull);
    });

    test('desc null is excluded (class-level includeIfNull: false)', () {
      final cell = _buildCell(desc: null);
      final json = cell.toJson();

      expect(json.containsKey('desc'), isFalse);
    });

    test('non-null icon/color values are included', () {
      final cell = _buildCell(
        icon: 42,
        color: 1,
        customColor: 0xFFAABBCC,
        customColorTinted: 0xFFDDEEFF,
      );
      final json = cell.toJson();

      expect(json['icon'], 42);
      expect(json['color'], 1);
      expect(json['custom_color'], 0xFFAABBCC);
      expect(json['custom_color_tinted'], 0xFFDDEEFF);
    });
  });
}

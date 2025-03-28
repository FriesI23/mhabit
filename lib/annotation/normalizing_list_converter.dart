// Copyright 2025 Fries_I23
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

import 'package:json_annotation/json_annotation.dart';

import '../common/types.dart';

class NormalizingListConverter
    implements JsonConverter<List<JsonMap>, List<List>> {
  const NormalizingListConverter();

  @override
  List<JsonMap> fromJson(List<List> json) {
    assert(json.length > 1 || json.isEmpty);
    if (json.isEmpty) return const [];
    final keyList = json.first.map((e) => e as String).toList();
    final result = <JsonMap>[];
    for (var i = 1; i < json.length; i++) {
      final data = json[i];
      result.add(Map.fromIterables(keyList, data));
    }
    return result;
  }

  @override
  List<List> toJson(Iterable<JsonMap> object) {
    final result = <List>[];
    if (object.isNotEmpty) {
      final keyList = object.first.keys.toList();
      result.add(keyList);
      for (var item in object) {
        final data = keyList.map((key) => item[key]).toList();
        result.add(data);
      }
    }
    return result;
  }
}

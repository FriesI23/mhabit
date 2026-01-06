// Copyright 2024 Fries_I23
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

import 'dart:convert';

import 'package:flutter/services.dart';

Future<String> getSqlFromFile(String filepath) async {
  final raw = await rootBundle.load(filepath);
  final data = raw.buffer.asUint8List(raw.offsetInBytes, raw.lengthInBytes);
  return utf8.decode(data);
}

({
  List<MapEntry<String, String>> updateList,
  List<MapEntry<String, String>> deleteList,
})
processDuplicatedMap(Map<String, String> uuidMap) {
  final seenValues = <String>{};
  final deleteList = <MapEntry<String, String>>[];
  final tempList = <MapEntry<String, String>>[];
  final allKeys = uuidMap.keys.toSet();

  for (var entry in uuidMap.entries) {
    final value = entry.value;

    if (seenValues.contains(value)) {
      deleteList.add(entry);
    } else {
      seenValues.add(value);
      tempList.add(entry);
    }
  }

  final reorderedList = <MapEntry<String, String>>[];
  final keyToEntry = Map.fromEntries(tempList.map((e) => MapEntry(e.key, e)));

  final processedKeys = <String>{};
  for (var entry in tempList) {
    final key = entry.key;
    final value = entry.value;

    if (allKeys.contains(value) && !processedKeys.contains(value)) {
      final priorEntry = keyToEntry[value];
      if (priorEntry != null) {
        reorderedList.add(priorEntry);
        processedKeys.add(value);
      }
    }

    if (!processedKeys.contains(key)) {
      reorderedList.add(entry);
      processedKeys.add(key);
    }
  }
  return (updateList: reorderedList, deleteList: deleteList);
}

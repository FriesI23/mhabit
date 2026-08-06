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

import 'dart:ui' show Locale;

import 'package:native_natural_sort/native_natural_sort.dart';

/// Parses a BCP-47 language tag (e.g. "zh", "zh-CN") into a [Locale].
Locale? _parseLocale(String? tag) {
  if (tag == null || tag.isEmpty) return null;
  final parts = tag.split('-');
  return switch (parts.length) {
    1 => Locale(parts[0]),
    >= 2 => Locale(parts[0], parts[1]),
    _ => null,
  };
}

/// Thin wrapper around [NativeSort] from the native_natural_sort package.
///
/// All platform-specific dispatch (Android Collator, iOS/macOS
/// localizedStandardCompare, Linux FFI→ICU, Windows CompareStringEx/FFI)
/// is handled by the package.  This extension provides the generic
/// [naturalSort] method used by the habit-display sorter.
extension NaturalSortExtension on NativeSort {
  /// Sorts [items] by native collation order.
  ///
  /// [idOf] is the stable identifier used for ordering and tie-breaking;
  /// [valueOf] is the string whose collation order determines position.
  ///
  /// Returns a [Future] that completes with the sorted list.  Empty
  /// input is returned immediately without calling into the platform.
  Future<List<T>> naturalSort<T>({
    required List<T> items,
    required String Function(T) idOf,
    required String Function(T) valueOf,
    bool descending = false,
    String? locale,
  }) async {
    if (items.isEmpty) return items;

    final sortItems = items
        .map((e) => SortItem(id: idOf(e), value: valueOf(e)))
        .toList();

    final sorted = await sort(
      sortItems,
      direction: descending
          ? SortDirection.descending
          : SortDirection.ascending,
      locale: _parseLocale(locale),
    );

    // Map sorted IDs back to original items.
    final idToItem = <String, T>{for (final e in items) idOf(e): e};
    final result = <T>[];
    for (final si in sorted) {
      final item = idToItem.remove(si.id);
      if (item != null) result.add(item);
    }
    // Append any items that appeared during the async gap
    // (e.g. added while the platform sort was in-flight).
    if (idToItem.isNotEmpty) {
      final remaining = idToItem.values.toList()
        ..sort((a, b) => valueOf(a).compareTo(valueOf(b)));
      result.addAll(remaining);
    }
    return result;
  }
}

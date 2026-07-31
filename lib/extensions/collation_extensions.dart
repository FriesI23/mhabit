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

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../common/collation.dart';
import '../common/collation_ffi_windows.dart';

/// Sorts [items] by their position in [rankedIds].
///
/// Items whose ids are not in [rankedIds] (e.g. added during the async
/// gap) fall back to [valueOf] → [Comparable.compareTo].
@visibleForTesting
List<T> sortByRank<T>({
  required List<T> items,
  required List<String> rankedIds,
  required String Function(T) idOf,
  required String Function(T) valueOf,
  bool descending = false,
}) {
  final rank = <String, int>{};
  for (var i = 0; i < rankedIds.length; i++) {
    rank[rankedIds[i]] = i;
  }

  final sorted = items.toList()
    ..sort((a, b) {
      final ra = rank[idOf(a)];
      final rb = rank[idOf(b)];
      if (ra != null && rb != null) return ra.compareTo(rb);
      if (ra != null) return -1;
      if (rb != null) return 1;
      return valueOf(a).compareTo(valueOf(b));
    });

  return descending ? sorted.reversed.toList() : sorted;
}

/// Extension that provides native-collation sorting on [CollationApi].
///
/// Dispatch: sync FFI on Linux; sync FFI on Windows (falling back to the
/// async MethodChannel when the system ICU is missing); async
/// MethodChannel on other platforms.
extension CollationApiNaturalSort on CollationApi {
  /// Sorts [items] by native collation order.
  ///
  /// [idOf] is the stable identifier used for ordering and tie-breaking;
  /// [valueOf] is the string whose collation order determines position.
  ///
  /// Returns synchronously on Linux and Windows (FFI), and a [Future] on
  /// other platforms (async MethodChannel).  Linux is FFI-only — callers
  /// own the fallback when the engine is unavailable.
  FutureOr<List<T>> naturalSort<T>({
    required List<T> items,
    required String Function(T) idOf,
    required String Function(T) valueOf,
    bool descending = false,
    String? locale,
  }) {
    if (items.isEmpty) return items;

    if (Platform.isLinux) {
      // Linux is FFI-only; callers own the fallback.
      return collationSortFfiLinux(
        items: items,
        idOf: idOf,
        valueOf: valueOf,
        descending: descending,
        locale: locale,
      );
    }

    if (Platform.isWindows) {
      // Fall back to the async platform channel when system ICU is missing.
      if (IcuCollationWindows.available) {
        return collationSortFfiWindows(
          items: items,
          idOf: idOf,
          valueOf: valueOf,
          descending: descending,
          locale: locale,
        );
      }
      return _naturalSortAsync(items, idOf, valueOf, descending, locale);
    }

    return _naturalSortAsync(items, idOf, valueOf, descending, locale);
  }

  Future<List<T>> _naturalSortAsync<T>(
    List<T> items,
    String Function(T) idOf,
    String Function(T) valueOf,
    bool descending,
    String? locale,
  ) async {
    final request = CollationRequest(
      items: items
          .map((e) => CollationItem(id: idOf(e), value: valueOf(e)))
          .toList(),
      locale: locale,
    );
    final sortedIds = await sortStrings(request);
    return sortByRank(
      items: items,
      rankedIds: sortedIds,
      idOf: idOf,
      valueOf: valueOf,
      descending: descending,
    );
  }
}

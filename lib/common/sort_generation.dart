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

import 'package:flutter/foundation.dart';

/// Guards synchronous sort results against being overwritten by a concurrent
/// data reload, by wrapping the sort in an async generation check.
///
/// The sort algorithm itself is synchronous; [SortGuard] provides the async
/// boundary so that an in-flight sort can be discarded when a reload bumps
/// the generation.
///
/// Usage:
/// ```dart
/// final _sortGuard = SortGuard();
///
/// // In loadData() — before reloading fresh data:
/// _sortGuard.bump();
///
/// // In _resortData() — guard the cache write:
/// final result = await _sortGuard.run(() => data.sort(...));
/// if (result == null) return; // discarded — data was reloaded during sort
/// ```
class SortGuard {
  int _generation = 0;

  /// Bump the generation — call before reloading the data source to
  /// invalidate any in-flight sorts.
  void bump() {
    _generation++;
  }

  /// Runs [sort] and returns its result, or `null` if [bump] was called
  /// during the operation (i.e. data was reloaded and the sort is stale).
  ///
  /// The [sort] closure is synchronous (e.g. `List.sort()`).  [run] wraps
  /// it in an async frame so that the generation can change across an
  /// `await` yield.
  Future<T?> run<T>(T Function() sort, {String? debugLabel}) async {
    final token = _generation;
    // Yield to let any pending microtask (reload bump) run before sort.
    await Future.delayed(Duration.zero);
    final result = sort();
    if (_generation != token) {
      assert(() {
        final label = debugLabel != null ? '[$debugLabel] ' : '';
        debugPrint(
          'SortGuard: ${label}sort result discarded'
          ' — data was reloaded during sort',
        );
        return true;
      }());
      return null;
    }
    return result;
  }

  /// Capture the current generation before a manual check.
  @visibleForTesting
  SortGuardToken capture() => SortGuardToken._(_generation);

  /// Whether [token] is still current (no [bump] happened since capture).
  @visibleForTesting
  bool isCurrent(SortGuardToken token) => _generation == token._value;
}

/// Opaque token produced by [SortGuard.capture].
@visibleForTesting
class SortGuardToken {
  final int _value;

  const SortGuardToken._(this._value);
}

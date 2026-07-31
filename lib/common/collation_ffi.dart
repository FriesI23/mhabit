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

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

/// Compares [a] and [b] by collation order: negative if [a] sorts first,
/// zero if collation-equal, positive if [b] sorts first.
typedef CollationCompareFn = int Function(String a, String b);

/// Contract for platform-native ICU collation engines.
///
/// Implemented by [IcuCollationBase] subclasses ([IcuCollationLinux] on
/// Linux, [IcuCollationWindows] on Windows) and consumed by [IcuCollation].
abstract interface class IcuCollationEngine {
  /// Compares [a] and [b] by collation order.
  int compare(String a, String b);

  /// Releases native resources.  No-op for test doubles.
  void dispose();
}

/// Base for platform FFI collation engines (Linux / Windows).
///
/// Resolves the ICU C API from [lib] (symbols may carry a version
/// [suffix], e.g. `_78`), opens a collator for [localeName] with numeric
/// ordering enabled via the `-u-kn` locale keyword, and compares strings
/// pairwise with [ucol_strcoll].
///
/// Numeric ordering must be requested at open time — setting the
/// UCOL_NUMERIC_COLLATION attribute afterwards has no effect — and sort
/// keys cannot represent numeric order ("2"/"10" collapse to equal keys),
/// hence direct [ucol_strcoll] comparison.
class IcuCollationBase implements IcuCollationEngine {
  IcuCollationBase(DynamicLibrary lib, String suffix, String? localeName) {
    _ucolOpen = lib
        .lookupFunction<
          Pointer<Void> Function(Pointer<Uint8>, Pointer<Int32>),
          Pointer<Void> Function(Pointer<Uint8>, Pointer<Int32>)
        >('ucol_open$suffix');
    _ucolClose = lib
        .lookupFunction<
          Void Function(Pointer<Void>),
          void Function(Pointer<Void>)
        >('ucol_close$suffix');
    _ucolStrColl = lib
        .lookupFunction<
          Int32 Function(
            Pointer<Void>,
            Pointer<Uint16>,
            Int32,
            Pointer<Uint16>,
            Int32,
          ),
          int Function(
            Pointer<Void>,
            Pointer<Uint16>,
            int,
            Pointer<Uint16>,
            int,
          )
        >('ucol_strcoll$suffix');
    _coll = _openCollator(localeName);
  }

  // UCollator* ucol_open(const char* loc, UErrorCode* status)
  late final Pointer<Void> Function(Pointer<Uint8>, Pointer<Int32>) _ucolOpen;
  // void ucol_close(UCollator* coll)
  late final void Function(Pointer<Void>) _ucolClose;
  // int32_t ucol_strcoll(
  //   const UCollator* coll, const UChar* s1, int32_t len1,
  //   const UChar* s2, int32_t len2)
  late final int Function(
    Pointer<Void>,
    Pointer<Uint16>,
    int,
    Pointer<Uint16>,
    int,
  )
  _ucolStrColl;
  late final Pointer<Void> _coll;

  Pointer<Void> _openCollator(String? localeName) {
    final hasLocale = localeName != null && localeName.isNotEmpty;
    final base = hasLocale ? localeName : Platform.localeName;
    final normalized = base.replaceAll('_', '-');
    // Numeric ordering is a locale keyword (`-u-kn`) requested at open
    // time; setting UCOL_NUMERIC_COLLATION afterwards is a no-op.
    final locale = '${normalized.isEmpty ? 'en' : normalized}-u-kn';
    final locPtr = locale.toNativeUtf8(allocator: malloc);
    final status = calloc<Int32>()..value = 0;
    try {
      final coll = _ucolOpen(locPtr.cast<Uint8>(), status);
      // Only positive status is an error (U_FAILURE); negative values are
      // warnings (e.g. U_USING_DEFAULT_WARNING) and still yield a valid
      // collator using fallback data.
      if (status.value > 0 || coll == nullptr) {
        if (coll != nullptr) _ucolClose(coll);
        throw UnsupportedError(
          'ucol_open failed for "$locale": UErrorCode=${status.value}',
        );
      }
      return coll;
    } finally {
      calloc.free(status);
      malloc.free(locPtr);
    }
  }

  @override
  void dispose() => _ucolClose(_coll);

  /// Compares [a] and [b] via [ucol_strcoll] (numeric-aware).
  @override
  int compare(String a, String b) {
    final pa = a.toNativeUtf16(allocator: malloc);
    final pb = b.toNativeUtf16(allocator: malloc);
    try {
      return _ucolStrColl(
        _coll,
        pa.cast<Uint16>(),
        a.length,
        pb.cast<Uint16>(),
        b.length,
      );
    } finally {
      malloc.free(pa);
      malloc.free(pb);
    }
  }
}

/// Synchronous collation sort using an injectable comparison function.
///
/// Pure-Dart [sort] logic fed by the injected [_compare] closure.
/// Production instances wrap a platform-native [IcuCollationEngine];
/// tests inject a mock via [IcuCollation.test].
class IcuCollation {
  final CollationCompareFn _compare;
  final void Function() _dispose;

  /// Production: wraps a platform-native [IcuCollationEngine].
  IcuCollation(IcuCollationEngine engine)
    : _compare = engine.compare,
      _dispose = engine.dispose;

  /// Test: inject a mock comparison function.  No native resources.
  @visibleForTesting
  IcuCollation.test(CollationCompareFn compare)
    : _compare = compare,
      _dispose = _noop;

  static void _noop() {}

  /// Releases native resources (no-op for test instances).
  void dispose() => _dispose();

  /// Sorts [items] by collation order of their values.
  ///
  /// Returns a new sorted list.  Collation ties are broken by [idOf].
  List<T> sort<T>({
    required List<T> items,
    required String Function(T) idOf,
    required String Function(T) valueOf,
    bool descending = false,
  }) {
    if (items.isEmpty) return items;

    final sorted = items.toList()
      ..sort((a, b) {
        final cmp = _compare(valueOf(a), valueOf(b));
        if (cmp != 0) return cmp;
        return idOf(a).compareTo(idOf(b));
      });
    return descending ? sorted.reversed.toList() : sorted;
  }
}

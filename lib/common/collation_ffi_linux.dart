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

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

typedef SortKeyFn = Uint8List Function(String);

/// ICU-native sort-key implementation via [ucol_getSortKey].
///
/// Loads `libicui18n.so` with a version fallback chain covering common
/// Linux distributions and Flatpak Freedesktop SDK runtimes, creates an
/// ICU collator for the given BCP-47 locale, enables numeric collation,
/// and generates sort-key byte arrays comparable lexicographically in
/// pure Dart.
///
/// Callers obtain a [SortKeyFn] closure for injection into [IcuCollation].
class IcuSortKey {
  // -- Library loading -------------------------------------------------------

  /// ICU soname versions covered by the fallback chain (70–77).
  static const _soVersions = ['77', '76', '75', '74', '73', '72', '71', '70'];

  /// Maps [Abi.current()] to the Linux multiarch directory component.
  static String get _multiarchTriplet => switch (Abi.current()) {
    Abi.linuxArm64 => 'aarch64-linux-gnu',
    Abi.linuxX64 => 'x86_64-linux-gnu',
    Abi.linuxArm => 'arm-linux-gnueabihf',
    Abi.linuxRiscv64 => 'riscv64-linux-gnu',
    _ => 'x86_64-linux-gnu',
  };

  static DynamicLibrary? _libCache;
  static String _icuVersionSuffix = '';

  static DynamicLibrary get _lib => _libCache ??= _loadLib();

  /// Extracts the ICU major version from a soname path.
  ///
  /// "libicui18n.so.72" → "_72",
  /// "/lib/aarch64-linux-gnu/libicui18n.so.72" → "_72",
  /// "libicui18n.so" → "".
  static String _extractVersionSuffix(String path) {
    final match = RegExp(r'\.so\.(\d+)$').firstMatch(path);
    return match != null ? '_${match.group(1)}' : '';
  }

  /// Probes the loaded [lib] for a `ucol_open_XX` symbol.
  ///
  /// Checks [preferred] first (extracted from the soname path), then
  /// falls back to trying all versions in [_soVersions], and finally
  /// tries the bare `ucol_open` (no suffix).  Returns the suffix
  /// (e.g. `"_72"`, `""`) or `null` when no variant is available.
  static String? _probeVersionSuffix(
    DynamicLibrary lib, {
    String preferred = '',
  }) {
    // 1. Try the version suggested by the soname.
    if (preferred.isNotEmpty) {
      try {
        lib.lookup<NativeFunction<Void Function()>>('ucol_open$preferred');
        return preferred;
      } on ArgumentError {
        // not available — fall through
      }
    }
    // 2. Try every known version.
    for (final v in _soVersions) {
      if ('_$v' == preferred) continue; // already tried above
      try {
        lib.lookup<NativeFunction<Void Function()>>('ucol_open_$v');
        return '_$v';
      } on ArgumentError {
        continue;
      }
    }
    // 3. Try unversioned symbol (standard ICU / Flatpak).
    try {
      lib.lookup<NativeFunction<Void Function()>>('ucol_open');
      return '';
    } on ArgumentError {
      return null;
    }
  }

  static DynamicLibrary _loadLib() {
    final arch = _multiarchTriplet;

    // Build fallback chain:
    //  1. bare sonames (host systems with working ldconfig)
    //  2. /usr/lib multiarch paths (Flatpak / usrmerge systems)
    //  3. /lib multiarch paths (traditional Debian layout)
    //  4. unversioned soname (last resort)
    final candidates = <String>[
      for (final v in _soVersions) 'libicui18n.so.$v',
      for (final v in _soVersions) '/usr/lib/$arch/libicui18n.so.$v',
      for (final v in _soVersions) '/lib/$arch/libicui18n.so.$v',
      'libicui18n.so',
    ];

    for (final candidate in candidates) {
      DynamicLibrary lib;
      try {
        lib = DynamicLibrary.open(candidate);
      } catch (_) {
        continue;
      }

      // Determine the ICU symbol-version suffix for this library.
      final extractedSuffix = _extractVersionSuffix(candidate);
      // The extracted suffix may be wrong (e.g. Flatpak has unversioned
      // symbols inside a versioned soname).  Probe to confirm.
      final suffix = _probeVersionSuffix(lib, preferred: extractedSuffix);
      if (suffix == null) continue; // can't resolve any symbol

      _icuVersionSuffix = suffix;
      return lib;
    }

    throw UnsupportedError(
      'libicui18n not found (tried versions $_soVersions,'
      ' /usr/lib/$arch + /lib/$arch multiarch paths,'
      ' and unversioned fallback)',
    );
  }

  // UCollator* ucol_open(const char* loc, UErrorCode* status)
  static final _ucolOpen = _lib
      .lookupFunction<
        Pointer<Void> Function(Pointer<Utf8>, Pointer<Int32>),
        Pointer<Void> Function(Pointer<Utf8>, Pointer<Int32>)
      >('ucol_open$_icuVersionSuffix');

  // void ucol_close(UCollator* coll)
  static final _ucolClose = _lib
      .lookupFunction<
        Void Function(Pointer<Void>),
        void Function(Pointer<Void>)
      >('ucol_close$_icuVersionSuffix');

  // int32_t ucol_getSortKey(
  //   const UCollator* coll, const UChar* source, int32_t sourceLength,
  //   uint8_t* result, int32_t resultLength)
  static final _ucolGetSortKey = _lib
      .lookupFunction<
        Int32 Function(
          Pointer<Void>,
          Pointer<Uint16>,
          Int32,
          Pointer<Uint8>,
          Int32,
        ),
        int Function(Pointer<Void>, Pointer<Uint16>, int, Pointer<Uint8>, int)
      >('ucol_getSortKey$_icuVersionSuffix');

  // void ucol_setAttribute(
  //   UCollator* coll, UColAttribute attr, UColAttributeValue value,
  //   UErrorCode* status)
  static final _ucolSetAttribute = _lib
      .lookupFunction<
        Void Function(Pointer<Void>, Int32, Int32, Pointer<Int32>),
        void Function(Pointer<Void>, int, int, Pointer<Int32>)
      >('ucol_setAttribute$_icuVersionSuffix');

  static const int _uZeroError = 0;
  static const int _ucolNumericCollation = 6;
  static const int _ucolOn = 17;

  final Pointer<Void> _coll;

  /// Creates a sort-key generator for [localeName] (BCP-47).
  ///
  /// Throws [UnsupportedError] if `libicui18n` cannot be loaded or if ICU
  /// cannot open a collator for the requested locale.  Callers should
  /// catch these and fall back to a non-collated sort.
  IcuSortKey(String? localeName) : _coll = _openCollator(localeName);

  static Pointer<Void> _openCollator(String? localeName) {
    final hasLocale = localeName != null && localeName.isNotEmpty;
    final locPtr = hasLocale
        ? localeName.toNativeUtf8(allocator: malloc)
        : nullptr;
    final status = calloc<Int32>()..value = _uZeroError;
    try {
      final coll = _ucolOpen(locPtr, status);
      if (status.value != _uZeroError || coll == nullptr) {
        if (coll != nullptr) _ucolClose(coll);
        throw UnsupportedError(
          'ucol_open failed for "$localeName": UErrorCode=${status.value}',
        );
      }

      // Enable numeric collation — best-effort, non-fatal.
      final attrStatus = calloc<Int32>()..value = _uZeroError;
      try {
        _ucolSetAttribute(coll, _ucolNumericCollation, _ucolOn, attrStatus);
      } finally {
        calloc.free(attrStatus);
      }

      return coll;
    } finally {
      calloc.free(status);
      if (hasLocale) malloc.free(locPtr);
    }
  }

  void dispose() => _ucolClose(_coll);

  /// Returns a collation sort-key byte array for [s].
  ///
  /// Converts the Dart [String] to UTF-16 ([UChar*]) and delegates to ICU
  /// [ucol_getSortKey].  The returned key includes only the sort-key bytes
  /// (trailing null terminator stripped) and can be compared with
  /// byte-wise lexicographic order.
  Uint8List call(String s) {
    final codeUnits = s.codeUnits;
    final srcPtr = malloc<Uint16>(codeUnits.length + 1);
    try {
      for (var i = 0; i < codeUnits.length; i++) {
        srcPtr[i] = codeUnits[i];
      }
      srcPtr[codeUnits.length] = 0;

      // ICU sort-key sizing: needed includes the null terminator.
      final needed = _ucolGetSortKey(
        _coll,
        srcPtr,
        codeUnits.length,
        nullptr,
        0,
      );
      if (needed <= 0) return Uint8List(0);

      final buf = malloc<Uint8>(needed);
      try {
        _ucolGetSortKey(_coll, srcPtr, codeUnits.length, buf, needed);
        // ICU docs: the returned length includes the trailing NUL.
        return Uint8List.fromList(buf.asTypedList(needed - 1));
      } finally {
        malloc.free(buf);
      }
    } finally {
      malloc.free(srcPtr);
    }
  }
}

/// Synchronous collation sort using an injectable sort-key function.
///
/// Pure-Dart [sort] logic fed by the injected [_sortKey] closure.
/// Production instances use [IcuSortKey] ([ucol_getSortKey] via FFI);
/// tests inject a mock via [IcuCollation.test].
class IcuCollation {
  final SortKeyFn _sortKey;
  final void Function() _dispose;

  /// Production: uses ICU [ucol_getSortKey] via [IcuSortKey].
  IcuCollation(String? localeName) : this._from(IcuSortKey(localeName));

  /// Test: inject a mock sort-key function.  No native resources.
  @visibleForTesting
  IcuCollation.test(SortKeyFn sortKey) : _sortKey = sortKey, _dispose = _noop;

  IcuCollation._from(IcuSortKey native)
    : _sortKey = native.call,
      _dispose = native.dispose;

  static void _noop() {}

  /// Releases native resources (no-op for test instances).
  void dispose() => _dispose();

  /// Sorts [items] by collation order of their values.
  ///
  /// Returns a new sorted list.  Ties are broken by [idOf].
  List<T> sort<T>({
    required List<T> items,
    required String Function(T) idOf,
    required String Function(T) valueOf,
    bool descending = false,
  }) {
    if (items.isEmpty) return items;

    // 1. Generate sort keys — O(n).
    final keys = <Uint8List>[];
    for (final item in items) {
      keys.add(_sortKey(valueOf(item)));
    }

    // 2. Sort in pure Dart using precomputed keys.
    final indices = List.generate(items.length, (i) => i);
    indices.sort((a, b) {
      final cmp = _compareKeys(keys[a], keys[b]);
      if (cmp != 0) return cmp;
      return idOf(items[a]).compareTo(idOf(items[b]));
    });

    final result = indices.map((i) => items[i]).toList();
    return descending ? result.reversed.toList() : result;
  }

  static int _compareKeys(Uint8List a, Uint8List b) {
    final len = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      if (a[i] != b[i]) return a[i] - b[i];
    }
    return a.length - b.length;
  }
}

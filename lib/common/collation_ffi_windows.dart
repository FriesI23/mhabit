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

import 'package:flutter/foundation.dart';

import '../logging/helper.dart';
import 'collation_ffi.dart';

/// Windows ICU collation resolver (singleton).
///
/// Resolves the OS-bundled ICU DLL eagerly at app startup ([init]); sort
/// callers branch on [isAvailable] rather than catching load exceptions.
/// Windows exports unversioned symbols — no version probing needed.  Use
/// [engine] to build a locale-specific collator.
class IcuCollationWindows {
  static IcuCollationWindows? _instance;

  factory IcuCollationWindows() => _instance ??= IcuCollationWindows._();

  IcuCollationWindows._();

  /// Windows system ICU candidates, most recent first.
  static const _dllCandidates = ['icu.dll', 'icuin.dll'];

  DynamicLibrary? _lib;
  bool _available = false;

  /// Whether a native collation engine was resolved successfully.
  /// Safe to call on any platform — returns `false` when [init] was
  /// never called or failed, without creating the singleton.
  static bool get available => _instance?._available ?? false;

  /// Whether the OS-bundled ICU DLL was resolved successfully.
  bool get isAvailable => _available;

  /// Resolves the OS-bundled ICU DLL once at app startup; failure is
  /// logged and leaves [isAvailable] `false` for conditional fallback.
  Future<void> init() async {
    if (_available) return;
    for (final candidate in _dllCandidates) {
      try {
        final lib = DynamicLibrary.open(candidate);
        if (!_hasSymbols(lib)) continue;
        _lib = lib;
        _available = true;
        return;
      } catch (_) {
        continue;
      }
    }
    appLog.load.warn(
      'Windows system ICU unavailable — natural sort falls back to '
      'platform',
      error: UnsupportedError(
        'System ICU not found (tried $_dllCandidates); '
        'ICU ships with Windows 10 1703+',
      ),
    );
  }

  /// Builds a collator engine for [localeName] from the resolved library.
  IcuCollationEngine engine(String? localeName) =>
      _IcuCollationWindowsEngine(_requireLib(), '', localeName);

  /// Verifies the unversioned ICU entry symbols are exported by [lib].
  bool _hasSymbols(DynamicLibrary lib) {
    for (final symbol in const ['ucol_open', 'ucol_close', 'ucol_strcoll']) {
      try {
        lib.lookup<NativeFunction<Void Function()>>(symbol);
      } on ArgumentError {
        return false;
      }
    }
    return true;
  }

  DynamicLibrary _requireLib() {
    final lib = _lib;
    if (lib == null) {
      throw StateError(
        'IcuCollationWindows not resolved; call IcuCollationWindows().init() '
        'first',
      );
    }
    return lib;
  }

  /// Resets the resolved state (tests only).
  @visibleForTesting
  void resetForTest() {
    _lib = null;
    _available = false;
  }
}

/// Windows ICU collator backed by the resolved [IcuCollationWindows] library.
final class _IcuCollationWindowsEngine extends IcuCollationBase {
  _IcuCollationWindowsEngine(super.lib, super.suffix, super.localeName);
}

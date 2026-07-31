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

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logging/helper.dart';
import 'collation_ffi.dart';

/// Pure `libicui18n` resolution rules for Linux.
///
/// Encapsulates which sonames/directories to probe, how to parse and order
/// candidates by ICU version, and how to validate a library (symbol probe).
/// Kept separate from the cache/load orchestration in [IcuCollationLinux]
/// so the rules can be unit-tested in isolation.
final class IcuCollationLinuxRules {
  /// App-recommended stable ICU version, tried before the highest one
  /// discovered (widely deployed: Debian 12, Ubuntu 23.04+).
  static const recommendedVersion = 72;

  /// The Linux multiarch directory component for the current ABI.
  String get multiarchTriplet => switch (Abi.current()) {
    Abi.linuxArm64 => 'aarch64-linux-gnu',
    Abi.linuxX64 => 'x86_64-linux-gnu',
    Abi.linuxArm => 'arm-linux-gnueabihf',
    Abi.linuxRiscv64 => 'riscv64-linux-gnu',
    _ => 'x86_64-linux-gnu',
  };

  /// Directories scanned for `libicui18n.so*` (host + Flatpak layouts).
  List<String> get searchDirs => [
    '/usr/lib/$multiarchTriplet',
    '/lib/$multiarchTriplet',
    '/app/lib', // Flatpak runtime layout
  ];

  /// Candidate paths in resolution order: unversioned soname, then the
  /// recommended stable version, then the highest version in [discovered].
  List<String> candidates(List<String> discovered) => [
    'libicui18n.so',
    'libicui18n.so.$recommendedVersion',
    if (discovered.isNotEmpty) discovered.first,
  ];

  /// Lists `libicui18n.so*` files under [dirs] ordered by descending ICU
  /// major version (unversioned entries last).
  Future<List<String>> discoverCandidates(List<String> dirs) async {
    final found = <String>[];
    for (final dir in dirs) {
      final directory = Directory(dir);
      if (!directory.existsSync()) continue;
      try {
        await for (final entity in directory.list(followLinks: true)) {
          if (entity is! File) continue;
          final path = entity.path;
          if (!path.split('/').last.startsWith('libicui18n.so')) continue;
          found.add(path);
        }
      } catch (_) {
        // Skip unreadable directories.
      }
    }
    found.sort(_byVersionDesc);
    return found;
  }

  int _byVersionDesc(String a, String b) {
    final va = extractVersionMajor(a);
    final vb = extractVersionMajor(b);
    if (va == null && vb == null) return a.compareTo(b);
    if (va == null) return 1;
    if (vb == null) return -1;
    if (va != vb) return vb.compareTo(va);
    return b.compareTo(a);
  }

  /// ICU major version from a soname path (`libicui18n.so.72.1` → 72),
  /// or `null` when unversioned (`libicui18n.so`).
  int? extractVersionMajor(String path) {
    final name = path.split('/').last;
    final match = RegExp(r'^libicui18n\.so\.(\d+)').firstMatch(name);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  /// ICU symbol-version suffix from a soname path:
  /// `libicui18n.so.72` → `_72`, `libicui18n.so` → `""`.
  String extractVersionSuffix(String path) {
    final major = extractVersionMajor(path);
    return major != null ? '_$major' : '';
  }

  /// Probes [lib] for a `ucol_open_XX` symbol — [preferred] version first,
  /// then the bare `ucol_open` (Flatpak-style unversioned exports) —
  /// returning the suffix or `null`.
  String? probeVersionSuffix(DynamicLibrary lib, {String preferred = ''}) {
    if (preferred.isNotEmpty) {
      try {
        lib.lookup<NativeFunction<Void Function()>>('ucol_open$preferred');
        return preferred;
      } on ArgumentError {
        // fall through to unversioned
      }
    }
    try {
      lib.lookup<NativeFunction<Void Function()>>('ucol_open');
      return '';
    } on ArgumentError {
      return null;
    }
  }

  /// Resolves [path] as a usable ICU library, returning the library and
  /// its symbol suffix, or `null` when [path] cannot be opened or probed.
  (DynamicLibrary, String)? tryLoadPath(String path) {
    DynamicLibrary lib;
    try {
      lib = DynamicLibrary.open(path);
    } catch (_) {
      return null;
    }
    final preferred = extractVersionSuffix(path);
    final suffix = probeVersionSuffix(lib, preferred: preferred);
    if (suffix == null) return null;
    return (lib, suffix);
  }
}

/// Linux ICU collation resolver (singleton).
///
/// Resolves the system `libicui18n` eagerly at app startup ([init]) via
/// directory search + SharedPreferences cache; sort callers branch on
/// [isAvailable] rather than catching load exceptions.  Use [engine] to
/// build a locale-specific collator.
class IcuCollationLinux {
  static IcuCollationLinux? _instance;

  factory IcuCollationLinux() => _instance ??= IcuCollationLinux._();

  IcuCollationLinux._();

  /// SharedPreferences key for the resolved `libicui18n` path (hint only;
  /// validated on read).
  static const cacheKey = 'collationFfiIcuLib';

  final IcuCollationLinuxRules _rules = IcuCollationLinuxRules();

  DynamicLibrary? _lib;
  String _icuVersionSuffix = '';
  String? _loadedPath;
  bool _available = false;

  /// Whether a native collation engine was resolved successfully.
  /// Safe to call on any platform — returns `false` when [init] was
  /// never called or failed, without creating the singleton.
  static bool get available => _instance?._available ?? false;

  /// Whether a native collation engine was resolved successfully.
  bool get isAvailable => _available;

  /// Resolves the native engine once at app startup: cache hit → directory
  /// search → static soname fallback.  On success caches the resolved path
  /// (best-effort); any failure is logged and leaves [isAvailable] `false`.
  Future<void> init({SharedPreferences? prefs}) async {
    if (_available) return;
    try {
      final resolved = prefs ?? await SharedPreferences.getInstance();

      final cachedPath = resolved.getString(cacheKey);
      if (cachedPath != null && _tryLoadPath(cachedPath)) {
        appLog.load.info(
          'Linux ICU collation loaded from cache',
          ex: [cachedPath],
        );
        return;
      }

      if (await _searchAndLoad()) {
        await _cacheWrite(resolved);
        return;
      }

      appLog.load.warn(
        'Linux ICU collation unavailable — natural sort falls back to '
        'plain sort',
      );
    } catch (e, s) {
      appLog.load.warn(
        'Linux ICU collation init failed — natural sort falls back to '
        'plain sort',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Builds a collator engine for [localeName] from the resolved library.
  IcuCollationEngine engine(String? localeName) =>
      _IcuCollationLinuxEngine(_requireLib(), _icuVersionSuffix, localeName);

  /// Best-effort cache write; failure must never affect availability.
  Future<void> _cacheWrite(SharedPreferences prefs) async {
    final loadedPath = _loadedPath;
    if (loadedPath == null) return;
    try {
      await prefs.setString(cacheKey, loadedPath);
    } catch (e) {
      appLog.load.debug('Linux ICU collation cache write failed', error: e);
    }
  }

  /// Applies a resolved library to the singleton state.
  void _applyResolved(DynamicLibrary lib, String suffix, String path) {
    _lib = lib;
    _icuVersionSuffix = suffix;
    _loadedPath = path;
    _available = true;
  }

  /// Attempts to resolve [path], applying the state on success.
  bool _tryLoadPath(String path) {
    final result = _rules.tryLoadPath(path);
    if (result == null) return false;
    _applyResolved(result.$1, result.$2, path);
    return true;
  }

  Future<bool> _searchAndLoad() async {
    final discovered = await _rules.discoverCandidates(_rules.searchDirs);
    for (final candidate in _rules.candidates(discovered)) {
      if (_tryLoadPath(candidate)) return true;
    }
    return false;
  }

  DynamicLibrary _requireLib() {
    final lib = _lib;
    if (lib == null) {
      throw StateError(
        'IcuCollationLinux not resolved; call IcuCollationLinux().init() first',
      );
    }
    return lib;
  }

  /// Resets the resolved state (tests only).
  @visibleForTesting
  void resetForTest() {
    _lib = null;
    _icuVersionSuffix = '';
    _loadedPath = null;
    _available = false;
  }
}

/// Linux ICU collator backed by the resolved [IcuCollationLinux] library.
final class _IcuCollationLinuxEngine extends IcuCollationBase {
  _IcuCollationLinuxEngine(super.lib, super.suffix, super.localeName);
}

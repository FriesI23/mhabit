// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import '../db/profile.dart';

abstract class Cache<K> {
  T? getCache<T>(K key);
  Future<void> updateCache<T>(K key, T? value,
      {void Function(bool, T?)? onUpdated});
  Future<void> removeCache<T>(K key, {void Function(bool, T?)? onRemoved});
  Future<void> clear({void Function(bool)? onClear});
  Future<void> reload({void Function(bool)? onReload});
  bool isDirty();
}

enum InputFillCacheKey {
  habitEditTargetDays,
}

class InputFillCache implements Cache<String> {
  final Map<String, dynamic> _cache;
  final WeakReference<Profile> _profile;
  bool _dirty = false;

  InputFillCache({required Profile profile})
      : _profile = WeakReference(profile),
        _cache = {} {
    reload();
  }

  @override
  Future<void> clear({void Function(bool)? onClear}) async {
    if (_profile.target == null) onClear?.call(false);
    final oldCache = {..._cache};
    _cache.clear();
    _markDirty();
    final result = await writeCache();
    if (!result) _cache.addAll(oldCache);
    onClear?.call(result);
  }

  @override
  Future<void> reload({void Function(bool)? onReload}) async {
    if (_profile.target == null) onReload?.call(false);
    final raw = _profile.target!.getInputFillCache();
    _cache.clear();
    _cache.addAll(raw);
    onReload?.call(true);
  }

  @override
  T? getCache<T>(key) {
    return _cache[key];
  }

  @override
  Future<void> removeCache<T>(key,
      {void Function(bool result, T? removeValue)? onRemoved}) async {
    if (_profile.target == null) onRemoved?.call(false, null);
    final oldValue = _cache.remove(key);
    _markDirty();
    final result = await writeCache();
    if (!result) _cache[key] = oldValue;
    onRemoved?.call(result, oldValue);
  }

  @override
  Future<void> updateCache<T>(key, T? value,
      {void Function(bool result, T? oldValue)? onUpdated}) async {
    if (_profile.target == null) onUpdated?.call(false, null);
    final oldValue = _cache[key];
    _cache[key] = value;
    _markDirty();
    final result = await writeCache();
    if (!result) _cache[key] = oldValue;
    onUpdated?.call(result, oldValue);
  }

  @override
  bool isDirty() {
    return _dirty;
  }

  void _markDirty() => _dirty = true;

  void _markClean() => _dirty = false;

  Future<bool> writeCache() async {
    if (_profile.target == null) return false;
    final result = await _profile.target!.setInputFillCache(_cache);
    if (result) _markClean();
    return result;
  }
}

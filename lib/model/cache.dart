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

import '../common/types.dart';
import '../logging/helper.dart';
import '../storage/profile/profile_helper.dart';

abstract interface class Cache<K> {
  T? getCache<T>(K key);
  Future<void> updateCache<T>(K key, T? value,
      {void Function(bool, T?)? onUpdated});
  Future<void> removeCache<T>(K key, {void Function(bool, T?)? onRemoved});
  Future<void> clear({void Function(bool)? onClear});
  Future<void> reload({void Function(bool)? onReload});
  bool isDirty();
}

class AppCacheDelegate<T extends ProfileHelperHandler<JsonMap>>
    implements Cache<String> {
  final JsonMap _cache = {};
  final WeakReference<T> _handler;
  bool _dirty = false;

  AppCacheDelegate({
    required T handler,
  }) : _handler = WeakReference(handler);

  @override
  Future<void> clear({void Function(bool)? onClear}) async {
    appLog.cache.debug("$runtimeType.clear", ex: [this]);
    if (_handler.target == null) onClear?.call(false);
    final oldCache = {..._cache};
    _cache.clear();
    _markDirty();
    final result = await writeCache();
    if (!result) _cache.addAll(oldCache);
    onClear?.call(result);
  }

  @override
  Future<void> reload({void Function(bool)? onReload}) async {
    appLog.cache.debug("$runtimeType.reload", ex: [this]);
    if (_handler.target == null) onReload?.call(false);
    final raw = _handler.target!.get();
    _cache.clear();
    if (raw != null) _cache.addAll(raw);
    onReload?.call(true);
  }

  @override
  V? getCache<V>(String key) {
    return _cache[key];
  }

  @override
  Future<void> removeCache<V>(String key,
      {void Function(bool result, V? removeValue)? onRemoved}) async {
    appLog.cache.debug("$runtimeType.removeCache", ex: [key, this]);
    if (_handler.target == null) onRemoved?.call(false, null);
    final V? oldValue = _cache.remove(key);
    _markDirty();
    final result = await writeCache();
    if (!result) _cache[key] = oldValue;
    onRemoved?.call(result, oldValue);
  }

  @override
  Future<void> updateCache<V>(String key, V? value,
      {void Function(bool result, V? oldValue)? onUpdated}) async {
    appLog.cache.debug("$runtimeType.updateCache", ex: [key, value, this]);
    if (_handler.target == null) onUpdated?.call(false, null);
    final V? oldValue = _cache[key];
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
    appLog.cache.debug("$runtimeType.writeCache", ex: [this]);
    if (_handler.target == null) return false;
    final result = await _handler.target!.set(_cache);
    if (result) _markClean();
    return result;
  }

  @override
  String toString() =>
      "$runtimeType(handler=$_handler,dirty=$_dirty,cache=$_cache)";
}

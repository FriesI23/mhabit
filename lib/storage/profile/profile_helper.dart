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

import 'package:shared_preferences/shared_preferences.dart';

import '../../common/types.dart';

abstract interface class ProfileHelperHandler<T> {
  String get key;
  Future<bool> set(T value);
  T? get();
  Future<bool> remove();
}

abstract class ProfileHelperConvertHandler<S, T>
    implements ProfileHelperHandler<S> {
  final Codec<S, T> _codec;

  const ProfileHelperConvertHandler({required Codec<S, T> codec})
    : _codec = codec;

  @override
  Future<bool> set(S value) => setMethod.call(key, _codec.encode(value));

  @override
  S? get() {
    final rawValue = getMethod.call(key);
    return rawValue != null ? _codec.decode(rawValue) : null;
  }

  Future<bool> Function(String key, T value) get setMethod;
  T? Function(String key) get getMethod;
}

abstract class ProfileHelperCovertToIntHandler<T>
    extends ProfileHelperConvertHandler<T, int> {
  final SharedPreferences _pref;

  const ProfileHelperCovertToIntHandler(
    SharedPreferences pref, {
    required super.codec,
  }) : _pref = pref;

  @override
  int? Function(String key) get getMethod => _pref.getInt;

  @override
  Future<bool> Function(String key, int value) get setMethod => _pref.setInt;

  @override
  Future<bool> remove() => _pref.remove(key);
}

abstract class ProfileHelperCovertToBoolHandler<T>
    extends ProfileHelperConvertHandler<T, bool> {
  final SharedPreferences _pref;

  const ProfileHelperCovertToBoolHandler(
    SharedPreferences pref, {
    required super.codec,
  }) : _pref = pref;

  @override
  bool? Function(String key) get getMethod => _pref.getBool;

  @override
  Future<bool> Function(String key, bool value) get setMethod => _pref.setBool;

  @override
  Future<bool> remove() => _pref.remove(key);
}

abstract class ProfileHelperCovertToJsonHandler<T>
    extends ProfileHelperConvertHandler<T, JsonMap> {
  final SharedPreferences _pref;

  const ProfileHelperCovertToJsonHandler(
    SharedPreferences pref, {
    required super.codec,
  }) : _pref = pref;

  JsonMap? _getMethod(String key) {
    final source = _pref.getString(key);
    return source != null ? jsonDecode(source) : null;
  }

  @override
  JsonMap? Function(String key) get getMethod => _getMethod;

  Future<bool> _setMethod(String key, JsonMap value) =>
      _pref.setString(key, jsonEncode(value));

  @override
  Future<bool> Function(String key, JsonMap value) get setMethod => _setMethod;

  @override
  Future<bool> remove() => _pref.remove(key);
}

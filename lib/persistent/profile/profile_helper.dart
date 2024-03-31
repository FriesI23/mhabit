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

abstract interface class ProfileHelperHandler<T> {
  String get key;
  Future<bool> set(T value);
  T? get();
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

  const ProfileHelperCovertToIntHandler(SharedPreferences pref,
      {required super.codec})
      : _pref = pref;

  @override
  int? Function(String key) get getMethod => _pref.getInt;

  @override
  Future<bool> Function(String key, int value) get setMethod => _pref.setInt;
}

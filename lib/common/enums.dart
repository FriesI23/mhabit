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

abstract class EnumWithDBCodeABC<T> {
  int get dbCode;
}

enum HabitsRecordScrollBehavior implements EnumWithDBCodeABC {
  unknown(code: 0),
  scrollable(code: 1),
  page(code: 2);

  final int _code;

  const HabitsRecordScrollBehavior({required int code}) : _code = code;

  @override
  int get dbCode => _code;

  static HabitsRecordScrollBehavior? getFromDBCode(int dbCode,
      {HabitsRecordScrollBehavior? withDefault =
          HabitsRecordScrollBehavior.unknown}) {
    for (var value in HabitsRecordScrollBehavior.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }
}

enum DonateWay {
  paypal,
  buyMeACoffee,
  alipay,
  wechatPay,
  cryptoCurrencyAll;

  static final _name2EnumMap = Map<String, DonateWay>.fromEntries(
      DonateWay.values.map((e) => MapEntry(e.name, e)));

  static DonateWay? getDonateWayByName(String name, {String? prefix = "@"}) {
    if (prefix != null) name = name.replaceFirst(prefix, '');
    return _name2EnumMap[name];
  }
}

enum UserAction implements EnumWithDBCodeABC {
  nothing(code: 0),
  tap(code: 1),
  doubleTap(code: 2),
  longTap(code: 3);

  final int _code;

  const UserAction({required int code}) : _code = code;

  @override
  int get dbCode => _code;

  static UserAction? getFromDBCode(int dbCode,
      {UserAction? withDefault = UserAction.nothing}) {
    for (var value in UserAction.values) {
      if (value.dbCode == dbCode) return value;
    }
    return withDefault;
  }
}

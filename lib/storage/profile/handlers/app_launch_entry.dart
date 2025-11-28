// Copyright 2025 Fries_I23
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

import '../../../models/app_entry.dart';
import '../profile_helper.dart';

final class AppLaunchEntryProfileHandler
    extends ProfileHelperCovertToIntHandler<AppEntrys> {
  @override
  String get key => "appLaunchEntry";

  const AppLaunchEntryProfileHandler(super.pref,
      {super.codec = const AppLaunchEntryProfileCodec()});
}

final class AppLaunchEntryProfileCodec extends Codec<AppEntrys, int> {
  const AppLaunchEntryProfileCodec();

  @override
  Converter<int, AppEntrys> get decoder => const _Decoder();

  @override
  Converter<AppEntrys, int> get encoder => const _Encoder();
}

final class _Decoder extends Converter<int, AppEntrys> {
  const _Decoder();

  @override
  AppEntrys convert(int input) =>
      AppEntrys.getFromDBCode(input, withDefault: AppEntrys.undefined)!;
}

final class _Encoder extends Converter<AppEntrys, int> {
  const _Encoder();

  @override
  int convert(AppEntrys input) => input.dbCode;
}

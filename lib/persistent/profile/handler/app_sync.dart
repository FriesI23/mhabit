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

import '../../../common/types.dart';
import '../../../model/app_sync_server.dart';
import '../converter.dart';
import '../profile_helper.dart';

class AppSyncSwitchHandler extends ProfileHelperCovertToBoolHandler<bool> {
  const AppSyncSwitchHandler(super.pref) : super(codec: const SameTypeCodec());

  @override
  String get key => 'enableSync';
}

class AppSyncServerConfigHandler
    extends ProfileHelperCovertToJsonHandler<AppSyncServer?> {
  const AppSyncServerConfigHandler(super.pref,
      {super.codec = const AppSyncServerConfigCodec()});

  @override
  String get key => 'syncServer';
}

final class AppSyncServerConfigCodec extends Codec<AppSyncServer?, JsonMap> {
  const AppSyncServerConfigCodec();

  @override
  Converter<JsonMap, AppSyncServer?> get decoder =>
      const _AppSyncServerConfigDecoder();

  @override
  Converter<AppSyncServer, JsonMap> get encoder =>
      const _AppSyncServerConfigEncoder();
}

final class _AppSyncServerConfigDecoder
    extends Converter<JsonMap, AppSyncServer?> {
  const _AppSyncServerConfigDecoder();

  @override
  AppSyncServer? convert(JsonMap input) => AppSyncServer.fromJson(input);
}

final class _AppSyncServerConfigEncoder
    extends Converter<AppSyncServer, JsonMap> {
  const _AppSyncServerConfigEncoder();

  @override
  JsonMap convert(AppSyncServer input) => input.toJson();
}

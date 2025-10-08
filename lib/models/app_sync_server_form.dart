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

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'app_sync_server.dart';

part 'app_sync_server_form.g.dart';

sealed class AppSyncServerForm {
  final String uuid;
  final AppSyncServerType type;

  const AppSyncServerForm({required this.uuid, required this.type});
}

@CopyWith(skipFields: true)
final class FakeSyncServerForm extends AppSyncServerForm {
  final Map<String, String> data = const {};

  const FakeSyncServerForm({required super.uuid})
      : super(type: AppSyncServerType.fake);

  String toDebugString() {
    return """AppSyncServerForm(
  uuid=$uuid,type=$type,
  data=$data,
  )""";
  }

  @override
  String toString() => 'AppSyncServerForm[$uuid](data=$data)';
}

@CopyWith(skipFields: true)
final class WebDavSyncServerForm extends AppSyncServerForm {
  final String? path;
  final String? username;
  final String? password;
  final bool? ignoreSSL;
  final Duration? timeout;
  final Duration? connectTimeout;
  final int? connectRetryCount;
  final Set<AppSyncServerMobileNetwork>? syncMobileNetworks;
  final bool? syncInLowData;

  const WebDavSyncServerForm({
    required super.uuid,
    this.path,
    this.username,
    this.password,
    this.ignoreSSL,
    this.timeout,
    this.connectTimeout,
    this.connectRetryCount,
    this.syncMobileNetworks,
    this.syncInLowData,
  }) : super(type: AppSyncServerType.webdav);

  String toDebugString() {
    final password = kDebugMode
        ? this.password
        : List.generate(this.password?.length ?? 0, (_) => "*").join();
    return """AppSyncServerForm(
  uuid=$uuid,type=$type,
  path=$path,username=$username,password=$password,
  ignoreSSL=$ignoreSSL,timeout=$timeout,
  connectTimeout=$connectTimeout,connectRetryCount=$connectRetryCount,
  syncMobileNetworks=$syncMobileNetworks,
  syncInLowData=$syncInLowData,
  )""";
  }

  @override
  String toString() => 'AppSyncServerForm[$uuid](path=$path,'
      'username=$username,'
      'password=${List.generate(password?.length ?? 0, (_) => "*").join()}'
      ')';
}

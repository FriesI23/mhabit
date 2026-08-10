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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_router.dart';

const _kRouteQuerySelectedGroupId = 'selectedGroupId';

/// Unpacked parameters for the group manage route builder.
typedef GroupManageParams = ({String? selectedGroupId});

/// Unpacks [GoRouterState] into [GroupManageParams] for the
/// [AppRoute.groupManage] route builder.
///
/// Reads the pre-selected group from the [_kRouteQuerySelectedGroupId]
/// query parameter.
extension GroupManageRoute on GoRouterState {
  GroupManageParams unpackGroupManage() {
    final selectedGroupId = uri.queryParameters[_kRouteQuerySelectedGroupId];
    return (selectedGroupId: selectedGroupId);
  }
}

/// Pushes the [AppRoute.groupManage] route onto the navigator.
extension GroupManagePush on BuildContext {
  Future<void> pushGroupManage({String? selectedGroupId}) => pushNamed(
    AppRoute.groupManage.name,
    queryParameters: selectedGroupId != null
        ? {_kRouteQuerySelectedGroupId: selectedGroupId}
        : const <String, dynamic>{},
  );
}

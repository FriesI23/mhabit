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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/app_sync_server.dart';
import '../../provider/app_sync_server_form.dart';

class AppSyncServerPathTile extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;

  const AppSyncServerPathTile({
    super.key,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final type = context
        .select<AppSyncServerFormViewModel, AppSyncServerType>((vm) => vm.type);
    final controller =
        context.select<AppSyncServerFormViewModel, TextEditingController>(
            (vm) => vm.pathInputController);
    return Offstage(
      offstage: !type.includePathField,
      child: ListTile(
        contentPadding: contentPadding,
        title: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Path',
            hintText: 'Enter a valid WebDAV path here.',
          ),
          keyboardType: TextInputType.url,
        ),
      ),
    );
  }
}

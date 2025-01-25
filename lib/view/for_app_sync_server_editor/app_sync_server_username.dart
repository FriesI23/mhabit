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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../model/app_sync_server.dart';
import '../../provider/app_sync_server_form.dart';

class AppSyncServerUsernameTile extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;

  const AppSyncServerUsernameTile({
    super.key,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final type = context
        .select<AppSyncServerFormViewModel, AppSyncServerType>((vm) => vm.type);
    final controller =
        context.select<AppSyncServerFormViewModel, TextEditingController>(
            (vm) => vm.usernameInputController);
    return Visibility(
      visible: type.includePathField,
      child: ListTile(
        contentPadding: contentPadding,
        title: TextField(
          controller: controller,
          decoration: const InputDecoration(
            icon: Icon(MdiIcons.accountCircleOutline),
            labelText: 'Username',
            hintText: 'Enter username here, leave empty if not required.',
          ),
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }
}

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

import '../../../l10n/localizations.dart';
import '../../../providers/app_sync_server_form.dart';

class AppSyncServerUsernameTile extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const AppSyncServerUsernameTile(
      {super.key, this.contentPadding, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      contentPadding: contentPadding,
      title: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: const Icon(MdiIcons.accountCircleOutline),
          labelText:
              l10n?.appSync_serverEditor_usernameTile_titleText ?? 'Username',
          hintText: l10n?.appSync_serverEditor_usernameTile_hintText,
        ),
        keyboardType: TextInputType.text,
        onChanged: onChanged,
      ),
    );
  }
}

class AppWebDavSyncServerUsernameTile extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String?>? onChanged;

  const AppWebDavSyncServerUsernameTile(
      {super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AppSyncServerUsernameTile(
      controller: controller,
      onChanged: (value) {
        final vm = context.read<AppSyncServerFormViewModel>();
        if (!vm.mounted || vm.webdav == null) return;
        vm.webdav?.username = value.isEmpty ? null : value;
        onChanged?.call(vm.webdav?.username);
      },
    );
  }
}

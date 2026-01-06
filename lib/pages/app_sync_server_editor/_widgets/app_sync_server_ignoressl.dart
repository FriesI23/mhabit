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

class AppSyncServerIgnoreSSLTile extends StatelessWidget {
  final bool? value;
  final EdgeInsetsGeometry? contentPadding;
  final ValueChanged<bool?>? onChanged;

  const AppSyncServerIgnoreSSLTile({
    super.key,
    this.value,
    this.contentPadding,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Visibility(
      child: CheckboxListTile.adaptive(
        secondary: const Icon(MdiIcons.lockOffOutline),
        contentPadding: contentPadding,
        title: Text(
          l10n?.appSync_serverEditor_ignoreSSLTile_titleText ??
              "Ignore SSL Certificate",
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class AppWebDavSyncServerIgnoreSSLTile extends StatelessWidget {
  const AppWebDavSyncServerIgnoreSSLTile({super.key});

  @override
  Widget build(BuildContext context) {
    context.select<AppSyncServerFormViewModel, bool>((vm) => vm.webdav != null);
    return Selector<AppSyncServerFormViewModel, bool?>(
      selector: (context, vm) => vm.webdav?.ignoreSSL,
      builder: (context, ignoreSSL, child) => AppSyncServerIgnoreSSLTile(
        value: ignoreSSL,
        onChanged: (value) {
          final vm = context.read<AppSyncServerFormViewModel>();
          if (!vm.mounted || vm.webdav == null) return;
          vm.webdav?.ignoreSSL = value;
        },
      ),
    );
  }
}
